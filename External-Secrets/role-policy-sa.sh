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

create_iam_resources() {
  # Check if the role already exists
  ROLE_EXISTS=$(aws iam get-role --role-name $ROLE_NAME 2>/dev/null)

  if [ $? -eq 0 ]; then
    echo "IAM role $ROLE_NAME already exists."

    # Check if the policy already exists
    POLICY_EXISTS=$(aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_NUMBER:policy/$POLICY_NAME 2>/dev/null)

    if [ $? -eq 0 ]; then
      echo "IAM policy $POLICY_NAME already exists."
      
      # Attach the policy to the role
      aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::$ACCOUNT_NUMBER:policy/$POLICY_NAME

      if [ $? -eq 0 ]; then
        echo "Policy $POLICY_NAME attached to IAM role $ROLE_NAME."
      else
        echo "Error: Unable to attach policy to IAM role."
        exit 1
      fi
    fi
  else
    # Retrieve the OIDC issuer URL
    OIDC_PROVIDER_URL=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text)

    if [ -z "$OIDC_PROVIDER_URL" ]; then
      echo "Error: Unable to retrieve OIDC issuer URL."
      exit 1
    fi

    echo "OIDC PROVIDER URL: $OIDC_PROVIDER_URL"

    # Extract the OIDC provider ARN
    OIDC_PROVIDER_ARN="arn:aws:iam::$ACCOUNT_NUMBER:oidc-provider/$(echo $OIDC_PROVIDER_URL | sed 's|https://||')"

    echo "OIDC_PROVIDER_ARN: $OIDC_PROVIDER_ARN"

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
          "$(echo $OIDC_PROVIDER_URL | sed 's|https://||'):aud": "sts.amazonaws.com",
          "$(echo $OIDC_PROVIDER_URL | sed 's|https://||'):sub": "system:serviceaccount:$SERVICE_ACCOUNT_NAMESPACE:$SERVICE_ACCOUNT_NAME"
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
      echo "Error: Unable to create IAM role."
      exit 1
    fi

    # Fetch the secret ARN
    SECRET_ARN=$(aws secretsmanager list-secrets --query "SecretList[?Name=='$RDS_SECRET_NAME'].ARN" --output text)

    echo "RDS-Secret-Arn: $SECRET_ARN"

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
      "Resource": [
       "$SECRET_ARN",
       arn:aws:iam::aws:policy/SecretsManagerReadWrite 
       ]
    }
  ]
}
EOF
    )

    # Create the IAM policy
    aws iam create-policy --policy-name $POLICY_NAME --policy-document "$POLICY_DOCUMENT" --description "$POLICY_DESCRIPTION"

    if [ $? -ne 0 ]; then
      echo "Error: Unable to create IAM policy."
    fi

    # Get the policy ARN
    POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)

    if [ -z "$POLICY_ARN" ]; then
      echo "Error: Unable to retrieve policy ARN."
      exit 1
    fi

    # Attach the policy to the role
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn $POLICY_ARN

    if [ $? -ne 0 ]; then
      echo "Error: Unable to attach policy to IAM role."
      exit 1
    fi

    echo "Successfully created IAM role $ROLE_NAME and attached policy $POLICY_NAME."
  fi
}

create_service_account() {
  # Check if the service account already exists
  kubectl get sa $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    echo "Service account $SERVICE_ACCOUNT_NAME already exists in namespace $SERVICE_ACCOUNT_NAMESPACE."
    kubectl annotate serviceaccount $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE eks.amazonaws.com/role-arn=arn:aws:iam::$ACCOUNT_NUMBER:role/$ROLE_NAME
    echo "Service account $SERVICE_ACCOUNT_NAME in namespace $SERVICE_ACCOUNT_NAMESPACE is now linked to IAM role $ROLE_NAME."
  else
    # Create the Kubernetes service account with the IAM role annotation
    kubectl create serviceaccount $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE
    if [ $? -eq 0 ]; then
      kubectl annotate serviceaccount $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE eks.amazonaws.com/role-arn=arn:aws:iam::$ACCOUNT_NUMBER:role/$ROLE_NAME
      echo "Service account $SERVICE_ACCOUNT_NAME in namespace $SERVICE_ACCOUNT_NAMESPACE is now linked to IAM role $ROLE_NAME."
    else
      echo "Unable to create Service Account with $ROLE_NAME"
    fi
  fi
}

# Execute functions
create_iam_resources
create_service_account
