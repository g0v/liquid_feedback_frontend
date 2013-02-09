BEGIN;

CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('2.1.1', 2, 1, 1))
  AS "subquery"("string", "major", "minor", "revision");

ALTER TABLE "initiative" ADD COLUMN "harmonic_weight" NUMERIC(12, 3);
COMMENT ON COLUMN "initiative"."harmonic_weight" IS 'Indicates the relevancy of the initiative, calculated from the potential supporters weighted with the harmonic series to avoid a large number of clones affecting other initiative''s sorting positions too much; shall be used as secondary sorting key after "admitted" as primary sorting key';

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
    AND (
      "direct_supporter_snapshot"."satisfied" = TRUE OR
      coalesce("initiative"."admitted", FALSE) = FALSE
    )
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
    "initiative"."admitted",
    sum("remaining_harmonic_supporter_weight"."weight_num") AS "weight_num",
    "remaining_harmonic_supporter_weight"."weight_den"
  FROM "remaining_harmonic_supporter_weight"
  JOIN "direct_supporter_snapshot"
    ON "remaining_harmonic_supporter_weight"."issue_id" = "direct_supporter_snapshot"."issue_id"
    AND "remaining_harmonic_supporter_weight"."event" = "direct_supporter_snapshot"."event"
    AND "remaining_harmonic_supporter_weight"."member_id" = "direct_supporter_snapshot"."member_id"
  JOIN "initiative"
    ON "direct_supporter_snapshot"."initiative_id" = "initiative"."id"
    AND (
      "direct_supporter_snapshot"."satisfied" = TRUE OR
      coalesce("initiative"."admitted", FALSE) = FALSE
    )
    AND "initiative"."harmonic_weight" ISNULL
  GROUP BY
    "initiative"."issue_id",
    "initiative"."id",
    "initiative"."admitted",
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
          AND (
            coalesce("admitted", FALSE) = FALSE OR NOT EXISTS (
              SELECT NULL FROM "initiative"
              WHERE "issue_id" = "issue_id_p"
              AND "harmonic_weight" ISNULL
              AND coalesce("admitted", FALSE) = FALSE
            )
          )
          ORDER BY "initiative_id" DESC, "weight_den" DESC
          -- NOTE: non-admitted initiatives placed first (at last positions),
          --       latest initiatives treated worse in case of tie
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
      UPDATE "initiative" SET "harmonic_weight" = 0
        WHERE "issue_id" = "issue_id_p" AND "harmonic_weight" ISNULL;
    END;
  $$;

COMMENT ON FUNCTION "set_harmonic_initiative_weights"
  ( "issue"."id"%TYPE )
  IS 'Calculates and sets "harmonic_weight" of initiatives in a given issue';

CREATE OR REPLACE FUNCTION "manual_freeze"("issue_id_p" "issue"."id"%TYPE)
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    DECLARE
      "issue_row" "issue"%ROWTYPE;
    BEGIN
      PERFORM "create_snapshot"("issue_id_p");
      PERFORM "freeze_after_snapshot"("issue_id_p");
      PERFORM "set_harmonic_initiative_weights"("issue_id_p");
      RETURN;
    END;
  $$;

