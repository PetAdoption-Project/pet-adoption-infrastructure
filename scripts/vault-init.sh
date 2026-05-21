#!/bin/sh
set -e

: "${VAULT_ADDR:?VAULT_ADDR is not set}"
: "${VAULT_TOKEN:?VAULT_TOKEN is not set}"

SECRET_PATH="secret/petadoption/services"

echo "Waiting for Vault to be ready..."
until vault status > /dev/null 2>&1; do
  sleep 2
done
echo "Vault is ready."

echo "Storing secrets..."
vault kv put "$SECRET_PATH" \
  db-url="$DATA_SOURCE_URL" \
  db-username="$POSTGRES_USER" \
  db-password="$POSTGRES_PASSWORD" \
  keycloak-url="$KEYCLOAK_URL" \
  keycloak-realm="$KEYCLOAK_REALM" \
  keycloak-admin-client-id="$KEYCLOAK_ADMIN_CLIENT_ID" \
  keycloak-gateway-client-id="$KEYCLOAK_GATEWAY_CLIENT_ID"

echo "Vault initialized successfully."
