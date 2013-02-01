BEGIN;

CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('2.1.1', 2, 1, 1))
  AS "subquery"("string", "major", "minor", "revision");

ALTER TABLE "initiative" ADD COLUMN "harmonic_weight" NUMERIC(12, 3);
COMMENT ON COLUMN "initiative"."harmonic_weight" IS 'Indicates the relevancy of the initiative, calculated from the potential supporters weighted with the harmonic series to avoid a large number of clones affecting other initiative''s sorting positions too much';

ALTER TABLE "suggestion" ADD COLUMN "harmonic_weight" NUMERIC(12, 3);
COMMENT ON COLUMN "suggestion"."harmonic_weight" IS 'Indicates the relevancy of the suggestion, calculated from the supporters (positive "degree") of the suggestion weighted with the harmonic series to avoid a large number of clones affecting other suggestion''s sortings position too much';

CREATE VIEW "remaining_harmonic_supporter_weight" AS
  SELECT
    "direct_interest_snapshot"."issue_id",
    "direct_interest_snapshot"."event",
    "direct_interest_snapshot"."member_id",
    "direct_interest_snapshot"."weight" AS "weight_num",
    count("initiative"."id") AS "weight_den"
  FROM "issue"
  JOIN "direct_interest_snapshot"
    ON "issue"."id" = "direct_interest_snapshot"."issue_id"
    AND "issue"."latest_snapshot_event" = "direct_interest_snapshot"."event"
  JOIN "direct_supporter_snapshot"
    ON "direct_interest_snapshot"."issue_id" = "direct_supporter_snapshot"."issue_id"
    AND "direct_interest_snapshot"."event" = "direct_supporter_snapshot"."event"
    AND "direct_interest_snapshot"."member_id" = "direct_supporter_snapshot"."member_id"
  JOIN "initiative"
    ON "direct_supporter_snapshot"."initiative_id" = "initiative"."id"
    AND "initiative"."harmonic_weight" ISNULL
  GROUP BY
    "direct_interest_snapshot"."issue_id",
    "direct_interest_snapshot"."event",
    "direct_interest_snapshot"."member_id",
    "direct_interest_snapshot"."weight";

COMMENT ON VIEW "remaining_harmonic_supporter_weight" IS 'Helper view for function "set_harmonic_initiative_weights"';

CREATE VIEW "remaining_harmonic_initiative_weight_summands" AS
  SELECT
    "initiative"."issue_id",
    "initiative"."id" AS "initiative_id",
    sum("remaining_harmonic_supporter_weight"."weight_num") AS "weight_num",
    "remaining_harmonic_supporter_weight"."weight_den"
  FROM "remaining_harmonic_supporter_weight"
  JOIN "direct_supporter_snapshot"
    ON "remaining_harmonic_supporter_weight"."issue_id" = "direct_supporter_snapshot"."issue_id"
    AND "remaining_harmonic_supporter_weight"."event" = "direct_supporter_snapshot"."event"
    AND "remaining_harmonic_supporter_weight"."member_id" = "direct_supporter_snapshot"."member_id"
  JOIN "initiative"
    ON "direct_supporter_snapshot"."initiative_id" = "initiative"."id"
    AND "initiative"."harmonic_weight" ISNULL
  GROUP BY
    "initiative"."issue_id",
    "initiative"."id",
    "remaining_harmonic_supporter_weight"."weight_den";

COMMENT ON VIEW "remaining_harmonic_initiative_weight_summands" IS 'Helper view for function "set_harmonic_initiative_weights"';

