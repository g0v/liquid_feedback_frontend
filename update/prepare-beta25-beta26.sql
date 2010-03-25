BEGIN;

CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('incomplete_update_from_beta25_to_beta26', NULL, NULL, NULL))
  AS "subquery"("string", "major", "minor", "revision");

ALTER TABLE "member" ADD COLUMN "last_login" TIMESTAMPTZ;
ALTER TABLE "member_history" ADD COLUMN "active" BOOLEAN;

UPDATE "member_history" SET "active" = TRUE;
INSERT INTO "member_history" ("member_id", "login", "active", "name")
  SELECT "id", "login", TRUE AS "active", "name"
  FROM "member" WHERE "active" = FALSE;

COMMIT;

-- Complete the update as follows:
-- =========================================
-- pg_dump --disable-triggers --data-only DATABASE_NAME > tmp.sql
-- dropdb DATABASE_NAME
-- createdb DATABASE_NAME
-- psql -v ON_ERROR_STOP=1 -f core.sql DATABASE_NAME
-- psql -v ON_ERROR_STOP=1 -f tmp.sql DATABASE_NAME
-- rm tmp.sql

