#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <libpq-fe.h>
#include <search.h>

static char *escapeLiteral(PGconn *conn, const char *str, size_t len) {
  // provides compatibility for PostgreSQL versions prior 9.0
  // in future: return PQescapeLiteral(conn, str, len);
  char *res;
  size_t res_len;
  res = malloc(2*len+3);
  if (!res) return NULL;
  res[0] = '\'';
  res_len = PQescapeStringConn(conn, res+1, str, len, NULL);
  res[res_len+1] = '\'';
  res[res_len+2] = 0;
  return res;
}

static void freemem(void *ptr) {
  // to be used for "escapeLiteral" function
  // provides compatibility for PostgreSQL versions prior 9.0
  // in future: PQfreemem(ptr);
  free(ptr);
}

#define COL_MEMBER_ID     0
#define COL_WEIGHT        1
#define COL_PREFERENCE    2
#define COL_SUGGESTION_ID 3

struct candidate {
  char *key;
  double score_per_step;
  int reaches_score;
  double score;
  int seat;
};

static int compare_candidate(struct candidate *c1, struct candidate *c2) {
  return strcmp(c1->key, c2->key);
}

static int candidate_count;
static struct candidate *candidates;

static void register_candidate(char **candidate_key, VISIT visit, int level) {
  if (visit == postorder || visit == leaf) {
    struct candidate *candidate;
    candidate = candidates + (candidate_count++);
    candidate->key   = *candidate_key;
    candidate->seat  = 0;
  }
}

static struct candidate *candidate_by_key(char *candidate_key) {
  struct candidate *candidate;
  struct candidate compare;
  compare.key = candidate_key;
  candidate = bsearch(&compare, candidates, candidate_count, sizeof(struct candidate), (void *)compare_candidate);
  if (!candidate) {
    fprintf(stderr, "Candidate not found (should not happen).\n");
    abort();
  }
  return candidate;
}

struct ballot_section {
  int count;
  struct candidate **candidates;
};

struct ballot {
  int weight;
  struct ballot_section sections[4];
};

static struct candidate *loser(int round_number, struct ballot *ballots, int ballot_count) {
  int i, j, k;
  int remaining;
  for (i=0; i<candidate_count; i++) {
    candidates[i].score = 0.0;
  }
  remaining = candidate_count - round_number;
  while (1) {
    double scale;
    if (remaining <= 1) break;
    for (i=0; i<candidate_count; i++) {
      candidates[i].score_per_step = 0.0;
      candidates[i].reaches_score = 0;
    }
    for (i=0; i<ballot_count; i++) {
      for (j=0; j<4; j++) {
        int matches = 0;
        for (k=0; k<ballots[i].sections[j].count; k++) {
          struct candidate *candidate;
          candidate = ballots[i].sections[j].candidates[k];
          if (candidate->score < 1.0 && !candidate->seat) matches++;
        }
        if (matches) {
          double score_inc;
          score_inc = 1.0 / (double)matches;
          for (k=0; k<ballots[i].sections[j].count; k++) {
            struct candidate *candidate;
            candidate = ballots[i].sections[j].candidates[k];
            if (candidate->score < 1.0 && !candidate->seat) {
              candidate->score_per_step += score_inc;
            }
          }
          break;
        }
      }
    }
    scale = (double)candidate_count;
    for (i=0; i<candidate_count; i++) {
      double max_scale;
      if (candidates[i].score_per_step > 0.0) {
        max_scale = (1.0-candidates[i].score) / candidates[i].score_per_step;
        if (max_scale <= scale) {
          scale = max_scale;
          candidates[i].reaches_score = 1;
        }
      }
    }
    for (i=0; i<candidate_count; i++) {
      if (candidates[i].score_per_step > 0.0) {
        if (candidates[i].reaches_score) {
          candidates[i].score = 1.0;
          remaining--;
        } else {
          candidates[i].score += scale * candidates[i].score_per_step;
          if (candidates[i].score >= 1.0) remaining--;
        }
        if (remaining <= 1) break;
      }
    }
  }
  for (i=candidate_count-1; i>=0; i--) {
    if (candidates[i].score < 1.0 && !candidates[i].seat) return candidates+i;
  }
  fprintf(stderr, "No remaining candidate (should not happen).");
  abort();
}