CREATE FUNCTION "set_harmonic_initiative_weights"
  ( "issue_id_p" "issue"."id"%TYPE )
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    DECLARE
      "weight_row"   "remaining_harmonic_initiative_weight_summands"%ROWTYPE;
      "i"            INT4;
      "count_v"      INT4;
      "summand_v"    FLOAT;
      "id_ary"       INT4[];
      "weight_ary"   FLOAT[];
      "min_weight_v" FLOAT;
    BEGIN
      UPDATE "initiative" SET "harmonic_weight" = NULL
        WHERE "issue_id" = "issue_id_p";
      LOOP
        "min_weight_v" := NULL;
        "i" := 0;
        "count_v" := 0;
        FOR "weight_row" IN
          SELECT * FROM "remaining_harmonic_initiative_weight_summands"
          WHERE "issue_id" = "issue_id_p"
          ORDER BY "initiative_id" DESC, "weight_den" DESC
          -- NOTE: latest initiatives treated worse
        LOOP
          "summand_v" := "weight_row"."weight_num"::FLOAT / "weight_row"."weight_den"::FLOAT;
          IF "i" = 0 OR "weight_row"."initiative_id" != "id_ary"["i"] THEN
            "i" := "i" + 1;
            "count_v" := "i";
            "id_ary"["i"] := "weight_row"."initiative_id";
            "weight_ary"["i"] := "summand_v";
          ELSE
            "weight_ary"["i"] := "weight_ary"["i"] + "summand_v";
          END IF;
        END LOOP;
        EXIT WHEN "count_v" = 0;
        "i" := 1;
        LOOP
          "weight_ary"["i"] := "weight_ary"["i"]::NUMERIC(18,9)::NUMERIC(12,3);
          IF "min_weight_v" ISNULL OR "weight_ary"["i"] < "min_weight_v" THEN
            "min_weight_v" := "weight_ary"["i"];
          END IF;
          "i" := "i" + 1;
          EXIT WHEN "i" > "count_v";
        END LOOP;
        "i" := 1;
        LOOP
          IF "weight_ary"["i"] = "min_weight_v" THEN
            UPDATE "initiative" SET "harmonic_weight" = "min_weight_v"
              WHERE "id" = "id_ary"["i"];
            EXIT;
          END IF;
          "i" := "i" + 1;
        END LOOP;
      END LOOP;
    END;
  $$;

COMMENT ON FUNCTION "set_harmonic_initiative_weights"
  ( "issue"."id"%TYPE )
  IS 'Calculates and sets "harmonic_weight" of initiatives in a given issue';

CREATE VIEW "remaining_harmonic_opinion_weight" AS
  SELECT
    "initiative"."issue_id",
    "opinion"."initiative_id",
    "direct_interest_snapshot"."member_id",
    "direct_interest_snapshot"."weight" AS "weight_num",
    count("opinion"."suggestion_id") AS "weight_den"
  FROM "issue"
  JOIN "direct_interest_snapshot"
    ON "issue"."id" = "direct_interest_snapshot"."issue_id"
    AND "issue"."latest_snapshot_event" = "direct_interest_snapshot"."event"
  JOIN "initiative"
    ON "direct_interest_snapshot"."issue_id" = "initiative"."issue_id"
  JOIN "opinion"
    ON "direct_interest_snapshot"."member_id" = "opinion"."member_id"
    AND "initiative"."id" = "opinion"."initiative_id"
    AND "opinion"."degree" > 0
  GROUP BY
    "initiative"."issue_id",
    "opinion"."initiative_id",
    "direct_interest_snapshot"."member_id",
    "direct_interest_snapshot"."weight";

COMMENT ON VIEW "remaining_harmonic_opinion_weight" IS 'Helper view for function "set_harmonic_suggestion_weights"';

CREATE VIEW "remaining_harmonic_suggestion_weight_summands" AS
  SELECT
    "suggestion"."initiative_id",
    "opinion"."suggestion_id",
    sum("remaining_harmonic_opinion_weight"."weight_num") AS "weight_num",
    "remaining_harmonic_opinion_weight"."weight_den"
  FROM "remaining_harmonic_opinion_weight"
  JOIN "opinion"
    ON "remaining_harmonic_opinion_weight"."initiative_id" = "opinion"."initiative_id"
    AND "remaining_harmonic_opinion_weight"."member_id" = "opinion"."member_id"
  JOIN "suggestion"
    ON "opinion"."suggestion_id" = "suggestion"."id"
    AND "suggestion"."harmonic_weight" ISNULL
  GROUP BY
    "suggestion"."initiative_id",
    "opinion"."suggestion_id",
    "remaining_harmonic_opinion_weight"."weight_den";

