# eza (modern ls) when installed, plain ls otherwise.
# Only flags supported by both GNU and BSD/macOS ls are used in the fallback.
# Use `\ls` or `command ls` to bypass the alias.
if (( $+commands[eza] )); then
  alias ls='eza --group-directories-first'
  alias ll='eza -l --group-directories-first --git --header --time-style=long-iso'
  alias la='eza -la --group-directories-first --git --header --time-style=long-iso --color-scale'
  alias lt='eza --tree --level=2 --group-directories-first'
else
  alias ll='ls -lh'
  alias la='ls -lah'
fi
