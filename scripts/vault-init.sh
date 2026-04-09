#!/bin/bash
set -e

VAULT_ADDR=${VAULT_ADDR:-http://localhost:8200}

echo "Waiting for Vault to be ready..."
until curl -sf "$VAULT_ADDR/v1/sys/health" > /dev/null 2>&1; do
  sleep 2
done
echo "Vault is ready."

echo "Storing secrets..."
curl -sf -X POST "$VAULT_ADDR/v1/secret/data/petadoption/services" \
  -H "X-Vault-Token: $VAULT_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"data\": {
      \"db-url\": \"$DATA_SOURCE_URL\",
      \"db-username\": \"$POSTGRES_USER\",
      \"db-password\": \"$POSTGRES_PASSWORD\",
      \"keycloak-url\": \"$KEYCLOAK_URL\",
      \"keycloak-realm\": \"$KEYCLOAK_REALM\",
      \"keycloak-admin-client-id\": \"$KEYCLOAK_ADMIN_CLIENT_ID\",
      \"keycloak-gateway-client-id\": \"$KEYCLOAK_GATEWAY_CLIENT_ID\"
    }
  }"

echo "Vault initialized successfully."