COMMENT ON VIEW "remaining_harmonic_suggestion_weight_summands" IS 'Helper view for function "set_harmonic_suggestion_weights"';

CREATE FUNCTION "set_harmonic_suggestion_weights"
  ( "initiative_id_p" "initiative"."id"%TYPE )
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    DECLARE
      "weight_row"   "remaining_harmonic_suggestion_weight_summands"%ROWTYPE;
      "i"            INT4;
      "count_v"      INT4;
      "summand_v"    FLOAT;
      "id_ary"       INT4[];
      "weight_ary"   FLOAT[];
      "min_weight_v" FLOAT;
    BEGIN
      UPDATE "suggestion" SET "harmonic_weight" = NULL
        WHERE "initiative_id" = "initiative_id_p";
      LOOP
        "min_weight_v" := NULL;
        "i" := 0;
        "count_v" := 0;
        FOR "weight_row" IN
          SELECT * FROM "remaining_harmonic_suggestion_weight_summands"
          WHERE "initiative_id" = "initiative_id_p"
          ORDER BY "suggestion_id" DESC, "weight_den" DESC
          -- NOTE: latest suggestions treated worse
        LOOP
          "summand_v" := "weight_row"."weight_num"::FLOAT / "weight_row"."weight_den"::FLOAT;
          IF "i" = 0 OR "weight_row"."suggestion_id" != "id_ary"["i"] THEN
            "i" := "i" + 1;
            "count_v" := "i";
            "id_ary"["i"] := "weight_row"."suggestion_id";
            "weight_ary"["i"] := "summand_v";
          ELSE
            "weight_ary"["i"] := "weight_ary"["i"] + "summand_v";
          END IF;
        END LOOP;
        EXIT WHEN "count_v" = 0;
        "i" := 1;
        LOOP
          "weight_ary"["i"] := "weight_ary"["i"]::NUMERIC(18,9)::NUMERIC(12,3);
          IF "min_weight_v" ISNULL OR "weight_ary"["i"] < "min_weight_v" THEN
            "min_weight_v" := "weight_ary"["i"];
          END IF;
          "i" := "i" + 1;
          EXIT WHEN "i" > "count_v";
        END LOOP;
        "i" := 1;
        LOOP
          IF "weight_ary"["i"] = "min_weight_v" THEN
            UPDATE "suggestion" SET "harmonic_weight" = "min_weight_v"
              WHERE "id" = "id_ary"["i"];
            EXIT;
          END IF;
          "i" := "i" + 1;
        END LOOP;
      END LOOP;
    END;
  $$;

COMMENT ON FUNCTION "set_harmonic_suggestion_weights"
  ( "issue"."id"%TYPE )
  IS 'Calculates and sets "harmonic_weight" of suggestions in a given initiative';

