#!/bin/bash

# Variables
CLUSTER_NAME="lucky-eks-cluster"
REGION="us-west-2"
ACCOUNT_ID="788150207190"

# Get OIDC provider URL
get_oidc_provider_url() {
  echo "Retrieving OIDC provider URL for cluster $CLUSTER_NAME in region $REGION..."
  OIDC_PROVIDER_URL=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text)

  if [ $? -ne 0 ]; then
    echo "Error: Unable to retrieve OIDC provider URL."
    exit 1
  fi

  echo "OIDC provider URL: $OIDC_PROVIDER_URL"
  echo $OIDC_PROVIDER_URL
}

# Associate OIDC provider
associate_oidc_provider() {
  OIDC_PROVIDER_URL=$(get_oidc_provider_url)
  OIDC_PROVIDER_HOST=$(echo $OIDC_PROVIDER_URL | sed 's|https://||')

  echo "Checking if OIDC provider already exists..."
  EXISTING_PROVIDERS=$(aws iam list-open-id-connect-providers --query "OpenIDConnectProviderList[*].Arn" --output text)
  for PROVIDER in $EXISTING_PROVIDERS; do
    if [[ "$PROVIDER" == "arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_PROVIDER_HOST" ]]; then
      echo "OIDC provider already exists: $PROVIDER"
      return
    fi
  done

  echo "Creating OIDC provider..."
  THUMBPRINT=$(openssl s_client -servername $OIDC_PROVIDER_HOST -showcerts -connect $OIDC_PROVIDER_HOST:443 < /dev/null 2> /dev/null | openssl x509 -fingerprint -noout | sed 's/://g' | cut -d"=" -f2)
  aws iam create-open-id-connect-provider \
    --url $OIDC_PROVIDER_URL \
    --client-id-list sts.amazonaws.com \
    --thumbprint-list $THUMBPRINT \
    --query OpenIDConnectProviderArn --output text

  if [ $? -ne 0 ]; then
    echo "Error: Unable to create OIDC provider."
    exit 1
  fi

  echo "OIDC provider created successfully."
}

# Execute function
associate_oidc_provider
