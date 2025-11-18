-- ============================================
-- 005_inventory.sql
-- Tạo bảng inventory + items
-- ============================================

-- Bảng chính quản lý inventory của mỗi user
CREATE TABLE IF NOT EXISTS user_inventory (
  user_id TEXT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Item trong inventory
CREATE TABLE IF NOT EXISTS user_inventory_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  item_id TEXT NOT NULL, -- tạm thời là text, sau này có bảng items thì đặt FK
  quantity INT NOT NULL DEFAULT 0,

  UNIQUE(user_id, item_id)
);