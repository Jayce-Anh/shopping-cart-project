#!/usr/bin/env bash
# ArgoCD admin password (plaintext) lives in Secrets Manager.
# Helm stores only the bcrypt hash in the cluster — there is no argocd-initial-admin-secret.
set -euo pipefail

SECRET_NAME="${SECRET_NAME:-lab-shopping-cart-helm-addon-credentials}"
REGION="${AWS_REGION:-ap-southeast-1}"

aws secretsmanager get-secret-value \
  --secret-id "${SECRET_NAME}" \
  --region "${REGION}" \
  --query 'SecretString' \
  --output text | jq -r '.argocd_password'
echo
