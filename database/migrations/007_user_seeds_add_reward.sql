-- ============================================
-- 007_user_seeds_add_reward.sql
-- Thêm field reward vào bảng user_seeds
-- ============================================

ALTER TABLE user_seeds
ADD COLUMN IF NOT EXISTS reward INT DEFAULT 0;

-- Cập nhật giá trị mặc định cho các record cũ (tùy chọn)
UPDATE user_seeds
SET reward = 0
WHERE reward IS NULL;