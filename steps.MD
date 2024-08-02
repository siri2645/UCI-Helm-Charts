# Changes in Values file for Ingress, Jenkins, Sonrqube, Jfrog and External Secrets

First Create the EKS Cluster 

## Ingress Nginx

Deploying the ingress-nginx Helm chart using the following steps:

```
1. Create a dedicated namespace for the ingress controller, named ingress-controller.

2. Deployed the ingress Helm chart within this namespace.
```

Each Helm chart includes a default values.yaml file, which can be customized to fit our deployment needs. Here are the modifications we made:

```
1. Internal Load Balancer (line 537): Enabled the internal load balancer and added the necessary annotations for proper configuration.

2. TLS Certificate: Add a certificate annotation in the annotations section.

3. Service Type (line 552): Change the service type from ClusterIP to LoadBalancer to allow external access to the service.

4. External Service Type (line 466): Change the external service type from LoadBalancer to ClusterIP since we are using an internal load balancer.

5. Admission Webhook (line 728): Disabled the webhook because it generates dynamic admission control on API requests, preventing deletion or updates related to external secrets. The webhook locks the current configuration.
```

## Jenkins

Deploying the Jenkins Helm chart using the following steps:

```
1. Create a dedicated namespace for the Jenkins, named as Jenkins.

2. Deploying the Jenkins Helm chart within this namespace.
```

#### Default Jenkins values file changes

```
1. Path-Based Routing (line 173): To enable path-based routing for Jenkins, add these path “/jenkins”.

2. Disable Ingress (line 654): Disable the default ingress and deploy a custom ingress YAML file to support path-based routing.
```

## Sonarqube

Deploying the Sonarqube Helm chart using the following steps:

```
1. Create a dedicated namespace for the Sonarqube, named as sonarqube.

2. Deploying the Sonarqube Helm chart within this namespace.
```
#### Default sonarqube values file changes

```
1. Path-Based Routing:
   - Extra Environment Variables: Add the following at the end of the file for SonarQube path-based routing:
        extraEnv:
           sonar.web.context: /SonarQube
     
   - Readiness Probe (line 179): Set `sonarWebContext` to `/sonarqube/`.
   - Liveness Probe (line 190): Set `sonarWebContext` to `/sonarqube/`.
   - Startup Probe (line 201): Set `sonarWebContext` to `/sonarqube/`.

2. Disable Ingress (line 102): Disable the default ingress and deploy a custom ingress YAML file to enable path-based routing.

3. Database Configuration (line 438): Configure SonarQube to use AWS RDS.

4. PostgreSQL Configuration (line 454): Disable the default database.
```

## Jfrog

Deploying the Jfrog Helm chart using the following steps:

```
1. Create a dedicated namespace for the Jfrog, named as jfrog.

2. Deploying the jfrog Helm chart within this namespace.
```
#### Default jfrog values file changes
```
1. Keys (lines 17-18): For security reasons, generate the master and join keys and specify them in the values file.

2. Enable Ingress (line 112): Activate path-based ingress for JFrog.

3. Ingress-Nginx (line 1276): Set `enabled` to `false`.

4. Service Type (line 1557): set Service type ClusterIP

5. Database Configuration (line 1727): Configure JFrog to use AWS RDS.

6. PostgreSQL Configuration (line 1684): Disable the default database.
```
## External Secrets



To make AWS RDS credentials accessible in the EKS cluster, we deploy the External Secrets Helm chart along with the external-secrets.yaml and SecretStore.yaml files. An automation script, which includes role-policy.sh, secret-manager.sh, external-secrets.yaml, and secret-store.yaml, is used to achieve this. This script manages the deployment and configuration required to retrieve the credentials from AWS Secrets Manager and make them available in the EKS cluster.

#### Default external-secrets values file changes
```
1. Disable webhook line no 235: Disabled the webhook because it generates dynamic admission control on API requests, preventing deletion or updates related to external secrets. The webhook locks the current configuration.

2. Role-policy.sh, line no (4-13): we need to update the required details.

3. External-secrets.yaml, line no (16 and 20): here we change the aws rds key value(remoteRef key).
      a. Line no 4: if you want to change the external secrets file name also 
      
      b.Line no 5: here we can mention the namespace name
                                                         
      c. Line no 9: if you want to change the secretstore file name like secretstore to sonar-secretstore
      
      d. Line no 12: here we can mention the target file name. the rds credentials are stored in this file. 

4. Secretstore.yaml, line no 4: here which name we are mentioned in external secrets (line no 9) that name and this name should be same. 
      a. Line no 5: here we need to mention the namespace name.
      
      b. Line no 10: here we can mention the region name.
      c. 
      Line no 14: here we can mention the service account name

5. Jfrog-secrets-update.sh line no (4 to 9): here we can mention the required details. (this file we configured for jfrog only).
```




