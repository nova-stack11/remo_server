-- ============================================
-- 008_update_seed_reward.sql
-- Xóa reward khỏi user_seeds và thêm vào seed
-- ============================================

-- 1) XÓA reward khỏi bảng user_seeds (nếu tồn tại)
ALTER TABLE user_seeds
DROP COLUMN IF EXISTS reward;

-- 2) THÊM reward vào bảng seed
ALTER TABLE seed
ADD COLUMN IF NOT EXISTS reward INT DEFAULT 0;

-- 3) Đảm bảo seed cũ có giá trị mặc định
UPDATE seed
SET reward = 0
WHERE reward IS NULL;