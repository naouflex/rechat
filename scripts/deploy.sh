#!/usr/bin/env bash
# scripts/deploy.sh — provision and operate Rechat on a Google Cloud VM.
#
# Mirrors ../rewatch (GCE + Docker Compose + Caddy/Let's Encrypt) and adds
# git-init + GitHub Actions auto-deploy on push to main (like ../polytrader).
#
# Domain: https://rechat.naoufel.io (override with APP_DOMAIN).
#
# Usage:
#   scripts/deploy.sh provision        # create VM + firewall rules
#   scripts/deploy.sh install          # install Docker on the VM
#   scripts/deploy.sh upload           # stream the project (incl. .env) to the VM
#   scripts/deploy.sh authorize-db     # whitelist VM IP on Cloud SQL (optional)
#   scripts/deploy.sh init             # docker compose build + up -d
#   scripts/deploy.sh build            # rebuild images on the VM
#   scripts/deploy.sh start            # docker compose up -d
#   scripts/deploy.sh push             # re-upload + restart (no rebuild)
#   scripts/deploy.sh update           # re-upload, rebuild, restart
#   scripts/deploy.sh git-init         # convert VM dir to a git clone (keeps .env + HTTPS)
#   scripts/deploy.sh setup-deploy-key # create a GitHub deploy key on the VM
#   scripts/deploy.sh pull             # git pull on the VM + rebuild (after git-init)
#   scripts/deploy.sh deploy-logs      # tail the on-VM deploy log
#   scripts/deploy.sh status           # docker compose ps
#   scripts/deploy.sh logs [service]   # tail logs (default: rechat)
#   scripts/deploy.sh expose-http      # bind :80 on the VM (test via IP before DNS)
#   scripts/deploy.sh dns              # check the A record + print setup steps
#   scripts/deploy.sh https            # provision Caddy + Let's Encrypt
#   scripts/deploy.sh https-logs       # tail Caddy logs (cert progress)
#   scripts/deploy.sh verify           # curl health checks against APP_DOMAIN
#   scripts/deploy.sh ip               # print the VM's external IP
#   scripts/deploy.sh ssh              # open an SSH shell on the VM
#   scripts/deploy.sh ssh-config       # add a short alias to ~/.ssh/config
#   scripts/deploy.sh setup-autodeploy  # print GitHub Actions setup steps
#   scripts/deploy.sh all              # provision + install + upload + init
#
# Environment overrides:
#   INSTANCE          GCE instance name (default: rechat-prod)
#   ZONE              GCE zone          (default: europe-west1-b)
#   MACHINE_TYPE      VM machine type   (default: e2-standard-2)
#   BOOT_DISK_SIZE                      (default: 50GB)
#   REMOTE_DIR        Remote directory  (default: rechat)
#   APP_DOMAIN        Public hostname   (default: rechat.naoufel.io)
#   COMPOSE_FILE      Compose file      (default: docker-compose.prod.yml)
#   CLOUD_SQL_INSTANCE Cloud SQL name for authorize-db (default: watch-db)
#   GIT_REPO          Git remote URL for git-init (default: git@github.com:naouflex/rechat.git)
#   GIT_BRANCH        Branch to track on the VM (default: main)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

INSTANCE="${INSTANCE:-rechat-prod}"
ZONE="${ZONE:-europe-west1-b}"
MACHINE_TYPE="${MACHINE_TYPE:-e2-standard-2}"
IMAGE_FAMILY="${IMAGE_FAMILY:-debian-12}"
IMAGE_PROJECT="${IMAGE_PROJECT:-debian-cloud}"
BOOT_DISK_SIZE="${BOOT_DISK_SIZE:-50GB}"
TAGS="${TAGS:-http-server,https-server}"
REMOTE_DIR="${REMOTE_DIR:-rechat}"
ENV_FILE="${ENV_FILE:-$PROJECT_ROOT/.env}"
APP_DOMAIN="${APP_DOMAIN:-rechat.naoufel.io}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.prod.yml}"
CLOUD_SQL_INSTANCE="${CLOUD_SQL_INSTANCE:-watch-db}"
GIT_REPO="${GIT_REPO:-git@github.com:naouflex/rechat.git}"
GIT_BRANCH="${GIT_BRANCH:-main}"