CREATE OR REPLACE FUNCTION "create_snapshot"
  ( "issue_id_p" "issue"."id"%TYPE )
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    DECLARE
      "initiative_id_v"    "initiative"."id"%TYPE;
      "suggestion_id_v"    "suggestion"."id"%TYPE;
    BEGIN
      PERFORM "lock_issue"("issue_id_p");
      PERFORM "create_population_snapshot"("issue_id_p");
      PERFORM "create_interest_snapshot"("issue_id_p");
      UPDATE "issue" SET
        "snapshot" = now(),
        "latest_snapshot_event" = 'periodic',
        "population" = (
          SELECT coalesce(sum("weight"), 0)
          FROM "direct_population_snapshot"
          WHERE "issue_id" = "issue_id_p"
          AND "event" = 'periodic'
        )
        WHERE "id" = "issue_id_p";
      FOR "initiative_id_v" IN
        SELECT "id" FROM "initiative" WHERE "issue_id" = "issue_id_p"
      LOOP
        UPDATE "initiative" SET
          "supporter_count" = (
            SELECT coalesce(sum("di"."weight"), 0)
            FROM "direct_interest_snapshot" AS "di"
            JOIN "direct_supporter_snapshot" AS "ds"
            ON "di"."member_id" = "ds"."member_id"
            WHERE "di"."issue_id" = "issue_id_p"
            AND "di"."event" = 'periodic'
            AND "ds"."initiative_id" = "initiative_id_v"
            AND "ds"."event" = 'periodic'
          ),
          "informed_supporter_count" = (
            SELECT coalesce(sum("di"."weight"), 0)
            FROM "direct_interest_snapshot" AS "di"
            JOIN "direct_supporter_snapshot" AS "ds"
            ON "di"."member_id" = "ds"."member_id"
            WHERE "di"."issue_id" = "issue_id_p"
            AND "di"."event" = 'periodic'
            AND "ds"."initiative_id" = "initiative_id_v"
            AND "ds"."event" = 'periodic'
            AND "ds"."informed"
          ),
          "satisfied_supporter_count" = (
            SELECT coalesce(sum("di"."weight"), 0)
            FROM "direct_interest_snapshot" AS "di"
            JOIN "direct_supporter_snapshot" AS "ds"
            ON "di"."member_id" = "ds"."member_id"
            WHERE "di"."issue_id" = "issue_id_p"
            AND "di"."event" = 'periodic'
            AND "ds"."initiative_id" = "initiative_id_v"
            AND "ds"."event" = 'periodic'
            AND "ds"."satisfied"
          ),
          "satisfied_informed_supporter_count" = (
            SELECT coalesce(sum("di"."weight"), 0)
            FROM "direct_interest_snapshot" AS "di"
            JOIN "direct_supporter_snapshot" AS "ds"
            ON "di"."member_id" = "ds"."member_id"
            WHERE "di"."issue_id" = "issue_id_p"
            AND "di"."event" = 'periodic'
            AND "ds"."initiative_id" = "initiative_id_v"
            AND "ds"."event" = 'periodic'
            AND "ds"."informed"
            AND "ds"."satisfied"
          )
          WHERE "id" = "initiative_id_v";
        FOR "suggestion_id_v" IN
          SELECT "id" FROM "suggestion"
          WHERE "initiative_id" = "initiative_id_v"
        LOOP
          UPDATE "suggestion" SET
            "minus2_unfulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = -2
              AND "opinion"."fulfilled" = FALSE
            ),
            "minus2_fulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = -2
              AND "opinion"."fulfilled" = TRUE
            ),
            "minus1_unfulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = -1
              AND "opinion"."fulfilled" = FALSE
            ),
            "minus1_fulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = -1
              AND "opinion"."fulfilled" = TRUE
            ),
            "plus1_unfulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = 1
              AND "opinion"."fulfilled" = FALSE
            ),
            "plus1_fulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = 1
              AND "opinion"."fulfilled" = TRUE
            ),
            "plus2_unfulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = 2
              AND "opinion"."fulfilled" = FALSE
            ),
            "plus2_fulfilled_count" = (
              SELECT coalesce(sum("snapshot"."weight"), 0)
              FROM "issue" CROSS JOIN "opinion"
              JOIN "direct_interest_snapshot" AS "snapshot"
              ON "snapshot"."issue_id" = "issue"."id"
              AND "snapshot"."event" = "issue"."latest_snapshot_event"
              AND "snapshot"."member_id" = "opinion"."member_id"
              WHERE "issue"."id" = "issue_id_p"
              AND "opinion"."suggestion_id" = "suggestion_id_v"
              AND "opinion"."degree" = 2
              AND "opinion"."fulfilled" = TRUE
            )
            WHERE "suggestion"."id" = "suggestion_id_v";
        END LOOP;
        PERFORM "set_harmonic_suggestion_weights"("initiative_id_v");
      END LOOP;
      PERFORM "set_harmonic_initiative_weights"("issue_id_p");
      RETURN;
    END;
  $$;

SELECT "set_harmonic_initiative_weights"("id") FROM "issue";
SELECT "set_harmonic_suggestion_weights"("id") FROM "initiative";

COMMIT;
