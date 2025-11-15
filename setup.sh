#!/bin/bash
set -e

# ────────────────────────────────────────────────
# 🎨 Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ────────────────────────────────────────────────
# ⚙️ Config
REPO_URL="https://github.com/thekauer/dots.git"
NVIM_REPO_URL="https://github.com/thekauer/nvim.git"
INSTALL_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# ────────────────────────────────────────────────
# 🪶 Helper functions
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${YELLOW}→${NC} $1"; }

create_symlink() {
  local source="$1"
  local target="$2"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    print_info "Backing up existing $target"
    mv "$target" "$BACKUP_DIR/"
  fi

  [ -L "$target" ] && rm "$target"
  ln -s "$source" "$target"
  print_success "Linked $(basename "$source")"
}

# ────────────────────────────────────────────────
# 🧩 Step functions
check_os() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
  fi
}

install_homebrew() {
  if ! command -v brew &>/dev/null; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    print_success "Homebrew installed"
  else
    print_success "Homebrew already installed"
  fi
}

clone_or_update_repo() {
  local url="$1"
  local dir="$2"
  local name="$3"

  if [ -d "$dir" ]; then
    print_info "$name directory exists, pulling latest changes..."
    cd "$dir" && git pull
  else
    print_info "Cloning $name repository..."
    git clone "$url" "$dir"
  fi
  print_success "$name ready at $dir"
}

install_brewfile() {
  if [ -f "$INSTALL_DIR/Brewfile" ]; then
    print_info "Installing packages from Brewfile..."
    set +e
    brew bundle --file="$INSTALL_DIR/Brewfile"
    set -e
    print_success "Packages installed"
  fi
}

setup_zsh() {
  [ ! -f ~/.zshrc ] && touch ~/.zshrc
  if ! grep -q "powerlevel10k.zsh-theme" ~/.zshrc; then
    echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
    print_success "Added Powerlevel10k theme to ~/.zshrc"
  fi
}

backup_and_prepare_config_dir() {
  mkdir -p "$CONFIG_DIR"
  mkdir -p "$BACKUP_DIR"
  print_info "Backing up existing configs to $BACKUP_DIR..."
}

link_configs() {
  print_info "Linking configurations to $CONFIG_DIR"
  for item in config iterm_config.json raycast raycast_plugins; do
    local src="$INSTALL_DIR/$item"
    [ -e "$src" ] && create_symlink "$src" "$CONFIG_DIR/$item"
  done
}

link_dotfiles() {
  print_info "Linking dotfiles to $HOME"
  for item in .tmux.conf .p10k.zsh; do
    local src="$INSTALL_DIR/$item"
    if [ -e "$src" ]; then
      [[ "$item" == ".p10k.zsh" ]] && print_info "Linking Powerlevel10k configuration..."
      create_symlink "$src" "$HOME/$item"
    fi
  done
}

setup_neovim_config() {
  print_info "Setting up Neovim configuration..."
  clone_or_update_repo "$NVIM_REPO_URL" "$CONFIG_DIR/nvim" "Neovim config"
}

setup_tmux_plugins() {
  print_info "Setting up tmux plugin manager (TPM)..."
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [ -d "$tpm_dir" ]; then
    print_info "TPM already installed, pulling latest changes..."
    cd "$tpm_dir" && git pull
  else
    print_info "Cloning TPM..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  fi

  if [ -f "$HOME/.tmux.conf" ]; then
    print_info "Installing tmux plugins..."
    "$tpm_dir/bin/install_plugins" >/dev/null 2>&1 || true
    print_success "Tmux plugins installed"
  else
    print_info "No .tmux.conf found, skipping plugin installation"
  fi
}

cleanup_backup_dir() {
  if [ -z "$(ls -A "$BACKUP_DIR")" ]; then
    rmdir "$BACKUP_DIR"
  else
    print_info "Backups saved to: $BACKUP_DIR"
  fi
}

# ────────────────────────────────────────────────
# 🧠 Main setup flow
main() {
  print_info "Starting dotfiles installation..."
  check_os
  install_homebrew
  clone_or_update_repo "$REPO_URL" "$INSTALL_DIR" "Dotfiles"
  install_brewfile
  setup_zsh
  backup_and_prepare_config_dir
  link_configs
  link_dotfiles
  setup_neovim_config
  setup_tmux_plugins
  cleanup_backup_dir

  print_success "Dotfiles installation complete!"
  print_info "Please restart your terminal or run 'source ~/.zshrc'"
}

main "$@"