if [[ -t 1 ]]; then
  C_BLUE=$'\033[1;34m'; C_YELLOW=$'\033[1;33m'; C_RED=$'\033[1;31m'
  C_GREEN=$'\033[1;32m'; C_RESET=$'\033[0m'
else
  C_BLUE=""; C_YELLOW=""; C_RED=""; C_GREEN=""; C_RESET=""
fi
log()  { printf "%s[deploy]%s %s\n" "$C_BLUE"   "$C_RESET" "$*"; }
ok()   { printf "%s[ ok  ]%s %s\n" "$C_GREEN"  "$C_RESET" "$*"; }
warn() { printf "%s[warn ]%s %s\n" "$C_YELLOW" "$C_RESET" "$*" >&2; }
die()  { printf "%s[fail ]%s %s\n" "$C_RED"    "$C_RESET" "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

ssh_vm() {
  gcloud compute ssh "$INSTANCE" --zone="$ZONE" --quiet --command="$1"
}

vm_compose() {
  ssh_vm "cd ~/$REMOTE_DIR && \
    files='-f $COMPOSE_FILE'; \
    [ -f compose.https.yaml ] && files=\"\$files -f compose.https.yaml\"; \
    docker compose \$files $1"
}

vm_external_ip() {
  gcloud compute instances describe "$INSTANCE" --zone="$ZONE" \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)' 2>/dev/null
}

firewall_exists() {
  gcloud compute firewall-rules describe "$1" >/dev/null 2>&1
}

instance_exists() {
  gcloud compute instances describe "$INSTANCE" --zone="$ZONE" >/dev/null 2>&1
}

wait_for_ssh() {
  local max_attempts="${1:-18}"
  local interval="${2:-10}"
  local attempt=1
  log "Waiting for SSH on $INSTANCE (up to $((max_attempts * interval))s)..."
  while (( attempt <= max_attempts )); do
    if gcloud compute ssh "$INSTANCE" --zone="$ZONE" --quiet \
         --ssh-flag="-o ConnectTimeout=5" \
         --ssh-flag="-o StrictHostKeyChecking=accept-new" \
         --command='true' >/dev/null 2>&1; then
      ok "SSH ready (attempt $attempt)."
      return 0
    fi
    log "  attempt $attempt/$max_attempts: not ready yet, retrying in ${interval}s..."
    sleep "$interval"
    attempt=$((attempt + 1))
  done
  die "SSH did not become available on $INSTANCE within $((max_attempts * interval))s"
}

read_env_var() {
  local key="$1"
  [[ -f "$ENV_FILE" ]] || return 1
  awk -F= -v k="$key" '
    $0 !~ /^[[:space:]]*#/ && $1 == k {
      sub(/^[^=]+=/, "")
      gsub(/^"|"$/, "")
      gsub(/^\047|\047$/, "")
      print
      exit
    }
  ' "$ENV_FILE"
}

append_env_var() {
  local key="$1" value="$2"
  printf "\n%s='%s'\n" "$key" "$value" >>"$ENV_FILE"
}

