# ----------------------------------------------------------------------------
# Function: pls
#
# Description:
#   Inserts the last executed command into your prompt, prefixed with “sudo ”,
#   without executing it. After running `pls`, you’ll see:
#     sudo <last_command>
#   at your Zsh prompt—just press Enter to execute.
#
# Usage:
#   pls
#
# How it works:
#   1. fc -ln -1
#      • Fetches the most recent history entry (command only, no line number).
#   2. print -z "sudo $last_cmd"
#      • Pushes “sudo <last_command>” into the Zsh line-editor buffer.
#      • Does not run the command automatically.
#
# Example:
#   % apt-get update
#   % pls
#   sudo apt-get update ←  # now waiting at the prompt; press Enter to run
# ----------------------------------------------------------------------------
pls() {
  local last_cmd
  last_cmd=$(fc -ln -1)
  print -z "sudo $last_cmd"
}
