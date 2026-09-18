#!/bin/bash
# Fold agent-made skill edits back into the git repo.
#
# Hermes' own sync is one-way: repo -> ~/.hermes/skills, and it SKIPS anything
# the agent has edited ("user-modified, keeping"). So an improvement the agent
# writes to its installed copy never reaches git and is lost on reinstall.
# This carries it the other way, at the end of every session.
#
# It copies. It does not commit and does not push: a change the agent made to
# its own instructions is exactly the kind that should be read before it is
# published. `git status` in the repo is the review queue.

set -uo pipefail                     # no -e: a hook must never take the agent down
cat >/dev/null 2>&1 || true          # drain the JSON payload on stdin; unused

REPO="/Users/depi/jim/hermes"
LIVE="$HOME/.hermes/skills/launch-crew"
LOG="$HOME/.hermes/agent-hooks/sync-crew-skills.log"
PY="$REPO/venv/bin/python"

log() { printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG"; }

[ -d "$LIVE" ] && [ -d "$REPO/skills/launch-crew" ] || exit 0

copied=0 skipped=0
for live_file in "$LIVE"/*/SKILL.md; do
  [ -f "$live_file" ] || continue
  name=$(basename "$(dirname "$live_file")")
  repo_file="$REPO/skills/launch-crew/$name/SKILL.md"

  [ -f "$repo_file" ] || continue                      # never create new skills here
  cmp -s "$live_file" "$repo_file" && continue         # unchanged
  [ "$live_file" -nt "$repo_file" ] || continue        # repo is newer: a human edit wins

  # A broken skill silently stops loading, so never fold one back. Validate the
  # frontmatter parses and still carries the two fields the loader needs.
  if [ -x "$PY" ] && ! "$PY" - "$live_file" <<'PYEOF' >/dev/null 2>&1
import sys, yaml
t = open(sys.argv[1]).read()
parts = t.split('---')
d = yaml.safe_load(parts[1])
assert d.get('name') and d.get('description'), 'missing name/description'
assert len(d['description']) <= 60, 'description too long'
PYEOF
  then
    log "SKIP  $name — frontmatter tidak sah, tidak disalin"
    skipped=$((skipped+1))
    continue
  fi

  cp "$live_file" "$repo_file" && { log "SALIN $name -> repo"; copied=$((copied+1)); }
done

if [ "$copied" -gt 0 ]; then
  log "$copied skill disalin balik. Belum di-commit — periksa: git -C $REPO diff skills/launch-crew"
fi
[ "$skipped" -gt 0 ] && log "$skipped dilewati karena tidak sah"
exit 0
