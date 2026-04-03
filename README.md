# claude-caffeinate

A [Claude Code](https://cli.anthropic.com) plugin that prevents your Mac from sleeping while Claude is actively working.

## How it works

Every time Claude calls a tool (reading files, running commands, editing code), the plugin starts a `caffeinate` process with a 5-minute timeout. As long as Claude keeps working, the timeout is refreshed. When Claude stops and waits for your input, caffeinate expires and your Mac can sleep normally.

### Safety

- **`-w <pid>`** — tied to the Claude Code process. If Claude crashes or is force-quit, caffeinate exits immediately.
- **`-t 300`** — 5-minute deadman switch. If Claude stops calling tools, your Mac can sleep within 5 minutes.
- **`-is`** — prevents idle sleep and system sleep (lid close on AC power).
- **PID file** — tracks its own caffeinate instance, won't interfere with other caffeinate processes.

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
