BEGIN;

CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('incomplete_update_from_beta18_to_v1.0.0', NULL, NULL, NULL))
  AS "subquery"("string", "major", "minor", "revision");

ALTER TABLE "issue" RENAME COLUMN "latest_snapshot_event" TO "tmp";
ALTER TABLE "direct_population_snapshot"     RENAME COLUMN "event" TO "tmp";
ALTER TABLE "delegating_population_snapshot" RENAME COLUMN "event" TO "tmp";
ALTER TABLE "direct_interest_snapshot"       RENAME COLUMN "event" TO "tmp";
ALTER TABLE "delegating_interest_snapshot"   RENAME COLUMN "event" TO "tmp";
ALTER TABLE "direct_supporter_snapshot"      RENAME COLUMN "event" TO "tmp";

ALTER TABLE "issue" ADD COLUMN "latest_snapshot_event" TEXT;
ALTER TABLE "direct_population_snapshot"     ADD COLUMN "event" TEXT;
ALTER TABLE "delegating_population_snapshot" ADD COLUMN "event" TEXT;
ALTER TABLE "direct_interest_snapshot"       ADD COLUMN "event" TEXT;
ALTER TABLE "delegating_interest_snapshot"   ADD COLUMN "event" TEXT;
ALTER TABLE "direct_supporter_snapshot"      ADD COLUMN "event" TEXT;

ALTER TABLE "issue" ADD COLUMN "admission_time"    INTERVAL;
ALTER TABLE "issue" ADD COLUMN "discussion_time"   INTERVAL;
ALTER TABLE "issue" ADD COLUMN "verification_time" INTERVAL;
ALTER TABLE "issue" ADD COLUMN "voting_time"       INTERVAL;

UPDATE "issue" SET "latest_snapshot_event"  = "tmp";
UPDATE "direct_population_snapshot"     SET "event" = "tmp";
UPDATE "delegating_population_snapshot" SET "event" = "tmp";
UPDATE "direct_interest_snapshot"       SET "event" = "tmp";
UPDATE "delegating_interest_snapshot"   SET "event" = "tmp";
UPDATE "direct_supporter_snapshot"      SET "event" = "tmp";

UPDATE "issue" SET "latest_snapshot_event" = 'full_freeze' WHERE "latest_snapshot_event" = 'start_of_voting';
UPDATE "direct_population_snapshot"     SET "event" = 'full_freeze' WHERE "event" = 'start_of_voting';
UPDATE "delegating_population_snapshot" SET "event" = 'full_freeze' WHERE "event" = 'start_of_voting';
UPDATE "direct_interest_snapshot"       SET "event" = 'full_freeze' WHERE "event" = 'start_of_voting';
UPDATE "delegating_interest_snapshot"   SET "event" = 'full_freeze' WHERE "event" = 'start_of_voting';
UPDATE "direct_supporter_snapshot"      SET "event" = 'full_freeze' WHERE "event" = 'start_of_voting';

UPDATE "issue" SET
  "admission_time"    = "policy"."admission_time",
  "discussion_time"   = "policy"."discussion_time",
  "verification_time" = "policy"."verification_time",
  "voting_time"       = "policy"."voting_time"
  FROM "policy" WHERE "issue"."policy_id" = "policy"."id";

-- remove "tmp" columns indirectly
DROP TYPE "snapshot_event" CASCADE;

COMMIT;

-- Complete the update as follows:
-- =========================================
-- pg_dump --disable-triggers --data-only DATABASE_NAME > tmp.sql
-- dropdb DATABASE_NAME
-- createdb DATABASE_NAME
-- psql -v ON_ERROR_STOP=1 -f core.sql DATABASE_NAME
-- psql -v ON_ERROR_STOP=1 -f tmp.sql DATABASE_NAME
-- rm tmp.sql

