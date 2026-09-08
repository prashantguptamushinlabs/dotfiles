# Instructions for Codex agents

Read this file before changing this repository.

## Purpose

This is the user's personal, portable workstation-setup repository. Keep it useful for restoring a machine and easy for the user to review.

## Updating the snapshot

- Run `./capture-current-setup.sh` when the task is to refresh captured shell, editor, Node, MongoDB Compass, or GNOME settings.
- Inspect `git diff` after capture. Preserve the existing directory structure unless a change requires a deliberate migration.
- The script intentionally excludes credentials, tokens, SSH keys, histories, database files, cookies, cached state, and saved Compass connections. Do not weaken those exclusions or add sensitive data without the user's explicit informed approval.
- Treat connection strings, `.env` files, npm auth, private keys, access tokens, and browser/editor profile databases as sensitive even if they look harmless.

## Git workflow

- The user may add any non-sensitive files they wish. Help them do so and update this README when workflows change.
- Do not commit or push automatically unless the user asks to commit or push in the current task.
- Before a requested commit, run `git diff --check` and give the user a concise summary of the staged change when practical.
- For a requested push on this machine, use `GIT_SSH_COMMAND='ssh -F /dev/null' git push`; this avoids a known system SSH configuration permission issue while using the user's normal GitHub SSH key.
