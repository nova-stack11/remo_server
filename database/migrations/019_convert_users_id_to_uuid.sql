-- ============================================
-- 019 - Fix users.id to UUID + related tables
-- Safe migration: create new UUID column then swap
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

------------------------------------------------------
-- STEP 1 — Drop all foreign keys referencing users.id
------------------------------------------------------
ALTER TABLE user_seeds DROP CONSTRAINT IF EXISTS user_seeds_user_id_fkey;
ALTER TABLE user_garden_plots DROP CONSTRAINT IF EXISTS user_garden_plots_user_id_fkey;

------------------------------------------------------
-- STEP 2 — Create new UUID column for users
------------------------------------------------------
ALTER TABLE users ADD COLUMN id_new UUID;

-- If users.id already contains UUID text (CHECK THIS FIRST)
UPDATE users SET id_new = id::uuid;

-- If users.id is NOT a UUID format, use this instead:
-- UPDATE users SET id_new = gen_random_uuid();

------------------------------------------------------
-- STEP 3 — Drop old PK, drop old id column, rename
------------------------------------------------------
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_pkey;

ALTER TABLE users DROP COLUMN id;

ALTER TABLE users RENAME COLUMN id_new TO id;

ALTER TABLE users ADD PRIMARY KEY (id);

------------------------------------------------------
-- STEP 4 — Fix related tables user_id columns
------------------------------------------------------
-- Convert to text first (in case they are corrupted)
ALTER TABLE user_seeds
    ALTER COLUMN user_id TYPE TEXT USING user_id::text;

ALTER TABLE user_garden_plots
    ALTER COLUMN user_id TYPE TEXT USING user_id::text;

-- Now convert to UUID (safe)
ALTER TABLE user_seeds
    ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

ALTER TABLE user_garden_plots
    ALTER COLUMN user_id TYPE UUID USING user_id::uuid;

------------------------------------------------------
-- STEP 5 — Recreate foreign keys
------------------------------------------------------
ALTER TABLE user_seeds
    ADD CONSTRAINT user_seeds_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE user_garden_plots
    ADD CONSTRAINT user_garden_plots_user_id_fkey
    FOREIGN KEY (user_id) REFERENCES users(id);

