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

## Updating and pushing

This is your repository: add, edit, or remove any files you want. Before publishing, check that no secrets have slipped in; do not commit private keys, access tokens, passwords, saved database connections, browser profiles, or shell history.

To save and publish your changes:

```bash
cd /home/prashant/myWorkspace/setup/dotfiles
./capture-current-setup.sh       # optional; refreshes captured workstation settings
git diff                         # review changes
git add .
git commit -m "Describe the update"
GIT_SSH_COMMAND='ssh -F /dev/null' git push
```

`GIT_SSH_COMMAND='ssh -F /dev/null'` is needed on this machine because its system SSH configuration currently has an incorrect permission setting. It still uses your normal GitHub SSH key.

## Restore notes

Copy shell files to your home directory only after reviewing them. Install editor extensions from `apps/cursor/extensions.txt` or `apps/vscode/extensions.txt`; restore Node packages from `apps/node/global-packages.json`; and import the GNOME `.ini` snippets deliberately with `dconf load`.
