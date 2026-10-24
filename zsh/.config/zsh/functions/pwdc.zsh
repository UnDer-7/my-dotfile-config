# ----------------------------------------------------------------------------
# Function: pwdc
#
# Description:
#   Prints the current directory (like `pwd`) and copies it to the clipboard.
#   The clipboard logic (tool per session, warnings) lives in _clipboard_copy
#   (_clipboard.zsh). If copying fails, the path is still printed.
#
# Usage:
#   pwdc
#
# Example:
#   % pwdc
#   /home/user/projects
#   ✅ Path copied to clipboard.
# ----------------------------------------------------------------------------
pwdc() {
  print -r -- "$PWD"
  print -rn -- "$PWD" | _clipboard_copy Path
}
