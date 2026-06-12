# dotfiles

Personal macOS dev environment: zsh (oh-my-zsh + powerlevel10k), tmux (tpm + dracula), git, iTerm2.

## Install on a new machine

```bash
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer is idempotent. Existing dotfiles get moved to `~/.dotfiles-backup-<timestamp>/` before the symlinks are created.

## What's NOT in this repo (by design)

- **SSH private keys** — generate a fresh key per machine and add it to GitHub.
- **GitHub auth token** — use `gh auth login` instead of storing a token in `.gitconfig`.
- **Cloud credentials** (`~/.aws`, `~/.kube`, `~/.doppler`, `~/.gnupg`) — recreate via the respective CLIs.
- **Host-specific SSH configs** — `~/.ssh/config` stays per-machine.

## Layout

```
dotfiles/
├── install.sh          # idempotent installer
├── zsh/
│   ├── .zshrc
│   └── .p10k.zsh
├── tmux/
│   └── .tmux.conf
├── git/
│   └── .gitconfig      # no token; auth via `gh auth login`
└── iterm2/
    └── com.googlecode.iterm2.plist   # loaded via iTerm2's "custom folder" feature
```

## iTerm2 preferences

iTerm2's plist isn't symlinked (iTerm2 rewrites the file on save, which breaks
symlinks). Instead `install.sh` points iTerm2 at `iterm2/` in this repo via its
native **Load preferences from a custom folder** feature:

```bash
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$PWD/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
```

After the first install, open **Settings > General > Settings** and set
**Save changes** to **Automatically** so future tweaks are written back to the
repo on quit. Then just commit the updated plist (it's a binary file, so diffs
show only "Binary file changed").

## Updating

Edit the file in `~/dotfiles/` directly (the symlink in `$HOME` points here). Commit and push.
On the other machine: `git pull` — no reinstall needed.
