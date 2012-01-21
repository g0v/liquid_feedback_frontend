BEGIN;

CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('2.0.1', 2, 0, 1))
  AS "subquery"("string", "major", "minor", "revision");

ALTER TABLE "issue" ALTER "state" SET DEFAULT 'admission';  -- fixes wrong update script from v1.3.1 to v1.4.0

COMMENT ON COLUMN "member"."activated" IS 'Timestamp of first activation of account (i.e. usage of "invite_code"); required to be set for "active" members';
COMMENT ON COLUMN "member"."statement" IS 'Freely chosen text of the member for his/her profile';

COMMENT ON COLUMN "policy"."admission_time"    IS 'Maximum duration of issue state ''admission''; Maximum time an issue stays open without being "accepted"';
COMMENT ON COLUMN "policy"."discussion_time"   IS 'Duration of issue state ''discussion''; Regular time until an issue is "half_frozen" after being "accepted"';
COMMENT ON COLUMN "policy"."verification_time" IS 'Duration of issue state ''verification''; Regular time until an issue is "fully_frozen" (e.g. entering issue state ''voting'') after being "half_frozen"';
COMMENT ON COLUMN "policy"."voting_time"       IS 'Duration of issue state ''voting''; Time after an issue is "fully_frozen" but not "closed" (duration of issue state ''voting'')';
COMMENT ON COLUMN "policy"."issue_quorum_num"  IS   'Numerator of potential supporter quorum to be reached by one initiative of an issue to be "accepted" and enter issue state ''discussion''';
COMMENT ON COLUMN "policy"."issue_quorum_den"  IS 'Denominator of potential supporter quorum to be reached by one initiative of an issue to be "accepted" and enter issue state ''discussion''';

COMMENT ON COLUMN "unit"."active" IS 'TRUE means new issues can be created in areas of this area';

CREATE TABLE "unit_setting" (
        PRIMARY KEY ("member_id", "key", "unit_id"),
        "member_id"             INT4            REFERENCES "member" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
        "key"                   TEXT            NOT NULL,
        "unit_id"               INT4            REFERENCES "unit" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
        "value"                 TEXT            NOT NULL );

COMMENT ON TABLE "unit_setting" IS 'Place for frontend to store unit specific settings of members as strings';

COMMENT ON COLUMN "initiative"."discussion_url"         IS 'URL pointing to a discussion platform for this initiative';
COMMENT ON COLUMN "initiative"."revoked"                IS 'Point in time, when one initiator decided to revoke the initiative';
COMMENT ON COLUMN "initiative"."revoked_by_member_id"   IS 'Member, who decided to revoke the initiative';
COMMENT ON COLUMN "initiative"."admitted"               IS 'TRUE, if initiative reaches the "initiative_quorum" when freezing the issue';
COMMENT ON COLUMN "initiative"."positive_votes"         IS 'Calculated from table "direct_voter"';
COMMENT ON COLUMN "initiative"."negative_votes"         IS 'Calculated from table "direct_voter"';
COMMENT ON COLUMN "initiative"."direct_majority"        IS 'TRUE, if "positive_votes"/("positive_votes"+"negative_votes") is strictly greater or greater-equal than "direct_majority_num"/"direct_majority_den", and "positive_votes" is greater-equal than "direct_majority_positive", and ("positive_votes"+abstentions) is greater-equal than "direct_majority_non_negative"';
COMMENT ON COLUMN "initiative"."indirect_majority"      IS 'Same as "direct_majority", but also considering indirect beat paths';
COMMENT ON COLUMN "initiative"."schulze_rank"           IS 'Schulze-Ranking without tie-breaking';
COMMENT ON COLUMN "initiative"."better_than_status_quo" IS 'TRUE, if initiative has a schulze-ranking better than the status quo (without tie-breaking)';
COMMENT ON COLUMN "initiative"."worse_than_status_quo"  IS 'TRUE, if initiative has a schulze-ranking worse than the status quo (without tie-breaking)';
COMMENT ON COLUMN "initiative"."reverse_beat_path"      IS 'TRUE, if there is a beat path (may include ties) from this initiative to the status quo';
COMMENT ON COLUMN "initiative"."multistage_majority"    IS 'TRUE, if either (a) this initiative has no better rank than the status quo, or (b) there exists a better ranked initiative X, which directly beats this initiative, and either more voters prefer X to this initiative than voters preferring X to the status quo or less voters prefer this initiative to X than voters preferring the status quo to X';
COMMENT ON COLUMN "initiative"."eligible"               IS 'Initiative has a "direct_majority" and an "indirect_majority", is "better_than_status_quo" and depending on selected policy the initiative has no "reverse_beat_path" or "multistage_majority"';
COMMENT ON COLUMN "initiative"."winner"                 IS 'Winner is the "eligible" initiative with best "schulze_rank" and in case of ties with lowest "id"';
COMMENT ON COLUMN "initiative"."rank"                   IS 'Unique ranking for all "admitted" initiatives per issue; lower rank is better; a winner always has rank 1, but rank 1 does not imply that an initiative is winner; initiatives with "direct_majority" AND "indirect_majority" always have a better (lower) rank than other initiatives';

