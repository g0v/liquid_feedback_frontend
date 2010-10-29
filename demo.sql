-- NOTE: This file requires that sequence generators have not been used.
-- (All new rows need to start with id '1'.)

BEGIN;

INSERT INTO "member" ("login", "name") VALUES
  ('user1',  'User #1'),   -- id  1
  ('user2',  'User #2'),   -- id  2
  ('user3',  'User #3'),   -- id  3
  ('user4',  'User #4'),   -- id  4
  ('user5',  'User #5'),   -- id  5
  ('user6',  'User #6'),   -- id  6
  ('user7',  'User #7'),   -- id  7
  ('user8',  'User #8'),   -- id  8
  ('user9',  'User #9'),   -- id  9
  ('user10', 'User #10'),  -- id 10
  ('user11', 'User #11'),  -- id 11
  ('user12', 'User #12'),  -- id 12
  ('user13', 'User #13'),  -- id 13
  ('user14', 'User #14'),  -- id 14
  ('user15', 'User #15'),  -- id 15
  ('user16', 'User #16'),  -- id 16
  ('user17', 'User #17'),  -- id 17
  ('user18', 'User #18'),  -- id 18
  ('user19', 'User #19'),  -- id 19
  ('user20', 'User #20'),  -- id 20
  ('user21', 'User #21'),  -- id 21
  ('user22', 'User #22'),  -- id 22
  ('user23', 'User #23');  -- id 23

-- set password to "login"
UPDATE "member" SET "password" = '$1$PcI6b1Bg$2SHjAZH2nMLFp0fxHis.Q0';

INSERT INTO "policy" (
        "index",
        "name",
        "admission_time",
        "discussion_time",
        "verification_time",
        "voting_time",
        "issue_quorum_num", "issue_quorum_den",
        "initiative_quorum_num", "initiative_quorum_den"
    ) VALUES (
        1,
        'Default policy',
        '1 hour', '1 hour', '1 hour', '1 hour',
        25, 100,
        20, 100 );

CREATE FUNCTION "time_warp"() RETURNS VOID
  LANGUAGE 'plpgsql' VOLATILE AS $$
    BEGIN
      UPDATE "issue" SET
        "snapshot"     = "snapshot"     - '1 hour 1 minute'::INTERVAL,
        "created"      = "created"      - '1 hour 1 minute'::INTERVAL,
        "accepted"     = "accepted"     - '1 hour 1 minute'::INTERVAL,
        "half_frozen"  = "half_frozen"  - '1 hour 1 minute'::INTERVAL,
        "fully_frozen" = "fully_frozen" - '1 hour 1 minute'::INTERVAL;
      PERFORM "check_everything"();
      RETURN;
    END;
  $$;

INSERT INTO "area" ("name") VALUES
  ('Area #1'),  -- id 1
  ('Area #2'),  -- id 2
  ('Area #3'),  -- id 3
  ('Area #4');  -- id 4

INSERT INTO "allowed_policy" ("area_id", "policy_id", "default_policy")
  VALUES (1, 1, TRUE), (2, 1, TRUE), (3, 1, TRUE), (4, 1, TRUE);

INSERT INTO "membership" ("area_id", "member_id", "autoreject") VALUES
  (1,  9, FALSE),
  (1, 19, FALSE),
  (2,  9, TRUE),
  (2, 10, TRUE),
  (2, 17, TRUE),
  (3,  9, FALSE),
  (3, 11, FALSE),
  (3, 12, TRUE),
  (3, 14, FALSE),
  (3, 20, FALSE),
  (3, 21, TRUE),
  (3, 22, TRUE),
  (4,  6, FALSE),
  (4,  9, FALSE),
  (4, 13, FALSE),
  (4, 22, TRUE);

-- global delegations
INSERT INTO "delegation"
  ("truster_id", "scope", "trustee_id") VALUES
  ( 1, 'global',  9),
  ( 2, 'global', 11),
  ( 3, 'global', 12),
  ( 4, 'global', 13),
  ( 5, 'global', 14),
  ( 6, 'global',  7),
  ( 7, 'global',  8),
  ( 8, 'global',  6),
  (10, 'global',  9),
  (11, 'global',  9),
  (12, 'global', 21),
  (15, 'global', 10),
  (16, 'global', 17),
  (17, 'global', 19),
  (18, 'global', 19),
  (23, 'global', 22);

-- delegations for topics
INSERT INTO "delegation"
  ("area_id", "truster_id", "scope", "trustee_id") VALUES
  (1,  3, 'area', 17),
  (2,  5, 'area', 10),
  (2,  9, 'area', 10),
  (3,  4, 'area', 14),
  (3, 16, 'area', 20),
  (3, 19, 'area', 20),
  (4,  5, 'area', 13),
  (4, 12, 'area', 22);

INSERT INTO "issue" ("area_id", "policy_id") VALUES
  (3, 1);  -- id 1

INSERT INTO "initiative" ("issue_id", "name") VALUES
  (1, 'Initiative #1'),  -- id 1
  (1, 'Initiative #2'),  -- id 2
  (1, 'Initiative #3'),  -- id 3
  (1, 'Initiative #4'),  -- id 4
  (1, 'Initiative #5'),  -- id 5
  (1, 'Initiative #6'),  -- id 6
  (1, 'Initiative #7');  -- id 7

