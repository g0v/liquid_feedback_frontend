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

static int candidate_count;
static char **candidates;

static void register_candidate(char **candidate, VISIT visit, int level) {
  if (visit == postorder || visit == leaf) {
    candidates[candidate_count++] = *candidate;
  }
}

static int ptrstrcmp(char **s1, char **s2) {
  return strcmp(*s1, *s2);
}

static int candidate_number(char *candidate) {
  char **addr;
  addr = bsearch(&candidate, candidates, candidate_count, sizeof(char *), (void *)ptrstrcmp);
  if (!addr) {
    fprintf(stderr, "Candidate not found (should not happen)\n");
    abort();
  }
  return addr - candidates;
}

struct ballot_section {
  int count;
  int *candidates;
};

struct ballot {
  int weight;
  struct ballot_section sections[4];
};

static void process_initiative(PGresult *res) {
  void *candidate_tree = NULL;
  int ballot_count = 0;
  int tuple_count, i;
  char *old_member_id = NULL;
  struct ballot *ballots, *ballot;
  int candidates_in_sections[4] = {0, };
  candidate_count = 0;
  tuple_count = PQntuples(res);
  for (i=0; i<=tuple_count; i++) {
    char *member_id, *suggestion_id;
    if (i<tuple_count) {
      member_id = PQgetvalue(res, i, COL_MEMBER_ID);
      suggestion_id = PQgetvalue(res, i, COL_SUGGESTION_ID);
      if (!candidate_tree || !tfind(suggestion_id, &candidate_tree, (void *)strcmp)) {
        candidate_count++;
        if (!tsearch(suggestion_id, &candidate_tree, (void *)strcmp)) {
          fprintf(stderr, "Insufficient memory\n");
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
  candidates = malloc(candidate_count * sizeof(char *));
  if (!candidates) {
    fprintf(stderr, "Insufficient memory\n");
    abort();
  }
  candidate_count = 0;
  twalk(candidate_tree, (void *)register_candidate);
  while (candidate_tree) tdelete(*(void **)candidate_tree, &candidate_tree, (void *)strcmp);
  printf("Ballot count: %i\n", ballot_count);
  ballots = calloc(ballot_count, sizeof(struct ballot));
  if (!ballots) {
    fprintf(stderr, "Insufficient memory\n");
    abort();
  }
  ballot = ballots;
  for (i=0; i<=tuple_count; i++) {
    char *member_id, *suggestion_id;
    int weight, preference;
    if (i<tuple_count) {
      member_id = PQgetvalue(res, i, COL_MEMBER_ID);
      suggestion_id = PQgetvalue(res, i, COL_SUGGESTION_ID);
      weight = (int)strtol(PQgetvalue(res, i, COL_WEIGHT), (char **)NULL, 10);
      if (weight <= 0) {
        fprintf(stderr, "Unexpected weight value\n");
        abort();
      }
      preference = (int)strtol(PQgetvalue(res, i, COL_PREFERENCE), (char **)NULL, 10);
      if (preference < 1 || preference > 4) {
        fprintf(stderr, "Unexpected preference value\n");
        abort();
      }
      preference--;
      ballot->weight = weight;
      ballot->sections[preference].count++;
    }
    if (i==tuple_count || (old_member_id && strcmp(old_member_id, member_id))) {
      ballot++;
    }
    old_member_id = member_id;
  }
  for (i=0; i<ballot_count; i++) {
    int j;
    for (j=0; j<4; j++) {
      if (ballots[i].sections[j].count) {
        ballots[i].sections[j].candidates = malloc(ballots[i].sections[j].count * sizeof(int));
        if (!ballots[i].sections[j].candidates) {
          fprintf(stderr, "Insufficient memory\n");
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
      if (preference < 1 || preference > 4) {
        fprintf(stderr, "Unexpected preference value\n");
        abort();
      }
      preference--;
      ballot->sections[preference].candidates[candidates_in_sections[preference]++] = candidate_number(suggestion_id);
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
    fprintf(stdout, "\n");
    fprintf(stdout, "Usage: %s <conninfo>\n", argv[0]);
    fprintf(stdout, "\n");
    fprintf(stdout, "<conninfo> is specified by PostgreSQL's libpq,\n");
    fprintf(stdout, "see http://www.postgresql.org/docs/9.1/static/libpq-connect.html\n");
    fprintf(stdout, "\n");
    fprintf(stdout, "Example: %s dbname=liquid_feedback\n", argv[0]);
    fprintf(stdout, "\n");
    return argc == 1 ? 1 : 0;
  }
  {
    size_t len = 0;
    for (i=1; i<argc; i++) len += strlen(argv[i]) + 1;
    conninfo = malloc(len * sizeof(char));
    if (!conninfo) {
      fprintf(stderr, "Error: Could not allocate memory for conninfo string\n");
      return 1;
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
    fprintf(stderr, "Error: Could not create database handle\n");
    return 1;
  }
  if (PQstatus(db) != CONNECTION_OK) {
    fprintf(stderr, "Could not open connection:\n%s", PQerrorMessage(db));
    return 1;
  }

  // check initiatives:
  res = PQexec(db, "SELECT \"initiative_id\", \"final\" FROM \"initiative_suggestion_order_calculation\"");
  if (!res) {
    fprintf(stderr, "Error in pqlib while sending SQL command selecting open issues\n");
    err = 1;
  } else if (PQresultStatus(res) != PGRES_TUPLES_OK) {
    fprintf(stderr, "Error while executing SQL command selecting open issues:\n%s", PQresultErrorMessage(res));
    err = 1;
    PQclear(res);
  } else {
    count = PQntuples(res);
    printf("Number of initiatives to process: %i\n", count);
    for (i=0; i<count; i++) {
      char *initiative_id, *escaped_initiative_id;
      char *cmd;
      PGresult *res2;
      initiative_id = PQgetvalue(res, i, 0);
      printf("Processing initiative_id: %s\n", initiative_id);
      escaped_initiative_id = escapeLiteral(db, initiative_id, strlen(initiative_id));
      if (asprintf(&cmd, "SELECT \"member_id\", \"weight\", \"preference\", \"suggestion_id\" FROM \"individual_suggestion_ranking\" WHERE \"initiative_id\" = %s ORDER BY \"member_id\", \"preference\"", escaped_initiative_id) < 0) {
        fprintf(stderr, "Could not prepare query string in memory.\n");
        err = 1;
        freemem(escaped_initiative_id);
        break;
      }
      res2 = PQexec(db, cmd);
      free(cmd);
      if (!res2) {
        fprintf(stderr, "Error in pqlib while sending SQL command selecting open issues\n");
        err = 1;
      } else if (PQresultStatus(res2) != PGRES_TUPLES_OK) {
        fprintf(stderr, "Error while executing SQL command selecting open issues:\n%s", PQresultErrorMessage(res));
        err = 1;
        PQclear(res2);
      } else {
        if (PQntuples(res2) == 0) {
          printf("Nothing to do.\n");
        } else {
          process_initiative(res2);
        }
        PQclear(res2);
      }
      freemem(escaped_initiative_id);
    }
    PQclear(res);
  }

  // cleanup and exit
  PQfinish(db);
  return err;

}
