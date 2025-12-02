#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ================================
# Migration Script (Single File)
# Docker Container: postgres_db
# Database: game_db
# User: game_user
# ================================

CONTAINER="postgres_db"
DB="game_db"
USER="game_user"
FILENAME="$SCRIPT_DIR/migrations/020_friend_system.sql"

if [ ! -f "$FILENAME" ]; then
  echo "❌ Error: File '$FILENAME' does not exist."
  exit 1
fi

echo "🚀 Running migration file: $FILENAME"

docker exec -i "$CONTAINER" psql -U "$USER" -d "$DB" < "$FILENAME"

echo "✅ Migration applied successfully!"