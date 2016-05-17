-- Convert schema 'db_upgrades\_source\deploy\1\001-auto.yml' to 'db_upgrades\_source\deploy\2\001-auto.yml':;

;
BEGIN;

;
ALTER TABLE hardware ADD COLUMN group_id integer NOT NULL DEFAULT 1;

;
CREATE INDEX hardware_idx_group_id ON hardware (group_id);

;

;

COMMIT;