# Create or extend .env with production defaults (no manual key generation).
ensure_prod_env() {
  if [[ ! -f "$ENV_FILE" ]]; then
    if [[ -f "$PROJECT_ROOT/.env.example" ]]; then
      cp "$PROJECT_ROOT/.env.example" "$ENV_FILE"
      log "Created $ENV_FILE from .env.example"
    else
      die "$ENV_FILE not found and no .env.example to copy."
    fi
  fi

  if [[ -z "$(read_env_var WEBUI_SECRET_KEY || true)" ]]; then
    require_cmd openssl
    local key
    key="$(openssl rand -hex 32)"
    log "Generating WEBUI_SECRET_KEY in $ENV_FILE ..."
    append_env_var WEBUI_SECRET_KEY "$key"
  fi

  if [[ -z "$(read_env_var WEBUI_URL || true)" ]]; then
    append_env_var WEBUI_URL "https://$APP_DOMAIN"
    log "Set WEBUI_URL=https://$APP_DOMAIN"
  fi

  if [[ -z "$(read_env_var WEBUI_NAME || true)" ]]; then
    append_env_var WEBUI_NAME "Rechat"
  fi

  if [[ -z "$(read_env_var CORS_ALLOW_ORIGIN || true)" ]]; then
    append_env_var CORS_ALLOW_ORIGIN "https://$APP_DOMAIN"
    log "Set CORS_ALLOW_ORIGIN=https://$APP_DOMAIN"
  fi

  if [[ -z "$(read_env_var LETSENCRYPT_EMAIL || true)" ]]; then
    local email=""
    if command -v gcloud >/dev/null 2>&1; then
      email="$(gcloud config get-value account 2>/dev/null || true)"
    fi
    if [[ -n "$email" && "$email" == *@* ]]; then
      append_env_var LETSENCRYPT_EMAIL "$email"
      log "Set LETSENCRYPT_EMAIL=$email from gcloud account"
    else
      warn "LETSENCRYPT_EMAIL not set — add it to $ENV_FILE before running https"
    fi
  fi
}

UPLOAD_EXCLUDES=(
  --exclude=./node_modules
  --exclude=./build
  --exclude=./.git
  --exclude=./.venv
  --exclude=./venv
  --exclude=./backend/.venv
  --exclude=./.cache
  --exclude=./.idea
  --exclude=./.vscode
  --exclude=./.cursor
  --exclude=./.DS_Store
  --exclude=./static/pyodide
  --exclude=__pycache__
  --exclude='*.pyc'
)

cmd_provision() {
  require_cmd gcloud

  local just_created=0
  log "Ensuring VM $INSTANCE exists in zone $ZONE..."
  if instance_exists; then
    ok "VM $INSTANCE already exists."
  else
    gcloud compute instances create "$INSTANCE" \
      --machine-type="$MACHINE_TYPE" \
      --image-family="$IMAGE_FAMILY" \
      --image-project="$IMAGE_PROJECT" \
      --boot-disk-size="$BOOT_DISK_SIZE" \
      --tags="$TAGS" \
      --zone="$ZONE"
    just_created=1
    ok "VM created."
  fi

  log "Ensuring firewall rule allow-rechat-http (tcp:80,443)..."
  if firewall_exists allow-rechat-http; then
    ok "allow-rechat-http already exists."
  else
    gcloud compute firewall-rules create allow-rechat-http \
      --allow=tcp:80,tcp:443 \
      --target-tags=http-server
  fi

  local ip
  ip="$(vm_external_ip || true)"
  [[ -n "$ip" ]] && ok "External IP: $ip"

  if (( just_created )); then
    wait_for_ssh
  fi

  echo
  log "Next: point DNS for $APP_DOMAIN to $ip"
  echo "  Type: A    Name: rechat    Value: $ip    TTL: 300"
  echo
  echo "  Then run: $0 dns && $0 https && $0 verify"
}

cmd_install() {
  require_cmd gcloud
  instance_exists || die "VM $INSTANCE not found; run 'provision' first."
  wait_for_ssh
  log "Installing Docker on $INSTANCE..."
  ssh_vm '
    set -e
    if ! command -v docker >/dev/null 2>&1; then
      curl -fsSL https://get.docker.com | sh
    else
      echo "docker already installed: $(docker --version)"
    fi
    if ! id -nG "$USER" | tr " " "\n" | grep -qx docker; then
      sudo usermod -aG docker "$USER"
      echo "added $USER to docker group"
    fi
  '
  ok "Docker ready."
}

