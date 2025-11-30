-- 015: Add need_water to user_farm_plants

ALTER TABLE user_farm_plants
ADD COLUMN need_water BOOLEAN NOT NULL DEFAULT FALSE;