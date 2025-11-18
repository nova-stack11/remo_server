#!/bin/bash

# ================================
# Migration Script for PostgreSQL
# Docker Container: postgres_db
# Database: game_db
# User: game_user
# ================================

CONTAINER="postgres_db"
DB="game_db"
USER="game_user"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"

echo "🔄 Running all migrations in /migrations ..."

for file in "$MIGRATIONS_DIR"/*.sql; do
  echo "🚀 Running migration: $file"
  docker exec -i $CONTAINER psql -U $USER -d $DB < "$file"
done

echo "✅ All migrations applied successfully!"