static int write_ranks(PGconn *db, char *escaped_initiative_id, int final) {
  PGresult *res;
  char *cmd;
  int i;
  if (final) {
    if (asprintf(&cmd, "BEGIN; UPDATE \"initiative\" SET \"final_suggestion_order_calculated\" = TRUE WHERE \"id\" = %s; UPDATE \"suggestion\" SET \"proportional_order\" = NULL WHERE \"initiative_id\" = %s", escaped_initiative_id, escaped_initiative_id) < 0) {
      fprintf(stderr, "Could not prepare query string in memory.\n");
      abort();
    }
  } else {
    if (asprintf(&cmd, "BEGIN; UPDATE \"suggestion\" SET \"proportional_order\" = NULL WHERE \"initiative_id\" = %s", escaped_initiative_id) < 0) {
      fprintf(stderr, "Could not prepare query string in memory.\n");
      abort();
    }
  }
  res = PQexec(db, cmd);
  free(cmd);
  if (!res) {
    fprintf(stderr, "Error in pqlib while sending SQL command to initiate suggestion update.\n");
    return 1;
  } else if (
    PQresultStatus(res) != PGRES_COMMAND_OK &&
    PQresultStatus(res) != PGRES_TUPLES_OK
  ) {
    fprintf(stderr, "Error while executing SQL command to initiate suggestion update:\n%s", PQresultErrorMessage(res));
    PQclear(res);
    return 1;
  } else {
    PQclear(res);
  }
  for (i=0; i<candidate_count; i++) {
    char *escaped_suggestion_id;
    escaped_suggestion_id = escapeLiteral(db, candidates[i].key, strlen(candidates[i].key));
    if (!escaped_suggestion_id) {
      fprintf(stderr, "Could not escape literal in memory.\n");
      abort();
    }
    if (asprintf(&cmd, "UPDATE \"suggestion\" SET \"proportional_order\" = %i WHERE \"id\" = %s", candidates[i].seat, escaped_suggestion_id) < 0) {
      fprintf(stderr, "Could not prepare query string in memory.\n");
      abort();
    }
    freemem(escaped_suggestion_id);
    res = PQexec(db, cmd);
    free(cmd);
    if (!res) {
      fprintf(stderr, "Error in pqlib while sending SQL command to update suggestion order.\n");
    } else if (
      PQresultStatus(res) != PGRES_COMMAND_OK &&
      PQresultStatus(res) != PGRES_TUPLES_OK
    ) {
      fprintf(stderr, "Error while executing SQL command to update suggestion order:\n%s", PQresultErrorMessage(res));
      PQclear(res);
    } else {
      PQclear(res);
      continue;
    }
    res = PQexec(db, "ROLLBACK");
    if (res) PQclear(res);
    return 1;
  }
  res = PQexec(db, "COMMIT");
  if (!res) {
    fprintf(stderr, "Error in pqlib while sending SQL command to commit transaction.\n");
    return 1;
  } else if (
    PQresultStatus(res) != PGRES_COMMAND_OK &&
    PQresultStatus(res) != PGRES_TUPLES_OK
  ) {
    fprintf(stderr, "Error while executing SQL command to commit transaction:\n%s", PQresultErrorMessage(res));
    PQclear(res);
    return 1;
  } else {
    PQclear(res);
    return 0;
  }
}

