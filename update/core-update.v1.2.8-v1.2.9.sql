BEGIN;
 
CREATE OR REPLACE VIEW "liquid_feedback_version" AS
  SELECT * FROM (VALUES ('1.2.9', 1, 2, 9))
  AS "subquery"("string", "major", "minor", "revision");


ALTER TABLE "supporter" ADD "auto_support" BOOLEAN NOT NULL DEFAULT 'f';

CREATE FUNCTION VOLATILE update_supporter_drafts()
  RETURNS trigger
  LANGUAGE 'plpgsql' AS $$
  BEGIN
    UPDATE supporter SET draft_id = NEW.id 
    WHERE initiative_id = NEW.initiative_id AND
          (auto_support = 't' OR member_id = NEW.author_id);
    RETURN new;
  END
$$;

COMMENT ON FUNCTION "update_supporter_drafts"() IS 'Automaticly update the supported draft_id to the latest version when auto_support is enabled';

CREATE TRIGGER "update_draft_supporter"
  AFTER INSERT ON "draft"
  FOR EACH ROW EXECUTE PROCEDURE
  update_supporter_drafts();

CREATE FUNCTION "check_delegation"()
  RETURNS TRIGGER
  LANGUAGE 'plpgsql' VOLATILE AS $$
  BEGIN
    IF EXISTS (
      SELECT NULL FROM "member" WHERE 
        "id" = NEW."trustee_id" AND active = 'n'
    ) THEN
      RAISE EXCEPTION 'Cannot delegate to an inactive member';
    END IF;
    RETURN NEW;
  END;
$$;

CREATE TRIGGER "update_delegation"
  BEFORE INSERT OR UPDATE ON "delegation"
  FOR EACH ROW EXECUTE PROCEDURE
  check_delegation();

CREATE OR REPLACE FUNCTION "delete_member"("member_id_p" "member"."id"%TYPE)
  RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    BEGIN
      UPDATE "member" SET
        "last_login"                   = NULL,
        "login"                        = NULL,
        "password"                     = NULL,
        "active"                       = FALSE,
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
        "statement"                    = NULL
        WHERE "id" = "member_id_p";
      -- "text_search_data" is updated by triggers
      DELETE FROM "setting"            WHERE "member_id" = "member_id_p";
      DELETE FROM "setting_map"        WHERE "member_id" = "member_id_p";
      DELETE FROM "member_relation_setting" WHERE "member_id" = "member_id_p";
      DELETE FROM "member_image"       WHERE "member_id" = "member_id_p";
      DELETE FROM "contact"            WHERE "member_id" = "member_id_p";
      DELETE FROM "area_setting"       WHERE "member_id" = "member_id_p";
      DELETE FROM "issue_setting"      WHERE "member_id" = "member_id_p";
      DELETE FROM "initiative_setting" WHERE "member_id" = "member_id_p";
      DELETE FROM "suggestion_setting" WHERE "member_id" = "member_id_p";
      DELETE FROM "membership"         WHERE "member_id" = "member_id_p";
      DELETE FROM "delegation"         WHERE "truster_id" = "member_id_p";
      DELETE FROM "delegation"         WHERE "trustee_id" = "member_id_p";
      DELETE FROM "direct_voter" USING "issue"
        WHERE "direct_voter"."issue_id" = "issue"."id"
        AND "issue"."closed" ISNULL
        AND "member_id" = "member_id_p";
      RETURN;
    END;
  $$;

COMMENT ON FUNCTION "delete_member"("member_id_p" "member"."id"%TYPE) IS 'Deactivate member and clear certain settings and data of this member (data protection)';

CREATE INDEX "initiative_issue_id_idx" ON "initiative" ("issue_id");

COMMIT;
