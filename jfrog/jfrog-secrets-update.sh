#!/bin/bash

# Variables
source_secret_name='rds!db-e6531643-8234-401b-8144-64263f2e1809'  # Enclose the value in single quotes
rds_instance_identifier="database-1"     # Replace with your RDS instance identifier
new_secret_name="jfrog-secret"        # Name for the new secret
new_secret_description="Credentials and endpoint for JFrog DB"  # Description for the new secret

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
rds_endpoint=$(aws rds describe-db-instances --db-instance-identifier $rds_instance_identifier --query "DBInstances[0].Endpoint.Address" --output text)

# Create a new secret with the retrieved username, password, and RDS endpoint
new_secret_string=$(jq -n \
    --arg username "$username" \
    --arg password "$password" \
    --arg endpoint "$rds_endpoint" \
    '{username: $username, password: $password, endpoint: $endpoint}')

aws secretsmanager create-secret \
    --name $new_secret_name \
    --description "$new_secret_description" \
    --secret-string "$new_secret_string"

if [ $? -eq 0 ]; then
    echo "Secret $new_secret_name created successfully with the username, password, and endpoint."
else
    echo "Failed to create the new secret. Exiting."
    exit 1
fi
