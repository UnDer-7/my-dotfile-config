# ----------------------------------------------------------------------------
# Directory Shortcuts and ‘d’ Function
#
# Description:
#   A set of global aliases for quickly moving up the directory tree,
#   plus the `d` function for inspecting and navigating your directory stack.
#
# Global Aliases:
#   ...     → ../..         # move up two levels
#   ....    → ../../..      # move up three levels
#   .....   → ../../../..   # move up four levels
#   ......  → ../../../../..# move up five levels
#
#   -       → cd -          # jump to previous directory
#   0       → cd -0         # go to the 0th entry of the directory stack (current dir)
#   1       → cd -1         # go to the 1st entry (previous dir)
#   2       → cd -2         # go to the 2nd entry, etc.
#   … through 9
#
# Function: d
#
# Synopsis:
#   d [n | +n | -n | flags]
#
# Behavior:
#   • No arguments:
#       Lists the first 10 entries of your directory stack, numbered.
#       You can then `cd` into any by number.
#         % d
#         0  ~/projects
#         1  /etc
#         2  /var/log
#         …
#
#   • With arguments:
#       Forwards all arguments to the builtin `dirs` command.
#       Examples:
#         d -l        # print stack with full paths
#         d +2        # show only the 3rd entry
#         d -p        # print each entry on its own line
#
# Completion:
#   compdef _dirs d   # Enables argument and option completion for `d`
#
# Usage Examples:
#   cd /usr/local/bin; pushd ~; pushd /tmp
#   d               # view stack
#   1               # Go to first location shown in the d command
#   3               # Go to third location shown in the d command
#   ...
#
# References:
#   https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/directories.zsh
# ----------------------------------------------------------------------------

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 0='cd -0'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d
