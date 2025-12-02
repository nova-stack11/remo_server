-- 019_friend_system.sql
--
-- Friend system schema: requests, friends, blocks, indexes, and triggers.
-- This migration is designed for PostgreSQL.

-- =====================
-- UP
-- =====================

-- 1) Enum for friend request status
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'friend_request_status') THEN
    CREATE TYPE friend_request_status AS ENUM ('pending', 'accepted', 'rejected', 'canceled');
  END IF;
END $$;

-- 2) friend_requests table
CREATE TABLE IF NOT EXISTS friend_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user_id UUID NOT NULL,
  to_user_id   UUID NOT NULL,
  message      TEXT NULL,
  status       friend_request_status NOT NULL DEFAULT 'pending',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT fk_friend_requests_from_user FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_friend_requests_to_user   FOREIGN KEY (to_user_id)   REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT chk_friend_requests_not_self CHECK (from_user_id <> to_user_id)
);

-- Allow only one pending request per pair (directional) at a time
CREATE UNIQUE INDEX IF NOT EXISTS ux_friend_requests_pending
  ON friend_requests(from_user_id, to_user_id)
  WHERE status = 'pending';

-- Speeds up inbox queries
CREATE INDEX IF NOT EXISTS ix_friend_requests_to_status
  ON friend_requests(to_user_id, status);

-- 3) friends table (store both directions)
CREATE TABLE IF NOT EXISTS friends (
  user_id   UUID NOT NULL,
  friend_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT pk_friends PRIMARY KEY (user_id, friend_id),
  CONSTRAINT fk_friends_user   FOREIGN KEY (user_id)   REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_friends_friend FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT chk_friends_not_self CHECK (user_id <> friend_id)
);

CREATE INDEX IF NOT EXISTS ix_friends_user ON friends(user_id);

-- 4) blocks table
CREATE TABLE IF NOT EXISTS blocks (
  user_id         UUID NOT NULL,
  blocked_user_id UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT pk_blocks PRIMARY KEY (user_id, blocked_user_id),
  CONSTRAINT fk_blocks_user      FOREIGN KEY (user_id)         REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_blocks_blocked   FOREIGN KEY (blocked_user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT chk_blocks_not_self CHECK (user_id <> blocked_user_id)
);

CREATE INDEX IF NOT EXISTS ix_blocks_user ON blocks(user_id);

-- 5) Trigger to auto-update updated_at on friend_requests
CREATE OR REPLACE FUNCTION trg_friend_requests_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at_friend_requests ON friend_requests;
CREATE TRIGGER set_updated_at_friend_requests
BEFORE UPDATE ON friend_requests
FOR EACH ROW EXECUTE FUNCTION trg_friend_requests_set_updated_at();

-- 6) Guard trigger: prevent creating a request when already friends or blocked (either direction)
CREATE OR REPLACE FUNCTION trg_friend_requests_prevent_invalid()
RETURNS TRIGGER AS $$
DECLARE
  is_blocked BOOLEAN;
  is_friends BOOLEAN;
BEGIN
  -- Prevent when either side blocked the other
  SELECT EXISTS (
    SELECT 1 FROM blocks
    WHERE (user_id = NEW.from_user_id AND blocked_user_id = NEW.to_user_id)
       OR (user_id = NEW.to_user_id AND blocked_user_id = NEW.from_user_id)
  ) INTO is_blocked;

  IF is_blocked THEN
    RAISE EXCEPTION 'Cannot send friend request due to block relation';
  END IF;

  -- Prevent when they are already friends (in any direction)
  SELECT EXISTS (
    SELECT 1 FROM friends
    WHERE (user_id = NEW.from_user_id AND friend_id = NEW.to_user_id)
       OR (user_id = NEW.to_user_id AND friend_id = NEW.from_user_id)
  ) INTO is_friends;

  IF is_friends THEN
    RAISE EXCEPTION 'Users are already friends';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS prevent_invalid_friend_requests ON friend_requests;
CREATE TRIGGER prevent_invalid_friend_requests
BEFORE INSERT ON friend_requests
FOR EACH ROW EXECUTE FUNCTION trg_friend_requests_prevent_invalid();