static int process_initiative(PGconn *db, PGresult *res, char *escaped_initiative_id, int final) {
  int err;
  int ballot_count = 0;
  struct ballot *ballots;
  int i;
  {
    void *candidate_tree = NULL;
    int tuple_count;
    char *old_member_id = NULL;
    struct ballot *ballot;
    int candidates_in_sections[4] = {0, };
    tuple_count = PQntuples(res);
    if (!tuple_count) {
      if (final) {
        printf("No suggestions found, but marking initiative as finally calculated.\n");
        err = write_ranks(db, escaped_initiative_id, final);
        printf("Done.\n");
        return err;
      } else {
        printf("Nothing to do.\n");
        return 0;
      }
    }
    candidate_count = 0;
    for (i=0; i<=tuple_count; i++) {
      char *member_id, *suggestion_id;
      if (i<tuple_count) {
        member_id = PQgetvalue(res, i, COL_MEMBER_ID);
        suggestion_id = PQgetvalue(res, i, COL_SUGGESTION_ID);
        if (!candidate_tree || !tfind(suggestion_id, &candidate_tree, (void *)strcmp)) {
          candidate_count++;
          if (!tsearch(suggestion_id, &candidate_tree, (void *)strcmp)) {
            fprintf(stderr, "Insufficient memory while inserting into candidate tree.\n");
            abort();
          }
        }
      }
      if (i==tuple_count || (old_member_id && strcmp(old_member_id, member_id))) {
        ballot_count++;
      }
      old_member_id = member_id;
    }
    printf("Candidate count: %i\n", candidate_count);
    candidates = malloc(candidate_count * sizeof(struct candidate));
    if (!candidates) {
      fprintf(stderr, "Insufficient memory while creating candidate list.\n");
      abort();
    }
    candidate_count = 0;
    twalk(candidate_tree, (void *)register_candidate);
    while (candidate_tree) tdelete(*(void **)candidate_tree, &candidate_tree, (void *)strcmp);
    printf("Ballot count: %i\n", ballot_count);
    ballots = calloc(ballot_count, sizeof(struct ballot));
    if (!ballots) {
      fprintf(stderr, "Insufficient memory while creating ballot list.\n");
      abort();
    }
    ballot = ballots;
    for (i=0; i<tuple_count; i++) {
      char *member_id, *suggestion_id;
      int weight, preference;
      member_id = PQgetvalue(res, i, COL_MEMBER_ID);
      suggestion_id = PQgetvalue(res, i, COL_SUGGESTION_ID);
      weight = (int)strtol(PQgetvalue(res, i, COL_WEIGHT), (char **)NULL, 10);
      if (weight <= 0) {
        fprintf(stderr, "Unexpected weight value.\n");
        free(ballots);
        free(candidates);
        return 1;
      }
      preference = (int)strtol(PQgetvalue(res, i, COL_PREFERENCE), (char **)NULL, 10);
      if (preference < 1 || preference > 4) {
        fprintf(stderr, "Unexpected preference value.\n");
        free(ballots);
        free(candidates);
        return 1;
      }
      preference--;
      ballot->weight = weight;
      ballot->sections[preference].count++;
      if (old_member_id && strcmp(old_member_id, member_id)) ballot++;
      old_member_id = member_id;
    }
    for (i=0; i<ballot_count; i++) {
      int j;
      for (j=0; j<4; j++) {
        if (ballots[i].sections[j].count) {
          ballots[i].sections[j].candidates = malloc(ballots[i].sections[j].count * sizeof(struct candidate *));
          if (!ballots[i].sections[j].candidates) {
            fprintf(stderr, "Insufficient memory while creating ballot section.\n");
            abort();
          }
        }
      }
    }
    ballot = ballots;
    for (i=0; i<=tuple_count; i++) {
      char *member_id, *suggestion_id;
      int preference;
      if (i<tuple_count) {
        member_id = PQgetvalue(res, i, COL_MEMBER_ID);
        suggestion_id = PQgetvalue(res, i, COL_SUGGESTION_ID);
        preference = (int)strtol(PQgetvalue(res, i, COL_PREFERENCE), (char **)NULL, 10);
        preference--;
        ballot->sections[preference].candidates[candidates_in_sections[preference]++] = candidate_by_key(suggestion_id);
      }
      if (i==tuple_count || (old_member_id && strcmp(old_member_id, member_id))) {
        ballot++;
        candidates_in_sections[0] = 0;
        candidates_in_sections[1] = 0;
        candidates_in_sections[2] = 0;
        candidates_in_sections[3] = 0;
      }
      old_member_id = member_id;
    }
  }

  for (i=0; i<candidate_count; i++) {
    struct candidate *candidate = loser(i, ballots, ballot_count);
    candidate->seat = candidate_count - i;
    printf("Assigning rank #%i to suggestion #%s.\n", candidate_count - i, candidate->key);
  }

  for (i=0; i<ballot_count; i++) {
    int j;
    for (j=0; j<4; j++) {
      if (ballots[i].sections[j].count) {
        free(ballots[i].sections[j].candidates);
      }
    }
  }
  free(ballots);

  if (final) {
    printf("Writing final ranks to database.\n");
  } else {
    printf("Writing ranks to database.\n");
  }
  err = write_ranks(db, escaped_initiative_id, final);
  printf("Done.\n");

  free(candidates);

  return err;
}

