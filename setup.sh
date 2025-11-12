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
  brew bundle --file="$INSTALL_DIR/Brewfile"
  print_success "Packages installed"
fi

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

# Symlink all config directories/files
print_info "Creating symlinks..."

# Find all items in the dotfiles directory (excluding .git, README, etc.)
cd "$INSTALL_DIR"
for item in *; do
  # Skip hidden files, README, and other non-config files
  if [[ "$item" == "."* ]] || [[ "$item" == "README"* ]] || [[ "$item" == "setup.sh" ]] || [[ "$item" == "LICENSE"* ]] || [[ "$item" == "Brewfile"* ]]; then
    continue
  fi

  source_path="$INSTALL_DIR/$item"
  target_path="$CONFIG_DIR/$item"

  create_symlink "$source_path" "$target_path"
done

# Source shell config if present
for shell_config in .zshrc .bashrc .bash_profile; do
  if [ -f "$INSTALL_DIR/$shell_config" ]; then
    target="$HOME/$shell_config"
    create_symlink "$INSTALL_DIR/$shell_config" "$target"
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
