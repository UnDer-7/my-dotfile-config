# Programs

Programs to install on a new machine. `./setup.sh` only links the configs and
never installs these: use your package manager or the official installer.

## Essentials (install these first)

These are the programs whose config lives in this repo. Install them first, in
this order, before running `./setup.sh link`:

| # | Program     | Why                                                                                 | Link                                                 |
|---|-------------|-------------------------------------------------------------------------------------|------------------------------------------------------|
| 1 | zsh         | Shell (`zsh` package). Make it the default shell: `chsh -s "$(command -v zsh)"`     | https://www.zsh.org                                  |
| 2 | kitty       | Terminal (`kitty` package)                                                          | https://sw.kovidgoyal.net/kitty/binary/              |
| 3 | Vim         | Editor (`vim` package)                                                              | https://www.vim.org/download.php                     |
| 4 | jq          | Needed by the Claude Code status line                                               | https://jqlang.org/download/                         |
| 5 | Claude Code | AI coding assistant (`claude` package)                                              | https://docs.anthropic.com/en/docs/claude-code/setup |

## Git and GitHub setup

Better done right after the essentials and before the [Development](#development)
programs, so cloning and committing already work as expected. Install `git` and
the [GitHub CLI](https://cli.github.com) (`gh`) first, then run once:

```sh
# Identity
git config --global user.name "<your name>"
git config --global user.email "<your email>"

# Defaults
git config --global init.defaultBranch main
git config --global pull.rebase false

# Always use HTTPS for GitHub (git and gh), with gh as the credential helper
gh auth login --git-protocol https --web
gh config set git_protocol https
gh auth setup-git
git config --global url."https://github.com/".insteadOf "git@github.com:"
git config --global --add url."https://github.com/".insteadOf "ssh://git@github.com/"

# Signed commits and tags (GPG)
gpg --list-secret-keys --keyid-format=long   # pick the key ID (after "sec   rsa4096/")
git config --global user.signingkey <key-id>
git config --global commit.gpgsign true
git config --global tag.gpgSign true
gh gpg-key add <(gpg --armor --export <key-id>)   # register the public key on GitHub
```

The GPG key itself is not in this repo. Either bring it from another machine
(`gpg --export-secret-keys --armor <key-id>` there, `gpg --import` here) or
create a new one with `gpg --full-generate-key`.

## Development

| Program                           | Notes                                             | Link                                    |
|-----------------------------------|---------------------------------------------------|-----------------------------------------|
| SDKMAN (Java, Maven, Gradle)      |                                                   | https://sdkman.io/install               |
| fnm (Node.js)                     |                                                   | https://github.com/Schniz/fnm           |
| Go                                |                                                   | https://go.dev/dl/                      |
| Docker (and Docker Compose)       |                                                   | https://docs.docker.com/engine/install/ |
| JetBrains Toolbox (IntelliJ IDEA) | Install IntelliJ IDEA from the Toolbox            | https://www.jetbrains.com/toolbox-app/  |
| Visual Studio Code                | Code - OSS as an alternative                      | https://code.visualstudio.com           |
| Postman                           |                                                   | https://www.postman.com/downloads/      |
| Bruno                             |                                                   | https://www.usebruno.com                |
| GitHub CLI (`gh`)                 | See [Git and GitHub setup](#git-and-github-setup) | https://cli.github.com                  |
| ripgrep (`rg`)                    | Fast `grep` replacement                           | https://github.com/BurntSushi/ripgrep   |
| Meld                              | Visual diff/merge for files and folders           | https://meldmerge.org                   |
| just                              | Command runner for project tasks                  | https://github.com/casey/just           |

## Browsers

| Program     | Link                                 |
|-------------|--------------------------------------|
| Firefox     | https://www.mozilla.org/firefox/     |
| Chrome      | https://www.google.com/chrome/       |
| Zen Browser | https://zen-browser.app              |

## Utilities

| Program      | Notes                                                                                                                                       | Link                                       |
|--------------|---------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------|
| 7-Zip        |                                                                                                                                             | https://www.7-zip.org                      |
| zip / unzip  | Usually from the package manager                                                                                                            |                                            |
| CopyQ        | Clipboard manager (or any other)                                                                                                            | https://hluk.github.io/CopyQ/              |
| xclip        | Copy from the terminal (or similar: `wl-clipboard` on Wayland, `pbcopy` is built into macOS)                                                | https://github.com/astrand/xclip           |
| eza          | Modern `ls`. The `ls`/`ll`/`la`/`lt` aliases use it when installed, falling back to plain `ls`. Switch color themes with `eza-theme <name>` | https://eza.rocks                          |
| zoxide       | Smarter `cd` (`z`, `zi`). `.zshrc` only initializes it when installed                                                                       | https://github.com/ajeetdsouza/zoxide      |
| fzf          | Fuzzy finder. Used by `zi` and `z foo<SPACE><TAB>` for interactive selection                                                                | https://github.com/junegunn/fzf            |
| MediaInfo    |                                                                                                                                             | https://mediaarea.net/en/MediaInfo         |
| HandBrake    |                                                                                                                                             | https://handbrake.fr                       |
| virt-manager | Linux only                                                                                                                                  | https://virt-manager.org                   |
| qBittorrent  | Torrent client                                                                                                                              | https://www.qbittorrent.org                |
| btop         | System monitor                                                                                                                              | https://github.com/aristocratic/btop       |
| Glances      | System monitor                                                                                                                              | https://nicolargo.github.io/glances/       |
| fastfetch    | System info in the terminal                                                                                                                 | https://github.com/fastfetch-cli/fastfetch |
| unrar        | Extract `.rar` files. Usually from the package manager                                                                                      |                                            |
| wget         | Download files. Usually from the package manager                                                                                            |                                            |
| rsync        | Sync/copy files. Usually from the package manager                                                                                           |                                            |
| pv           | Progress bar for pipes. Usually from the package manager                                                                                    |                                            |
| duf          | Disk usage overview                                                                                                                         | https://github.com/muesli/duf              |

## Media and communication

| Program        | Notes                                    | Link                                   |
|----------------|------------------------------------------|----------------------------------------|
| Spotify        |                                          | https://www.spotify.com/download/      |
| VLC            | Video player                             | https://www.videolan.org/vlc/          |
| Haruna         | Video player (KDE)                       | https://apps.kde.org/haruna/           |
| Plex           | Client only (`plezy` as an alternative)  | https://www.plex.tv/apps-devices/      |
| Discord        |                                          | https://discord.com/download           |
| Steam          |                                          | https://store.steampowered.com/about/  |

## Personal

| Item       | Notes                       | Link                                         |
|------------|-----------------------------|----------------------------------------------|
| Wallpapers | Clone the repo              | https://github.com/UnDer-7/my-wallpepers     |

## Needed by `setup.sh` itself

`git` and `curl` must be installed before running the script (it stops if they
are missing). `stow` is installed by the script if missing (it asks first).