int main(int argc, char **argv) {

  // variable declarations:
  int err = 0;
  int i, count;
  char *conninfo;
  PGconn *db;
  PGresult *res;

  // parse command line:
  if (argc == 0) return 1;
  if (argc == 1 || !strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")) {
    FILE *out;
    out = argc == 1 ? stderr : stdout;
    fprintf(out, "\n");
    fprintf(out, "Usage: %s <conninfo>\n", argv[0]);
    fprintf(out, "\n");
    fprintf(out, "<conninfo> is specified by PostgreSQL's libpq,\n");
    fprintf(out, "see http://www.postgresql.org/docs/9.1/static/libpq-connect.html\n");
    fprintf(out, "\n");
    fprintf(out, "Example: %s dbname=liquid_feedback\n", argv[0]);
    fprintf(out, "\n");
    return argc == 1 ? 1 : 0;
  }
  {
    size_t len = 0;
    for (i=1; i<argc; i++) len += strlen(argv[i]) + 1;
    conninfo = malloc(len * sizeof(char));
    if (!conninfo) {
      fprintf(stderr, "Error: Could not allocate memory for conninfo string.\n");
      abort();
    }
    conninfo[0] = 0;
    for (i=1; i<argc; i++) {
      if (i>1) strcat(conninfo, " ");
      strcat(conninfo, argv[i]);
    }
  }

  // connect to database:
  db = PQconnectdb(conninfo);
  if (!db) {
    fprintf(stderr, "Error: Could not create database handle.\n");
    return 1;
  }
  if (PQstatus(db) != CONNECTION_OK) {
    fprintf(stderr, "Could not open connection:\n%s", PQerrorMessage(db));
    return 1;
  }

  // check initiatives:
  res = PQexec(db, "SELECT \"initiative_id\", \"final\" FROM \"initiative_suggestion_order_calculation\"");
  if (!res) {
    fprintf(stderr, "Error in pqlib while sending SQL command selecting initiatives to process.\n");
    err = 1;
  } else if (PQresultStatus(res) != PGRES_TUPLES_OK) {
    fprintf(stderr, "Error while executing SQL command selecting initiatives to process:\n%s", PQresultErrorMessage(res));
    err = 1;
    PQclear(res);
  } else if (PQnfields(res) < 2) {
    fprintf(stderr, "Too few columns returned by SQL command selecting initiatives to process.\n");
    err = 1;
    PQclear(res);
  } else {
    count = PQntuples(res);
    printf("Number of initiatives to process: %i\n", count);
    for (i=0; i<count; i++) {
      char *initiative_id, *escaped_initiative_id;
      int final;
      char *cmd;
      PGresult *res2;
      initiative_id = PQgetvalue(res, i, 0);
      final = (PQgetvalue(res, i, 1)[0] == 't') ? 1 : 0;
      printf("Processing initiative_id: %s\n", initiative_id);
      escaped_initiative_id = escapeLiteral(db, initiative_id, strlen(initiative_id));
      if (!escaped_initiative_id) {
        fprintf(stderr, "Could not escape literal in memory.\n");
        abort();
      }
      if (asprintf(&cmd, "SELECT \"member_id\", \"weight\", \"preference\", \"suggestion_id\" FROM \"individual_suggestion_ranking\" WHERE \"initiative_id\" = %s ORDER BY \"member_id\", \"preference\"", escaped_initiative_id) < 0) {
        fprintf(stderr, "Could not prepare query string in memory.\n");
        abort();
      }
      res2 = PQexec(db, cmd);
      free(cmd);
      if (!res2) {
        fprintf(stderr, "Error in pqlib while sending SQL command selecting individual suggestion rankings.\n");
        err = 1;
      } else if (PQresultStatus(res2) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Error while executing SQL command selecting individual suggestion rankings:\n%s", PQresultErrorMessage(res));
        err = 1;
        PQclear(res2);
      } else if (PQnfields(res2) < 4) {
        fprintf(stderr, "Too few columns returned by SQL command selecting individual suggestion rankings.\n");
        err = 1;
        PQclear(res2);
      } else {
        if (process_initiative(db, res2, escaped_initiative_id, final)) err = 1;
        PQclear(res2);
      }
      freemem(escaped_initiative_id);
    }
    PQclear(res);
  }

  // cleanup and exit
  PQfinish(db);
  if (!err) printf("Successfully terminated.\n");
  else fprintf(stderr, "Exiting with error code #%i.\n", err);
  return err;

}
