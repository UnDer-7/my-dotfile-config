# my-dotfile-config

Dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each
top-level directory in the repo is a Stow package (`zsh/`, `vim/`, ...), with
the internal layout mirroring exactly where the files should land under
`$HOME` (e.g. `zsh/.config/zsh/.zshrc` becomes `~/.config/zsh/.zshrc`).

## Packages per OS

- **Linux**: `zsh`, `vim` (more packages will be added here in the future)
- **macOS**: `zsh`, `vim`

The `./setup.sh` script detects the OS automatically and picks the right list.

## Bootstrap on a new machine

1. Clone the repo:

   ```sh
   git clone git@github.com:UnDer-7/my-dotfile-config.git ~/my-dotfile-config
   cd ~/my-dotfile-config
   ```

2. **Manual backup/removal of conflicting real files.** Stow refuses to
   create a symlink if a *real* file (not a symlink) already exists at the
   target. Before the first `./setup link`, check and manually move/remove,
   if present:

   - `~/.zshenv`
   - `~/.zshrc` (old version, if it still exists outside the `ZDOTDIR` scheme)
   - `~/.vimrc`
   - `~/.config/zsh`

   The script **does not** back these up automatically — this is a required
   manual step, to avoid risky backup logic inside the script.

3. Run `./setup link`. The script:
   - detects the OS (`Linux`/`Darwin`) and picks the right packages;
   - checks whether `stow` is installed; if not, it asks before installing
     (via `apt-get`/`pacman`/`dnf` on Linux, or `brew` on macOS — in that
     case Homebrew must already be installed);
   - runs `stow -v -t "$HOME" -d "$REPO_DIR" <packages>`.

4. **Zsh plugins and theme (p10k, fast-syntax-highlighting,
   zsh-autosuggestions, zsh-completions) are not versioned in git** — only
   the manifest (`.zsh_plugins.zsh`) and the theme config (`.zsh_theme.zsh`,
   `.p10k.zsh`) are tracked. The actual plugin content needs to be installed
   manually after `link`.

   TODO - figure out how to document this.

5. `~/.zsh_local` and `~/.zsh_secrets` remain real files outside the repo,
   created automatically (empty) the first time `.zshrc` is sourced, if they
   don't already exist. Used for machine-specific overrides and secrets —
   never versioned.

## Reverting

```sh
./setup unlink
```

Removes the symlinks created by Stow (`stow -D`). Real files inside the repo
are not affected.

## Why Stow

- Each package is isolated (zsh, vim, ...) — lets you link only what a given
  machine needs.
- No extra dependency: just `stow` itself, `setup` is plain bash (no
  Justfile/Makefile).
- Third-party plugins/themes stay out of git (gitignored), only the manifest
  of which plugin/theme to use is tracked — same behavior as before the
  migration.
