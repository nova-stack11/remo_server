-- ============================================
-- Migration 009
-- Cleanup old inventory tables & update seeds
-- ============================================

-- 1. Drop table user_inventory
DROP TABLE IF EXISTS user_inventory;

-- 2. Drop table user_inventory_items
DROP TABLE IF EXISTS user_inventory_items;

-- 3. user_seeds: remove column sprite_path
ALTER TABLE user_seeds
    DROP COLUMN IF EXISTS sprite_path;

-- 4. seed: add new image columns
ALTER TABLE seed
    ADD COLUMN IF NOT EXISTS seed_image TEXT,
    ADD COLUMN IF NOT EXISTS stage1_image TEXT,
    ADD COLUMN IF NOT EXISTS stage2_image TEXT,
    ADD COLUMN IF NOT EXISTS stage3_image TEXT;

-- 4b. Temporary default images for new seed image fields
UPDATE seed
SET seed_image = 'plants/tomato/Crop_Tomato_Small_Basket_32x32.png',
    stage1_image = 'plants/tomato/Crop_Tomato_Sprout_32x32.png',
    stage2_image = 'plants/tomato/Crop_Tomato_Fruitless_32x32.png',
    stage3_image = 'plants/tomato/Crop_Tomato_Ripe_32x32.png'
WHERE seed_image IS NULL
   OR stage1_image IS NULL
   OR stage2_image IS NULL
   OR stage3_image IS NULL;

-- 5. user_farm_plants: remove grow_duration, water_interval
ALTER TABLE user_farm_plants
    DROP COLUMN IF EXISTS grow_duration,
    DROP COLUMN IF EXISTS water_interval;