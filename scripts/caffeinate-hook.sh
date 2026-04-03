#!/bin/bash
# Refresh caffeinate keep-alive for Claude Code active work.
# Called on PreToolUse — only runs if /caffeinate was invoked first.
#
# Safety:
#   Flag file   only runs if /tmp/claude-caffeinate-enabled exists
#   -w <pid>    exits if Claude Code dies (crash-safe, no orphans)
#   -t 1800     30-minute deadman switch (expires when Claude stops calling tools)
#   -is         prevent idle sleep + system sleep (including lid-close on AC)
#   PID file    tracks our own caffeinate so we don't kill other instances

# Only run if caffeinate mode was enabled via /caffeinate
[ -f /tmp/claude-caffeinate-enabled ] || exit 0

PIDFILE="/tmp/claude-caffeinate.pid"

# Kill previous caffeinate if we started one
if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
fi

# Find the topmost claude process that is our ancestor
CLAUDE_PID=""
p=$$
while [ "$p" -gt 1 ]; do
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')
    [ -z "$p" ] && break
    comm=$(ps -o comm= -p "$p" 2>/dev/null)
    if [ "$comm" = "claude" ]; then
        CLAUDE_PID="$p"
    fi
done

if [ -z "$CLAUDE_PID" ]; then
    exit 0
fi

caffeinate -is -w "$CLAUDE_PID" -t 1800 &
echo $! > "$PIDFILE"
