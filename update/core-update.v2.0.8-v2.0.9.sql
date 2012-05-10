BEGIN;

CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('2.0.9', 2, 0, 9))
  AS "subquery"("string", "major", "minor", "revision");

COMMENT ON TYPE "delegation_chain_row" IS 'Type of rows returned by "delegation_chain" function';

CREATE FUNCTION "delegation_chain_for_closed_issue"
  ( "member_id_p"           "member"."id"%TYPE,
    "issue_id_p"            "issue"."id"%TYPE )
  RETURNS SETOF "delegation_chain_row"
  LANGUAGE 'plpgsql' STABLE AS $$
    DECLARE
      "output_row"           "delegation_chain_row";
      "direct_voter_row"     "direct_voter"%ROWTYPE;
      "delegating_voter_row" "delegating_voter"%ROWTYPE;
    BEGIN
      "output_row"."index"         := 0;
      "output_row"."member_id"     := "member_id_p";
      "output_row"."member_valid"  := TRUE;
      "output_row"."participation" := FALSE;
      "output_row"."overridden"    := FALSE;
      "output_row"."disabled_out"  := FALSE;
      LOOP
        SELECT INTO "direct_voter_row" * FROM "direct_voter"
          WHERE "issue_id" = "issue_id_p"
          AND "member_id" = "output_row"."member_id";
        IF "direct_voter_row"."member_id" NOTNULL THEN
          "output_row"."participation" := TRUE;
          "output_row"."scope_out"     := NULL;
          "output_row"."disabled_out"  := NULL;
          RETURN NEXT "output_row";
          RETURN;
        END IF;
        SELECT INTO "delegating_voter_row" * FROM "delegating_voter"
          WHERE "issue_id" = "issue_id_p"
          AND "member_id" = "output_row"."member_id";
        IF "delegating_voter_row"."member_id" ISNULL THEN
          RETURN;
        END IF;
        "output_row"."scope_out" := "delegating_voter_row"."scope";
        RETURN NEXT "output_row";
        "output_row"."member_id" := "delegating_voter_row"."delegate_member_ids"[1];
        "output_row"."scope_in"  := "output_row"."scope_out";
      END LOOP;
    END;
  $$;

COMMENT ON FUNCTION "delegation_chain_for_closed_issue"
  ( "member"."id"%TYPE,
    "member"."id"%TYPE )
  IS 'Helper function for "delegation_chain" function, handling the special case of closed issues after voting';

DROP FUNCTION "delegation_chain"
  ( "member"."id"%TYPE,
    "unit"."id"%TYPE,
    "area"."id"%TYPE,
    "issue"."id"%TYPE );

DROP FUNCTION "delegation_chain"
  ( "member"."id"%TYPE,
    "unit"."id"%TYPE,
    "area"."id"%TYPE,
    "issue"."id"%TYPE,
    "member"."id"%TYPE );