INSERT INTO "draft" ("initiative_id", "author_id", "content") VALUES
  (1, 17, 'Lorem ipsum...'),  -- id 1
  (2, 20, 'Lorem ipsum...'),  -- id 2
  (3, 20, 'Lorem ipsum...'),  -- id 3
  (4, 20, 'Lorem ipsum...'),  -- id 4
  (5, 14, 'Lorem ipsum...'),  -- id 5
  (6, 11, 'Lorem ipsum...'),  -- id 6
  (7, 12, 'Lorem ipsum...');  -- id 7

INSERT INTO "initiator" ("initiative_id", "member_id") VALUES
  (1, 17),
  (1, 19),
  (2, 20),
  (3, 20),
  (4, 20),
  (5, 14),
  (6, 11),
  (7, 12);

INSERT INTO "supporter" ("member_id", "initiative_id", "draft_id") VALUES
  ( 7,  4,  4),
  ( 8,  2,  2),
  (11,  6,  6),
  (12,  7,  7),
  (14,  1,  1),
  (14,  2,  2),
  (14,  3,  3),
  (14,  4,  4),
  (14,  5,  5),
  (14,  6,  6),
  (14,  7,  7),
  (17,  1,  1),
  (17,  3,  3),
  (19,  1,  1),
  (19,  2,  2),
  (20,  1,  1),
  (20,  2,  2),
  (20,  3,  3),
  (20,  4,  4),
  (20,  5,  5);

INSERT INTO "suggestion" ("initiative_id", "author_id", "name", "description") VALUES
  (1, 19, 'Suggestion #1', 'Lorem ipsum...');  -- id 1
INSERT INTO "opinion" ("member_id", "suggestion_id", "degree", "fulfilled") VALUES
  (14, 1, 2, FALSE);
INSERT INTO "opinion" ("member_id", "suggestion_id", "degree", "fulfilled") VALUES
  (19, 1, 2, FALSE);

SELECT "time_warp"();
SELECT "time_warp"();
SELECT "time_warp"();

INSERT INTO "direct_voter" ("member_id", "issue_id") VALUES
  ( 8, 1),
  ( 9, 1),
  (11, 1),
  (12, 1),
  (14, 1),
  (19, 1),
  (20, 1),
  (21, 1);

INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES
  ( 8, 1, 1,  1),
  ( 8, 1, 2,  1),
  ( 8, 1, 3,  1),
  ( 8, 1, 4,  1),
  ( 8, 1, 5,  1),
  ( 8, 1, 6, -1),
  ( 8, 1, 7, -1),
  ( 9, 1, 1, -2),
  ( 9, 1, 2, -3),
  ( 9, 1, 3, -2),
  ( 9, 1, 4, -2),
  ( 9, 1, 5, -2),
  ( 9, 1, 6, -1),
  (11, 1, 1, -1),
  (11, 1, 2, -1),
  (11, 1, 3, -1),
  (11, 1, 4, -1),
  (11, 1, 5, -1),
  (11, 1, 6,  2),
  (11, 1, 7,  1),
  (12, 1, 1, -1),
  (12, 1, 3, -1),
  (12, 1, 4, -1),
  (12, 1, 5, -1),
  (12, 1, 6, -2),
  (12, 1, 7,  1),
  (14, 1, 1,  1),
  (14, 1, 2,  3),
  (14, 1, 3,  1),
  (14, 1, 4,  2),
  (14, 1, 5,  1),
  (14, 1, 6,  1),
  (14, 1, 7,  1),
  (19, 1, 1,  3),
  (19, 1, 2,  4),
  (19, 1, 3,  2),
  (19, 1, 4,  2),
  (19, 1, 5,  2),
  (19, 1, 7,  1),
  (20, 1, 1,  1),
  (20, 1, 2,  2),
  (20, 1, 3,  1),
  (20, 1, 4,  1),
  (20, 1, 5,  1),
  (21, 1, 5, -1);

SELECT "time_warp"();

DROP FUNCTION "time_warp"();

-- Test policies that help with testing specific frontend parts

INSERT INTO "policy" (
        "index",
        "active",
        "name",
        "description",
        "admission_time",
        "discussion_time",
        "verification_time",
        "voting_time",
        "issue_quorum_num",
        "issue_quorum_den",
        "initiative_quorum_num",
        "initiative_quorum_den"
    ) VALUES (
        1,
        TRUE,
        'Test New',
        DEFAULT,
        '2 days',
        '1 second',
        '1 second',
        '1 second',
        0, 100,
        0, 100
    ), (
        1,
        TRUE,
        'Test Accept',
        DEFAULT,
        '1 second',
        '2 days',
        '1 second',
        '1 second',
        0, 100,
        0, 100
    ), (
        1,
        TRUE,
        'Test Frozen',
        DEFAULT,
        '1 second',
        '5 minutes',
        '2 days',
        '1 second',
        0, 100,
        0, 100
    ), (
        1,
        TRUE,
        'Test Voting',
        DEFAULT,
        '1 second',
        '5 minutes',
        '1 second',
        '2 days',
        0, 100,
        0, 100
    );
END;

