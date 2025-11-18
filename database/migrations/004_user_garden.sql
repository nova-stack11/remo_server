-- ============================================
-- 004_user_garden.sql
-- Bảng quản lý khu vườn (20 ô) của user
-- ============================================

CREATE TABLE IF NOT EXISTS user_garden_plots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  plot_code VARCHAR(10) NOT NULL,        -- ví dụ: x1y1
  plot_state INT NOT NULL DEFAULT 0,     -- mặc định state = 0 (locked)
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(user_id, plot_code)
);

-- ============================================
-- Seed 20 ô vườn cho user admin (nếu tồn tại)
-- ============================================

DO $$
DECLARE
  uid TEXT;
  x INT;
  y INT;
BEGIN
  SELECT id INTO uid FROM users WHERE username = 'admin@remo.com' LIMIT 1;

  IF uid IS NOT NULL THEN

    -- 20 ô: lưới 4x5 (x1y1 → x4y5)
    FOR x IN 1..4 LOOP
      FOR y IN 1..5 LOOP
        INSERT INTO user_garden_plots (user_id, plot_code, plot_state)
        VALUES (uid, FORMAT('x%sy%s', x, y), 0)  -- default lock state 0
        ON CONFLICT (user_id, plot_code) DO NOTHING;
      END LOOP;
    END LOOP;

  END IF;

END
$$;