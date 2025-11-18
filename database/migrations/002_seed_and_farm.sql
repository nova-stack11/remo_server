-- ============================================
-- 002_seed_and_farm.sql
-- Tạo bảng seed + user_farm_plants + dữ liệu mẫu
-- ============================================

-- --------------------------------------------
-- Bảng seed
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS seed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(50) NOT NULL,
  grow_duration INT NOT NULL,     -- giây
  water_interval INT NOT NULL,    -- giây
  stages INT NOT NULL DEFAULT 3
);

ALTER TABLE seed ADD CONSTRAINT seed_name_unique UNIQUE(name);

-- --------------------------------------------
-- Bảng user_farm_plants
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS user_farm_plants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES users(id),
  tile_x INT NOT NULL,
  tile_y INT NOT NULL,
  seed_id UUID NOT NULL REFERENCES public.seed(id),

  planted_at TIMESTAMPTZ NOT NULL,
  last_watered_at TIMESTAMPTZ NOT NULL,

  grow_duration INT NOT NULL,
  water_interval INT NOT NULL,

  stage INT NOT NULL DEFAULT 1,
  is_dead BOOLEAN NOT NULL DEFAULT FALSE,
  withered_at TIMESTAMPTZ,

  UNIQUE(user_id, tile_x, tile_y)
);

-- --------------------------------------------
-- Seed dữ liệu mẫu cho bảng seed
-- --------------------------------------------
INSERT INTO seed (name, grow_duration, water_interval, stages)
VALUES
  ('Carrot', 7200, 3600, 3),
  ('Tomato', 14400, 7200, 3),
  ('Flower', 10800, 5400, 3)
ON CONFLICT (name) DO NOTHING;

-- --------------------------------------------
-- Thêm 1 cây mẫu cho admin (nếu tồn tại)
-- --------------------------------------------
DO $$
DECLARE
  uid TEXT;
BEGIN
  SELECT id INTO uid FROM users WHERE username = 'admin@remo.com' LIMIT 1;

  IF uid IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM user_farm_plants WHERE user_id = uid AND tile_x = 5 AND tile_y = 5
    ) THEN
      INSERT INTO user_farm_plants (
        user_id, tile_x, tile_y, seed_id,
        planted_at, last_watered_at,
        grow_duration, water_interval, stage
      )
      VALUES (
        uid, 5, 5, (SELECT id FROM seed WHERE name = 'Carrot'),
        NOW() - INTERVAL '1 hour',
        NOW() - INTERVAL '30 minutes',
        7200, 3600, 1
      );
    END IF;
  END IF;
END
$$;