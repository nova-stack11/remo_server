-- ===========================================
-- Migration 011
-- Rename tile_x → x, tile_y → y
-- ===========================================

-- 1. Đổi tên cột tile_x thành x
ALTER TABLE user_farm_plants
    RENAME COLUMN tile_x TO x;

-- 2. Đổi tên cột tile_y thành y
ALTER TABLE user_farm_plants
    RENAME COLUMN tile_y TO y;