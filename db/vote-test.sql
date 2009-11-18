BEGIN;

INSERT INTO "member" ("login", "name", "ident_number") VALUES
  ('bernd',    'Bernd',    '002'),
  ('cesar',    'Cesar',    '003'),
  ('doris',    'Doris',    '004'),
  ('emil',     'Emil',     '005'),
  ('frank',    'Frank',    '006'),
  ('gerhard',  'Gerhard',  '007'),
  ('hugo',     'Hugo',     '008'),
  ('ines',     'Ines',     '009'),
  ('johann',   'Johann',   '010'),
  ('klaus',    'Klaus',    '011'),
  ('lisa',     'Lisa',     '012'),
  ('monika',   'Monika',   '013'),
  ('norbert',  'Norbert',  '014'),
  ('olaf',     'Olaf',     '015'),
  ('peter',    'Peter',    '016'),
  ('quinn',    'Quinn',    '017'),
  ('ralf',     'Ralf',     '018'),
  ('sabine',   'Sabine',   '019'),
  ('tobias',   'Tobias',   '020'),
  ('ulla',     'Ulla',     '021'),
  ('vincent',  'Vincent',  '022'),
  ('wolfgang', 'Wolfgang', '023'),
  ('xavier',   'Xavier',   '024'),
  ('yoko',     'Yoko',     '025'),
  ('zareb',    'Zareb',    '026');

INSERT INTO "issue" ("area_id", "policy_id") VALUES (1, 3);
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #1');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #2');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #3');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #4');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #5');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #6');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #7');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #8');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #9');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #10');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #11');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #12');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #13');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #14');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #15');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #16');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #17');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #18');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #19');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #20');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #21');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #22');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #23');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #24');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #25');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #26');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #27');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #28');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #29');
INSERT INTO "initiative" ("issue_id", "name") VALUES (1, 'Initiative #30');

INSERT INTO "draft" ("initiative_id", "content") SELECT "id", 'Lorem ipsum ...' FROM "initiative";
INSERT INTO "initiator" ("member_id", "initiative_id") SELECT 1, "id" FROM "initiative";
INSERT INTO "supporter" ("member_id", "initiative_id", "draft_id") SELECT "member"."id", "initiative"."id", "initiative"."id" FROM "member", "initiative";

INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 1, 1);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 2, 2);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 3, 3);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 4, 4);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 5, 5);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 6, 6);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 7, 7);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 8, 8);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 9, 9);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 10, 10);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 11, 11);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 12, 12);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 13, 13);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 14, 14);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 15, 15);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 16, 16);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 17, 17);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 18, 18);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 19, 19);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 20, 20);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 21, 21);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 22, 22);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 23, 23);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 24, 24);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 25, 25);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 26, 26);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 27, 27);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 28, 28);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 29, 29);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (1, 1, 30, 30);

INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 1, 2);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 2, 1);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 3, 3);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 4, 4);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 5, 5);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 6, 6);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 7, 7);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 8, 8);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 9, 9);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 10, 10);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 11, 11);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 12, 12);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 13, 13);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 14, 14);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 15, 15);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 16, 16);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 17, 17);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 18, 18);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 19, 19);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 20, 20);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 21, 21);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 22, 22);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 23, 23);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 24, 24);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 25, 25);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 26, 26);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 27, 27);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 28, 28);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 29, 29);
INSERT INTO "vote" ("member_id", "issue_id", "initiative_id", "grade") VALUES (2, 1, 30, 30);


SELECT check_issues();
UPDATE issue SET frozen = now();

END;

-- UPDATE issue SET closed = now();
