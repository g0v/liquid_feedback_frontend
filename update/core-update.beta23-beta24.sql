BEGIN;

CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('beta24', NULL, NULL, NULL))
  AS "subquery"("string", "major", "minor", "revision");

COMMENT ON TABLE "setting" IS 'Place to store a frontend specific setting for members as a string';

COMMENT ON TABLE "member_relation_setting" IS 'Place to store a frontend specific setting related to relations between members as a string';

CREATE OR REPLACE FUNCTION "delete_private_data"()
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    DECLARE
      "issue_id_v" "issue"."id"%TYPE;
    BEGIN
      UPDATE "member" SET
        "login"                        = 'login' || "id"::text,
        "password"                     = NULL,
        "notify_email"                 = NULL,
        "notify_email_unconfirmed"     = NULL,
        "notify_email_secret"          = NULL,
        "notify_email_secret_expiry"   = NULL,
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
      UPDATE "member_history" SET "login" = 'login' || "member_id"::text;
      DELETE FROM "invite_code";
      DELETE FROM "setting";
      DELETE FROM "setting_map";
      DELETE FROM "member_relation_setting";
      DELETE FROM "member_image";
      DELETE FROM "contact";
      DELETE FROM "session";
      DELETE FROM "area_setting";
      DELETE FROM "issue_setting";
      DELETE FROM "initiative_setting";
      DELETE FROM "suggestion_setting";
      DELETE FROM "direct_voter" USING "issue"
        WHERE "direct_voter"."issue_id" = "issue"."id"
        AND "issue"."closed" ISNULL;
      RETURN;
    END;
  $$;

COMMIT;
