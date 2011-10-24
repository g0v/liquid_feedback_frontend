BEGIN;

-- work in progress

ALTER TABLE "issue" ALTER "state" SET DEFAULT 'admission';  -- fixes wrong update script from v1.3.1 to v1.4.0

COMMIT;
