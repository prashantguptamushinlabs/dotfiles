#!/usr/bin/env bash
set -euo pipefail

# Restore workstation setup from this repository.
# Run interactively or let Claude Code guide you through it.

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
home_dir="${HOME:?HOME must be set}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { printf "${GREEN}[INFO]${NC} %s\n" "$1"; }
warn()  { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
error() { printf "${RED}[ERROR]${NC} %s\n" "$1"; }

confirm() {
  local prompt="$1"
  local response
  printf "%s [y/N] " "$prompt"
  read -r response
  [[ "$response" =~ ^[Yy]$ ]]
}

# Parse arguments
DRY_RUN=false
COMPONENT=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --component) COMPONENT="$2"; shift 2 ;;
    --help|-h)
      cat <<EOF
Usage: ./setup.sh [OPTIONS]

Options:
  --dry-run         Show what would be done without making changes
  --component NAME  Only run specific component: shell, apps, gnome, claude, all
  --help            Show this help

Components:
  shell   - zsh, oh-my-zsh, powerlevel10k, shell configs
  apps    - snap packages, apt packages, node, cursor/vscode extensions
  gnome   - GNOME extensions and settings
  claude  - Claude Code settings
  all     - Everything (default if no component specified)

Run without arguments for interactive mode.
EOF
      exit 0
      ;;
    *) error "Unknown option: $1"; exit 1 ;;
  esac
done

run_cmd() {
  if $DRY_RUN; then
    info "[DRY-RUN] Would run: $*"
  else
    "$@"
  fi
}

# ============================================================================
# SHELL SETUP
# ============================================================================
setup_shell() {
  info "Setting up shell environment..."

  # Install zsh if not present
  if ! command -v zsh >/dev/null 2>&1; then
    info "Installing zsh..."
    run_cmd sudo apt update
    run_cmd sudo apt install -y zsh
  fi

  # Install Oh My Zsh
  if [ ! -d "$home_dir/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    if ! $DRY_RUN; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
      info "[DRY-RUN] Would install Oh My Zsh"
    fi
  fi

  # Install Powerlevel10k
  p10k_dir="${ZSH_CUSTOM:-$home_dir/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ ! -d "$p10k_dir" ]; then
    info "Installing Powerlevel10k..."
    run_cmd git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
  fi

  # Install zsh plugins
  zsh_custom="${ZSH_CUSTOM:-$home_dir/.oh-my-zsh/custom}"
  for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-autocomplete; do
    plugin_dir="$zsh_custom/plugins/$plugin"
    if [ ! -d "$plugin_dir" ]; then
      info "Installing $plugin..."
      case $plugin in
        zsh-autosuggestions)
          run_cmd git clone https://github.com/zsh-users/zsh-autosuggestions "$plugin_dir" ;;
        zsh-syntax-highlighting)
          run_cmd git clone https://github.com/zsh-users/zsh-syntax-highlighting "$plugin_dir" ;;
        zsh-autocomplete)
          run_cmd git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete "$plugin_dir" ;;
      esac
    fi
  done

  # Copy shell config files
  info "Copying shell configuration files..."
  for file in .bashrc .zshrc .p10k.zsh .tmux.conf .gitconfig .profile; do
    if [ -f "$root_dir/shell/$file" ]; then
      if [ -f "$home_dir/$file" ] && ! $DRY_RUN; then
        cp "$home_dir/$file" "$home_dir/$file.backup.$(date +%Y%m%d%H%M%S)"
      fi
      run_cmd cp "$root_dir/shell/$file" "$home_dir/$file"
    fi
  done

  # Install Meslo Nerd Font (required for Powerlevel10k)
  font_dir="$home_dir/.local/share/fonts"
  if [ -f "$root_dir/apps/system/fonts.txt" ] && grep -q "Meslo" "$root_dir/apps/system/fonts.txt"; then
    if ! fc-list | grep -qi "meslo.*nerd"; then
      info "Installing Meslo Nerd Font..."
      run_cmd mkdir -p "$font_dir"
      if ! $DRY_RUN; then
        curl -fLo "$font_dir/MesloLGSNerdFont-Regular.ttf" \
          "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Regular/MesloLGSNerdFont-Regular.ttf"
        curl -fLo "$font_dir/MesloLGSNerdFont-Bold.ttf" \
          "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Bold/MesloLGSNerdFont-Bold.ttf"
        curl -fLo "$font_dir/MesloLGSNerdFont-Italic.ttf" \
          "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Italic/MesloLGSNerdFont-Italic.ttf"
        curl -fLo "$font_dir/MesloLGSNerdFont-BoldItalic.ttf" \
          "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/BoldItalic/MesloLGSNerdFont-BoldItalic.ttf"
        fc-cache -fv
      fi
    fi
  fi

  # Set zsh as default shell
  if [ "$SHELL" != "$(which zsh)" ]; then
    info "Setting zsh as default shell..."
    run_cmd chsh -s "$(which zsh)"
  fi

  info "Shell setup complete!"
}