COMMENT ON COLUMN "privilege"."admin_manager"        IS 'Grant/revoke admin privileges to/from other members';
COMMENT ON COLUMN "privilege"."unit_manager"         IS 'Create and disable sub units';
COMMENT ON COLUMN "privilege"."area_manager"         IS 'Create and disable areas and set area parameters';
COMMENT ON COLUMN "privilege"."voting_right_manager" IS 'Select which members are allowed to discuss and vote within the unit';

COMMENT ON COLUMN "supporter"."issue_id" IS 'WARNING: No index: For selections use column "initiative_id" and join via table "initiative" where neccessary';

ALTER TABLE "direct_supporter_snapshot" ADD COLUMN "draft_id" INT8;

UPDATE "direct_supporter_snapshot" SET "draft_id" = "supporter"."draft_id" FROM "supporter" WHERE "direct_supporter_snapshot"."initiative_id" = "supporter"."initiative_id" AND "direct_supporter_snapshot"."member_id" = "supporter"."member_id";
UPDATE "direct_supporter_snapshot" SET "draft_id" = "current_draft"."id" FROM "current_draft" WHERE "direct_supporter_snapshot"."initiative_id" = "current_draft"."initiative_id" AND "direct_supporter_snapshot"."draft_id" ISNULL;

ALTER TABLE "direct_supporter_snapshot" ADD FOREIGN KEY ("initiative_id", "draft_id") REFERENCES "draft" ("initiative_id", "id") ON DELETE NO ACTION ON UPDATE CASCADE;
ALTER TABLE "direct_supporter_snapshot" ALTER COLUMN "draft_id" SET NOT NULL;

COMMENT ON COLUMN "direct_supporter_snapshot"."issue_id"  IS 'WARNING: No index: For selections use column "initiative_id" and join via table "initiative" where neccessary';

COMMENT ON COLUMN "direct_voter"."weight" IS 'Weight of member (1 or higher) according to "delegating_voter" table';

COMMENT ON COLUMN "vote"."issue_id" IS 'WARNING: No index: For selections use column "initiative_id" and join via table "initiative" where neccessary';
COMMENT ON COLUMN "vote"."grade"    IS 'Values smaller than zero mean reject, values greater than zero mean acceptance, zero or missing row means abstention. Preferences are expressed by different positive or negative numbers.';

