# ----------------------------------------------------------------------------
# Function: pwdc
#
# Description:
#   Prints the current directory (like `pwd`) and copies it to the clipboard.
#   Picks the clipboard tool for the current session:
#     • macOS          → pbcopy (built in)
#     • Wayland        → wl-copy (wl-clipboard), or xclip through XWayland
#     • X11            → xclip
#   If the tool is missing, the path is still printed and a warning names the
#   detected session and what to install for it.
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
  local dir=$PWD
  local -a copy_cmd

  print -r -- "$dir"

  local session hint
  if [[ $OSTYPE == darwin* ]]; then
    session=macOS
    hint="pbcopy should be built into macOS; check that /usr/bin is in your PATH."
    (( $+commands[pbcopy] )) && copy_cmd=(pbcopy)
  elif [[ -n $WAYLAND_DISPLAY ]]; then
    session=Wayland
    hint="Install wl-clipboard."
    if (( $+commands[wl-copy] )); then
      copy_cmd=(wl-copy)
    elif [[ -n $DISPLAY ]] && (( $+commands[xclip] )); then
      # XWayland fallback
      copy_cmd=(xclip -selection clipboard)
    fi
  elif [[ -n $DISPLAY ]]; then
    session=X11
    hint="Install xclip."
    (( $+commands[xclip] )) && copy_cmd=(xclip -selection clipboard)
  else
    session=none
    hint="No graphical session detected (SSH or TTY?), so there is no clipboard to copy to."
  fi

  if (( ! $#copy_cmd )); then
    print -u2 "⚠️  Could not copy to clipboard (session: $session)."
    print -u2 "   $hint"
    return 1
  fi

  if print -rn -- "$dir" | "${copy_cmd[@]}" 2>/dev/null; then
    print "✅ Path copied to clipboard."
  else
    print -u2 "⚠️  Could not copy to clipboard: '${copy_cmd[1]}' failed."
    return 1
  fi
}
