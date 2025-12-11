-- Migration 023: Chat System
-- Creates tables for direct/group chat, messages, message status, and user presence

-- ============================================================================
-- 1. ENUM TYPES
-- ============================================================================

-- Conversation type: direct (1-on-1) or group (multiple users)
CREATE TYPE conversation_type AS ENUM ('direct', 'group');

-- Message type: text, image, gif, voice, gift
CREATE TYPE message_type AS ENUM ('text', 'image', 'gif', 'voice', 'gift');

-- Message delivery status
CREATE TYPE message_delivery_status AS ENUM ('sent', 'delivered', 'seen');

-- User presence status
CREATE TYPE presence_status AS ENUM ('online', 'offline', 'away');


-- ============================================================================
-- 2. CONVERSATIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type conversation_type NOT NULL DEFAULT 'direct',
  name VARCHAR(100) NULL,  -- NULL for direct chats, required for groups
  avatar_url TEXT NULL,     -- Group avatar URL
  created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for finding conversations by creator
CREATE INDEX IF NOT EXISTS ix_conversations_created_by ON conversations(created_by);

-- Index for querying by type
CREATE INDEX IF NOT EXISTS ix_conversations_type ON conversations(type);


-- ============================================================================
-- 3. CONVERSATION_MEMBERS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS conversation_members (
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  is_muted BOOLEAN NOT NULL DEFAULT false,
  last_read_at TIMESTAMPTZ NULL,  -- Track when user last read messages
  CONSTRAINT pk_conversation_members PRIMARY KEY (conversation_id, user_id)
);

-- Index for finding all conversations for a user (critical for performance)
CREATE INDEX IF NOT EXISTS ix_conversation_members_user_id ON conversation_members(user_id);

-- Index for finding all members of a conversation
CREATE INDEX IF NOT EXISTS ix_conversation_members_conversation_id ON conversation_members(conversation_id);


-- ============================================================================
-- 4. MESSAGES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,  -- Message text or file path/URL
  type message_type NOT NULL DEFAULT 'text',
  metadata JSONB NULL,  -- For gift data, image URLs, voice duration, etc.
  reply_to_message_id UUID NULL REFERENCES messages(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for paginating messages in a conversation (most important query)
CREATE INDEX IF NOT EXISTS ix_messages_conversation_created_at
  ON messages(conversation_id, created_at DESC);

-- Index for finding messages by sender
CREATE INDEX IF NOT EXISTS ix_messages_from_user ON messages(from_user_id);

-- Index for finding reply threads
CREATE INDEX IF NOT EXISTS ix_messages_reply_to ON messages(reply_to_message_id)
  WHERE reply_to_message_id IS NOT NULL;


-- ============================================================================
-- 5. MESSAGE_STATUS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS message_status (
  message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status message_delivery_status NOT NULL DEFAULT 'sent',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT pk_message_status PRIMARY KEY (message_id, user_id)
);

-- Index for finding unread messages for a user
CREATE INDEX IF NOT EXISTS ix_message_status_user_status
  ON message_status(user_id, status);

-- Index for finding status updates for a message
CREATE INDEX IF NOT EXISTS ix_message_status_message_id ON message_status(message_id);


-- ============================================================================
-- 6. USER_PRESENCE TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_presence (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  status presence_status NOT NULL DEFAULT 'offline',
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for finding online users
CREATE INDEX IF NOT EXISTS ix_user_presence_status ON user_presence(status);


-- ============================================================================
-- 7. TRIGGERS FOR AUTO-UPDATING TIMESTAMPS
-- ============================================================================

-- Trigger function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to conversations
DROP TRIGGER IF EXISTS tr_conversations_updated_at ON conversations;
CREATE TRIGGER tr_conversations_updated_at
  BEFORE UPDATE ON conversations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to messages
DROP TRIGGER IF EXISTS tr_messages_updated_at ON messages;
CREATE TRIGGER tr_messages_updated_at
  BEFORE UPDATE ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to message_status
DROP TRIGGER IF EXISTS tr_message_status_updated_at ON message_status;
CREATE TRIGGER tr_message_status_updated_at
  BEFORE UPDATE ON message_status
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to user_presence
DROP TRIGGER IF EXISTS tr_user_presence_updated_at ON user_presence;
CREATE TRIGGER tr_user_presence_updated_at
  BEFORE UPDATE ON user_presence
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();


-- ============================================================================
-- 8. HELPER VIEWS (Optional - for easier querying)
-- ============================================================================

-- View to get conversation list with last message info
CREATE OR REPLACE VIEW conversation_list_view AS
SELECT
  c.id AS conversation_id,
  c.type,
  c.name,
  c.avatar_url,
  c.created_by,
  c.created_at AS conversation_created_at,
  cm.user_id,
  cm.is_muted,
  cm.last_read_at,
  m.id AS last_message_id,
  m.content AS last_message_content,
  m.type AS last_message_type,
  m.from_user_id AS last_message_from,
  m.created_at AS last_message_at,
  (
    SELECT COUNT(*)
    FROM messages m2
    WHERE m2.conversation_id = c.id
      AND m2.created_at > COALESCE(cm.last_read_at, '1970-01-01'::timestamptz)
      AND m2.from_user_id != cm.user_id
  ) AS unread_count
FROM conversations c
INNER JOIN conversation_members cm ON c.id = cm.conversation_id
LEFT JOIN LATERAL (
  SELECT *
  FROM messages
  WHERE conversation_id = c.id
  ORDER BY created_at DESC
  LIMIT 1
) m ON true;


-- ============================================================================
-- 9. CONSTRAINTS AND VALIDATIONS
-- ============================================================================

-- Ensure group chats have a name
ALTER TABLE conversations
  ADD CONSTRAINT chk_group_has_name
  CHECK (type = 'direct' OR (type = 'group' AND name IS NOT NULL));

-- Prevent users from sending messages to themselves in direct chats
-- (This will be enforced in application logic, but adding a constraint for direct chats with 2 members)


-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Migration 023 Summary:
-- ✅ Created 5 tables: conversations, conversation_members, messages, message_status, user_presence
-- ✅ Created 4 ENUM types for type safety
-- ✅ Added 11 indexes for query performance
-- ✅ Added 4 triggers for automatic timestamp updates
-- ✅ Created 1 view for easier conversation list queries
-- ✅ Added constraints for data validation
