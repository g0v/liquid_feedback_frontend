-- NOTE: This file creates an admin user with an empty password!

BEGIN;

INSERT INTO "member" (
        "id",
        "login",
        "password",
        "active",
        "admin",
        "name"
    ) VALUES (
        DEFAULT,
        'admin',
        '',
        TRUE,
        TRUE,
        'Administrator' );

INSERT INTO "policy" (
        "id",
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
        DEFAULT,
        TRUE,
        'Extensive proceeding',
        DEFAULT,
        '1 month',
        '5 months',
        '1 month',
        '3 weeks',
        10, 100,
        10, 100
    ), (
        DEFAULT,
        TRUE,
        'Standard proceeding',
        DEFAULT,
        '1 month',
        '1 month',
        '1 week',
        '1 week',
        10, 100,
        10, 100
    ), (
       DEFAULT,
       TRUE,
       'Fast proceeding',
       DEFAULT,
       '48 hours',
       '3 hours',
       '1 hour',
       '20 hours',
        1, 100,
        1, 100 );

INSERT INTO "area" (
        "id",
        "active",
        "name",
        "description"
    ) VALUES (
        DEFAULT,
        TRUE,
        'Generic area',
        DEFAULT );

COMMIT;
