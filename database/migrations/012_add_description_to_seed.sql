-- 012_add_description_to_seed.sql

ALTER TABLE seed
ADD COLUMN description TEXT DEFAULT '' NOT NULL;