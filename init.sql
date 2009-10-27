-- NOTE: This file creates an admin user with an empty password!

BEGIN;

INSERT INTO "member" (
        "id",
        "login",
        "password",
        "active",
        "admin",
        "name",
        "ident_number"
    ) VALUES (
        DEFAULT,
        'admin',
        '',
        TRUE,
        TRUE,
        'Administrator',
        DEFAULT );

INSERT INTO "policy" (
        "id",
        "active",
        "name",
        "description",
        "admission_time",
        "discussion_time",
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
        '6 months',
        '3 weeks',
        5, 100,
        1, 100
    ), (
        DEFAULT,
        TRUE,
        'Standard proceeding',
        DEFAULT,
        '1 week',
        '1 month',
        '1 week',
        5, 100,
        1, 100
    ), (
       DEFAULT,
       TRUE,
       'Fast proceeding',
       DEFAULT,
       '24 hours',
       '4 hours',
       '20 hours',
        5, 100,
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