CREATE OR REPLACE FUNCTION "check_issue"
  ( "issue_id_p" "issue"."id"%TYPE )
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    DECLARE
      "issue_row"      "issue"%ROWTYPE;
      "policy_row"     "policy"%ROWTYPE;
      "new_snapshot_v" BOOLEAN;
    BEGIN
      PERFORM "lock_issue"("issue_id_p");
      SELECT * INTO "issue_row" FROM "issue" WHERE "id" = "issue_id_p";
      -- only process open issues:
      IF "issue_row"."closed" ISNULL THEN
        SELECT * INTO "policy_row" FROM "policy"
          WHERE "id" = "issue_row"."policy_id";
        -- create a snapshot, unless issue is already fully frozen:
        IF "issue_row"."fully_frozen" ISNULL THEN
          PERFORM "create_snapshot"("issue_id_p");
          "new_snapshot_v" := TRUE;
          SELECT * INTO "issue_row" FROM "issue" WHERE "id" = "issue_id_p";
        ELSE
          "new_snapshot_v" := FALSE;
        END IF;
        -- eventually close or accept issues, which have not been accepted:
        IF "issue_row"."accepted" ISNULL THEN
          IF EXISTS (
            SELECT NULL FROM "initiative"
            WHERE "issue_id" = "issue_id_p"
            AND "supporter_count" > 0
            AND "supporter_count" * "policy_row"."issue_quorum_den"
            >= "issue_row"."population" * "policy_row"."issue_quorum_num"
          ) THEN
            -- accept issues, if supporter count is high enough
            PERFORM "set_snapshot_event"("issue_id_p", 'end_of_admission');
            -- NOTE: "issue_row" used later
            "issue_row"."state" := 'discussion';
            "issue_row"."accepted" := now();
            UPDATE "issue" SET
              "state"    = "issue_row"."state",
              "accepted" = "issue_row"."accepted"
              WHERE "id" = "issue_row"."id";
          ELSIF
            now() >= "issue_row"."created" + "issue_row"."admission_time"
          THEN
            -- close issues, if admission time has expired
            PERFORM "set_snapshot_event"("issue_id_p", 'end_of_admission');
            UPDATE "issue" SET
              "state" = 'canceled_issue_not_accepted',
              "closed" = now()
              WHERE "id" = "issue_row"."id";
          END IF;
        END IF;
        -- eventually half freeze issues:
        IF
          -- NOTE: issue can't be closed at this point, if it has been accepted
          "issue_row"."accepted" NOTNULL AND
          "issue_row"."half_frozen" ISNULL
        THEN
          IF
            now() >= "issue_row"."accepted" + "issue_row"."discussion_time"
          THEN
            PERFORM "set_snapshot_event"("issue_id_p", 'half_freeze');
            -- NOTE: "issue_row" used later
            "issue_row"."state" := 'verification';
            "issue_row"."half_frozen" := now();
            UPDATE "issue" SET
              "state"       = "issue_row"."state",
              "half_frozen" = "issue_row"."half_frozen"
              WHERE "id" = "issue_row"."id";
          END IF;
        END IF;
        -- close issues after some time, if all initiatives have been revoked:
        IF
          "issue_row"."closed" ISNULL AND
          NOT EXISTS (
            -- all initiatives are revoked
            SELECT NULL FROM "initiative"
            WHERE "issue_id" = "issue_id_p" AND "revoked" ISNULL
          ) AND (
            -- and issue has not been accepted yet
            "issue_row"."accepted" ISNULL OR
            NOT EXISTS (
              -- or no initiatives have been revoked lately
              SELECT NULL FROM "initiative"
              WHERE "issue_id" = "issue_id_p"
              AND now() < "revoked" + "issue_row"."verification_time"
            ) OR (
              -- or verification time has elapsed
              "issue_row"."half_frozen" NOTNULL AND
              "issue_row"."fully_frozen" ISNULL AND
              now() >= "issue_row"."half_frozen" + "issue_row"."verification_time"
            )
          )
        THEN
          -- NOTE: "issue_row" used later
          IF "issue_row"."accepted" ISNULL THEN
            "issue_row"."state" := 'canceled_revoked_before_accepted';
          ELSIF "issue_row"."half_frozen" ISNULL THEN
            "issue_row"."state" := 'canceled_after_revocation_during_discussion';
          ELSE
            "issue_row"."state" := 'canceled_after_revocation_during_verification';
          END IF;
          "issue_row"."closed" := now();
          UPDATE "issue" SET
            "state"  = "issue_row"."state",
            "closed" = "issue_row"."closed"
            WHERE "id" = "issue_row"."id";
        END IF;
        -- fully freeze issue after verification time:
        IF
          "issue_row"."half_frozen" NOTNULL AND
          "issue_row"."fully_frozen" ISNULL AND
          "issue_row"."closed" ISNULL AND
          now() >= "issue_row"."half_frozen" + "issue_row"."verification_time"
        THEN
          PERFORM "freeze_after_snapshot"("issue_id_p");
          -- NOTE: "issue" might change, thus "issue_row" has to be updated below
        END IF;
        SELECT * INTO "issue_row" FROM "issue" WHERE "id" = "issue_id_p";
        -- close issue by calling close_voting(...) after voting time:
        IF
          "issue_row"."closed" ISNULL AND
          "issue_row"."fully_frozen" NOTNULL AND
          now() >= "issue_row"."fully_frozen" + "issue_row"."voting_time"
        THEN
          PERFORM "close_voting"("issue_id_p");
          -- calculate ranks will not consume much time and can be done now
          PERFORM "calculate_ranks"("issue_id_p");
        END IF;
        -- if a new shapshot has been created, then recalculate harmonic weights:
        IF "new_snapshot_v" THEN
          PERFORM "set_harmonic_initiative_weights"("issue_id_p");
        END IF;
      END IF;
      RETURN;
    END;
  $$;

SELECT "set_harmonic_initiative_weights"("id") FROM "issue";

COMMIT;
