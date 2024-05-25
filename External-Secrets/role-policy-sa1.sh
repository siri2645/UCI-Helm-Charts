#!/bin/bash

# Variables
ACCOUNT_NUMBER="788150207190"
CLUSTER_NAME="lucky-eks-cluster"
ROLE_NAME="AWS-SECRET-CSI-STORE-ROLE"
OIDC_AUDIENCE="sts.amazonaws.com"
POLICY_NAME="secret-store-policy"
POLICY_DESCRIPTION="Policy to provide access to secret manager and eks clusters"
SERVICE_ACCOUNT_NAMESPACE="sonarqube"
SERVICE_ACCOUNT_NAME="sonarqube-sa"
REGION="us-west-2"
RDS_SECRET_NAME="rds!db-f5244589-c961-4fa7-b0e5-7459fd8d2929"
LOG_FILE="script.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

create_iam_resources() {
  log "Checking if IAM role $ROLE_NAME already exists..."
  ROLE_EXISTS=$(aws iam get-role --role-name $ROLE_NAME 2>/dev/null)

  if [ $? -eq 0 ]; then
    log "IAM role $ROLE_NAME already exists."

    log "Checking if IAM policy $POLICY_NAME already exists..."
    POLICY_EXISTS=$(aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_NUMBER:policy/$POLICY_NAME 2>/dev/null)

    if [ $? -eq 0 ]; then
      log "IAM policy $POLICY_NAME already exists."
      
      log "Attaching policy $POLICY_NAME to IAM role $ROLE_NAME..."
      aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::$ACCOUNT_NUMBER:policy/$POLICY_NAME

      if [ $? -eq 0 ]; then
        log "Policy $POLICY_NAME attached to IAM role $ROLE_NAME."
      else
        log "Error: Unable to attach policy to IAM role."
        exit 1
      fi
    fi
  else
    log "Creating IAM role $ROLE_NAME..."

    # Retrieve the OIDC issuer URL
    OIDC_PROVIDER_URL=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text)

    if [ -z "$OIDC_PROVIDER_URL" ]; then
      log "Error: Unable to retrieve OIDC issuer URL."
      exit 1
    fi

    log "OIDC PROVIDER URL: $OIDC_PROVIDER_URL"

    # Extract the OIDC provider ARN
    OIDC_PROVIDER_ARN="arn:aws:iam::$ACCOUNT_NUMBER:oidc-provider/$(echo $OIDC_PROVIDER_URL | sed 's|https://||')"

    log "OIDC_PROVIDER_ARN: $OIDC_PROVIDER_ARN"

    # Create the IAM role trust policy
    TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "$OIDC_PROVIDER_ARN"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$OIDC_PROVIDER_ARN:sub": "system:serviceaccount:$SERVICE_ACCOUNT_NAMESPACE:$SERVICE_ACCOUNT_NAME"
        }
      }
    }
  ]
}
EOF
    )

    # Create the IAM role with the trust policy
    aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document "$TRUST_POLICY"

    if [ $? -ne 0 ]; then
      log "Error: Unable to create IAM role."
      exit 1
    fi

    log "Fetching the secret ARN..."
    # Fetch the secret ARN
    SECRET_ARN=$(aws secretsmanager list-secrets --query "SecretList[?Name=='$RDS_SECRET_NAME'].ARN" --output text)

    log "RDS-Secret-Arn: $SECRET_ARN"

    # Policy Document
    POLICY_DOCUMENT=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": ["$SECRET_ARN"]
    }
  ]
}
EOF
    )

    log "Creating IAM policy $POLICY_NAME..."
    # Create the IAM policy
    aws iam create-policy --policy-name $POLICY_NAME --policy-document "$POLICY_DOCUMENT" --description "$POLICY_DESCRIPTION"

    if [ $? -ne 0 ]; then
      log "Error: Unable to create IAM policy."
    fi

    log "Retrieving policy ARN for $POLICY_NAME..."
    # Get the policy ARN
    POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)

    if [ -z "$POLICY_ARN" ]; then
      log "Error: Unable to retrieve policy ARN."
      exit 1
    fi

    log "Attaching policy $POLICY_NAME to IAM role $ROLE_NAME..."
    # Attach the policy to the role
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn $POLICY_ARN

    if [ $? -ne 0 ]; then
      log "Error: Unable to attach policy to IAM role."
      exit 1
    fi

    log "Successfully created IAM role $ROLE_NAME and attached policy $POLICY_NAME."
  fi
}

create_service_account() {
  log "Checking if service account $SERVICE_ACCOUNT_NAME exists in namespace $SERVICE_ACCOUNT_NAMESPACE..."
  # Check if the service account already exists
  kubectl get sa $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    log "Service account $SERVICE_ACCOUNT_NAME already exists in namespace $SERVICE_ACCOUNT_NAMESPACE."
  else
    log "Creating service account $SERVICE_ACCOUNT_NAME in namespace $SERVICE_ACCOUNT_NAMESPACE..."
    # Create the Kubernetes service account with the IAM role annotation
    kubectl create serviceaccount $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE
    if [ $? -eq 0 ]; then
      log "Annotating and labeling service account $SERVICE_ACCOUNT_NAME..."
      kubectl annotate serviceaccount $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE eks.amazonaws.com/role-arn=arn:aws:iam::$ACCOUNT_NUMBER:role/$ROLE_NAME
      log "Service account $SERVICE_ACCOUNT_NAME in namespace $SERVICE_ACCOUNT_NAMESPACE is now linked to IAM role $ROLE_NAME."
    else
      log "Error: Unable to create Service Account $SERVICE_ACCOUNT_NAME."
    fi
  fi
}

# Execute functions
log "Starting IAM resource creation..."
create_iam_resources

log "Starting service account creation..."
create_service_account

log "Script execution completed."
