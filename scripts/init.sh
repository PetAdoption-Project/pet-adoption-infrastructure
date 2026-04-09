#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../.env.local"

if [ -f "$ENV_FILE" ]; then
  echo "Loading environment from .env.local..."
  set -a
  # shellcheck source=../.env.local
  source "$ENV_FILE"
  set +a
  export VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
  export KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:8180}"
else
  echo "No .env.local found, using environment variables..."
  : "${VAULT_ADDR:?VAULT_ADDR is required}"
  : "${VAULT_TOKEN:?VAULT_TOKEN is required}"
  : "${KEYCLOAK_URL:?KEYCLOAK_URL is required}"
  : "${KEYCLOAK_ADMIN:?KEYCLOAK_ADMIN is required}"
  : "${KEYCLOAK_ADMIN_PASSWORD:?KEYCLOAK_ADMIN_PASSWORD is required}"
fi

echo "=== Running vault-init.sh ==="
bash "$SCRIPT_DIR/vault-init.sh"

echo "=== Running keycloak-init.sh ==="
bash "$SCRIPT_DIR/keycloak-init.sh"

echo "=== Init complete ==="
