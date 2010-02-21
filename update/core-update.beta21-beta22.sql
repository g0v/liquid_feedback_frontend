BEGIN;
CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('beta22', NULL, NULL, NULL))
  AS "subquery"("string", "major", "minor", "revision");
ALTER TABLE "issue" DROP CONSTRAINT "valid_state";
ALTER TABLE "issue" ADD CONSTRAINT "valid_state" CHECK (
  ("accepted" ISNULL  AND "half_frozen" ISNULL  AND "fully_frozen" ISNULL  AND "closed" ISNULL  AND "ranks_available" = FALSE) OR
  ("accepted" ISNULL  AND "half_frozen" ISNULL  AND "fully_frozen" ISNULL  AND "closed" NOTNULL AND "ranks_available" = FALSE) OR
  ("accepted" NOTNULL AND "half_frozen" ISNULL  AND "fully_frozen" ISNULL  AND "closed" ISNULL  AND "ranks_available" = FALSE) OR
  ("accepted" NOTNULL AND "half_frozen" ISNULL  AND "fully_frozen" ISNULL  AND "closed" NOTNULL AND "ranks_available" = FALSE) OR
  ("accepted" NOTNULL AND "half_frozen" NOTNULL AND "fully_frozen" ISNULL  AND "closed" ISNULL  AND "ranks_available" = FALSE) OR
  ("accepted" NOTNULL AND "half_frozen" NOTNULL AND "fully_frozen" ISNULL  AND "closed" NOTNULL AND "ranks_available" = FALSE) OR
  ("accepted" NOTNULL AND "half_frozen" NOTNULL AND "fully_frozen" NOTNULL AND "closed" ISNULL  AND "ranks_available" = FALSE) OR
  ("accepted" NOTNULL AND "half_frozen" NOTNULL AND "fully_frozen" NOTNULL AND "closed" NOTNULL AND "ranks_available" = FALSE) OR
  ("accepted" NOTNULL AND "half_frozen" NOTNULL AND "fully_frozen" NOTNULL AND "closed" NOTNULL AND "ranks_available" = TRUE) );
COMMIT;
