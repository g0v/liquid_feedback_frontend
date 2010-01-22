
CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('beta17', NULL, NULL, NULL))
  AS "subquery"("string", "major", "minor", "revision");

COMMENT ON TABLE "setting" IS 'Place to store a frontend specific member setting as a string';

CREATE TABLE "setting_map" (
        PRIMARY KEY ("member_id", "key", "subkey"),
        "member_id"             INT4            REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
        "key"                   TEXT            NOT NULL,
        "subkey"                TEXT            NOT NULL,
        "value"                 TEXT            NOT NULL );
CREATE INDEX "setting_map_key_idx" ON "setting_map" ("key");

COMMENT ON TABLE "setting_map" IS 'Place to store a frontend specific member setting as a map of key value pairs';

COMMENT ON COLUMN "setting_map"."key"    IS 'Name of the setting, preceded by a frontend specific prefix';
COMMENT ON COLUMN "setting_map"."subkey" IS 'Key of a map entry';
COMMENT ON COLUMN "setting_map"."value"  IS 'Value of a map entry';

CREATE INDEX "issue_created_idx" ON "issue" ("created");
CREATE INDEX "issue_accepted_idx" ON "issue" ("accepted");
CREATE INDEX "issue_half_frozen_idx" ON "issue" ("half_frozen");
CREATE INDEX "issue_fully_frozen_idx" ON "issue" ("fully_frozen");
CREATE INDEX "issue_closed_idx" ON "issue" ("closed");
CREATE INDEX "issue_closed_idx_canceled" ON "issue" ("closed") WHERE "fully_frozen" ISNULL;
CREATE INDEX "initiative_created_idx" ON "initiative" ("created");
CREATE INDEX "initiative_revoked_idx" ON "initiative" ("revoked");
CREATE INDEX "draft_created_idx" ON "draft" ("created");
CREATE INDEX "suggestion_created_idx" ON "suggestion" ("created");

CREATE TYPE "timeline_event" AS ENUM (
  'issue_created',
  'issue_canceled',
  'issue_accepted',
  'issue_half_frozen',
  'issue_finished_without_voting',
  'issue_voting_started',
  'issue_finished_after_voting',
  'initiative_created',
  'initiative_revoked',
  'draft_created',
  'suggestion_created');

COMMENT ON TYPE "timeline_event" IS 'Types of event in timeline tables';

CREATE VIEW "timeline_issue" AS
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
    WHERE "fully_frozen" NOTNULL AND "closed" != "fully_frozen"
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

COMMENT ON VIEW "timeline_issue" IS 'Helper view for "timeline" view';

CREATE VIEW "timeline_initiative" AS
    SELECT
      "created" AS "occurrence",
      'initiative_created'::"timeline_event" AS "event",
      "id" AS "initiative_id"
    FROM "initiative"
  UNION ALL
    SELECT
      "revoked" AS "occurrence",
      'initiative_revoked'::"timeline_event" AS "event",
      "id" AS "initiative_id"
    FROM "initiative" WHERE "revoked" NOTNULL;

COMMENT ON VIEW "timeline_initiative" IS 'Helper view for "timeline" view';

CREATE VIEW "timeline_draft" AS
  SELECT
    "created" AS "occurrence",
    'draft_created'::"timeline_event" AS "event",
    "id" AS "draft_id"
  FROM "draft";

COMMENT ON VIEW "timeline_draft" IS 'Helper view for "timeline" view';

CREATE VIEW "timeline_suggestion" AS
  SELECT
    "created" AS "occurrence",
    'suggestion_created'::"timeline_event" AS "event",
    "id" AS "suggestion_id"
  FROM "suggestion";

COMMENT ON VIEW "timeline_suggestion" IS 'Helper view for "timeline" view';

CREATE VIEW "timeline" AS
    SELECT
      "occurrence",
      "event",
      "issue_id",
      NULL AS "initiative_id",
      NULL::INT8 AS "draft_id",  -- TODO: Why do we need a type-cast here? Is this due to 32 bit architecture?
      NULL::INT8 AS "suggestion_id"
    FROM "timeline_issue"
  UNION ALL
    SELECT
      "occurrence",
      "event",
      NULL AS "issue_id",
      "initiative_id",
      NULL AS "draft_id",
      NULL AS "suggestion_id"
    FROM "timeline_initiative"
  UNION ALL
    SELECT
      "occurrence",
      "event",
      NULL AS "issue_id",
      NULL AS "initiative_id",
      "draft_id",
      NULL AS "suggestion_id"
    FROM "timeline_draft"
  UNION ALL
    SELECT
      "occurrence",
      "event",
      NULL AS "issue_id",
      NULL AS "initiative_id",
      NULL AS "draft_id",
      "suggestion_id"
    FROM "timeline_suggestion";

COMMENT ON VIEW "timeline" IS 'Aggregation of different events in the system';

