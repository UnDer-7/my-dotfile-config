# ----------------------------------------------------------------------------
# Function: help
#
# Description:
#   Runs `<command> --help` and colorizes the output with bat when installed,
#   falling back to plain output otherwise.
#
# Usage:
#   help <command> [subcommand...]
#
# Examples:
#   help cp
#   help git commit
#   cp --help | bathelp   # colorize any help text directly
#
# References:
#   https://github.com/sharkdp/bat#highlighting---help-messages
# ----------------------------------------------------------------------------

(( $+commands[bat] )) && alias bathelp='bat --plain --language=help'

function help () {
  if (( $+commands[bat] )); then
    "$@" --help 2>&1 | bat --plain --language=help
  else
    "$@" --help
  fi
}
