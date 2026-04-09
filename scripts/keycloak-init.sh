#!/bin/sh
set -e

KEYCLOAK_URL=${KEYCLOAK_URL:-http://keycloak:8080}
VAULT_ADDR=${VAULT_ADDR:-http://vault:8200}
REALM="pet-adoption"

echo "Waiting for Keycloak to be ready..."
until curl -sf "${KEYCLOAK_URL}/realms/master" > /dev/null; do
  sleep 3
done
echo "Keycloak is ready."

echo "Fetching admin token..."
ADMIN_TOKEN=$(curl -sf \
  -d "client_id=admin-cli" \
  -d "username=${KEYCLOAK_ADMIN}" \
  -d "password=${KEYCLOAK_ADMIN_PASSWORD}" \
  -d "grant_type=password" \
  "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
  | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$ADMIN_TOKEN" ]; then
  echo "Failed to get admin token"
  exit 1
fi

regenerate_client_secret() {
  CLIENT_ID="$1"
  UUID=$(curl -sf \
    -H "Authorization: Bearer ${ADMIN_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${REALM}/clients?clientId=${CLIENT_ID}" \
    | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

  if [ -z "$UUID" ]; then
    echo "Client '${CLIENT_ID}' not found in realm '${REALM}'"
    exit 1
  fi

  # Keycloak 19+ masks secrets in GET — regenerate to get the actual value
  SECRET=$(curl -sf -X POST \
    -H "Authorization: Bearer ${ADMIN_TOKEN}" \
    "${KEYCLOAK_URL}/admin/realms/${REALM}/clients/${UUID}/client-secret" \
    | grep -o '"value":"[^"]*"' | cut -d'"' -f4)

  if [ -z "$SECRET" ]; then
    echo "Failed to regenerate secret for client '${CLIENT_ID}'"
    exit 1
  fi

  echo "$SECRET"
}

echo "Regenerating client secrets..."
ADMIN_CLIENT_SECRET=$(regenerate_client_secret "pet-adoption-admin")
GATEWAY_CLIENT_SECRET=$(regenerate_client_secret "pet-adoption-gateway")

echo "Waiting for Vault to be ready..."
until curl -sf "${VAULT_ADDR}/v1/sys/health" > /dev/null; do
  sleep 2
done

echo "Patching Vault with Keycloak client secrets..."
curl -sf \
  -X PATCH \
  -H "X-Vault-Token: ${VAULT_TOKEN}" \
  -H "Content-Type: application/merge-patch+json" \
  -d "{\"data\":{\"keycloak-admin-client-secret\":\"${ADMIN_CLIENT_SECRET}\",\"keycloak-gateway-client-secret\":\"${GATEWAY_CLIENT_SECRET}\"}}" \
  "${VAULT_ADDR}/v1/secret/data/petadoption/services" > /dev/null

echo "Keycloak initialized successfully."