CREATE OR REPLACE FUNCTION "create_interest_snapshot"
  ( "issue_id_p" "issue"."id"%TYPE )
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    DECLARE
      "member_id_v" "member"."id"%TYPE;
    BEGIN
      DELETE FROM "direct_interest_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic';
      DELETE FROM "delegating_interest_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic';
      DELETE FROM "direct_supporter_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic';
      INSERT INTO "direct_interest_snapshot"
        ("issue_id", "event", "member_id")
        SELECT
          "issue_id_p"  AS "issue_id",
          'periodic'    AS "event",
          "member"."id" AS "member_id"
        FROM "issue"
        JOIN "area" ON "issue"."area_id" = "area"."id"
        JOIN "interest" ON "issue"."id" = "interest"."issue_id"
        JOIN "member" ON "interest"."member_id" = "member"."id"
        JOIN "privilege"
          ON "privilege"."unit_id" = "area"."unit_id"
          AND "privilege"."member_id" = "member"."id"
        WHERE "issue"."id" = "issue_id_p"
        AND "member"."active" AND "privilege"."voting_right";
      FOR "member_id_v" IN
        SELECT "member_id" FROM "direct_interest_snapshot"
        WHERE "issue_id" = "issue_id_p"
        AND "event" = 'periodic'
      LOOP
        UPDATE "direct_interest_snapshot" SET
          "weight" = 1 +
            "weight_of_added_delegations_for_interest_snapshot"(
              "issue_id_p",
              "member_id_v",
              '{}'
            )
          WHERE "issue_id" = "issue_id_p"
          AND "event" = 'periodic'
          AND "member_id" = "member_id_v";
      END LOOP;
       INSERT INTO "direct_supporter_snapshot"
        ( "issue_id", "initiative_id", "event", "member_id",
          "draft_id", "informed", "satisfied" )
        SELECT
          "issue_id_p"            AS "issue_id",
          "initiative"."id"       AS "initiative_id",
          'periodic'              AS "event",
          "supporter"."member_id" AS "member_id",
          "supporter"."draft_id"  AS "draft_id",
          "supporter"."draft_id" = "current_draft"."id" AS "informed",
          NOT EXISTS (
            SELECT NULL FROM "critical_opinion"
            WHERE "initiative_id" = "initiative"."id"
            AND "member_id" = "supporter"."member_id"
          ) AS "satisfied"
        FROM "initiative"
        JOIN "supporter"
        ON "supporter"."initiative_id" = "initiative"."id"
        JOIN "current_draft"
        ON "initiative"."id" = "current_draft"."initiative_id"
        JOIN "direct_interest_snapshot"
        ON "supporter"."member_id" = "direct_interest_snapshot"."member_id"
        AND "initiative"."issue_id" = "direct_interest_snapshot"."issue_id"
        AND "event" = 'periodic'
        WHERE "initiative"."issue_id" = "issue_id_p";
      RETURN;
    END;
  $$;

CREATE OR REPLACE FUNCTION "delete_private_data"()
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    BEGIN
      UPDATE "member" SET
        "invite_code"                  = NULL,
        "last_login"                   = NULL,
        "login"                        = NULL,
        "password"                     = NULL,
        "notify_email"                 = NULL,
        "notify_email_unconfirmed"     = NULL,
        "notify_email_secret"          = NULL,
        "notify_email_secret_expiry"   = NULL,
        "notify_email_lock_expiry"     = NULL,
        "password_reset_secret"        = NULL,
        "password_reset_secret_expiry" = NULL,
        "organizational_unit"          = NULL,
        "internal_posts"               = NULL,
        "realname"                     = NULL,
        "birthday"                     = NULL,
        "address"                      = NULL,
        "email"                        = NULL,
        "xmpp_address"                 = NULL,
        "website"                      = NULL,
        "phone"                        = NULL,
        "mobile_phone"                 = NULL,
        "profession"                   = NULL,
        "external_memberships"         = NULL,
        "external_posts"               = NULL,
        "statement"                    = NULL;
      -- "text_search_data" is updated by triggers
      DELETE FROM "setting";
      DELETE FROM "setting_map";
      DELETE FROM "member_relation_setting";
      DELETE FROM "member_image";
      DELETE FROM "contact";
      DELETE FROM "ignored_member";
      DELETE FROM "area_setting";
      DELETE FROM "issue_setting";
      DELETE FROM "ignored_initiative";
      DELETE FROM "initiative_setting";
      DELETE FROM "suggestion_setting";
      DELETE FROM "non_voter";
      DELETE FROM "direct_voter" USING "issue"
        WHERE "direct_voter"."issue_id" = "issue"."id"
        AND "issue"."closed" ISNULL;
      RETURN;
    END;
  $$;

COMMIT;
