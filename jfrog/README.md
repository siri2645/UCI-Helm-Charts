Flowchart for JFrog Helm Deployment with IAM Roles and Secrets Management
Start

Pre-checks and Setup

Create IAM Identity Provider for the EKS Cluster with Thumbprint.
Run Main Script (secret-manager.sh)

Execute role-policy-sa.sh
Create IAM Resources
Check if IAM Role exists
If exists, check if policy exists and attach if necessary.
If Role doesn't exist, create IAM Role and Trust Policy
Retrieve OIDC issuer URL from EKS cluster.
Create IAM Role with Trust Policy.
Retrieve Secret ARN from AWS Secrets Manager.
Create IAM Policy with permissions to access the secret.
Attach IAM Policy to the Role.
Create Kubernetes Service Account
Check if Service Account exists.
If exists, annotate with IAM Role ARN.
If not, create Service Account and annotate with IAM Role ARN.
Execute jfrog-secrets-update.sh
Retrieve username and password from existing secret in AWS Secrets Manager.
Retrieve RDS endpoint.
Create new secret with retrieved credentials and endpoint.
Setup Helm for external-secrets
Add and update Helm repository for external-secrets.
Check if namespace "external-secrets" exists.
If exists, deploy jfrogdb-externalsecrets.yaml and jfrogdb-secretstore.yaml.
If not, install external-secrets with Helm and deploy manifests.
End


Visual Flowchart Representation
Here’s a visual representation of the above steps:

Start
  |
  v
Pre-checks and Setup
  |
  v
Run Main Script (secret-manager.sh)
  |
  v
---------------------------------------------
| Execute role-policy-sa.sh                 |
|-------------------------------------------|
|  Create IAM Resources                     |
|    |                                      |
|    v                                      |
|  Check if IAM Role exists                 |
|    |                                      |
|    |--> If exists, check policy and attach|
|    |                                      |
|    v                                      |
|  If Role doesn't exist, create IAM Role   |
|    |                                      |
|    v                                      |
|  Retrieve OIDC issuer URL from EKS        |
|    |                                      |
|    v                                      |
|  Create IAM Role with Trust Policy        |
|    |                                      |
|    v                                      |
|  Retrieve Secret ARN from Secrets Manager |
|    |                                      |
|    v                                      |
|  Create IAM Policy                        |
|    |                                      |
|    v                                      |
|  Attach IAM Policy to Role                |
|    |                                      |
|    v                                      |
|  Create Kubernetes Service Account        |
|    |                                      |
|    v                                      |
|  Check if Service Account exists          |
|    |                                      |
|    |--> If exists, annotate with Role ARN |
|    |                                      |
|    v                                      |
|  If not, create Service Account           |
|    |                                      |
|    v                                      |
|  Annotate with IAM Role ARN               |
|-------------------------------------------|
| Execute jfrog-secrets-update.sh           |
|-------------------------------------------|
|  Retrieve username and password from secret|
|    |                                      |
|    v                                      |
|  Retrieve RDS endpoint                    |
|    |                                      |
|    v                                      |
|  Create new secret with credentials       |
---------------------------------------------
  |
  v
Setup Helm for external-secrets
  |
  v
Add and update Helm repository for external-secrets
  |
  v
Check if namespace "external-secrets" exists
  |
  v
|--> If exists, deploy jfrogdb-externalsecrets.yaml and jfrogdb-secretstore.yaml
|--> If not, install external-secrets with Helm and deploy manifests
  |
  v
End
