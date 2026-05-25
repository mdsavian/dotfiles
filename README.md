# dotfiles

Personal macOS dev environment: zsh (oh-my-zsh + powerlevel10k), tmux (tpm + dracula), git.

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
└── git/
    └── .gitconfig      # no token; auth via `gh auth login`
```

## Updating

Edit the file in `~/dotfiles/` directly (the symlink in `$HOME` points here). Commit and push.
On the other machine: `git pull` — no reinstall needed.
