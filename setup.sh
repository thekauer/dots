#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/thekauer/dots.git"
INSTALL_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

# Helper functions
print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_info() {
  echo -e "${YELLOW}→${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
  print_error "This script is designed for macOS only"
  exit 1
fi

print_info "Starting dotfiles installation..."

[ ! -f ~/.zshrc ] && touch ~/.zshrc

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  print_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  print_success "Homebrew installed"
else
  print_success "Homebrew already installed"
fi

# Clone or update dotfiles repository
if [ -d "$INSTALL_DIR" ]; then
  print_info "Dotfiles directory exists, pulling latest changes..."
  cd "$INSTALL_DIR"
  git pull
else
  print_info "Cloning dotfiles repository..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi
print_success "Repository ready at $INSTALL_DIR"

# Install packages from Brewfile first (before linking configs)
if [ -f "$INSTALL_DIR/Brewfile" ]; then
  print_info "Installing packages from Brewfile..."
  # prevent non zero brew exit code from stopping the entire script
  set +e
  brew bundle --file="$INSTALL_DIR/Brewfile"
  set -e
  print_success "Packages installed"
fi

echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc

# Create .config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Backup existing configs
backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
print_info "Backing up existing configs to $backup_dir..."
mkdir -p "$backup_dir"

# Function to create symlinks
create_symlink() {
  local source="$1"
  local target="$2"

  # If target exists and is not a symlink, back it up
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    print_info "Backing up existing $target"
    mv "$target" "$backup_dir/"
  fi

  # Remove existing symlink if present
  if [ -L "$target" ]; then
    rm "$target"
  fi

  # Create symlink
  ln -s "$source" "$target"
  print_success "Linked $(basename $source)"
}

# Symlink configuration files and directories
print_info "Creating symlinks..."

# Configurations for ~/.config
print_info "Linking configurations to $CONFIG_DIR"
for item in config iterm_config.json raycast raycast_plugins; do
  source_path="$INSTALL_DIR/$item"
  if [ -e "$source_path" ]; then
    create_symlink "$source_path" "$CONFIG_DIR/$item"
  fi
done

# Dotfiles for ~
print_info "Linking dotfiles to $HOME"
for item in .tmux.conf .p10k.zsh; do
  source_path="$INSTALL_DIR/$item"
  if [ -e "$source_path" ]; then
    if [[ "$item" == ".p10k.zsh" ]]; then
      print_info "Linking Powerlevel10k configuration..."
    fi
    create_symlink "$source_path" "$HOME/$item"
  fi
done

print_success "Dotfiles installation complete!"
print_info "Please restart your terminal or run 'source ~/.zshrc' (or your shell config)"

# Check if backup directory is empty and remove if so
if [ -z "$(ls -A $backup_dir)" ]; then
  rmdir "$backup_dir"
else
  print_info "Backups saved to: $backup_dir"
fi
