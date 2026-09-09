#!/usr/bin/env bash
set -euo pipefail

# Run from the repository root. Captures portable, reviewable workstation setup.
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
home_dir="${HOME:?HOME must be set}"

copy_file() {
  local source_path="$1"
  local destination_path="$2"
  if [ -f "$source_path" ]; then
    mkdir -p "$(dirname -- "$root_dir/$destination_path")"
    cp "$source_path" "$root_dir/$destination_path"
  fi
}

mkdir -p "$root_dir"/{shell,apps/cursor,apps/vscode,apps/mongodb-compass,apps/node,apps/claude,apps/system,gnome}

# Shell and terminal configuration. Histories, completions, and SSH material are never copied.
copy_file "$home_dir/.bashrc" "shell/.bashrc"
copy_file "$home_dir/.zshrc" "shell/.zshrc"
copy_file "$home_dir/.p10k.zsh" "shell/.p10k.zsh"
copy_file "$home_dir/.tmux.conf" "shell/.tmux.conf"
copy_file "$home_dir/.gitconfig" "shell/.gitconfig"
copy_file "$home_dir/.profile" "shell/.profile"
copy_file "$home_dir/.shell.pre-oh-my-zsh" "shell/.shell.pre-oh-my-zsh"

# Editor settings and extension manifests. Do not capture history or global storage.
# Redact any tokens/keys in environmentVariables arrays
redact_editor_settings() {
  local source_path="$1"
  local dest_path="$2"
  if [ -f "$source_path" ] && command -v jq >/dev/null 2>&1; then
    jq '
      if .["claudeCode.environmentVariables"] then
        .["claudeCode.environmentVariables"] |= map(
          if .name | test("TOKEN|KEY|SECRET|PASSWORD"; "i") then .value = "REDACTED_SET_YOUR_OWN"
          else . end
        )
      else . end
    ' "$source_path" > "$dest_path"
  elif [ -f "$source_path" ]; then
    cp "$source_path" "$dest_path"
  fi
}
redact_editor_settings "$home_dir/.config/Cursor/User/settings.json" "$root_dir/apps/cursor/settings.json"
redact_editor_settings "$home_dir/.config/Code/User/settings.json" "$root_dir/apps/vscode/settings.json"
copy_file "$home_dir/.config/Code/User/keybindings.json" "apps/vscode/keybindings.json"
if command -v cursor >/dev/null 2>&1; then
  # Cursor may create a diagnostic log merely to list extensions. Keep that
  # transient state outside the real profile so capture also works in read-only homes.
  cursor_config_dir="$(mktemp -d)"
  XDG_CONFIG_HOME="$cursor_config_dir" cursor --list-extensions | sort > "$root_dir/apps/cursor/extensions.txt"
  rm -rf "$cursor_config_dir"
fi
if command -v code >/dev/null 2>&1; then code --list-extensions | sort > "$root_dir/apps/vscode/extensions.txt"; fi

# Node tooling versions and global packages. .npmrc is excluded because it can hold auth tokens.
{
  command -v node >/dev/null 2>&1 && printf 'node=%s\n' "$(node --version)"
  command -v npm >/dev/null 2>&1 && printf 'npm=%s\n' "$(npm --version)"
  command -v nodemon >/dev/null 2>&1 && printf 'nodemon=%s\n' "$(nodemon --version)"
  command -v mongosh >/dev/null 2>&1 && printf 'mongosh=%s\n' "$(mongosh --version)"
} > "$root_dir/apps/node/versions.env"
if command -v npm >/dev/null 2>&1; then npm list -g --depth=0 --json > "$root_dir/apps/node/global-packages.json"; fi

# Compass general preferences with device identifiers, telemetry IDs, and proxy data removed.
compass_preferences="$home_dir/.config/MongoDB Compass/AppPreferences/General.json"
if [ -f "$compass_preferences" ] && command -v jq >/dev/null 2>&1; then
  jq 'del(.id, .telemetryAnonymousId, .userCreatedAt, .proxy)' "$compass_preferences" > "$root_dir/apps/mongodb-compass/General.json"
fi

# Declarative GNOME desktop settings only—never GNOME Online Accounts or credential stores.
for schema_path in \
  /org/gnome/desktop/interface/ \
  /org/gnome/desktop/wm/preferences/ \
  /org/gnome/desktop/input-sources/ \
  /org/gnome/desktop/peripherals/ \
  /org/gnome/mutter/ \
  /org/gnome/shell/ \
  /org/gnome/settings-daemon/plugins/; do
  filename="$(printf '%s' "$schema_path" | tr '/' '_' | sed 's/^_//;s/_$//').ini"
  dconf dump "$schema_path" > "$root_dir/gnome/$filename" 2>/dev/null || true
done

printf '%s\n' \
  '{' \
  '  "connectionString": "mongodb://USER:PASSWORD@HOST:27017/DATABASE",' \
  '  "name": "replace-with-a-safe-name"' \
  '}' > "$root_dir/apps/mongodb-compass/connection-template.json"

# Installed applications: snaps (user-installed, not base/core packages)
if command -v snap >/dev/null 2>&1; then
  snap list 2>/dev/null | awk 'NR>1 && !/^(bare|core|gnome-|gtk-common|mesa-|snapd|prompting-client|desktop-security)/ {print $1}' | sort > "$root_dir/apps/system/snaps.txt"
fi

# Installed applications: key apt packages (dev tools, not auto-installed deps)
dpkg-query -W -f='${Package}\n' 2>/dev/null | grep -E '^(git|curl|wget|zsh|tmux|vim|neovim|htop|tree|jq|ripgrep|fzf|bat|fd-find|build-essential|cmake|python3-pip|python3-venv|docker|docker-compose|golang|rustc|cargo|fonts-)' | sort > "$root_dir/apps/system/apt-packages.txt" 2>/dev/null || true

# GNOME extensions list (for easy reinstall)
if command -v gnome-extensions >/dev/null 2>&1; then
  gnome-extensions list 2>/dev/null | sort > "$root_dir/gnome/extensions.txt"
fi

# Claude Code settings (secrets redacted)
claude_settings="$home_dir/.claude/settings.json"
if [ -f "$claude_settings" ] && command -v jq >/dev/null 2>&1; then
  jq 'if .env then .env |= with_entries(
    if .key | test("TOKEN|KEY|SECRET|PASSWORD"; "i") then .value = "REDACTED_SET_YOUR_OWN"
    else . end
  ) else . end' "$claude_settings" > "$root_dir/apps/claude/settings.json"
fi

# Fonts manifest (custom fonts in user directory)
if [ -d "$home_dir/.local/share/fonts" ]; then
  ls "$home_dir/.local/share/fonts/" 2>/dev/null | head -50 > "$root_dir/apps/system/fonts.txt" || true
fi

printf 'Captured current workstation setup in %s\n' "$root_dir"
