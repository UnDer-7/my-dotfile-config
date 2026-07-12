# Agent Instructions

## Language

All code, comments, and documentation in this repository must be written in English. This applies to every file (scripts, configs, README, this file included) regardless of the language used in the conversation.

## What this repo is

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package (`zsh/`, `vim/`, and more added over time). The internal layout of each package mirrors exactly where its files should land under `$HOME` — e.g. `zsh/.config/zsh/.zshrc` symlinks to `~/.config/zsh/.zshrc`, `vim/.vimrc` symlinks to `~/.vimrc`.

Supports two machines with different package sets:
- **Linux**: `zsh`, `vim` (more packages added here over time)
- **macOS**: `zsh`, `vim`

## Commands

- `./setup link` — symlink the OS-appropriate packages into `$HOME` via `stow`. Installs `stow` first if missing (asks before installing).
- `./setup unlink` — remove those symlinks (`stow -D`).
- `bash -n setup` — syntax-check the setup script without running it.

There is no build/lint/test suite in this repo.

## Architecture notes

- **Package = Stow package**, not an app grouping. A package's directory tree under its root is the literal path that will be symlinked under `$HOME` (Stow's `--target` convention). When adding a new package, create it as `<pkg>/<path-as-it-should-appear-under-$HOME>`.
- **`setup`** (bash, `set -euo pipefail`) is the only entry point for linking/unlinking. It detects the OS via `uname -s` and picks the package list accordingly — that list lives inline in the script (`PACKAGES=(...)` per OS branch), not in a config file.
- **ZDOTDIR indirection**: `zsh/.zshenv` sets `ZDOTDIR="$HOME/.config/zsh"`. Stow symlinks `~/.zshenv` and `~/.config/zsh` (the whole `zsh/.config/zsh/` package subtree), so all of `.zshrc`, `alias/`, `functions/`, `plugins/`, `themes/` live under `$ZDOTDIR`. Inside `.zshrc`, `ZSH_HOME=$ZDOTDIR` and everything else (`ZSH_PLUGINS_FOLDER`, `ZSH_THEMES_FOLDER`, etc.) derives from it — don't hardcode a repo path here.
- **Plugins and themes are intentionally NOT vendored in git.** Only the manifest/config that says which plugin or theme to use is tracked (`zsh/.config/zsh/plugins/.zsh_plugins.zsh`, `zsh/.config/zsh/themes/.zsh_theme.zsh`, `zsh/.config/zsh/themes/p10k/.p10k.zsh`). The actual plugin/theme code is installed manually on each machine and stays gitignored — see the `.gitignore` rules for `/zsh/.config/zsh/plugins/*` and `/zsh/.config/zsh/themes/*` (with explicit exceptions for the tracked manifest files). Do not turn plugins/themes into git submodules — this is a deliberate, standing decision.
- **`~/.zsh_local` and `~/.zsh_secrets`** are real files outside the repo, never tracked, never managed by Stow. `.zshrc` creates them (empty, with restrictive permissions) on first run if missing, and sources them last so they can override anything else. Machine-specific config goes in `.zsh_local`; secrets/tokens go in `.zsh_secrets`.
- **Stow will refuse to link if a real (non-symlink) file already exists at the target path** (e.g. a pre-existing `~/.zshrc`, `~/.vimrc`, `~/.config/zsh`). `setup` does not attempt automatic backup/removal of conflicting files — that's a manual prerequisite, documented in the README, by design (to avoid risky backup logic in the script).
