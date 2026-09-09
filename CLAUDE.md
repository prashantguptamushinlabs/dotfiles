# Claude Code Setup Instructions

When Prashant asks you to set up a new machine using this repository, follow these instructions.

## Quick Start

```bash
git clone git@github.com:prashantguptamushinlabs/dotfiles.git ~/myWorkspace/setup/dotfiles
cd ~/myWorkspace/setup/dotfiles
./setup.sh --dry-run  # Preview changes first
./setup.sh            # Run full setup
```

## What This Repository Contains

- **Shell**: zsh, oh-my-zsh, powerlevel10k theme, zsh plugins, tmux, git config
- **Apps**: Snap packages (Brave, Firefox, Postman, Slack), apt dev tools, Cursor/VS Code settings and extensions
- **Node**: nvm, Node.js version, global npm packages
- **GNOME**: Desktop settings, dock config, keyboard shortcuts, enabled extensions
- **Claude Code**: Settings template (secrets need to be filled in)

## Setup Order

Run components in this order for best results:

1. **Shell first** (`./setup.sh --component shell`)
   - Installs zsh, oh-my-zsh, powerlevel10k, plugins
   - Copies shell configs (.zshrc, .bashrc, .gitconfig, etc.)
   - Installs Meslo Nerd Font for terminal icons
   - Sets zsh as default shell

2. **Apps second** (`./setup.sh --component apps`)
   - Installs apt packages (build-essential, git, curl, jq, etc.)
   - Installs snap packages (brave, firefox, postman, slack)
   - Installs nvm and the correct Node.js version
   - Installs global npm packages
   - Installs Cursor/VS Code extensions

3. **GNOME third** (`./setup.sh --component gnome`)
   - Shows list of GNOME extensions to install manually
   - Optionally loads GNOME dconf settings (dock position, theme, keybindings)

4. **Claude last** (`./setup.sh --component claude`)
   - Installs Claude Code if not present
   - Copies settings template
   - **User must add their own API keys**

## Manual Steps Required

### After Shell Setup
- Log out and back in, or run `exec zsh`
- Terminal may need font changed to "MesloLGS Nerd Font" for icons to render

### After Apps Setup  
- Cursor/VS Code: Sign in to sync settings if using Settings Sync
- Snap packages: Some may need `--classic` flag; script will warn if install fails

### After GNOME Setup
- Install extensions from https://extensions.gnome.org or use Extension Manager app
- Key extensions to install:
  - `InternetSpeedMeter@alshakib.dev` - Network speed in top bar
  - `copyous@boerdereinar.dev` - Clipboard manager
  - `system-monitor@gnome-shell-extensions.gcampax.github.com` - System monitor
  - `tiling-assistant@ubuntu.com` - Window tiling

### After Claude Setup
- Edit `~/.claude/settings.json` and add your Bedrock API key:
  ```json
  {
    "env": {
      "CLAUDE_CODE_USE_BEDROCK": "1",
      "AWS_REGION": "us-east-1",
      "AWS_BEARER_TOKEN_BEDROCK": "YOUR_BEDROCK_API_KEY_HERE"
    }
  }
  ```
- Or use `claude` and follow the login flow for direct Anthropic API

## Prashant's Preferred Setup

- **Shell**: zsh with powerlevel10k, instant prompt enabled
- **Terminal**: GNOME Terminal or Ptyxis with MesloLGS Nerd Font
- **Editor**: Cursor (AI-powered VS Code fork)
- **Browser**: Brave (primary), Firefox (secondary)
- **Node**: Managed via nvm, currently v22.x
- **API**: Claude via Amazon Bedrock (us-east-1)
- **Theme**: Dark mode everywhere

## Troubleshooting

### Powerlevel10k icons not showing
```bash
# Ensure font is installed
fc-list | grep -i meslo
# If missing, run:
./setup.sh --component shell
# Then change terminal font to "MesloLGS Nerd Font"
```

### zsh plugins not loading
```bash
# Check plugins are cloned
ls ~/.oh-my-zsh/custom/plugins/
# Should contain: zsh-autosuggestions, zsh-syntax-highlighting, zsh-autocomplete
```

### Claude Code not using Bedrock
```bash
# Check settings
cat ~/.claude/settings.json
# Ensure CLAUDE_CODE_USE_BEDROCK is "1" and AWS_BEARER_TOKEN_BEDROCK is set
```

### GNOME settings not applying
```bash
# Load manually
dconf load /org/gnome/shell/ < gnome/org_gnome_shell.ini
```

## Updating the Repository

When Prashant changes settings on his main machine and wants to capture them:

```bash
cd ~/myWorkspace/setup/dotfiles
./capture-current-setup.sh
git diff  # Review changes
git add .
git commit -m "Update workstation settings"
git push
```

## Security Notes

- Never commit API keys, tokens, or passwords
- The capture script automatically redacts sensitive values from Claude settings
- SSH keys, .npmrc, browser profiles, and shell history are excluded
- Review `git diff` before committing to catch accidental secrets
