# ----------------------------------------------------------------------------
# Function: update-my-dotfile-config
#
# Description:
#   Runs `git pull --ff-only` in this dotfiles repo and in every third-party
#   repo that setup.sh clones (zsh plugins, zsh theme, kitty themes, eza
#   themes), then lists the new commits of each one. Repos that are not
#   cloned yet are skipped.
#
#   When a terminal opens, the same repos are checked for updates in the
#   background (`git fetch`: only the remote-tracking refs change, never the
#   checked-out files). If any is behind its remote, a notice lists it with
#   its latest commit and a link to review the changes. The prompt is never
#   blocked: the notice shows up as soon as the check ends, or at the next
#   prompt if a program (vim, claude, ...) is running in the foreground.
#   Repos that could not be checked are reported too, with the git errors
#   saved to the log file below.
#
# Usage:
#   update-my-dotfile-config
#
# Settings (put them in ~/.zsh_local):
#   DOTFILES_UPDATE_CHECK=0                 # disable the background check
#   DOTFILES_UPDATE_CHECK_INTERVAL=21600    # seconds between real checks
#                                           # (default 6h); terminals opened
#                                           # in between reuse the last result
#
# Files:
#   ${XDG_CACHE_HOME:-~/.cache}/zsh/dotfiles-updates          last result
#   ${XDG_STATE_HOME:-~/.local/state}/zsh/dotfiles-update.log  last errors
# ----------------------------------------------------------------------------

# Resolved from this file's real location, so it works whether Stow folded
# ~/.config/zsh into one symlink or linked the files one by one.
typeset -g DOTFILES_REPO_DIR="${${(%):-%x}:A:h:h:h:h:h}"

# Pairs of "label" "path".
# Keep in sync with the clone_if_missing calls in setup.sh. If a third place
# starts listing these repos, or the list grows much longer, move it to a
# single shared file that both read.
typeset -ga DOTFILES_UPDATE_REPOS=(
  "my-dotfile-config"                     "$DOTFILES_REPO_DIR"
  "zsh plugin: fast-syntax-highlighting"  "$ZSH_PLUGINS_FOLDER/fast-syntax-highlighting"
  "zsh plugin: zsh-autosuggestions"       "$ZSH_PLUGINS_FOLDER/zsh-autosuggestions"
  "zsh plugin: zsh-completions"           "$ZSH_PLUGINS_FOLDER/zsh-completions"
  "zsh theme: powerlevel10k"              "$ZSH_THEMES_FOLDER/p10k/powerlevel10k"
  "kitty themes"                          "$HOME/.config/kitty/kitty-themes"
  "eza themes"                            "${EZA_CONFIG_DIR:-$HOME/.config/eza}/eza-themes"
)

typeset -g _DOTFILES_UPDATE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/dotfiles-updates"
typeset -g _DOTFILES_UPDATE_LOG="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/dotfiles-update.log"

