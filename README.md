# claude-caffeinate

A [Claude Code](https://cli.anthropic.com) plugin that lets you close your MacBook lid while Claude works.

## Why?

Claude Code already has built-in `caffeinate -i` support that prevents idle sleep during active work. But it doesn't prevent **system sleep** — so if you close your laptop lid, your Mac sleeps and Claude stops.

This plugin adds the `-s` flag, which prevents sleep even when the lid is closed (while on AC power). It's opt-in: run `/caffeinate` in your session when you want to walk away with the lid closed.

## Usage

```
/claude-caffeinate:caffeinate
```

That's it. Your Mac will stay awake — even with the lid closed — while Claude is actively working. The caffeinate process automatically expires 30 minutes after Claude's last tool use, so your Mac will sleep normally once Claude is done.

To disable mid-session:

```bash
rm /tmp/claude-caffeinate-enabled
```

## How it works

1. `/caffeinate` creates a flag file at `/tmp/claude-caffeinate-enabled`
2. On every tool use, a `PreToolUse` hook checks for that flag
3. If present, it starts `caffeinate -is -w <claude_pid> -t 1800`
4. Each tool use refreshes the 30-minute timeout
5. When Claude stops working, caffeinate expires on its own

### Safety

- **Opt-in** — does nothing until you run `/caffeinate`
- **`-w <pid>`** — tied to the Claude Code process. If Claude crashes or is force-quit, caffeinate exits immediately. No orphans.
- **`-t 1800`** — 30-minute deadman switch. If Claude stops calling tools, your Mac can sleep within 30 minutes.
- **`-is`** — prevents idle sleep + system sleep (lid close on AC power). Does not prevent sleep on battery.
- **PID file** — tracks its own caffeinate instance, won't interfere with other caffeinate processes.
- **Flag file** — cleared on reboot. One session at a time.

## Installation

Add the marketplace, then install:

```
/plugin marketplace add jul-sh/claude-plugins
/plugin install claude-caffeinate@jul-sh
```

Or add to your `~/.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "claude-caffeinate@jul-sh": true
  },
  "extraKnownMarketplaces": {
    "jul-sh": {
      "source": {
        "source": "github",
        "repo": "jul-sh/claude-plugins"
      }
    }
  }
}
```

## Requirements

- macOS (uses the built-in `caffeinate` command)
- AC power (the `-s` flag only prevents lid-close sleep on AC)
