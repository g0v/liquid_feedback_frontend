BEGIN;
 
CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('1.2.9', 1, 2, 9))
  AS "subquery"("string", "major", "minor", "revision");

ALTER TABLE "supporter" ADD COLUMN
  "auto_support" BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;
