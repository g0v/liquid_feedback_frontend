BEGIN;

CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('beta18', NULL, NULL, NULL))
  AS "subquery"("string", "major", "minor", "revision");

CREATE OR REPLACE VIEW "timeline_issue" AS
    SELECT
      "created" AS "occurrence",
      'issue_created'::"timeline_event" AS "event",
      "id" AS "issue_id"
    FROM "issue"
  UNION ALL
    SELECT
      "closed" AS "occurrence",
      'issue_canceled'::"timeline_event" AS "event",
      "id" AS "issue_id"
    FROM "issue" WHERE "closed" NOTNULL AND "fully_frozen" ISNULL
  UNION ALL
    SELECT
      "accepted" AS "occurrence",
      'issue_accepted'::"timeline_event" AS "event",
      "id" AS "issue_id"
    FROM "issue" WHERE "accepted" NOTNULL
  UNION ALL
    SELECT
      "half_frozen" AS "occurrence",
      'issue_half_frozen'::"timeline_event" AS "event",
      "id" AS "issue_id"
    FROM "issue" WHERE "half_frozen" NOTNULL
  UNION ALL
    SELECT
      "fully_frozen" AS "occurrence",
      'issue_voting_started'::"timeline_event" AS "event",
      "id" AS "issue_id"
    FROM "issue"
    WHERE "fully_frozen" NOTNULL
    AND ("closed" ISNULL OR "closed" != "fully_frozen")
  UNION ALL
    SELECT
      "closed" AS "occurrence",
      CASE WHEN "fully_frozen" = "closed" THEN
        'issue_finished_without_voting'::"timeline_event"
      ELSE
        'issue_finished_after_voting'::"timeline_event"
      END AS "event",
      "id" AS "issue_id"
    FROM "issue" WHERE "closed" NOTNULL AND "fully_frozen" NOTNULL;

COMMIT;
