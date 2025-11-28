-- 014_user_farm_plants_refactor.sql

-- 1. Xóa toàn bộ dữ liệu cũ
DELETE FROM user_farm_plants;

-- 2. Xóa các cột không còn dùng
ALTER TABLE user_farm_plants
  DROP COLUMN IF EXISTS user_id,
  DROP COLUMN IF EXISTS x,
  DROP COLUMN IF EXISTS y;

-- 3. Thêm garden_id
ALTER TABLE user_farm_plants
  ADD COLUMN garden_id UUID;

-- 4. Thêm khóa ngoại garden_id
ALTER TABLE user_farm_plants
  ADD CONSTRAINT fk_user_farm_plants_garden
    FOREIGN KEY (garden_id)
    REFERENCES user_garden_plots(id)
    ON DELETE CASCADE;