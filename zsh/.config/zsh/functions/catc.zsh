# ----------------------------------------------------------------------------
# Function: catc
#
# Description:
#   Prints files (like `cat`) and copies their exact content to the clipboard.
#   With no file arguments it reads stdin, so it also works at the end of a
#   pipe. When bat is installed and stdout is a terminal, the content is
#   displayed through bat (like the `cat` alias); the clipboard always gets
#   the raw content from the real cat, without bat's header or line numbers.
#   Keep the bat options in sync with the `cat` alias (alias/bat_alias.zsh).
#   The clipboard logic (tool per session, warnings) lives in _clipboard_copy
#   (_clipboard.zsh). If copying fails, the content is still
#   printed. Nothing is copied when a file cannot be read.
#
# Usage:
#   catc [cat options] [file...]
#   <command> | catc
#
# Examples:
#   % catc ~/.ssh/id_ed25519.pub
#   ssh-ed25519 AAAA... user@host
#   ✅ Content copied to clipboard.
#
#   % git log -1 --format=%H | catc
# ----------------------------------------------------------------------------
catc() {
  local content

  # The trailing "x" keeps $(...) from stripping trailing newlines.
  content="$(command cat "$@" && print -n x)" || return
  content="${content%x}"

  if (( $+commands[bat] )) && [[ -t 1 ]]; then
    # Display only. With a single file, pass its name so bat picks the syntax.
    # Keep the bat options in sync with the `cat` alias (alias/bat_alias.zsh).
    local -a files=(${@:#-*}) name
    (( $#files == 1 )) && name=(--file-name "$files[1]")
    print -rn -- "$content" | bat --paging=never "${name[@]}"
  else
    print -rn -- "$content"
    # Keep the status message on its own line.
    [[ -z $content || $content == *$'\n' ]] || print
  fi

  print -rn -- "$content" | _clipboard_copy Content
}
