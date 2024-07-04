#!/bin/bash

# Source variables from the main script
RDS_SECRET_NAME="rds!db-e6531643-8234-401b-8144-64263f2e1809"
RDS_INSTANCE_IDENTIFIER="database-1"
NEW_SECRET_NAME="jfrog-secret"
NEW_SECRET_DESCRIPTION="Credentials and endpoint for JFrog DB"

# Retrieve username and password from the source secret
source_secret=$(aws secretsmanager get-secret-value --secret-id "$source_secret_name" 2>&1)
if [ $? -ne 0 ]; then
    echo "Failed to fetch the source secret. Exiting."
    exit 1
fi

# Extract username and password from the source secret
username=$(echo $source_secret | jq -r '.SecretString' | jq -r '.username')
password=$(echo $source_secret | jq -r '.SecretString' | jq -r '.password')

# Retrieve RDS endpoint
rds_endpoint=$(aws rds describe-db-instances --db-instance-identifier $RDS_INSTANCE_IDENTIFIER --query "DBInstances[0].Endpoint.Address" --output text)

# Create a new secret with the retrieved username, password, and RDS endpoint
new_secret_string=$(jq -n \
    --arg username "$username" \
    --arg password "$password" \
    --arg endpoint "$rds_endpoint" \
    '{username: $username, password: $password, endpoint: $endpoint}')

aws secretsmanager create-secret \
    --name $NEW_SECRET_NAME \
    --description "$NEW_SECRET_DESCRIPTION" \
    --secret-string "$new_secret_string"

if [ $? -eq 0 ]; then
    echo "Secret $NEW_SECRET_NAME created successfully with the username, password, and endpoint."
else
    echo "Failed to create the new secret. Exiting."
    exit 1
fi
