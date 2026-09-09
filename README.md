# Dotfiles and Workstation Setup

Personal workstation configuration for quick setup on new machines.

## Quick Setup on a New Machine

```bash
# Clone the repository
git clone git@github.com:prashantguptamushinlabs/dotfiles.git ~/myWorkspace/setup/dotfiles
cd ~/myWorkspace/setup/dotfiles

# Preview what will be installed
./setup.sh --dry-run

# Run full setup
./setup.sh

# Or run specific components
./setup.sh --component shell   # zsh, oh-my-zsh, powerlevel10k
./setup.sh --component apps    # snap/apt packages, node, editor extensions
./setup.sh --component gnome   # GNOME extensions and settings
./setup.sh --component claude  # Claude Code settings
```

## What's Included

### Shell Environment
- zsh with Oh My Zsh
- Powerlevel10k theme with instant prompt
- Plugins: zsh-autosuggestions, zsh-syntax-highlighting, zsh-autocomplete
- tmux configuration
- Git configuration

### Applications
- **Browsers**: Brave, Firefox
- **Development**: Cursor, VS Code, Postman
- **Communication**: Slack
- **Database**: MongoDB Compass
- **Node.js**: nvm, global packages

### GNOME Desktop
- Extension list for easy reinstall
- Desktop interface settings
- Dock configuration
- Keyboard shortcuts

### Claude Code
- Settings template (add your own API keys)

## Capturing Current Setup

To update the repository with your current machine's configuration:

```bash
./capture-current-setup.sh
git diff                    # Review changes - check for secrets!
git add .
git commit -m "Update settings"
git push
```

## Security Policy

This repository **excludes** sensitive data:
- SSH keys and known_hosts
- Shell history
- npm credentials (.npmrc)
- Saved database connections
- Browser profiles and cookies
- Access tokens and API keys (redacted in captured files)
- Editor history and state

**Always review `git diff` before committing.**

## Manual Steps After Setup

1. **Terminal font**: Change to "MesloLGS Nerd Font" for powerlevel10k icons
2. **GNOME extensions**: Install from extensions.gnome.org or Extension Manager
3. **Claude Code**: Add your API key to `~/.claude/settings.json`
4. **Shell**: Run `exec zsh` or log out/in for zsh to become default

## Files Structure

```
.
├── CLAUDE.md                    # Instructions for Claude Code to help with setup
├── README.md                    # This file
├── capture-current-setup.sh     # Capture current machine settings
├── setup.sh                     # Restore settings to a new machine
├── shell/                       # Shell configurations
│   ├── .bashrc
│   ├── .zshrc
│   ├── .p10k.zsh
│   ├── .tmux.conf
│   └── .gitconfig
├── apps/
│   ├── system/                  # System packages
│   │   ├── snaps.txt
│   │   ├── apt-packages.txt
│   │   └── fonts.txt
│   ├── cursor/                  # Cursor editor
│   │   ├── settings.json
│   │   └── extensions.txt
│   ├── vscode/                  # VS Code
│   ├── node/                    # Node.js setup
│   │   ├── versions.env
│   │   └── global-packages.json
│   ├── claude/                  # Claude Code
│   │   └── settings.json        # Template with redacted secrets
│   └── mongodb-compass/
├── gnome/                       # GNOME settings
│   ├── extensions.txt           # Extension list
│   └── *.ini                    # dconf dumps
└── AGENTS.md                    # Legacy Codex instructions
```

## Using with Claude Code

When you ask Claude Code to set up a new machine, it will read `CLAUDE.md` and follow those instructions. Just say:

> "Set up this machine using my dotfiles repository"

Claude will guide you through the setup process.
