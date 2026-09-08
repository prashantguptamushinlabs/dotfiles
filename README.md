# Dotfiles and workstation setup

This repository captures portable, reviewable configuration for this Linux workstation:

- Bash, Zsh, Powerlevel10k, tmux, Git, and Oh My Zsh startup files
- Cursor and VS Code settings plus extension manifests
- Node, npm, nodemon, Mongosh versions and global npm packages
- Sanitized MongoDB Compass preferences and a connection template
- Selected GNOME desktop settings

## Security policy

This repository intentionally excludes SSH keys, shell history, npm credentials, saved Compass connections, browser or editor cookies, access tokens, device identifiers, caches, databases, and editor history.

Run `./capture-current-setup.sh` to refresh the snapshot. Review `git diff` before committing, especially after installing new tools or changing application settings.

## Restore notes

Copy shell files to your home directory only after reviewing them. Install editor extensions from `apps/cursor/extensions.txt` or `apps/vscode/extensions.txt`; restore Node packages from `apps/node/global-packages.json`; and import the GNOME `.ini` snippets deliberately with `dconf load`.
