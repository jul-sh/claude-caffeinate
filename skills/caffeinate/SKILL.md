---
name: caffeinate
description: Enable caffeinate mode to keep the Mac awake (including lid-close) while Claude works
disable-model-invocation: true
---

!`touch /tmp/claude-caffeinate-enabled`

Caffeinate mode is now active for this session. Your Mac will stay awake — even with the lid closed — while Claude is actively working. It will automatically expire 30 minutes after Claude's last tool use, and is cleared when the session ends.
