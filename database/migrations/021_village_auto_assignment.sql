-- =============================================
-- 021 - MAP SYSTEM v1 (UUID-based)
-- =============================================

-- Enable uuid extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ============================================================
-- 1) MAPS TABLE
-- ============================================================
-- A unified map table (village, clan land, home, park, beach, etc.)
CREATE TABLE IF NOT EXISTS maps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    type TEXT NOT NULL,             -- village, park, beach, home, clan, event,...
    dynamic_index INT,              -- for generating new instance maps
    capacity INT,                   -- max members (ex: village 16)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    config JSONB                    -- custom JSON config if needed
);


-- ============================================================
-- 2) MAP MEMBERS
-- ============================================================
CREATE TABLE IF NOT EXISTS map_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    map_id UUID REFERENCES maps(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    slot_code TEXT,                -- ex: v_1 … v_16 for village, or null for free maps
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(map_id, slot_code),
    UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_map_members_map
    ON map_members(map_id);

CREATE INDEX IF NOT EXISTS idx_map_members_user
    ON map_members(user_id);


-- ============================================================
-- 3) USER MAP STATE (current active map + position)
-- ============================================================
CREATE TABLE IF NOT EXISTS user_map_state (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    map_id UUID REFERENCES maps(id) ON DELETE CASCADE,
    pos_x DOUBLE PRECISION DEFAULT 0,
    pos_y DOUBLE PRECISION DEFAULT 0,
    direction TEXT DEFAULT 'down', -- up, down, left, right
    last_update TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_map_state_map
    ON user_map_state(map_id);