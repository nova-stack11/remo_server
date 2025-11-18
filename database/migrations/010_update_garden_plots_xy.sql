-- ================================
-- Migration 010
-- Update user_garden_plots:
-- - Remove plot_code
-- - Add x, y columns
-- - Convert data from plot_code "x1y1" → x=1, y=1
-- ================================

-- 1. Add new columns x, y
ALTER TABLE user_garden_plots
    ADD COLUMN IF NOT EXISTS x INTEGER,
    ADD COLUMN IF NOT EXISTS y INTEGER;

-- 2. Parse old plot_code into x/y
-- plot_code format: 'x1y2'
UPDATE user_garden_plots
SET
  x = CAST(REGEXP_REPLACE(plot_code, 'x([0-9]+)y([0-9]+)', '\1') AS INTEGER),
  y = CAST(REGEXP_REPLACE(plot_code, 'x([0-9]+)y([0-9]+)', '\2') AS INTEGER)
WHERE plot_code IS NOT NULL;

-- 3. Ensure no NULL (safety)
UPDATE user_garden_plots
SET x = 0 WHERE x IS NULL;

UPDATE user_garden_plots
SET y = 0 WHERE y IS NULL;

-- 4. Drop old column
ALTER TABLE user_garden_plots
    DROP COLUMN IF EXISTS plot_code;

-- 5. Add unique constraint on new coordinates
ALTER TABLE user_garden_plots
    ADD CONSTRAINT user_garden_plots_user_xy_unique UNIQUE (user_id, x, y);