CREATE FUNCTION "delegation_chain"
  ( "member_id_p"           "member"."id"%TYPE,
    "unit_id_p"             "unit"."id"%TYPE,
    "area_id_p"             "area"."id"%TYPE,
    "issue_id_p"            "issue"."id"%TYPE,
    "simulate_trustee_id_p" "member"."id"%TYPE DEFAULT NULL )
  RETURNS SETOF "delegation_chain_row"
  LANGUAGE 'plpgsql' STABLE AS $$
    DECLARE
      "scope_v"            "delegation_scope";
      "unit_id_v"          "unit"."id"%TYPE;
      "area_id_v"          "area"."id"%TYPE;
      "issue_row"          "issue"%ROWTYPE;
      "visited_member_ids" INT4[];  -- "member"."id"%TYPE[]
      "loop_member_id_v"   "member"."id"%TYPE;
      "output_row"         "delegation_chain_row";
      "output_rows"        "delegation_chain_row"[];
      "delegation_row"     "delegation"%ROWTYPE;
      "row_count"          INT4;
      "i"                  INT4;
      "loop_v"             BOOLEAN;
    BEGIN
      IF
        "unit_id_p" NOTNULL AND
        "area_id_p" ISNULL AND
        "issue_id_p" ISNULL
      THEN
        "scope_v" := 'unit';
        "unit_id_v" := "unit_id_p";
      ELSIF
        "unit_id_p" ISNULL AND
        "area_id_p" NOTNULL AND
        "issue_id_p" ISNULL
      THEN
        "scope_v" := 'area';
        "area_id_v" := "area_id_p";
        SELECT "unit_id" INTO "unit_id_v"
          FROM "area" WHERE "id" = "area_id_v";
      ELSIF
        "unit_id_p" ISNULL AND
        "area_id_p" ISNULL AND
        "issue_id_p" NOTNULL
      THEN
        SELECT INTO "issue_row" * FROM "issue" WHERE "id" = "issue_id_p";
        IF "issue_row"."id" ISNULL THEN
          RETURN;
        END IF;
        IF "issue_row"."closed" NOTNULL THEN
          IF "simulate_trustee_id_p" NOTNULL THEN
            RAISE EXCEPTION 'Tried to simulate delegation chain for closed issue.';
          END IF;
          FOR "output_row" IN
            SELECT * FROM
            "delegation_chain_for_closed_issue"("member_id_p", "issue_id_p")
          LOOP
            RETURN NEXT "output_row";
          END LOOP;
          RETURN;
        END IF;
        "scope_v" := 'issue';
        SELECT "area_id" INTO "area_id_v"
          FROM "issue" WHERE "id" = "issue_id_p";
        SELECT "unit_id" INTO "unit_id_v"
          FROM "area"  WHERE "id" = "area_id_v";
      ELSE
        RAISE EXCEPTION 'Exactly one of unit_id_p, area_id_p, or issue_id_p must be NOTNULL.';
      END IF;
      "visited_member_ids" := '{}';
      "loop_member_id_v"   := NULL;
      "output_rows"        := '{}';
      "output_row"."index"         := 0;
      "output_row"."member_id"     := "member_id_p";
      "output_row"."member_valid"  := TRUE;
      "output_row"."participation" := FALSE;
      "output_row"."overridden"    := FALSE;
      "output_row"."disabled_out"  := FALSE;
      "output_row"."scope_out"     := NULL;
      LOOP
        IF "visited_member_ids" @> ARRAY["output_row"."member_id"] THEN
          "loop_member_id_v" := "output_row"."member_id";
        ELSE
          "visited_member_ids" :=
            "visited_member_ids" || "output_row"."member_id";
        END IF;
        IF "output_row"."participation" ISNULL THEN
          "output_row"."overridden" := NULL;
        ELSIF "output_row"."participation" THEN
          "output_row"."overridden" := TRUE;
        END IF;
        "output_row"."scope_in" := "output_row"."scope_out";
        IF EXISTS (
          SELECT NULL FROM "member" JOIN "privilege"
          ON "privilege"."member_id" = "member"."id"
          AND "privilege"."unit_id" = "unit_id_v"
          WHERE "id" = "output_row"."member_id"
          AND "member"."active" AND "privilege"."voting_right"
        ) THEN
          IF "scope_v" = 'unit' THEN
            SELECT * INTO "delegation_row" FROM "delegation"
              WHERE "truster_id" = "output_row"."member_id"
              AND "unit_id" = "unit_id_v";
          ELSIF "scope_v" = 'area' THEN
            "output_row"."participation" := EXISTS (
              SELECT NULL FROM "membership"
              WHERE "area_id" = "area_id_p"
              AND "member_id" = "output_row"."member_id"
            );
            SELECT * INTO "delegation_row" FROM "delegation"
              WHERE "truster_id" = "output_row"."member_id"
              AND (
                "unit_id" = "unit_id_v" OR
                "area_id" = "area_id_v"
              )
              ORDER BY "scope" DESC;
          ELSIF "scope_v" = 'issue' THEN
            IF "issue_row"."fully_frozen" ISNULL THEN
              "output_row"."participation" := EXISTS (
                SELECT NULL FROM "interest"
                WHERE "issue_id" = "issue_id_p"
                AND "member_id" = "output_row"."member_id"
              );
            ELSE
              IF "output_row"."member_id" = "member_id_p" THEN
                "output_row"."participation" := EXISTS (
                  SELECT NULL FROM "direct_voter"
                  WHERE "issue_id" = "issue_id_p"
                  AND "member_id" = "output_row"."member_id"
                );
              ELSE
                "output_row"."participation" := NULL;
              END IF;
            END IF;
            SELECT * INTO "delegation_row" FROM "delegation"
              WHERE "truster_id" = "output_row"."member_id"
              AND (
                "unit_id" = "unit_id_v" OR
                "area_id" = "area_id_v" OR
                "issue_id" = "issue_id_p"
              )
              ORDER BY "scope" DESC;
          END IF;
        ELSE
          "output_row"."member_valid"  := FALSE;
          "output_row"."participation" := FALSE;
          "output_row"."scope_out"     := NULL;
          "delegation_row" := ROW(NULL);
        END IF;
        IF
          "output_row"."member_id" = "member_id_p" AND
          "simulate_trustee_id_p" NOTNULL
        THEN
          "output_row"."scope_out" := "scope_v";
          "output_rows" := "output_rows" || "output_row";
          "output_row"."member_id" := "simulate_trustee_id_p";
        ELSIF "delegation_row"."trustee_id" NOTNULL THEN
          "output_row"."scope_out" := "delegation_row"."scope";
          "output_rows" := "output_rows" || "output_row";
          "output_row"."member_id" := "delegation_row"."trustee_id";
        ELSIF "delegation_row"."scope" NOTNULL THEN
          "output_row"."scope_out" := "delegation_row"."scope";
          "output_row"."disabled_out" := TRUE;
          "output_rows" := "output_rows" || "output_row";
          EXIT;
        ELSE
          "output_row"."scope_out" := NULL;
          "output_rows" := "output_rows" || "output_row";
          EXIT;
        END IF;
        EXIT WHEN "loop_member_id_v" NOTNULL;
        "output_row"."index" := "output_row"."index" + 1;
      END LOOP;
      "row_count" := array_upper("output_rows", 1);
      "i"      := 1;
      "loop_v" := FALSE;
      LOOP
        "output_row" := "output_rows"["i"];
        EXIT WHEN "output_row" ISNULL;  -- NOTE: ISNULL and NOT ... NOTNULL produce different results!
        IF "loop_v" THEN
          IF "i" + 1 = "row_count" THEN
            "output_row"."loop" := 'last';
          ELSIF "i" = "row_count" THEN
            "output_row"."loop" := 'repetition';
          ELSE
            "output_row"."loop" := 'intermediate';
          END IF;
        ELSIF "output_row"."member_id" = "loop_member_id_v" THEN
          "output_row"."loop" := 'first';
          "loop_v" := TRUE;
        END IF;
        IF "scope_v" = 'unit' THEN
          "output_row"."participation" := NULL;
        END IF;
        RETURN NEXT "output_row";
        "i" := "i" + 1;
      END LOOP;
      RETURN;
    END;
  $$;