update-my-dotfile-config() {
  emulate -L zsh
  local label dir before after url failed=()

  for label dir in "${DOTFILES_UPDATE_REPOS[@]}"; do
    print -r -- ""
    print -r -- "==> $label"
    if [[ ! -e "$dir/.git" ]]; then
      print -r -- "Not cloned, skipping: $dir"
      print -r -- "Run ./setup.sh link from the dotfiles repo to clone it."
      continue
    fi

    before="$(git -C "$dir" rev-parse HEAD 2>/dev/null)"
    if ! GIT_TERMINAL_PROMPT=0 git -C "$dir" pull --ff-only --quiet; then
      failed+=("$label")
      continue
    fi
    after="$(git -C "$dir" rev-parse HEAD 2>/dev/null)"

    if [[ "$before" == "$after" ]]; then
      print -r -- "Already up to date."
      continue
    fi
    git -C "$dir" --no-pager log --no-decorate --format='  %h %s (%cr)' "$before..$after"
    url="$(_dotfiles_repo_url "$dir")" && print -r -- "  Changes: $(_dotfiles_review_url "$url" "$before" "$after")"
  done

  # Drop the cached notice; the next terminal checks again from scratch.
  rm -f "$_DOTFILES_UPDATE_CACHE"

  print -r -- ""
  if (( ${#failed} )); then
    print -r -- "Failed to update (see the git output above):"
    print -rl -- "  - "${^failed}
  else
    print -r -- "Everything is up to date."
  fi
  print -r -- "Open a new terminal (or run 'exec zsh') to load the changes."
  print -r -- "If the dotfiles repo added new plugins or themes, run ./setup.sh link to clone them."
  (( ${#failed} == 0 ))
}

# Prints the web URL of a repo's remote ($2, default origin), turning SSH
# remotes into https.
_dotfiles_repo_url() {
  local url
  url="$(git -C "$1" remote get-url "${2:-origin}" 2>/dev/null)" || return 1
  url="${url%.git}"
  case "$url" in
    git@*:*)     url="https://${${url#git@}/://}" ;;
    ssh://git@*) url="https://${url#ssh://git@}" ;;
  esac
  print -r -- "$url"
}

# Prints a GitHub compare link between two commits, or the repo URL for
# other hosts.
_dotfiles_review_url() {
  local url="$1" old="$2" new="$3"
  if [[ "$url" == https://github.com/* ]]; then
    print -r -- "$url/compare/${old:0:12}...${new:0:12}"
  else
    print -r -- "$url"
  fi
}

# Fetches one repo and prints its notice lines. Exit status: 0 when it has
# updates, 1 when it is up to date, 2 when the check failed (reason on stderr).
_dotfiles_check_repo() {
  local label="$1" dir="$2" upstream remote count subject url

  if ! upstream="$(git -C "$dir" rev-parse --abbrev-ref '@{u}' 2>/dev/null)"; then
    print -u2 -r -- "The current branch has no upstream branch configured."
    return 2
  fi
  remote="${upstream%%/*}"
  git -C "$dir" fetch --quiet "$remote" || return 2
  count="$(git -C "$dir" rev-list --count 'HEAD..@{u}')" || return 2
  (( count > 0 )) || return 1

  subject="$(git -C "$dir" log -1 --format='%s (%cr)' '@{u}')"
  print -r -- "  - $label: $count new commit${${count:#1}:+s}"
  print -r -- "      latest: $subject"
  if url="$(_dotfiles_repo_url "$dir" "$remote")"; then
    print -r -- "      review: $(_dotfiles_review_url "$url" "$(git -C "$dir" rev-parse HEAD)" "$(git -C "$dir" rev-parse '@{u}')")"
  fi
  return 0
}

# Prints the update notice (empty when there is nothing to report). Reuses the
# cached result while it is fresher than DOTFILES_UPDATE_CHECK_INTERVAL.
_dotfiles_check_updates() {
  emulate -L zsh
  zmodload zsh/datetime || return
  zmodload -F zsh/stat b:zstat || return

  local cache="$_DOTFILES_UPDATE_CACHE" log="$_DOTFILES_UPDATE_LOG"
  local lock="$_DOTFILES_UPDATE_CACHE.lock" interval="${DOTFILES_UPDATE_CHECK_INTERVAL:-21600}"
  local mtime label dir block rc
  local -a updates failed notice

  if [[ -f "$cache" ]] && zstat -A mtime +mtime "$cache" 2>/dev/null \
      && (( EPOCHSECONDS - mtime < interval )); then
    print -rn -- "$(<"$cache")"
    return
  fi

  mkdir -p "${cache:h}" "${log:h}" || return

  # Only one terminal checks at a time; the others show nothing this time.
  # A lock older than 5 minutes was left by a check that got killed.
  if ! mkdir "$lock" 2>/dev/null; then
    zstat -A mtime +mtime "$lock" 2>/dev/null && (( EPOCHSECONDS - mtime > 300 )) || return
    rmdir "$lock" 2>/dev/null
    mkdir "$lock" 2>/dev/null || return
  fi

  {
    # Exported only inside this background subshell, never in the terminal.
    export GIT_TERMINAL_PROMPT=0 GIT_HTTP_LOW_SPEED_LIMIT=1000 GIT_HTTP_LOW_SPEED_TIME=15
    export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -o BatchMode=yes -o ConnectTimeout=10}"

    for label dir in "${DOTFILES_UPDATE_REPOS[@]}"; do
      [[ -e "$dir/.git" ]] || continue
      block="$(_dotfiles_check_repo "$label" "$dir" 2>"$lock/stderr")"
      rc=$?
      case $rc in
        0) updates+=("$block") ;;
        2)
          failed+=("$label")
          {
            print -r -- "[$(strftime '%F %T' $EPOCHSECONDS)] $label ($dir)"
            <"$lock/stderr"
            print -r -- ""
          } >>"$log.new"
          ;;
      esac
    done

    if (( ${#updates} )); then
      notice+=("[dotfiles] Updates available:" "${updates[@]}")
      notice+=("  Review the changes at the links above, then run: update-my-dotfile-config")
    fi

    if (( ${#failed} )); then
      # Not cached, so the next terminal tries again.
      mv -f "$log.new" "$log"
      notice+=("[dotfiles] Could not check for updates: ${(j:, :)failed}")
      notice+=("  Usually a network problem; the git errors are in $log")
    else
      rm -f "$log"
      print -rn -- "${(F)notice}" >|"$cache.$$" && mv -f "$cache.$$" "$cache"
    fi
    print -rn -- "${(F)notice}"
  } always {
    rm -rf "$lock" "$log.new" "$cache.$$"
  }
}

# Called by zle when the background check has finished writing.
_dotfiles_update_notice() {
  local fd="$1" output
  zle -F "$fd"
  read -r -d '' -u "$fd" output
  exec {fd}<&-

  [[ -n "${output//[[:space:]]/}" ]] || return 0
  zle -I
  print -r -- "${output%$'\n'}"
}

# Starts the check on the first prompt, after ~/.zsh_local has been sourced
# (so its settings apply) and after p10k's instant prompt is done.
_dotfiles_update_check_start() {
  add-zsh-hook -d precmd _dotfiles_update_check_start
  [[ "${DOTFILES_UPDATE_CHECK:-1}" != 0 ]] || return 0

  local fd
  exec {fd}< <(_dotfiles_check_updates 2>/dev/null) || return 0
  zle -F "$fd" _dotfiles_update_notice
}

if [[ -o interactive ]]; then
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _dotfiles_update_check_start
fi
