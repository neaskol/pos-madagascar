#!/bin/bash

# Script to apply storage migration to remote Supabase
# Run this if storage buckets don't exist yet

set -e

PROJECT_REF="ofrbxqxhtnizdwipqdls"
MIGRATION_FILE="supabase/migrations/20260325000001_create_storage_buckets.sql"

echo "🔧 Applying Storage Migration to Supabase..."
echo "Project: $PROJECT_REF"
echo "Migration: $MIGRATION_FILE"
echo ""

# Check if migration file exists
if [ ! -f "$MIGRATION_FILE" ]; then
    echo "❌ Error: Migration file not found at $MIGRATION_FILE"
    exit 1
fi

echo "📋 Migration contents:"
echo "─────────────────────────────────────────"
head -20 "$MIGRATION_FILE"
echo "..."
echo "─────────────────────────────────────────"
echo ""

# Option 1: Try CLI push
echo "Attempting to push via CLI..."
if supabase db push --project-ref "$PROJECT_REF" 2>&1; then
    echo "✅ Migration applied successfully via CLI!"
    exit 0
fi

# If CLI fails, provide manual instructions
echo ""
echo "❌ CLI push failed (possibly network issue)"
echo ""
echo "📝 Manual Steps:"
echo "1. Go to: https://supabase.com/dashboard/project/$PROJECT_REF/editor"
echo "2. Click 'New Query' or 'SQL Editor'"
echo "3. Copy and paste the contents of: $MIGRATION_FILE"
echo "4. Click 'Run' to execute"
echo ""
echo "Or copy the SQL directly:"
echo "─────────────────────────────────────────"
cat "$MIGRATION_FILE"
echo "─────────────────────────────────────────"