COMMENT ON FUNCTION "delegation_chain"
  ( "member"."id"%TYPE,
    "unit"."id"%TYPE,
    "area"."id"%TYPE,
    "issue"."id"%TYPE,
    "member"."id"%TYPE )
  IS 'Shows a delegation chain for unit, area, or issue; See "delegation_chain_row" type for more information';

CREATE TYPE "delegation_info_loop_type" AS ENUM
  ('own', 'first', 'first_ellipsis', 'other', 'other_ellipsis');

COMMENT ON TYPE "delegation_info_loop_type" IS 'Type of "delegation_loop" in "delegation_info_type"; ''own'' means loop to self, ''first'' means loop to first trustee, ''first_ellipsis'' means loop to ellipsis after first trustee, ''other'' means loop to other trustee, ''other_ellipsis'' means loop to ellipsis after other trustee''';

CREATE TYPE "delegation_info_type" AS (
        "own_participation"           BOOLEAN,
        "own_delegation_scope"        "delegation_scope",
        "first_trustee_id"            INT4,
        "first_trustee_participation" BOOLEAN,
        "first_trustee_ellipsis"      BOOLEAN,
        "other_trustee_id"            INT4,
        "other_trustee_participation" BOOLEAN,
        "other_trustee_ellipsis"      BOOLEAN,
        "delegation_loop"             "delegation_info_loop_type");

COMMENT ON TYPE "delegation_info_type" IS 'Type of result returned by "delegation_info" function; For meaning of "participation" check comment on "delegation_chain_row" type';

