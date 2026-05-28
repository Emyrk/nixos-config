{ pkgs, lib, ... }:

# my-agents
#
# Clones or updates the Emyrk/my-agent repo at ~/agent and symlinks its
# contents into runtime-expected paths (~/.mux/, ~/.coder/, ~/.local/bin).
# my-agent is content; nixos-config is glue. GitHub is version control.
#
# Symlinks are placed per-skill so runtime-owned siblings (e.g.
# ~/.mux/skills/memory) coexist with the my-agent symlinks.

pkgs.writeShellApplication {
  name = "my-agents-sync";
  runtimeInputs = [ pkgs.git pkgs.coreutils pkgs.openssh ];
  text = ''
    set -euo pipefail

    REPO_URL="''${MY_AGENT_REPO_URL:-git@github.com:Emyrk/my-agent.git}"
    DEST="''${MY_AGENT_DEST:-$HOME/agent}"

    log() { printf '[my-agents] %s\n' "$*"; }

    # 1. Clone if missing. If present and clean, fast-forward pull.
    if [ ! -d "$DEST/.git" ]; then
      log "cloning $REPO_URL to $DEST"
      git clone --quiet "$REPO_URL" "$DEST"
    else
      log "fetching origin/main in $DEST"
      if ! git -C "$DEST" fetch --quiet origin main; then
        log "fetch failed; continuing with local checkout"
      fi
      if [ -z "$(git -C "$DEST" status --porcelain)" ] \
         && git -C "$DEST" merge-base --is-ancestor HEAD origin/main 2>/dev/null; then
        git -C "$DEST" pull --quiet --ff-only origin main || true
      else
        log "$DEST has local changes or diverges from origin/main; not pulling"
      fi
    fi

    link() {
      local src="$1" dst="$2"
      mkdir -p "$(dirname "$dst")"
      ln -sfn "$src" "$dst"
      log "linked $dst -> $src"
    }

    # 2. Per-runtime symlinks. Per-name on skills so runtime-owned
    # siblings (e.g. ~/.mux/skills/memory) coexist.
    for runtime in mux coder; do
      runtime_dir="$HOME/.$runtime"
      mkdir -p "$runtime_dir/skills"
      link "$DEST/AGENTS.md" "$runtime_dir/AGENTS.md"
      for skill in "$DEST/agent/skills"/*; do
        [ -d "$skill" ] || continue
        link "$skill" "$runtime_dir/skills/$(basename "$skill")"
      done
    done

    # 3. ~/agent points at $DEST. If MY_AGENT_DEST overrides the
    # default, place the convenience symlink.
    if [ "$DEST" != "$HOME/agent" ]; then
      link "$DEST" "$HOME/agent"
    fi

    # 4. Bin wrappers, per-file so other ~/.local/bin entries survive.
    mkdir -p "$HOME/.local/bin"
    if [ -d "$DEST/agent/bin" ]; then
      for f in "$DEST/agent/bin"/*; do
        [ -e "$f" ] || continue
        chmod +x "$f"
        link "$f" "$HOME/.local/bin/$(basename "$f")"
      done
    fi

    log "done"
  '';
}
