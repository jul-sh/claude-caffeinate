#!/bin/bash
# Refresh caffeinate keep-alive for Claude Code active work.
# Called on PreToolUse — kills any existing hook-started caffeinate
# and starts a fresh one with a 5-minute timeout tied to our claude process.
#
# Safety:
#   -w <pid>  exits if Claude Code dies (crash-safe, no orphans)
#   -t 300    5-minute deadman switch (expires when Claude stops calling tools)
#   -is       prevent idle sleep + system sleep (including lid-close on AC)
#   PID file  tracks our own caffeinate so we don't kill other instances

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
        # Keep walking up to find the topmost claude process
    fi
done

if [ -z "$CLAUDE_PID" ]; then
    exit 0
fi

caffeinate -is -w "$CLAUDE_PID" -t 300 &
echo $! > "$PIDFILE"