COMMENT ON COLUMN "delegation_info_type"."own_participation"           IS 'Member is directly participating';
COMMENT ON COLUMN "delegation_info_type"."own_delegation_scope"        IS 'Delegation scope of member';
COMMENT ON COLUMN "delegation_info_type"."first_trustee_id"            IS 'Direct trustee of member';
COMMENT ON COLUMN "delegation_info_type"."first_trustee_participation" IS 'Direct trustee of member is participating';
COMMENT ON COLUMN "delegation_info_type"."first_trustee_ellipsis"      IS 'Ellipsis in delegation chain after "first_trustee"';
COMMENT ON COLUMN "delegation_info_type"."other_trustee_id"            IS 'Another relevant trustee (due to participation)';
COMMENT ON COLUMN "delegation_info_type"."other_trustee_participation" IS 'Another trustee is participating (redundant field: if "other_trustee_id" is set, then "other_trustee_participation" is always TRUE, else "other_trustee_participation" is NULL)';
COMMENT ON COLUMN "delegation_info_type"."other_trustee_ellipsis"      IS 'Ellipsis in delegation chain after "other_trustee"';
COMMENT ON COLUMN "delegation_info_type"."delegation_loop"             IS 'Non-NULL value, if delegation chain contains a circle; See comment on "delegation_info_loop_type" for details';

CREATE FUNCTION "delegation_info"
  ( "member_id_p"           "member"."id"%TYPE,
    "unit_id_p"             "unit"."id"%TYPE,
    "area_id_p"             "area"."id"%TYPE,
    "issue_id_p"            "issue"."id"%TYPE,
    "simulate_trustee_id_p" "member"."id"%TYPE DEFAULT NULL )
  RETURNS "delegation_info_type"
  LANGUAGE 'plpgsql' STABLE AS $$
    DECLARE
      "current_row" "delegation_chain_row";
      "result"      "delegation_info_type";
    BEGIN
      "result"."own_participation" := FALSE;
      FOR "current_row" IN
        SELECT * FROM "delegation_chain"(
          "member_id_p",
          "unit_id_p", "area_id_p", "issue_id_p",
          "simulate_trustee_id_p")
      LOOP
        IF "current_row"."member_id" = "member_id_p" THEN
          "result"."own_participation"    := "current_row"."participation";
          "result"."own_delegation_scope" := "current_row"."scope_out";
          IF "current_row"."loop" = 'first' THEN
            "result"."delegation_loop" := 'own';
          END IF;
        ELSIF
          "current_row"."member_valid" AND
          ( "current_row"."loop" ISNULL OR
            "current_row"."loop" != 'repetition' )
        THEN
          IF "result"."first_trustee_id" ISNULL THEN
            "result"."first_trustee_id"            := "current_row"."member_id";
            "result"."first_trustee_participation" := "current_row"."participation";
            "result"."first_trustee_ellipsis"      := FALSE;
            IF "current_row"."loop" = 'first' THEN
              "result"."delegation_loop" := 'first';
            END IF;
          ELSIF "result"."other_trustee_id" ISNULL THEN
            IF "current_row"."participation" THEN
              "result"."other_trustee_id"            := "current_row"."member_id";
              "result"."other_trustee_participation" := TRUE;
              "result"."other_trustee_ellipsis"      := FALSE;
              IF "current_row"."loop" = 'first' THEN
                "result"."delegation_loop" := 'other';
              END IF;
            ELSE
              "result"."first_trustee_ellipsis" := TRUE;
              IF "current_row"."loop" = 'first' THEN
                "result"."delegation_loop" := 'first_ellipsis';
              END IF;
            END IF;
          ELSE
            "result"."other_trustee_ellipsis" := TRUE;
            IF "current_row"."loop" = 'first' THEN
              "result"."delegation_loop" := 'other_ellipsis';
            END IF;
          END IF;
        END IF;
      END LOOP;
      RETURN "result";
    END;
  $$;

COMMENT ON FUNCTION "delegation_info"
  ( "member"."id"%TYPE,
    "unit"."id"%TYPE,
    "area"."id"%TYPE,
    "issue"."id"%TYPE,
    "member"."id"%TYPE )
  IS 'Notable information about a delegation chain for unit, area, or issue; See "delegation_info_type" for more information';

COMMIT;
