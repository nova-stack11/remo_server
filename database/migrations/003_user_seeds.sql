-- ============================================
-- 004_user_seeds.sql
-- Bảng quản lý các seed mà user sở hữu
-- ============================================

CREATE TABLE IF NOT EXISTS user_seeds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES users(id),
  seed_id UUID NOT NULL REFERENCES seed(id),
  quantity INT NOT NULL DEFAULT 0,

  -- path hình trong assets hoặc CDN server
  sprite_path VARCHAR(255),

  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, seed_id)
);

-- ============================================
-- Seed dữ liệu mẫu cho user admin
-- ============================================
DO $$
DECLARE
  uid TEXT;
BEGIN
  SELECT id INTO uid FROM users WHERE username = 'admin@remo.com' LIMIT 1;

  IF uid IS NOT NULL THEN

    -- Admin có 10 carrot seed
    INSERT INTO user_seeds (user_id, seed_id, quantity, sprite_path)
    VALUES (uid, (SELECT id FROM seed WHERE name = 'Carrot'), 10, 'plants/tomato/Crop_Tomato_Ripe_32x32.png')
    ON CONFLICT (user_id, seed_id) DO NOTHING;

    -- Admin có 5 tomato seed
    INSERT INTO user_seeds (user_id, seed_id, quantity, sprite_path)
    VALUES (uid, (SELECT id FROM seed WHERE name = 'Tomato'), 5, 'plants/tomato/Crop_Tomato_Ripe_32x32.png')
    ON CONFLICT (user_id, seed_id) DO NOTHING;

    -- Admin có 8 flower seed
    INSERT INTO user_seeds (user_id, seed_id, quantity, sprite_path)
    VALUES (uid, (SELECT id FROM seed WHERE name = 'Flower'), 8, 'plants/tomato/Crop_Tomato_Ripe_32x32.png')
    ON CONFLICT (user_id, seed_id) DO NOTHING;

  END IF;

END
$$;