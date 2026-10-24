# bat (cat with syntax highlighting) when installed, plain cat otherwise.
# --paging=never keeps cat's behavior of printing straight to the terminal.
# When piped or redirected, bat prints the plain file contents like cat.
# Use `\cat` or `command cat` to bypass the alias.
if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
fi
