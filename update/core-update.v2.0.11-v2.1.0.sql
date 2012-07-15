BEGIN;

CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('2.1.0', 2, 1, 0))
  AS "subquery"("string", "major", "minor", "revision");

ALTER TABLE "policy" ADD COLUMN "polling" BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE "policy" ALTER COLUMN "admission_time"    DROP NOT NULL;
ALTER TABLE "policy" ALTER COLUMN "discussion_time"   DROP NOT NULL;
ALTER TABLE "policy" ALTER COLUMN "verification_time" DROP NOT NULL;
ALTER TABLE "policy" ALTER COLUMN "voting_time"       DROP NOT NULL;
ALTER TABLE "policy" ADD CONSTRAINT "timing" CHECK (
          ( "polling" = FALSE AND
            "admission_time" NOTNULL AND "discussion_time" NOTNULL AND
            "verification_time" NOTNULL AND "voting_time" NOTNULL ) OR
          ( "polling" = TRUE AND
            "admission_time" NOTNULL AND "discussion_time" NOTNULL AND
            "verification_time" NOTNULL AND "voting_time" NOTNULL ) OR
          ( "polling" = TRUE AND
            "admission_time" ISNULL AND "discussion_time" ISNULL AND
            "verification_time" ISNULL AND "voting_time" ISNULL ) );
COMMENT ON COLUMN "policy"."polling" IS 'TRUE = special policy for non-user-generated issues, i.e. polls (time values may be set to NULL, allowing individual timing for issues)';

ALTER TABLE "initiative" ADD COLUMN "polling" BOOLEAN NOT NULL DEFAULT FALSE;
COMMENT ON COLUMN "initiative"."polling" IS 'Initiative is an option for a poll (see "policy"."polling"), and does not need to pass the initiative quorum';

ALTER TABLE "privilege" RENAME COLUMN "voting_right_manager" TO "member_manager";
ALTER TABLE "privilege" ADD COLUMN "initiative_right" BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE "privilege" ADD COLUMN "polling_right"    BOOLEAN NOT NULL DEFAULT FALSE;
UPDATE "privilege" SET "initiative_right" = "voting_right";
COMMENT ON COLUMN "privilege"."admin_manager"    IS 'Grant/revoke any privileges to/from other members';
COMMENT ON COLUMN "privilege"."member_manager"   IS 'Adding/removing members from the unit, granting or revoking "initiative_right" and "voting_right"';
COMMENT ON COLUMN "privilege"."initiative_right" IS 'Right to create an initiative';
COMMENT ON COLUMN "privilege"."voting_right"     IS 'Right to support initiatives, create and rate suggestions, and to vote';
COMMENT ON COLUMN "privilege"."polling_right"    IS 'Right to create polls (see "policy"."polling" and "initiative"."polling")';

DROP TABLE "rendered_issue_comment";
DROP TABLE "issue_comment";

CREATE OR REPLACE FUNCTION "freeze_after_snapshot"
  ( "issue_id_p" "issue"."id"%TYPE )
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    DECLARE
      "issue_row"      "issue"%ROWTYPE;
      "policy_row"     "policy"%ROWTYPE;
      "initiative_row" "initiative"%ROWTYPE;
    BEGIN
      SELECT * INTO "issue_row" FROM "issue" WHERE "id" = "issue_id_p";
      SELECT * INTO "policy_row"
        FROM "policy" WHERE "id" = "issue_row"."policy_id";
      PERFORM "set_snapshot_event"("issue_id_p", 'full_freeze');
      FOR "initiative_row" IN
        SELECT * FROM "initiative"
        WHERE "issue_id" = "issue_id_p" AND "revoked" ISNULL
      LOOP
        IF
          "initiative_row"."polling" OR (
            "initiative_row"."satisfied_supporter_count" > 0 AND
            "initiative_row"."satisfied_supporter_count" *
            "policy_row"."initiative_quorum_den" >=
            "issue_row"."population" * "policy_row"."initiative_quorum_num"
          )
        THEN
          UPDATE "initiative" SET "admitted" = TRUE
            WHERE "id" = "initiative_row"."id";
        ELSE
          UPDATE "initiative" SET "admitted" = FALSE
            WHERE "id" = "initiative_row"."id";
        END IF;
      END LOOP;
      IF EXISTS (
        SELECT NULL FROM "initiative"
        WHERE "issue_id" = "issue_id_p" AND "admitted" = TRUE
      ) THEN
        UPDATE "issue" SET
          "state"        = 'voting',
          "accepted"     = coalesce("accepted", now()),
          "half_frozen"  = coalesce("half_frozen", now()),
          "fully_frozen" = now()
          WHERE "id" = "issue_id_p";
      ELSE
        UPDATE "issue" SET
          "state"           = 'canceled_no_initiative_admitted',
          "accepted"        = coalesce("accepted", now()),
          "half_frozen"     = coalesce("half_frozen", now()),
          "fully_frozen"    = now(),
          "closed"          = now(),
          "ranks_available" = TRUE
          WHERE "id" = "issue_id_p";
        -- NOTE: The following DELETE statements have effect only when
        --       issue state has been manipulated
        DELETE FROM "direct_voter"     WHERE "issue_id" = "issue_id_p";
        DELETE FROM "delegating_voter" WHERE "issue_id" = "issue_id_p";
        DELETE FROM "battle"           WHERE "issue_id" = "issue_id_p";
      END IF;
      RETURN;
    END;
  $$;

CREATE OR REPLACE FUNCTION "clean_issue"("issue_id_p" "issue"."id"%TYPE)
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    DECLARE
      "issue_row" "issue"%ROWTYPE;
    BEGIN
      SELECT * INTO "issue_row"
        FROM "issue" WHERE "id" = "issue_id_p"
        FOR UPDATE;
      IF "issue_row"."cleaned" ISNULL THEN
        UPDATE "issue" SET
          "state"           = 'voting',
          "closed"          = NULL,
          "ranks_available" = FALSE
          WHERE "id" = "issue_id_p";
        DELETE FROM "voting_comment"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "delegating_voter"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "direct_voter"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "delegating_interest_snapshot"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "direct_interest_snapshot"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "delegating_population_snapshot"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "direct_population_snapshot"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "non_voter"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "delegation"
          WHERE "issue_id" = "issue_id_p";
        DELETE FROM "supporter"
          WHERE "issue_id" = "issue_id_p";
        UPDATE "issue" SET
          "state"           = "issue_row"."state",
          "closed"          = "issue_row"."closed",
          "ranks_available" = "issue_row"."ranks_available",
          "cleaned"         = now()
          WHERE "id" = "issue_id_p";
      END IF;
      RETURN;
    END;
  $$;

COMMIT;
