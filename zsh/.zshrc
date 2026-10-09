# --- Related to 'd' function, must be before p10k ---
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

autoload -Uz compinit
compinit

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

############
### ENVS ###
############
export DOTFILE_CONFIG_HOME=$HOME/my-dotfile-config

export VISUAL=vim
export EDITOR="$VISUAL"

# Load local secrets (not tracked by git)
if [[ ! -f "$HOME/.zsh_secrets" ]]; then
    echo "[zshrc] ~/.zsh_secrets not found — creating empty file with restricted permissions (600)"
    cat > "$HOME/.zsh_secrets" << 'EOF'
# .zsh_secrets — Secret environment variables
# Use this file for API tokens, passwords and any sensitive credentials.
# This file is NOT tracked by git. For non-sensitive machine-specific envs, use ~/.zsh_local instead.
# Never share or commit this file.
# Permissions: 600 (owner: read/write | group: none | others: none) — only your user can read this file.
#
# Example:
#   export ANTHROPIC_API_KEY=sk-ant-...
#   export SONAR_TOKEN=meu_token
#   export DB_PASSWORD=senha123
EOF
    chmod 600 "$HOME/.zsh_secrets"
fi
source "$HOME/.zsh_secrets"

# ZSH
export ZSH_HOME=$DOTFILE_CONFIG_HOME/zsh
export ZSH_PLUGINS_FOLDER=$ZSH_HOME/plugins
export ZSH_THEMES_FOLDER=$ZSH_HOME/themes
export ZSH_FUNCTIONS_FOLDER=$ZSH_HOME/functions
export ZSH_ALIAS_FOLDER=$ZSH_HOME/alias

# VIM
export VIM_HOME=$DOTFILE_CONFIG_HOME/vim

#############
#### VIM ####
#############
export VIMINIT="source $VIM_HOME/.vimrc"

###############
# ZSH OPTIONS #
###############
export HISTFILE=$ZSH_HOME/.zsh_history

# How many commands zsh will load to memory
HISTSIZE=1000

# How many commands history will save on file
SAVEHIST=1000

# History won't show duplicates on search
setopt HIST_FIND_NO_DUPS

setopt EXTENDED_HISTORY       # record timestamp of command in HISTFILE
setopt HIST_EXPIRE_DUPS_FIRST # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS       # ignore duplicated commands history list
setopt HIST_IGNORE_SPACE      # ignore commands that start with space
setopt HIST_VERIFY            # show command with history expansion to user before running it
setopt SHARE_HISTORY          # share command history data

#############
## PLUGINS ##
#############
source "$ZSH_PLUGINS_FOLDER"/.zsh_plugins.zsh

#############
### THEME ###
#############
source "$ZSH_THEMES_FOLDER"/.zsh_theme.zsh

#############
# FUNCTIONS #
#############
# Automatically load all function files from the functions directory
for function_file in "$ZSH_FUNCTIONS_FOLDER"/*.zsh; do
  source "$function_file"
done

#############
### ALIAS ###
#############
# Automatically load all alias files from the alias directory
for alias_file in "$ZSH_ALIAS_FOLDER"/*.zsh; do
  source "$alias_file"
done

# Load machine-local overrides (not tracked by git)
# Sourced after plugins/aliases/functions so it can override dotfiles defaults.
if [[ ! -f "$HOME/.zsh_local" ]]; then
    echo "[zshrc] ~/.zsh_local not found — creating empty file"
    cat > "$HOME/.zsh_local" << 'EOF'
# .zsh_local — Machine-specific zsh config (not tracked by git)
# Sourced AFTER the main .zshrc, so anything here overrides dotfiles defaults.
# Use for: aliases, functions, exports, PATH changes, or any zsh config specific to this machine.
# For secrets/tokens, use ~/.zsh_secrets instead.
# Permissions: 644 (owner: read/write | group: read | others: read)
#
# Example:
#   export JAVA_HOME=/usr/lib/jvm/java-21
#   alias gs='git status'
#   work_vpn() { sudo openvpn ~/work.ovpn }
EOF
    chmod 644 "$HOME/.zsh_local"
fi
source "$HOME/.zsh_local"

###################
# VERSION MANAGER #
###################
# FNM: Node.js version manager
export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"

# SdkMan: Java, Maven, ... version manager
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
