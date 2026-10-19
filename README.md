# my-dotfile-config

Dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each
top-level directory in the repo is a Stow package (`zsh/`, `vim/`, `kitty/`, `claude/`, ...), with
the internal layout mirroring exactly where the files should land under
`$HOME` (e.g. `zsh/.config/zsh/.zshrc` becomes `~/.config/zsh/.zshrc`).

## Packages per OS

- **Linux**: `zsh`, `vim`, `kitty`, `claude` (more packages will be added here in the future)
- **macOS**: `zsh`, `vim`, `kitty`, `claude`

The `./setup.sh` script detects the OS automatically and picks the right list.

## Manual dependencies

The script links the configs but does not install the programs that use them.
Install these yourself (with your package manager or the official installer);
`./setup.sh link` ends by listing the ones still missing, without failing:

| Program  | Why                                          |
|----------|----------------------------------------------|
| `zsh`    | shell (zsh config); must be the default shell: `chsh -s "$(command -v zsh)"` |
| `vim`    | editor, `EDITOR=vim` (vim config)            |
| `kitty`  | terminal (kitty config)                      |
| `claude` | Claude Code (claude config)                  |
| `jq`     | needed by the Claude Code status line        |

The script itself needs `git` and `curl` (it stops if they are missing) and
`stow` (it offers to install it).

When adding a dependency, update both this table and `check_dependencies` in
`setup.sh`.

## Bootstrap on a new machine

1. Clone the repo:

   ```sh
   git clone git@github.com:UnDer-7/my-dotfile-config.git ~/my-dotfile-config
   cd ~/my-dotfile-config
   ```

2. **Manual backup/removal of conflicting real files.** Stow refuses to
   create a symlink if a *real* file (not a symlink) already exists at the
   target. Before the first `./setup.sh link`, check and manually move/remove,
   if present:

   - `~/.zshenv`
   - `~/.zshrc` (old version, if it still exists outside the `ZDOTDIR` scheme)
   - `~/.vimrc`
   - `~/.config/kitty/kitty.conf`
   - `~/.claude/settings.json`, `~/.claude/CLAUDE.md`, `~/.claude/statusline.sh`
   - `~/.config/zsh`

   The script **does not** back these up automatically — this is a required
   manual step, to avoid risky backup logic inside the script.

3. Run `./setup.sh link`. The script:
   - detects the OS (`Linux`/`Darwin`) and picks the right packages;
   - checks whether `stow` is installed; if not, it asks before installing
     (via `apt-get`/`pacman`/`dnf` on Linux, or `brew` on macOS — in that
     case Homebrew must already be installed);
   - creates `~/.config` and `~/.claude` if missing, so Stow links only the
     files/subdirectories inside them instead of the whole directories;
   - runs `stow -v -t "$HOME" -d "$REPO_DIR" <packages>`;
   - clones the zsh plugins and theme (see step 4);
   - installs the Powerlevel10k fonts (see step 5);
   - lists missing manual dependencies and warns if zsh is not the default
     shell (see [Manual dependencies](#manual-dependencies)).

   Requires `git` and `curl`. Re-running is safe: plugins, theme and fonts
   that are already present are skipped.

4. **Zsh plugins and theme are not versioned in git** — only the manifest
   (`.zsh_plugins.zsh`) and the theme config (`.zsh_theme.zsh`, `.p10k.zsh`)
   are tracked. `./setup.sh link` clones them (`git clone --depth=1`) into
   `~/.config/zsh`:

   | Path under `~/.config/zsh/`        | Repo                                                    |
   |------------------------------------|---------------------------------------------------------|
   | `plugins/fast-syntax-highlighting` | https://github.com/zdharma-continuum/fast-syntax-highlighting |
   | `plugins/zsh-autosuggestions`      | https://github.com/zsh-users/zsh-autosuggestions        |
   | `plugins/zsh-completions`          | https://github.com/zsh-users/zsh-completions            |
   | `themes/p10k/powerlevel10k`        | https://github.com/romkatv/powerlevel10k                |

   It also clones the kitty themes (`kitty.conf` includes its theme from
   there). Kitty itself is not installed by the script, only its config:

   | Path under `~/.config/kitty/` | Repo                                     |
   |-------------------------------|------------------------------------------|
   | `kitty-themes`                | https://github.com/dexpota/kitty-themes |

   To update them, run `git pull` inside each directory.

5. **Powerlevel10k font.** `./setup.sh link` installs the four MesloLGS NF
   `.ttf` files for the current user (no sudo):
   - Linux: `${XDG_DATA_HOME:-~/.local/share}/fonts`, then `fc-cache -f`;
   - macOS: `~/Library/Fonts`.

   **Manual step:** set `MesloLGS NF` as your terminal's font — see
   https://github.com/romkatv/powerlevel10k#manual-font-installation.

6. `~/.zsh_local` and `~/.zsh_secrets` remain real files outside the repo,
   created automatically (empty) the first time `.zshrc` is sourced, if they
   don't already exist. Used for machine-specific overrides and secrets —
   never versioned.

7. Zsh history lives in `~/.local/state/zsh/history` and the completion dump
   in `~/.cache/zsh/zcompdump` (respecting `XDG_STATE_HOME`/`XDG_CACHE_HOME`),
   outside the repo.

## Reverting

```sh
./setup.sh unlink
```

Removes the symlinks created by Stow (`stow -D`). Real files inside the repo
are not affected.

## Why Stow

- Each package is isolated (zsh, vim, ...) — lets you link only what a given
  machine needs.
- No extra dependency: just `stow` itself, `setup.sh` is plain bash (no
  Justfile/Makefile).
- Third-party plugins/themes stay out of git (gitignored), only the manifest
  of which plugin/theme to use is tracked — same behavior as before the
  migration.
