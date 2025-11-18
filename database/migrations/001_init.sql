-- ============================================
-- 001_init.sql
-- Khởi tạo bảng users + admin mặc định
-- ============================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- --------------------------------------------
-- Bảng users
-- --------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  token TEXT,
  refresh_token TEXT,
  gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
  birthday TEXT,
  character_name VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);

-- --------------------------------------------
-- Insert admin mặc định
-- --------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin@remo.com') THEN
    INSERT INTO users (username, password, gender, birthday, character_name)
    VALUES (
      'admin@remo.com',
      'Abcd@1234',
      'male',
      '2000-01-01T00:00:00.000Z',
      'ReMoMaster'
    );
  END IF;
END
$$;