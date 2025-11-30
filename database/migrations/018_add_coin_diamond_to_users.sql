-- migration 018: add coin and diamond columns to users table

ALTER TABLE users
ADD COLUMN coin BIGINT DEFAULT 0;

ALTER TABLE users
ADD COLUMN diamond BIGINT DEFAULT 0;