cmd_upload() {
  require_cmd gcloud
  require_cmd tar
  instance_exists || die "VM $INSTANCE not found; run 'provision' first."
  ensure_prod_env

  log "Streaming project to $INSTANCE:~/$REMOTE_DIR (excludes node_modules/build/.git)..."
  ssh_vm "mkdir -p ~/$REMOTE_DIR"
  tar -C "$PROJECT_ROOT" "${UPLOAD_EXCLUDES[@]}" -czf - . \
    | gcloud compute ssh "$INSTANCE" --zone="$ZONE" --quiet \
        --command="tar -xzf - -C ~/$REMOTE_DIR"

  ssh_vm "test -f ~/$REMOTE_DIR/.env && echo 'env ok' || (echo 'MISSING .env on VM' >&2; exit 1)"
  ok "Project uploaded."
}

cmd_authorize_db() {
  require_cmd gcloud
  instance_exists || die "VM $INSTANCE not found; run 'provision' first."

  if ! gcloud sql instances describe "$CLOUD_SQL_INSTANCE" >/dev/null 2>&1; then
    die "Cloud SQL instance '$CLOUD_SQL_INSTANCE' not found."
  fi

  local vm_ip cidr existing combined
  vm_ip="$(vm_external_ip || true)"
  [[ -n "$vm_ip" ]] || die "Could not determine VM external IP."
  cidr="$vm_ip/32"

  existing="$(gcloud sql instances describe "$CLOUD_SQL_INSTANCE" \
    --format='value(settings.ipConfiguration.authorizedNetworks[].value)' \
    2>/dev/null | tr ';\t\n' ',,,' | sed 's/,\+/,/g; s/^,//; s/,$//')"

  if [[ ",$existing," == *",$cidr,"* ]]; then
    ok "$cidr is already authorized on Cloud SQL '$CLOUD_SQL_INSTANCE'."
    return 0
  fi

  combined="${existing:+$existing,}$cidr"
  log "Authorizing $cidr on Cloud SQL '$CLOUD_SQL_INSTANCE'..."
  gcloud sql instances patch "$CLOUD_SQL_INSTANCE" \
    --authorized-networks="$combined" --quiet
  ok "Cloud SQL authorized networks updated."
}

cmd_build() {
  vm_compose 'build --pull'
}

cmd_init() {
  ensure_prod_env
  log "Building production images on $INSTANCE (frontend + backend; may take 10–20 min)..."
  vm_compose 'build --pull'
  log "Starting stack (ollama + rechat)..."
  vm_compose 'up -d'
  ok "Stack is up. Run '$0 status' or '$0 logs rechat'."
}

cmd_start()  { vm_compose 'up -d'; }
cmd_status() { vm_compose 'ps'; }
cmd_logs()   {
  local svc="${1:-rechat}"
  vm_compose "logs --tail=200 -f $svc"
}

cmd_push() {
  cmd_upload
  log "Restarting services (no rebuild)..."
  vm_compose 'up -d'
  ok "Push complete."
}

cmd_update() {
  cmd_upload
  log "Rebuilding and restarting..."
  vm_compose 'build --pull'
  vm_compose 'up -d'
  ok "Update applied."
}

