#!/usr/bin/env zsh
# Source in a clean zsh -f shell before recording. No personal shell config.
export DEMO_ROOT="$(mktemp -d /tmp/cli-demo.XXXXXX)"
export PROMPT='user@mac ~/demo $ '
unset RPROMPT
setopt INTERACTIVE_COMMENTS
