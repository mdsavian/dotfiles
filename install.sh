#!/usr/bin/env bash
# Dotfiles installer for macOS.
# Idempotent: safe to re-run. Backs up existing dotfiles to ~/.dotfiles-backup-<timestamp>/.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

log()  { printf "\033[1;34m[*]\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m[\xe2\x9c\x93]\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m[!]\033[0m %s\n" "$*"; }

# --- 1. Homebrew ---
if ! command -v brew >/dev/null 2>&1; then
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for this session (Apple Silicon)
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  ok "Homebrew already installed"
fi

# --- 2. Brew packages ---
log "Installing brew formulae..."
BREW_PACKAGES=(
  asdf
  fzf
  gh
  tmux
  zoxide
  zsh
)
brew install "${BREW_PACKAGES[@]}" || warn "Some formulae may already be installed"

log "Installing brew casks (apps)..."
brew install --cask iterm2 || warn "iterm2 may already be installed"

# --- 3. fzf shell integration ---
if [[ ! -f "$HOME/.fzf.zsh" ]]; then
  log "Installing fzf shell integration..."
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
else
  ok "fzf shell integration already installed"
fi

# --- 4. oh-my-zsh ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  log "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  ok "oh-my-zsh already installed"
fi

# --- 5. powerlevel10k ---
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  log "Installing powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  ok "powerlevel10k already installed"
fi

# --- 6. zsh custom plugins ---
ZSH_CUSTOM_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"
for plugin_repo in \
  "zsh-users/zsh-autosuggestions" \
  "zsh-users/zsh-syntax-highlighting"
do
  plugin_name="${plugin_repo##*/}"
  if [[ ! -d "$ZSH_CUSTOM_PLUGINS/$plugin_name" ]]; then
    log "Installing $plugin_name..."
    git clone --depth=1 "https://github.com/$plugin_repo" "$ZSH_CUSTOM_PLUGINS/$plugin_name"
  else
    ok "$plugin_name already installed"
  fi
done

# --- 7. tpm (tmux plugin manager) ---
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  log "Installing tpm..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  ok "tpm already installed"
fi

# --- 8. nvm ---
if [[ ! -d "$HOME/.nvm" ]]; then
  log "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
  ok "nvm already installed"
fi

# --- 9. Symlink dotfiles ---
link() {
  local src="$1"
  local dest="$2"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    mkdir -p "$BACKUP_DIR"
    log "Backing up existing $dest -> $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  elif [[ -L "$dest" ]]; then
    rm "$dest"
  fi
  ln -s "$src" "$dest"
  ok "Linked $dest -> $src"
}

log "Symlinking dotfiles..."
link "$DOTFILES_DIR/zsh/.zshrc"      "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/.p10k.zsh"   "$HOME/.p10k.zsh"
link "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/git/.gitconfig"  "$HOME/.gitconfig"

# --- 9b. iTerm2 prefs (load from this repo, not ~/Library/Preferences) ---
# iTerm2 rewrites its plist on save, so we don't symlink it; instead we point
# iTerm2 at a custom folder in this repo via its native "load prefs" feature.
ITERM_PREFS_DIR="$DOTFILES_DIR/iterm2"
if [[ -d "$ITERM_PREFS_DIR" ]]; then
  log "Pointing iTerm2 at custom prefs folder..."
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM_PREFS_DIR"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  ok "iTerm2 set to load prefs from $ITERM_PREFS_DIR (restart iTerm2 to apply)"
else
  warn "iTerm2 prefs folder not found at $ITERM_PREFS_DIR; skipping"
fi

# --- 10. Install tmux plugins via tpm ---
log "Installing tmux plugins via tpm..."
"$TPM_DIR/bin/install_plugins" || warn "tpm install_plugins failed; run prefix + I inside tmux"

# --- 11. Done ---
echo
ok "Dotfiles installed."
echo
cat <<'EOF'
NEXT STEPS (manual):

  1. Restart your terminal (or `exec zsh`) to load the new shell.
  2. Generate a new SSH key for THIS machine and add it to GitHub:
       ssh-keygen -t ed25519 -C "your-email@example.com"
       gh auth login           # uses the browser; no token in .gitconfig
       gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"
  3. Open tmux and press `prefix + I` if any plugins are missing.
  4. Install your Node version: `nvm install --lts`
  5. (Optional) Re-run `p10k configure` if the prompt looks off.
  6. Restart iTerm2 so it loads prefs from the repo. Then in
     Settings > General > Settings, set "Save changes" to "Automatically"
     so future tweaks are written back to the repo.

If something looks wrong, your old dotfiles are in:
EOF
echo "  $BACKUP_DIR"