cmd_git_init() {
  require_cmd gcloud
  instance_exists || die "VM $INSTANCE not found; run 'provision' first."
  ensure_prod_env

  log "Converting ~/$REMOTE_DIR on $INSTANCE to a git checkout of $GIT_REPO..."
  ssh_vm "
    set -euo pipefail
    dir=\$HOME/$REMOTE_DIR
    backup=\$(mktemp -d)
    staging=\$(mktemp -d)
    trap 'rm -rf \"\$backup\" \"\$staging\"' EXIT

    if [[ -d \"\$dir\" ]]; then
      [[ -f \"\$dir/.env\" ]] && cp \"\$dir/.env\" \"\$backup/.env\"
      [[ -f \"\$dir/compose.https.yaml\" ]] && cp \"\$dir/compose.https.yaml\" \"\$backup/\"
      [[ -d \"\$dir/caddy\" ]] && cp -a \"\$dir/caddy\" \"\$backup/\"
    fi

    if [[ -d \"\$dir/.git\" ]]; then
      echo 'Already a git checkout — syncing remote.'
      cd \"\$dir\"
      git remote set-url origin '$GIT_REPO' || git remote add origin '$GIT_REPO'
      git fetch origin '$GIT_BRANCH'
      git reset --hard origin/'$GIT_BRANCH'
    else
      git clone --branch '$GIT_BRANCH' --depth 1 '$GIT_REPO' \"\$staging\"
      rm -rf \"\$dir\"
      mv \"\$staging\" \"\$dir\"
    fi

    cd \"\$dir\"
    [[ -f \"\$backup/.env\" ]] && cp \"\$backup/.env\" .env
    [[ -f \"\$backup/compose.https.yaml\" ]] && cp \"\$backup/compose.https.yaml\" .
    [[ -d \"\$backup/caddy\" ]] && mkdir -p caddy && cp -a \"\$backup/caddy/.\" caddy/
    chmod +x scripts/vm-deploy.sh 2>/dev/null || true
    test -f .env || { echo 'MISSING .env after git-init' >&2; exit 1; }
    git log -1 --oneline
  "
  ok "VM is on git. Future deploys: push to main (GitHub Actions) or '$0 pull'"
}

cmd_setup_deploy_key() {
  require_cmd gcloud
  instance_exists || die "VM $INSTANCE not found."
  log "Creating read-only deploy key on $INSTANCE..."
  ssh_vm "
    set -euo pipefail
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    if [[ ! -f ~/.ssh/rechat_deploy ]]; then
      ssh-keygen -t ed25519 -N '' -f ~/.ssh/rechat_deploy -C 'rechat-prod-deploy'
    fi
    grep -q 'IdentityFile ~/.ssh/rechat_deploy' ~/.ssh/config 2>/dev/null || cat >> ~/.ssh/config <<'CFG'

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/rechat_deploy
  IdentitiesOnly yes
CFG
    chmod 600 ~/.ssh/config ~/.ssh/rechat_deploy
    ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null
    chmod 600 ~/.ssh/known_hosts 2>/dev/null || true
    echo '--- Add this deploy key to GitHub (repo → Settings → Deploy keys, read-only): ---'
    cat ~/.ssh/rechat_deploy.pub
  "
  ok "After adding the deploy key, run: $0 git-init"
}

cmd_pull() {
  require_cmd gcloud
  instance_exists || die "VM $INSTANCE not found."
  log "Pull + rebuild on $INSTANCE..."
  ssh_vm "cd ~/$REMOTE_DIR && chmod +x scripts/vm-deploy.sh && ./scripts/vm-deploy.sh"
  ok "Pull deploy complete."
}

cmd_deploy_logs() {
  ssh_vm "tail -n 200 -f ~/.rechat/deploy.log 2>/dev/null || echo 'No deploy log yet.'"
}

cmd_setup_autodeploy() {
  log "GitHub Actions deploy (push to main):"
  echo
  echo "  1. Run: ./scripts/setup-github-secrets.sh  (once — pushes secrets via gh CLI)"
  echo "  2. Run: ./scripts/install-git-hooks.sh     (syncs .env on each push to main)"
  echo "  3. One-time on VM: $0 setup-deploy-key && $0 git-init"
  echo
  echo "  Secrets set by setup-github-secrets.sh: GCP_PROJECT_ID, PRODUCTION_DOTENV, WEBUI_SECRET_KEY"
  echo "  Manual once: GCP_SA_KEY (service account JSON — see setup-github-secrets.sh output)"
  echo "  Manual deploy: $0 pull"
  echo "  Deploy log:    $0 deploy-logs"
}

cmd_ip()  { vm_external_ip; }

cmd_ssh() {
  gcloud compute ssh "$INSTANCE" --zone="$ZONE"
}

cmd_ssh_config() {
  require_cmd gcloud
  instance_exists || die "VM $INSTANCE not found; run 'provision' first."

  gcloud compute config-ssh --quiet >/dev/null

  local long_host host_key_alias ip
  long_host="$INSTANCE.$ZONE.$(gcloud config get-value project 2>/dev/null)"
  host_key_alias="$(awk -v h="$long_host" '
    $1=="Host" { in_block = ($2==h) }
    in_block && tolower($1) ~ /^hostkeyalias=?/ {
      sub(/.*HostKeyAlias[ =]+/, "")
      print; exit
    }' ~/.ssh/config | tr -d ' =')"
  ip="$(vm_external_ip)"
  [[ -n "$host_key_alias" ]] || die "Could not extract HostKeyAlias for $long_host."

  if grep -q "^Host $INSTANCE\$" ~/.ssh/config 2>/dev/null; then
    ok "Short alias 'Host $INSTANCE' already in ~/.ssh/config."
  else
    local tmp; tmp="$(mktemp)"
    {
      printf '# Rechat GCE VM (managed by scripts/deploy.sh).\n'
      printf 'Host %s\n' "$INSTANCE"
      printf '    HostName %s\n' "$ip"
      printf '    User %s\n' "${USER:-$(whoami)}"
      printf '    IdentityFile ~/.ssh/google_compute_engine\n'
      printf '    UserKnownHostsFile ~/.ssh/google_compute_known_hosts\n'
      printf '    IdentitiesOnly yes\n'
      printf '    CheckHostIP no\n'
      printf '    HostKeyAlias %s\n' "$host_key_alias"
      printf '    ServerAliveInterval 30\n\n'
      cat ~/.ssh/config 2>/dev/null
    } >"$tmp"
    mv "$tmp" ~/.ssh/config
    chmod 600 ~/.ssh/config
    ok "Alias added — use: ssh $INSTANCE"
  fi
}

cmd_expose_http() {
  require_cmd gcloud
  instance_exists || die "VM $INSTANCE not found."
  log "Publishing rechat on :80 (temporary, for testing via VM IP)..."
  ssh_vm "cat > ~/$REMOTE_DIR/compose.temp-http.yaml <<'EOF'
services:
  rechat:
    ports:
      - \"80:8080\"
EOF
cd ~/$REMOTE_DIR && docker compose -f $COMPOSE_FILE -f compose.temp-http.yaml up -d"
  local ip
  ip="$(vm_external_ip || true)"
  ok "App reachable at http://$ip/ (temporary — use https after DNS + '$0 https')"
}

cmd_dns() {
  require_cmd gcloud
  local ip resolved
  ip="$(vm_external_ip || true)"
  [[ -n "$ip" ]] || die "VM $INSTANCE has no external IP."

  resolved="$(dig +short "$APP_DOMAIN" A 2>/dev/null | head -1 || true)"

  echo "Domain     : $APP_DOMAIN"
  echo "VM IP      : $ip"
  echo "DNS A now  : ${resolved:-(none)}"
  echo

  if [[ "$resolved" == "$ip" ]]; then
    ok "DNS A record matches the VM — safe to run '$0 https'."
    return 0
  fi

  warn "DNS does not point at the VM yet."
  echo
  echo "At your DNS provider for naoufel.io, add:"
  echo "  Type: A    Host: rechat    Value: $ip    TTL: 300"
  echo
  echo "After propagation: $0 dns && $0 https && $0 verify"
  return 1
}

cmd_https() {
  require_cmd gcloud
  instance_exists || die "VM $INSTANCE not found."

  local domain email ip resolved
  domain="$APP_DOMAIN"
  email="${LETSENCRYPT_EMAIL:-$(read_env_var LETSENCRYPT_EMAIL || true)}"
  [[ -n "$email" ]] || die "Set LETSENCRYPT_EMAIL in $ENV_FILE"

  ip="$(vm_external_ip || true)"
  [[ -n "$ip" ]] || die "Could not determine VM external IP."
  resolved="$(dig +short "$domain" A 2>/dev/null | head -1 || true)"

  log "Domain : $domain"
  log "Email  : $email"
  log "VM IP  : $ip"
  if [[ "$resolved" != "$ip" ]]; then
    warn "DNS A for $domain is '${resolved:-unset}', expected $ip."
    warn "Let's Encrypt HTTP-01 may fail until DNS propagates."
  fi

  local tmpdir
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir:-}"' RETURN

  cat >"$tmpdir/Caddyfile" <<EOF
{
    email $email
}

$domain {
    encode zstd gzip
    reverse_proxy rechat:8080
}
EOF

  cat >"$tmpdir/compose.https.yaml" <<'EOF'
services:
  caddy:
    image: caddy:2-alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - rechat
volumes:
  caddy_data:
  caddy_config:
EOF

  log "Uploading Caddy config..."
  ssh_vm "mkdir -p ~/$REMOTE_DIR/caddy"
  gcloud compute scp --zone="$ZONE" --quiet \
    "$tmpdir/Caddyfile" "$INSTANCE:$REMOTE_DIR/caddy/Caddyfile"
  gcloud compute scp --zone="$ZONE" --quiet \
    "$tmpdir/compose.https.yaml" "$INSTANCE:$REMOTE_DIR/compose.https.yaml"

  log "Starting stack with HTTPS..."
  vm_compose 'up -d'

  ok "Caddy launched. Watch cert provisioning:"
  echo "  $0 https-logs"
  echo "  $0 verify"
}

cmd_https_logs() {
  vm_compose 'logs --tail=200 -f caddy'
}

cmd_verify() {
  require_cmd curl
  local base="https://$APP_DOMAIN"
  log "Checking $base ..."
  curl -fsS -o /dev/null -w "  GET / → HTTP %{http_code}\n" "$base/"
  curl -fsS -o /dev/null -w "  GET /health → HTTP %{http_code}\n" "$base/health"
  ok "HTTPS checks passed. Open:"
  echo "  $base"
}

cmd_all() {
  ensure_prod_env
  cmd_provision
  cmd_install
  cmd_upload
  cmd_init
  cmd_status
  echo
  ok "First-time deploy complete."
  echo "  1. $0 setup-deploy-key && $0 git-init"
  echo "  2. $0 dns && $0 https && $0 verify"
  echo "  3. ./scripts/setup-github-secrets.sh && ./scripts/install-git-hooks.sh"
  echo "     (or: $0 setup-autodeploy for details)"
}

usage() {
  sed -n '2,40p' "$0" | sed 's/^# \{0,1\}//'
}

main() {
  local cmd="${1:-}"
  [[ -n "$cmd" ]] || { usage; exit 1; }
  shift || true
  case "$cmd" in
    provision)      cmd_provision ;;
    install)        cmd_install ;;
    upload)         cmd_upload ;;
    authorize-db)   cmd_authorize_db ;;
    init)           cmd_init ;;
    build)          cmd_build ;;
    start)          cmd_start ;;
    push)           cmd_push ;;
    update)         cmd_update ;;
    git-init)       cmd_git_init ;;
    setup-deploy-key) cmd_setup_deploy_key ;;
    setup-autodeploy) cmd_setup_autodeploy ;;
    pull)           cmd_pull ;;
    deploy-logs)    cmd_deploy_logs ;;
    status)         cmd_status ;;
    logs)           cmd_logs "$@" ;;
    expose-http)    cmd_expose_http ;;
    dns)            cmd_dns ;;
    https)          cmd_https ;;
    https-logs)     cmd_https_logs ;;
    verify)         cmd_verify ;;
    ip)             cmd_ip ;;
    ssh)            cmd_ssh ;;
    ssh-config)     cmd_ssh_config ;;
    all)            cmd_all ;;
    -h|--help|help) usage ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