# ============================================================================
# APPS SETUP
# ============================================================================
setup_apps() {
  info "Setting up applications..."

  # Install apt packages
  if [ -f "$root_dir/apps/system/apt-packages.txt" ]; then
    info "Installing apt packages..."
    while IFS= read -r pkg; do
      if ! dpkg -l "$pkg" >/dev/null 2>&1; then
        run_cmd sudo apt install -y "$pkg"
      fi
    done < "$root_dir/apps/system/apt-packages.txt"
  fi

  # Install snap packages
  if [ -f "$root_dir/apps/system/snaps.txt" ]; then
    info "Installing snap packages..."
    while IFS= read -r snap; do
      if ! snap list "$snap" >/dev/null 2>&1; then
        info "Installing snap: $snap"
        run_cmd sudo snap install "$snap"
      fi
    done < "$root_dir/apps/system/snaps.txt"
  fi

  # Install nvm and node
  if [ ! -d "$home_dir/.nvm" ]; then
    info "Installing nvm..."
    if ! $DRY_RUN; then
      curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
      export NVM_DIR="$home_dir/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
  fi

  # Install node version from versions.env
  if [ -f "$root_dir/apps/node/versions.env" ]; then
    node_version=$(grep '^node=' "$root_dir/apps/node/versions.env" | cut -d= -f2)
    if [ -n "$node_version" ]; then
      info "Installing Node.js $node_version..."
      if ! $DRY_RUN; then
        export NVM_DIR="$home_dir/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install "$node_version" || true
        nvm use "$node_version" || true
      fi
    fi
  fi

  # Install global npm packages
  if [ -f "$root_dir/apps/node/global-packages.json" ] && command -v npm >/dev/null 2>&1; then
    info "Installing global npm packages..."
    if ! $DRY_RUN; then
      packages=$(jq -r '.dependencies | keys[]' "$root_dir/apps/node/global-packages.json" 2>/dev/null || true)
      for pkg in $packages; do
        npm install -g "$pkg" 2>/dev/null || true
      done
    fi
  fi

  # Cursor extensions
  if [ -f "$root_dir/apps/cursor/extensions.txt" ] && command -v cursor >/dev/null 2>&1; then
    info "Installing Cursor extensions..."
    while IFS= read -r ext; do
      run_cmd cursor --install-extension "$ext" || true
    done < "$root_dir/apps/cursor/extensions.txt"
  fi

  # VS Code extensions
  if [ -f "$root_dir/apps/vscode/extensions.txt" ] && command -v code >/dev/null 2>&1; then
    info "Installing VS Code extensions..."
    while IFS= read -r ext; do
      run_cmd code --install-extension "$ext" || true
    done < "$root_dir/apps/vscode/extensions.txt"
  fi

  # Copy editor settings
  if [ -f "$root_dir/apps/cursor/settings.json" ]; then
    cursor_config="$home_dir/.config/Cursor/User"
    run_cmd mkdir -p "$cursor_config"
    run_cmd cp "$root_dir/apps/cursor/settings.json" "$cursor_config/settings.json"
  fi

  if [ -f "$root_dir/apps/vscode/settings.json" ]; then
    vscode_config="$home_dir/.config/Code/User"
    run_cmd mkdir -p "$vscode_config"
    run_cmd cp "$root_dir/apps/vscode/settings.json" "$vscode_config/settings.json"
  fi

  info "Apps setup complete!"
}

# ============================================================================
# GNOME SETUP
# ============================================================================
setup_gnome() {
  info "Setting up GNOME..."

  # Install GNOME extensions
  if [ -f "$root_dir/gnome/extensions.txt" ]; then
    info "GNOME extensions to install:"
    cat "$root_dir/gnome/extensions.txt"
    warn "Install extensions manually from https://extensions.gnome.org or using Extension Manager"
    warn "Extensions: $(cat "$root_dir/gnome/extensions.txt" | tr '\n' ' ')"
  fi

  # Load GNOME settings
  if confirm "Load GNOME dconf settings? (This will override current settings)"; then
    for ini_file in "$root_dir"/gnome/*.ini; do
      [ -f "$ini_file" ] || continue
      filename=$(basename "$ini_file" .ini)
      schema_path="/$(echo "$filename" | tr '_' '/')/"
      info "Loading $schema_path from $ini_file..."
      if ! $DRY_RUN; then
        dconf load "$schema_path" < "$ini_file"
      fi
    done
  fi

  info "GNOME setup complete!"
}

# ============================================================================
# CLAUDE CODE SETUP
# ============================================================================
setup_claude() {
  info "Setting up Claude Code..."

  # Install Claude Code
  if ! command -v claude >/dev/null 2>&1; then
    info "Installing Claude Code..."
    if ! $DRY_RUN; then
      curl -fsSL https://claude.ai/install.sh | sh
    fi
  fi

  # Copy Claude settings (user needs to fill in secrets)
  if [ -f "$root_dir/apps/claude/settings.json" ]; then
    claude_dir="$home_dir/.claude"
    run_cmd mkdir -p "$claude_dir"
    if [ -f "$claude_dir/settings.json" ]; then
      warn "Claude settings.json already exists. Review and merge manually:"
      warn "  Source: $root_dir/apps/claude/settings.json"
      warn "  Target: $claude_dir/settings.json"
    else
      run_cmd cp "$root_dir/apps/claude/settings.json" "$claude_dir/settings.json"
      warn "Claude settings copied. Edit $claude_dir/settings.json to add your API keys!"
    fi
  fi

  info "Claude Code setup complete!"
}

# ============================================================================
# MAIN
# ============================================================================
main() {
  info "Workstation Setup Script"
  info "Repository: $root_dir"
  echo

  if $DRY_RUN; then
    warn "DRY RUN MODE - No changes will be made"
    echo
  fi

  case "${COMPONENT:-}" in
    shell)  setup_shell ;;
    apps)   setup_apps ;;
    gnome)  setup_gnome ;;
    claude) setup_claude ;;
    all|"")
      if [ -z "$COMPONENT" ]; then
        info "Running full setup. Use --component to run specific parts."
        echo
      fi
      setup_shell
      setup_apps
      setup_gnome
      setup_claude
      ;;
    *)
      error "Unknown component: $COMPONENT"
      exit 1
      ;;
  esac

  echo
  info "Setup complete!"
  info "You may need to log out and back in for all changes to take effect."
  info "For zsh changes, run: exec zsh"
}

main
