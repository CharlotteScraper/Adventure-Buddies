#!/bin/bash
set -e
cd /home/team/shared/flutter_app

# Initialize git if not already done
if [ ! -d ".git" ]; then
  git init
  echo "Git initialized"
fi

# Configure git
git config user.email "team@adventurebuddies.app"
git config user.name "Adventure Buddies Team"

# Add remote
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/CharlotteScraper/Adventure-Buddies.git

# Add files and commit
git add -A
git add -f .gitignore
git commit -m "Adventure Buddies MVP - Complete app with 4 interactive games, iOS/Android support, database, and COPPA privacy compliance

Full project built for the July 11, 2026 launch target."

# Push
git push -u origin main --force 2>&1

echo "PUSH COMPLETE"