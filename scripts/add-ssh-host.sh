#!/usr/bin/env bash
# add-ssh-host.sh — scaffold a new SSH host
#
# What it does:
#   1. Generate an Ed25519 keypair if one doesn't exist (per-host key by default).
#   2. Append a Host block to ~/.ssh/config.
#   3. (Optional) ssh-copy-id the public key to the remote.
#   4. (Optional) print a paste-ready ssh_domains entry for wezterm.lua.
#
# Idempotent: re-running with the same alias is a no-op for ~/.ssh/config and
# keys (will not overwrite). Use --force to replace.
#
# Usage:
#   ./add-ssh-host.sh                        # interactive
#   ./add-ssh-host.sh --alias prod \
#                     --hostname 10.0.0.42 \
#                     --user deploy \
#                     --port 22 \
#                     --keytype ed25519 \
#                     --copy-id \
#                     --wezterm-domain
#
# Flags:
#   --alias NAME            ssh-config Host alias and key suffix (required)
#   --hostname HOST         actual hostname or IP (required)
#   --user USER             ssh username (default: $USER)
#   --port N                ssh port (default: 22)
#   --keytype TYPE          ed25519 (default) | rsa | ecdsa
#   --keypath PATH          override key path (default ~/.ssh/id_<keytype>_<alias>)
#   --no-keygen             skip keygen even if no key exists
#   --copy-id               run ssh-copy-id after writing config
#   --wezterm-domain        print a ssh_domains snippet for wezterm.lua
#   --force                 replace an existing Host block with the same alias
#   -h, --help

set -euo pipefail

SSH_DIR="${HOME}/.ssh"
SSH_CONFIG="${SSH_DIR}/config"

# ----- defaults
ALIAS=""
HOSTNAME=""
USERNAME="${USER:-}"
PORT=22
KEYTYPE="ed25519"
KEYPATH=""
DO_KEYGEN=1
DO_COPY_ID=0
PRINT_DOMAIN=0
FORCE=0

usage() {
  sed -n '2,40p' "$0"
  exit 0
}

err() { echo "error: $*" >&2; exit 1; }
note() { echo "==> $*"; }

# ----- parse
while [[ $# -gt 0 ]]; do
  case "$1" in
    --alias) ALIAS="$2"; shift 2 ;;
    --hostname) HOSTNAME="$2"; shift 2 ;;
    --user) USERNAME="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    --keytype) KEYTYPE="$2"; shift 2 ;;
    --keypath) KEYPATH="$2"; shift 2 ;;
    --no-keygen) DO_KEYGEN=0; shift ;;
    --copy-id) DO_COPY_ID=1; shift ;;
    --wezterm-domain) PRINT_DOMAIN=1; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) usage ;;
    *) err "unknown arg: $1 (try --help)" ;;
  esac
done

# ----- interactive fill-ins
if [[ -z "$ALIAS" ]]; then
  read -r -p "alias (Host name in ssh config): " ALIAS
fi
if [[ -z "$HOSTNAME" ]]; then
  read -r -p "hostname or IP: " HOSTNAME
fi
[[ -z "$ALIAS" ]] && err "alias is required"
[[ -z "$HOSTNAME" ]] && err "hostname is required"
[[ -z "$USERNAME" ]] && err "username is required (set \$USER or pass --user)"

case "$KEYTYPE" in
  ed25519|rsa|ecdsa) ;;
  *) err "unknown keytype: $KEYTYPE (use ed25519|rsa|ecdsa)" ;;
esac

[[ -z "$KEYPATH" ]] && KEYPATH="${SSH_DIR}/id_${KEYTYPE}_${ALIAS}"

# ----- prepare ssh dir
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
[[ -f "$SSH_CONFIG" ]] || { touch "$SSH_CONFIG"; chmod 600 "$SSH_CONFIG"; }

# ----- key generation
if [[ "$DO_KEYGEN" -eq 1 && ! -f "$KEYPATH" ]]; then
  note "generating $KEYTYPE keypair at $KEYPATH"
  case "$KEYTYPE" in
    ed25519) ssh-keygen -t ed25519 -a 100 -f "$KEYPATH" -C "${USERNAME}@${ALIAS}" -N "" ;;
    rsa)     ssh-keygen -t rsa -b 4096 -f "$KEYPATH" -C "${USERNAME}@${ALIAS}" -N "" ;;
    ecdsa)   ssh-keygen -t ecdsa -b 521 -f "$KEYPATH" -C "${USERNAME}@${ALIAS}" -N "" ;;
  esac
  chmod 600 "$KEYPATH"
  chmod 644 "${KEYPATH}.pub"
else
  note "key already exists at $KEYPATH (skipping keygen)"
fi

# ----- write ~/.ssh/config block
BLOCK_HEADER="# >>> added by add-ssh-host.sh: ${ALIAS} >>>"
BLOCK_FOOTER="# <<< added by add-ssh-host.sh: ${ALIAS} <<<"

if grep -q "^${BLOCK_HEADER}$" "$SSH_CONFIG" 2>/dev/null; then
  if [[ "$FORCE" -eq 1 ]]; then
    note "removing existing block for alias '$ALIAS' (--force)"
    # Delete from header line through footer line, inclusive.
    awk -v h="$BLOCK_HEADER" -v f="$BLOCK_FOOTER" '
      $0 == h { skip = 1 }
      !skip { print }
      $0 == f { skip = 0 }
    ' "$SSH_CONFIG" > "${SSH_CONFIG}.tmp" && mv "${SSH_CONFIG}.tmp" "$SSH_CONFIG"
  else
    err "alias '$ALIAS' already present in $SSH_CONFIG (use --force to replace)"
  fi
fi

{
  echo ""
  echo "$BLOCK_HEADER"
  echo "Host ${ALIAS}"
  echo "    HostName ${HOSTNAME}"
  echo "    User ${USERNAME}"
  echo "    Port ${PORT}"
  echo "    IdentityFile ${KEYPATH}"
  echo "    IdentitiesOnly yes"
  echo "    ServerAliveInterval 30"
  echo "    ServerAliveCountMax 3"
  echo "$BLOCK_FOOTER"
} >> "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"
note "appended Host block for '$ALIAS' to $SSH_CONFIG"

# ----- ssh-copy-id (optional)
if [[ "$DO_COPY_ID" -eq 1 ]]; then
  if command -v ssh-copy-id >/dev/null 2>&1; then
    note "pushing public key with ssh-copy-id (you'll be prompted for the remote password)"
    ssh-copy-id -i "${KEYPATH}.pub" "${USERNAME}@${HOSTNAME}" -p "$PORT"
  else
    note "ssh-copy-id not found; falling back to cat | ssh"
    cat "${KEYPATH}.pub" \
      | ssh -p "$PORT" "${USERNAME}@${HOSTNAME}" \
        "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
  fi
fi

# ----- print wezterm ssh_domain snippet
if [[ "$PRINT_DOMAIN" -eq 1 ]]; then
  cat <<EOF

==> paste this into your wezterm.lua:

config.ssh_domains = config.ssh_domains or {}
table.insert(config.ssh_domains, {
  name = '${ALIAS}',
  remote_address = '${HOSTNAME}:${PORT}',
  username = '${USERNAME}',
  ssh_option = {
    identityfile = '${KEYPATH}',
    identitiesonly = 'yes',
  },
  multiplexing = 'None',   -- switch to 'WezTerm' if wezterm is installed on the remote
  assume_shell = 'Posix',
})

==> then connect with:
    wezterm connect ${ALIAS}

EOF
fi

note "done. test with: ssh ${ALIAS}"
