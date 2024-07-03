#!/bin/bash
helm uninstall jenkins -n jenkins
kubectl delete ns jenkins


ALTER DATABASE jfrogdb OWNER TO postgres;
GRANT ALL PRIVILEGES ON DATABASE jfrogdb TO postgres;


# Default values for artifactory.
# This is a YAML-formatted file.

# Beware when changing values here. You should know what you are doing!
# Access the values with {{ .Values.key.subkey }}
databaseUpgradeReady: true
global:
  # imageRegistry: releases-docker.jfrog.io
  # imagePullSecrets:
  #   - myRegistryKeySecretName
  ## Chart.AppVersion can be overidden using global.versions.artifactory or .Values.artifactory.image.tag
  ## Note: Order of preference is 1) global.versions 2) .Values.artifactory.image.tag 3) Chart.AppVersion
  ## This applies also for nginx images (.Values.nginx.image.tag)
  versions: {}
  artifactory:
  # initContainers:
  joinKey: 7dbc72684129d78f9647e6e77b385b647e0a04afbf550830bcf4a1064b78ee72
  masterKey: 8f21dc0a59ad1561517667a80d8d568f6c27b85767d80635da5f1654818db92b
     #joinKeySecretName: artifactoy-secret
     #masterKeySecretName: artifactory-secret

  ## Note: tags customInitContainersBegin,customInitContainers,customVolumes,customVolumeMounts,customSidecarContainers can be used both from global and application level simultaneously
  # customInitContainersBegin: |

  # customInitContainers: |

  # customVolumes: |

  # customVolumeMounts: |

  # customSidecarContainers: |

  ## certificates added to this secret will be copied to $JFROG_HOME/artifactory/var/etc/security/keys/trusted directory
  customCertificates:
    enabled: false
    # certificateSecretName:
  ## Applies to artifactory and nginx pods
  nodeSelector: {}
## String to partially override artifactory.fullname template (will maintain the release name)
##
# nameOverride:

## String to fully override artifactory.fullname template
##
# fullnameOverride:

# Init containers
initContainers:
  image:
    registry: releases-docker.jfrog.io
    repository: ubi9/ubi-minimal
    tag: 9.4.949
    pullPolicy: IfNotPresent
  resources:
    requests:
      memory: "50Mi"
      cpu: "10m"
    limits:
      memory: "1Gi"
      cpu: "1"
installer:
  type:
  platform:
## The installerInfo is intentionally commented out and the previous content has been moved under `files/installer-info.json`
## To override the content in `files/installer-info.json`, Uncomment the `installerInfo` and  add relevant data
# installerInfo: '{}'

# For supporting pulling from private registries
# imagePullSecrets:
#   - myRegistryKeySecretName

## Artifactory systemYaml override
## This is for advanced usecases where users wants to provide their own systemYaml for configuring artifactory
## Refer: https://www.jfrog.com/confluence/display/JFROG/Artifactory+System+YAML
## Note: This will override existing (default) .Values.artifactory.systemYaml in values.yaml
## Alternatively, systemYaml can be overidden via customInitContainers using external sources like vaults, external repositories etc. Please refer customInitContainer section below for anexample.
## Note: Order of preference is 1) customInitContainers 2) systemYamlOverride existingSecret 3) default systemYaml in values.yaml
systemYamlOverride:
  ## You can use a pre-existing secret by specifying existingSecret
  existingSecret:
    #existingSecret: "postgresql-password"
    #existingSecretKey: "postgresql-password"
  ## The dataKey should be the name of the secret data key created.
  dataKey:
## Role Based Access Control
## Ref: https://kubernetes.io/docs/admin/authorization/rbac/
rbac:
  create: false
  role:
    ## Rules to create. It follows the role specification
    rules:
      - apiGroups:
          - ''
        resources:
          - services
          - endpoints
          - pods
        verbs:
          - get
          - watch
          - list
## Service Account
## Ref: https://kubernetes.io/docs/admin/service-accounts-admin/
##
serviceAccount:
  create: false
  ## The name of the ServiceAccount to use.
  ## If not set and create is true, a name is generated using the fullname template
  name:
  ## Service Account annotations
  annotations: {}
  ## Explicitly mounts the API credentials for the Service Account
  automountServiceAccountToken: false
ingress:
  enabled: true
  defaultBackend:
    enabled: false
  # Used to create an Ingress record.
  hosts: [ucdevops.exlservice.com]
  routerPath: /
  artifactoryPath: /artifactory/
  rtfsPath: /artifactory/service/rtfs/
  className: "nginx"
  annotations: {}
  kubernetes.io/ingress.class: nginx
    # nginx.ingress.kubernetes.io/configuration-snippet: |
    #rewrite ^/jfrog(/|$)(.*) /artifactory/$2 break;
  #   proxy_pass_header   Server;
  #   proxy_set_header    X-JFrog-Override-Base-Url https://<artifactory-domain>;
  # kubernetes.io/tls-acme: "true"
  # nginx.ingress.kubernetes.io/proxy-body-size: "0"
  labels: {}
  # traffic-type: external
  # traffic-type: internal
  tls: []
  # Secrets must be manually created in the namespace.
  # - secretName: chart-example-tls
  #   hosts:
  #     - artifactory.domain.example

  # Additional ingress rules
  additionalRules: []
  # This is an experimental feature, enabling this feature will route all traffic through the Router.
  disableRouterBypass: false
## Allows to add custom ingress
customIngress: ""
networkpolicy: []
# Allows all ingress and egress
# - name: artifactory
#   podSelector:
#     matchLabels:
#       app: artifactory
#   egress:
#   - {}
#   ingress:
#   - {}
# Uncomment to allow only artifactory pods to communicate with postgresql (if postgresql.enabled is true)
# - name: postgresql
#   podSelector:
#     matchLabels:
#       app: postgresql
#   ingress:
#   - from:
#     - podSelector:
#         matchLabels:
#           app: artifactory

## Apply horizontal pod auto scaling on artifactory pods
## Ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 3
  targetCPUUtilizationPercentage: 70
## You can use a pre-existing secret with keys license_token and iam_role by specifying licenseConfigSecretName
## Example : Create a generic secret using `kubectl create secret generic <secret-name> --from-literal=license_token=${TOKEN} --from-literal=iam_role=${ROLE_ARN}`
aws:
  license:
    enabled: false
  licenseConfigSecretName:
  region: us-east-1
## Container Security Context
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
## @param containerSecurityContext.enabled Enabled containers' Security Context
## @param containerSecurityContext.runAsNonRoot Set container's Security Context runAsNonRoot
## @param containerSecurityContext.privileged Set container's Security Context privileged
## @param containerSecurityContext.allowPrivilegeEscalation Set container's Security Context allowPrivilegeEscalation
## @param containerSecurityContext.capabilities.drop List of capabilities to be dropped
## @param containerSecurityContext.seccompProfile.type Set container's Security Context seccomp profile
##
containerSecurityContext:
  enabled: true
  runAsNonRoot: true
  privileged: false
  allowPrivilegeEscalation: false
  seccompProfile:
    type: RuntimeDefault
  capabilities:
    drop:
      - ALL
## The following router settings are to configure only when splitServicesToContainers set to true
## splitServicesToContainers (by default it is false)
router:
  name: router
  image:
    registry: releases-docker.jfrog.io
    repository: jfrog/router
    tag: 7.105.1
    pullPolicy: IfNotPresent
  serviceRegistry:
    ## Service registry (Access) TLS verification skipped if enabled
    insecure: false
  internalPort: 8082
  externalPort: 8082
  tlsEnabled: false
  ## Extra environment variables that can be used to tune router to your needs.
  ## Uncomment and set value as needed
  extraEnvironmentVariables:
  # - name: MY_ENV_VAR
  #   value: ""
  resources: {}
  #  requests:
  #    memory: "100Mi"
  #    cpu: "100m"
  #  limits:
  #    memory: "1Gi"
  #    cpu: "1"

  # Add lifecycle hooks for router container
  lifecycle:
    # From Artifactory versions 7.52.x, Wait for Artifactory to complete any open uploads or downloads before terminating
    preStop:
      exec:
        command: ["sh", "-c", "while [[ $(curl --fail --silent --connect-timeout 2 http://localhost:8081/artifactory/api/v1/system/liveness) =~ OK ]]; do echo Artifactory is still alive; sleep 2; done"]
        # postStart:
        #   exec:
        #     command: ["/bin/sh", "-c", "echo Hello from the postStart handler"]
  ## Add custom volumesMounts
  customVolumeMounts: ""
  #  - name: custom-script
  #    mountPath: /scripts/script.sh
  #    subPath: script.sh

  livenessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl -s -k --fail --max-time {{ .Values.probes.timeoutSeconds }} {{ include "artifactory.scheme" . }}://localhost:{{ .Values.router.internalPort }}/router/api/v1/system/liveness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}90{{ else }}0{{ end }}
      periodSeconds: 10
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      failureThreshold: 5
      successThreshold: 1
  readinessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl -s -k --fail --max-time {{ .Values.probes.timeoutSeconds }} {{ include "artifactory.scheme" . }}://localhost:{{ .Values.router.internalPort }}/router/api/v1/system/readiness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}60{{ else }}0{{ end }}
      periodSeconds: 10
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      failureThreshold: 5
      successThreshold: 1
  startupProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl -s -k --fail --max-time {{ .Values.probes.timeoutSeconds }} {{ include "artifactory.scheme" . }}://localhost:{{ .Values.router.internalPort }}/router/api/v1/system/readiness
      initialDelaySeconds: 10
      failureThreshold: 30
      periodSeconds: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
  persistence:
    mountPath: "/var/opt/jfrog/router"
# Artifactory
artifactory:
  name: artifactory
  ## refer - https://www.jfrog.com/confluence/display/JFROG/Access+Federation#AccessFederation-EstablishingtheCircleofTrust
  ## root certificates added will be copied to $JFROG_HOME/artifactory/var/etc/access/keys/trusted folder.
  circleOfTrustCertificatesSecret:
  # unifiedSecretInstallation flag enables single unified secret holding all the artifactory internal(chart) secrets, It won't be affecting external secrets.
  ## Note: unifiedSecretInstallation flag is enabled by true by default from chart version 107.79.x, Users can switch to false to continue with the old wayof secret creation.
  unifiedSecretInstallation: true
  ## unifiedSecretPrependReleaseName Set this flag to false if unifiedSecret should not be created with <release-name> prepended.
  unifiedSecretPrependReleaseName: true
  # For HA installation, set this value > 1. This is only supported in Artifactory 7.25.x (appVersions) and above.
  replicaCount: 1
  # minAvailable: 1

  # Note that by default we use appVersion to get image tag/version
  image:
    registry: releases-docker.jfrog.io
    repository: jfrog/artifactory-pro
    # tag:
    pullPolicy: IfNotPresent
  labels: {}
  updateStrategy:
    type: RollingUpdate
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  schedulerName:
  # Create a priority class for the Artifactory pod or use an existing one
  # NOTE - Maximum allowed value of a user defined priority is 1000000000
  priorityClass:
    create: false
    value: 1000000000
    ## Override default name
    # name:
    ## Use an existing priority class
    # existingPriorityClass:
  # Spread Artifactory pods evenly across your nodes or some other topology
  topologySpreadConstraints: []
  # - maxSkew: 1
  #   topologyKey: kubernetes.io/hostname
  #   whenUnsatisfiable: DoNotSchedule
  #   labelSelector:
  #     matchLabels:
  #       app: '{{ template "artifactory.name" . }}'
  #       role: '{{ template "artifactory.name" . }}'
  #       release: "{{ .Release.Name }}"

  # Delete the db.properties file in ARTIFACTORY_HOME/etc/db.properties
  deleteDBPropertiesOnStartup: true
  # certificates added to this secret will be copied to $JFROG_HOME/artifactory/var/etc/security/keys/trusted directory
  customCertificates:
    enabled: false
    # certificateSecretName:
  database:
    maxOpenConnections: 80
  tomcat:
    maintenanceConnector:
      port: 8091
    connector:
      maxThreads: 200
      sendReasonPhrase: false
      extraConfig: 'acceptCount="400"'
  # Support for open metrics is only available for Artifactory 7.7.x (appVersions) and above.
  # To enable set `.Values.artifactory.openMetrics.enabled` to `true`
  # Refer - https://www.jfrog.com/confluence/display/JFROG/Open+Metrics
  openMetrics:
    enabled: false
    ## Settings for pushing metrics to Insight - enable filebeat to true
    filebeat:
      enabled: false
      log:
        enabled: false
        ## Log level for filebeat. Possible values: debug, info, warning, or error.
        level: "info"
      ## Elasticsearch details for filebeat to connect
      elasticsearch:
        url: "Elasticsearch url where JFrog Insight is installed For example, http://<ip_address>:8082"
        username: ""
        password: ""
  # Support for Cold Artifact Storage
  # set 'coldStorage.enabled' to 'true' only for Artifactory instance that you are designating as the Cold instance
  # Refer - https://jfrog.com/help/r/jfrog-platform-administration-documentation/setting-up-cold-artifact-storage
  coldStorage:
    enabled: false
  # This directory is intended for use with NFS eventual configuration for HA
  haDataDir:
    enabled: false
    path:
  haBackupDir:
    enabled: false
    path:
  # Files to copy to ARTIFACTORY_HOME/ on each Artifactory startup
  # Note : From 107.46.x chart versions, copyOnEveryStartup is not needed for binarystore.xml, it is always copied via initContainers
  copyOnEveryStartup:
  #  # Absolute path
  #  - source: /artifactory_bootstrap/artifactory.lic
  #    # Relative to ARTIFACTORY_HOME/
  #    target: etc/artifactory/

  # Sidecar containers for tailing Artifactory logs
  loggers: []
  # - access-audit.log
  # - access-request.log
  # - access-security-audit.log
  # - access-service.log
  # - artifactory-access.log
  # - artifactory-event.log
  # - artifactory-import-export.log
  # - artifactory-request.log
  # - artifactory-service.log
  # - frontend-request.log
  # - frontend-service.log
  # - metadata-request.log
  # - metadata-service.log
  # - router-request.log
  # - router-service.log
  # - router-traefik.log
  # - derby.log

  # Loggers containers resources
  loggersResources: {}
  #  requests:
  #    memory: "10Mi"
  #    cpu: "10m"
  #  limits:
  #    memory: "100Mi"
  #    cpu: "50m"

  # Sidecar containers for tailing Tomcat (catalina) logs
  catalinaLoggers: []
  # - tomcat-catalina.log
  # - tomcat-localhost.log

  # Tomcat (catalina) loggers resources
  catalinaLoggersResources: {}
  #  requests:
  #    memory: "10Mi"
  #    cpu: "10m"
  #  limits:
  #    memory: "100Mi"
  #    cpu: "50m"

  # Migration support from 6.x to 7.x
  migration:
    enabled: true
    timeoutSeconds: 3600
    ## Extra pre-start command in migration Init Container to install JDBC driver for MySql/MariaDb/Oracle
    # preStartCommand: "mkdir -p /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib; cd /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib && curl -o /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/mysql-connector-java-5.1.41.jar https://jcenter.bintray.com/mysql/mysql-connector-java/5.1.41/mysql-connector-java-5.1.41.jar"
  ## Add custom init containers execution before predefined init containers
  customInitContainersBegin: ""
  #  - name: "custom-setup"
  #    image: {{ include "artifactory.getImageInfoByValue" (list . "initContainers") }}
  #    imagePullPolicy: {{ .Values.initContainers.image.pullPolicy }}
  #    securityContext:
  #      runAsNonRoot: true
  #      allowPrivilegeEscalation: false
  #      capabilities:
  #        drop:
  #          - NET_RAW
  #    command:
  #      - 'sh'
  #      - '-c'
  #      - 'touch {{ .Values.artifactory.persistence.mountPath }}/example-custom-setup'
  #    volumeMounts:
  #      - mountPath: "{{ .Values.artifactory.persistence.mountPath }}"
  #        name: artifactory-volume

  ## Add custom init containers execution after predefined init containers
  customInitContainers: ""
  #  - name: "custom-systemyaml-setup"
  #    image: {{ include "artifactory.getImageInfoByValue" (list . "initContainers") }}
  #    imagePullPolicy: {{ .Values.initContainers.image.pullPolicy }}
  #    securityContext:
  #      runAsNonRoot: true
  #      allowPrivilegeEscalation: false
  #      capabilities:
  #        drop:
  #          - NET_RAW
  #    command:
  #      - 'sh'
  #      - '-c'
  #      - 'curl -o {{ .Values.artifactory.persistence.mountPath }}/etc/system.yaml https://<repo-url>/systemyaml'
  #    volumeMounts:
  #      - mountPath: "{{ .Values.artifactory.persistence.mountPath }}"
  #        name: artifactory-volume

  ## Add custom sidecar containers
  # - The provided example uses a custom volume (customVolumes)
  customSidecarContainers: ""
  #  - name: "sidecar-list-etc"
  #    image: {{ include "artifactory.getImageInfoByValue" (list . "initContainers") }}
  #    imagePullPolicy: {{ .Values.initContainers.image.pullPolicy }}
  #    securityContext:
  #      runAsNonRoot: true
  #      allowPrivilegeEscalation: false
  #      capabilities:
  #        drop:
  #          - NET_RAW
  #    command:
  #      - 'sh'
  #      - '-c'
  #      - 'sh /scripts/script.sh'
  #    volumeMounts:
  #      - mountPath: "{{ .Values.artifactory.persistence.mountPath }}"
  #        name: artifactory-volume
  #      - mountPath: "/scripts/script.sh"
  #        name: custom-script
  #        subPath: script.sh
  #    resources:
  #      requests:
  #        memory: "32Mi"
  #        cpu: "50m"
  #      limits:
  #        memory: "128Mi"
  #        cpu: "100m"

  ## Add custom volumes
  # If .Values.artifactory.unifiedSecretInstallation is true then secret name should be '{{ template "artifactory.unifiedSecretPrependReleaseName" . }}-unified-secret'
  customVolumes: ""
  #  - name: custom-script
  #    configMap:
  #      name: custom-script

  ## Add custom volumesMounts
  customVolumeMounts: ""
  #  - name: custom-script
  #    mountPath: "/scripts/script.sh"
  #    subPath: script.sh
  #  - name: posthook-start
  #    mountPath: "/scripts/posthoook-start.sh"
  #    subPath: posthoook-start.sh
  #  - name: prehook-start
  #    mountPath: "/scripts/prehook-start.sh"
  #    subPath: prehook-start.sh

  # Add custom persistent volume mounts - Available to the entire namespace
  customPersistentVolumeClaim: {}
  #  name:
  #  mountPath:
  #  accessModes:
  #   - "-"
  #  size:
  #  storageClassName:

  ## Artifactory license.
  license:
    ## licenseKey is the license key in plain text. Use either this or the license.secret setting
    licenseKey:
    ## If artifactory.license.secret is passed, it will be mounted as
    ## ARTIFACTORY_HOME/etc/artifactory.lic and loaded at run time.
    secret:
    ## The dataKey should be the name of the secret data key created.
    dataKey:
  ## Create configMap with artifactory.config.import.xml and security.import.xml and pass name of configMap in following parameter
  configMapName:
  # Add any list of configmaps to Artifactory
  configMaps: ""
  #  posthook-start.sh: |-
  #    echo "This is a post start script"
  #  posthook-end.sh: |-
  #    echo "This is a post end script"

  ## List of secrets for Artifactory user plugins.
  ## One Secret per plugin's files.
  userPluginSecrets:
  #  - archive-old-artifacts
  #  - build-cleanup
  #  - webhook
  #  - '{{ template "my-chart.fullname" . }}'

  ## Artifactory requires a unique master key.
  ## You can generate one with the command: "openssl rand -hex 32"
  ## An initial one is auto generated by Artifactory on first startup.
  # masterKey: FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  ## Alternatively, you can use a pre-existing secret with a key called master-key by specifying masterKeySecretName
  # masterKeySecretName:

  ## Join Key to connect other services to Artifactory
  ## IMPORTANT: Setting this value overrides the existing joinKey
  ## IMPORTANT: You should NOT use the example joinKey for a production deployment!
  # joinKey: EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
  ## Alternatively, you can use a pre-existing secret with a key called join-key by specifying joinKeySecretName
  # joinKeySecretName:

  ## Registration Token for JFConnect
  # jfConnectToken:
  ## Alternatively, you can use a pre-existing secret with a key called jfconnect-token by specifying jfConnectTokenSecretName
  # jfConnectTokenSecretName:

  # Add custom secrets - secret per file
  # If .Values.artifactory.unifiedSecretInstallation is true then secret name should be '{{ template "artifactory.unifiedSecretPrependReleaseName" . }}-unified-secret' common to all secrets
  customSecrets:
  #  - name: custom-secret
  #    key: custom-secret.yaml
  #    data: >
  #      custom_secret_config:
  #        parameter1: value1
  #        parameter2: value2
  #  - name: custom-secret2
  #    key: custom-secret2.config
  #    data: |
  #      here the custom secret 2 config

  ## If false, all service console logs will not redirect to a common console.log
  consoleLog: false
  ## admin allows to set the password for the default admin user.
  ## See: https://www.jfrog.com/confluence/display/JFROG/Users+and+Groups#UsersandGroups-RecreatingtheDefaultAdminUserrecreate
  admin:
    ip: "127.0.0.1"
    username: "admin"
    password:
    secret:
    dataKey:
  ## Extra pre-start command to install JDBC driver for MySql/MariaDb/Oracle
  # preStartCommand: "mkdir -p /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib; cd /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib && curl -o /opt/jfrog/artifactory/var/bootstrap/artifactory/tomcat/lib/mysql-connector-java-5.1.41.jar https://jcenter.bintray.com/mysql/mysql-connector-java/5.1.41/mysql-connector-java-5.1.41.jar"

  # Add lifecycle hooks for artifactory container
  lifecycle: {}
  # postStart:
  #   exec:
  #     command: ["/bin/sh", "-c", "echo Hello from the postStart handler"]
  # preStop:
  #   exec:
  #     command: ["/bin/sh","-c","echo Hello from the preStop handler"]

  ## Extra environment variables that can be used to tune Artifactory to your needs.
  ## Uncomment and set value as needed
  extraEnvironmentVariables:
  # - name: SERVER_XML_ARTIFACTORY_PORT
  #   value: "8081"
  # - name: SERVER_XML_ARTIFACTORY_MAX_THREADS
  #   value: "200"
  # - name: SERVER_XML_ACCESS_MAX_THREADS
  #   value: "50"
  # - name: SERVER_XML_ARTIFACTORY_EXTRA_CONFIG
  #   value: ""
  # - name: SERVER_XML_ACCESS_EXTRA_CONFIG
  #   value: ""
  # - name: SERVER_XML_EXTRA_CONNECTOR
  #   value: ""
  # - name: DB_POOL_MAX_ACTIVE
  #   value: "100"
  # - name: DB_POOL_MAX_IDLE
  #   value: "10"
  # - name: MY_SECRET_ENV_VAR
  #   valueFrom:
  #     secretKeyRef:
  #       name: my-secret-name
  #       key: my-secret-key
  ## System YAML entries now reside under files/system.yaml.
  ## You can provide the specific values that you want to add or override under 'artifactory.extraSystemYaml'.
  ## For example:
  ## extraSystemYaml:
  ##   shared:
  ##     node:
  ##       id: my-instance
  ## The entries provided under 'artifactory.extraSystemYaml' are merged with files/system.yaml to create the final system.yaml.
  ## If you have already provided system.yaml under, 'artifactory.systemYaml', the values in that entry take precedence over files/system.yaml
  ## You can modify specific entries with your own value under `artifactory.extraSystemYaml`, The values under extraSystemYaml overrides the values under 'artifactory.systemYaml' and files/system.yaml
  extraSystemYaml: {}
  ## systemYaml is intentionally commented and the previous content has been moved under files/system.yaml.
  ## You have to add the all entries of the system.yaml file here, and it overrides the values in files/system.yaml.
  # systemYaml:
  annotations: {}
  service:
    name: artifactory
    type: ClusterIP
    ## @param service.ipFamilyPolicy Controller Service ipFamilyPolicy (optional, cloud specific)
    ## This can be either SingleStack, PreferDualStack or RequireDualStack
    ## ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services
    ##
    ipFamilyPolicy: ""
    ## @param service.ipFamilies Controller Service ipFamilies (optional, cloud specific)
    ## This can be either ["IPv4"], ["IPv6"], ["IPv4", "IPv6"] or ["IPv6", "IPv4"]
    ## ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services
    ##
    ipFamilies: []
    ## For supporting whitelist on the Artifactory service (useful if setting service.type=LoadBalancer)
    ## Set this to a list of IP CIDR ranges
    ## Example: loadBalancerSourceRanges: ['10.10.10.5/32', '10.11.10.5/32']
    ## or pass from helm command line
    ## Example: helm install ... --set nginx.service.loadBalancerSourceRanges='{10.10.10.5/32,10.11.10.5/32}'
    loadBalancerSourceRanges: []
    annotations: {}
    ## If the type is NodePort you can set a fixed port
    # nodePort: 32082
  statefulset:
    annotations: {}
  ## IMPORTANT: If overriding artifactory.internalPort:
  ## DO NOT use port lower than 1024 as Artifactory runs as non-root and cannot bind to ports lower than 1024!
  externalPort: 8082
  internalPort: 8082
  externalArtifactoryPort: 8081
  internalArtifactoryPort: 8081
  terminationGracePeriodSeconds: 30
  ## Pod Security Context
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  ## @param artifactory.podSecurityContext.enabled Enable security context
  ## @param artifactory.podSecurityContext.runAsNonRoot Set pod's Security Context runAsNonRoot
  ## @param artifactory.podSecurityContext.runAsUser User ID for the pod
  ## @param artifactory.podSecurityContext.runASGroup Group ID for the pod
  ## @param artifactory.podSecurityContext.fsGroup Group ID for the pod
  ##
  podSecurityContext:
    enabled: true
    runAsNonRoot: true
    runAsUser: 1030
    runAsGroup: 1030
    fsGroup: 1030
    # fsGroupChangePolicy: "Always"
    # seLinuxOptions: {}
  livenessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl -s -k --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.artifactory.tomcat.maintenanceConnector.port }}/artifactory/api/v1/system/liveness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}180{{ else }}0{{ end }}
      periodSeconds: 10
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      failureThreshold: 5
      successThreshold: 1
  readinessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl -s -k --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.artifactory.tomcat.maintenanceConnector.port }}/artifactory/api/v1/system/readiness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}90{{ else }}0{{ end }}
      periodSeconds: 10
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      failureThreshold: 5
      successThreshold: 1
  startupProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl -s -k --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.artifactory.tomcat.maintenanceConnector.port }}/artifactory/api/v1/system/readiness
      initialDelaySeconds: 10
      failureThreshold: 90
      periodSeconds: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
  persistence:
    mountPath: "/var/opt/jfrog/artifactory"
    enabled: true
    ## A manually managed Persistent Volume and Claim
    ## Requires persistence.enabled: true
    ## If defined, PVC must be created manually before volume will be bound
    # existingClaim:

    accessMode: ReadWriteOnce
    ## Storage default size. Should be increased for production deployments.
    size: 20Gi
    ## Use a custom Secret to be mounted as your binarystore.xml
    ## NOTE: This will ignore all settings below that make up binarystore.xml
    customBinarystoreXmlSecret:
    ## Redundancy required For HA deployments, with "cluster" persistence storage type
    redundancy: 3
    lenientLimit: 1
    ## cache-fs binary provider configurations
    ## Refer: https://jfrog.com/help/r/jfrog-installation-setup-documentation/cache-fs-template-configuration
    maxCacheSize: 5000000000
    cacheProviderDir: cache
    ## maxFileSizeLimit:
    ## skipDuringUpload:

    ## Set the persistence storage type. This will apply the matching binarystore.xml to Artifactory config
    ## Supported types are:
    ## file-system (default)
    ## cluster-file-system
    ## nfs
    ## google-storage
    ## google-storage-v2
    ## google-storage-v2-direct
    ## cluster-google-storage-v2
    ## aws-s3-v3
    ## s3-storage-v3-direct
    ## cluster-s3-storage-v3
    ## s3-storage-v3-archive
    ## azure-blob
    ## azure-blob-storage-direct
    ## azure-blob-storage-v2-direct
    ## cluster-azure-blob-storage
    type: file-system
    ## Use binarystoreXml to provide a custom binarystore.xml
    ## This is intentionally commented and below previous content of binarystoreXml is moved under files/binarystore.xml
    ## binarystoreXml:

    ## For artifactory.persistence.type nfs
    ## If using NFS as the shared storage, you must have a running NFS server that is accessible by your Kubernetes
    ## cluster nodes.
    ## Need to have the following set
    nfs:
      # Must pass actual IP of NFS server with '--set For artifactory.persistence.nfs.ip=${NFS_IP}'
      ip:
      haDataMount: "/data"
      haBackupMount: "/backup"
      dataDir: "/var/opt/jfrog/artifactory"
      backupDir: "/var/opt/jfrog/artifactory-backup"
      capacity: 200Gi
    ## For artifactory.persistence.type file-system
    fileSystem:
      cache:
        enabled: false
    ## For artifactory.persistence.type google-storage, google-storage-v2, google-storage-v2-direct, cluster-google-storage-v2
    googleStorage:
      ## When using GCP buckets as your binary store
      gcpServiceAccount:
        enabled: false
        ## Use either an existing secret prepared in advance or put the config (replace the content) in the values
        ## ref: https://github.com/jfrog/charts/blob/master/stable/artifactory-ha/README.md#google-storage
        # customSecretName:
        # config: |
        #   {
        #      "type": "service_account",
        #      "project_id": "<project_id>",
        #      "private_key_id": "?????",
        #      "private_key": "-----BEGIN PRIVATE KEY-----\n????????==\n-----END PRIVATE KEY-----\n",
        #      "client_email": "???@j<project_id>.iam.gserviceaccount.com",
        #      "client_id": "???????",
        #      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        #      "token_uri": "https://oauth2.googleapis.com/token",
        #      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        #      "client_x509_cert_url": "https://www.googleapis.com/robot/v1....."
        #   }
      endpoint: commondatastorage.googleapis.com
      httpsOnly: false
      # Set a unique bucket name
      bucketName: "artifactory-gcp"
      ## GCP Bucket Authentication with Identity and Credential is deprecated.
      ## identity:
      ## credential:
      path: "artifactory/filestore"
      bucketExists: false
      useInstanceCredentials: false
      enableSignedUrlRedirect: false
    ## For artifactory.persistence.type aws-s3-v3, s3-storage-v3-direct, cluster-s3-storage-v3, s3-storage-v3-archive
    awsS3V3:
      testConnection: false
      identity:
      credential:
      region:
      bucketName: artifactory-aws
      path: artifactory/filestore
      endpoint:
      port:
      useHttp:
      maxConnections: 50
      connectionTimeout:
      socketTimeout:
      kmsServerSideEncryptionKeyId:
      kmsKeyRegion:
      kmsCryptoMode:
      useInstanceCredentials: true
      usePresigning: false
      signatureExpirySeconds: 300
      signedUrlExpirySeconds: 30
      cloudFrontDomainName:
      cloudFrontKeyPairId:
      cloudFrontPrivateKey:
      enableSignedUrlRedirect: false
      enablePathStyleAccess: false
      multiPartLimit:
      multipartElementSize:
    ## For artifactory.persistence.type azure-blob, azure-blob-storage-direct, cluster-azure-blob-storage, azure-blob-storage-v2-direct
    azureBlob:
      accountName:
      accountKey:
      endpoint:
      containerName:
      multiPartLimit: 100000000
      multipartElementSize: 50000000
      testConnection: false
    ## artifactory data Persistent Volume Storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    # storageClassName: "-"
    ## Annotations for the Persistent Volume Claim
    annotations: {}
  ## Uncomment the following resources definitions or pass them from command line
  ## to control the cpu and memory resources allocated by the Kubernetes cluster
  resources: {}
  #  requests:
  #    memory: "1Gi"
  #    cpu: "500m"
  #  limits:
  #    memory: "2Gi"
  #    cpu: "1"
  ## The following Java options are passed to the java process running Artifactory.
  ## You should set them according to the resources set above
  javaOpts:
    # xms: "1g"
    # xmx: "2g"
    jmx:
      enabled: false
      port: 9010
      host:
      ssl: false
      # When authenticate is true, accessFile and passwordFile are required
      authenticate: false
      accessFile:
      passwordFile:
      # corePoolSize: 24
  # other: ""

  nodeSelector: {}
  tolerations: []
  affinity: {}
  ## Only used if "affinity" is empty
  podAntiAffinity:
    ## Valid values are "soft" or "hard"; any other value indicates no anti-affinity
    type: "soft"
    topologyKey: "kubernetes.io/hostname"
  ssh:
    enabled: false
    internalPort: 1339
    externalPort: 1339
frontend:
  name: frontend
  enabled: true
  internalPort: 8070
  ## Extra environment variables that can be used to tune frontend to your needs.
  ## Uncomment and set value as needed
  extraEnvironmentVariables:
  # - name: MY_ENV_VAR
  #   value: ""
  resources: {}
  #  requests:
  #    memory: "100Mi"
  #    cpu: "100m"
  #  limits:
  #    memory: "1Gi"
  #    cpu: "1"

  # Add lifecycle hooks for frontend container
  lifecycle: {}
  # postStart:
  #   exec:
  #     command: ["/bin/sh", "-c", "echo Hello from the postStart handler"]
  # preStop:
  #   exec:
  #     command: ["/bin/sh","-c","echo Hello from the preStop handler"]

  ## Session settings
  session:
    ## Time in minutes after which the frontend token will need to be refreshed
    timeoutMinutes: '30'
  ## The following settings are to configure the frequency of the liveness and startup probes when splitServicesToContainers set to true
  livenessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.frontend.internalPort }}/api/v1/system/liveness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}180{{ else }}0{{ end }}
      failureThreshold: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      periodSeconds: 10
      successThreshold: 1
  startupProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.frontend.internalPort }}/api/v1/system/readiness
      initialDelaySeconds: 30
      failureThreshold: 90
      periodSeconds: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
access:
  enabled: true
  ## Enable TLS by changing the tls entry (under the security section) in the access.config.yaml file.
  ## ref: https://www.jfrog.com/confluence/display/JFROG/Managing+TLS+Certificates#ManagingTLSCertificates
  ## When security.tls is set to true, JFrog Access will act as the Certificate Authority (CA) and sign the TLS certificates used by all the different JFrog Platform nodes.
  ## This ensures that the node to node communication is done over TLS.
  accessConfig:
    security:
      tls: false
  ## You can use a pre-existing secret by specifying customCertificatesSecretName
  ## Example : Create a tls secret using `kubectl create secret tls <secret-name> --cert=ca.crt --key=ca.private.key`
  # customCertificatesSecretName:

  ## When resetAccessCAKeys is true, Access will regenerate the CA certificate and matching private key
  # resetAccessCAKeys: false
  database:
    maxOpenConnections: 80
  tomcat:
    connector:
      maxThreads: 50
      sendReasonPhrase: false
      extraConfig: 'acceptCount="100"'
metadata:
  name: metadata
  enabled: true
  internalPort: 8086
  database:
    maxOpenConnections: 80
  ## Extra environment variables that can be used to tune metadata to your needs.
  ## Uncomment and set value as needed
  extraEnvironmentVariables:
  # - name: MY_ENV_VAR
  #   value: ""
  resources: {}
  #  requests:
  #    memory: "100Mi"
  #    cpu: "100m"
  #  limits:
  #    memory: "1Gi"
  #    cpu: "1"

  # Add lifecycle hooks for metadata container
  lifecycle: {}
  # postStart:
  #   exec:
  #     command: ["/bin/sh", "-c", "echo Hello from the postStart handler"]
  # preStop:
  #   exec:
  #     command: ["/bin/sh","-c","echo Hello from the preStop handler"]

  ## The following settings are to configure the frequency of the liveness and startup probes when splitServicesToContainers set to true
  livenessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.metadata.internalPort }}/api/v1/system/liveness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}180{{ else }}0{{ end }}
      failureThreshold: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      periodSeconds: 10
      successThreshold: 1
  startupProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.metadata.internalPort }}/api/v1/system/readiness
      initialDelaySeconds: 30
      failureThreshold: 90
      periodSeconds: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
event:
  name: event
  enabled: true
  internalPort: 8061
  ## WebHook handlers settings for event
  webhooks: {}
  # urlStrictPolicy: false

  ## Extra environment variables that can be used to tune event to your needs.
  ## Uncomment and set value as needed
  extraEnvironmentVariables:
  # - name: MY_ENV_VAR
  #   value: ""
  resources: {}
  #  requests:
  #    memory: "100Mi"
  #    cpu: "100m"
  #  limits:
  #    memory: "1Gi"
  #    cpu: "1"

  # Add lifecycle hooks for event container
  lifecycle: {}
  # postStart:
  #   exec:
  #     command: ["/bin/sh", "-c", "echo Hello from the postStart handler"]
  # preStop:
  #   exec:
  #     command: ["/bin/sh","-c","echo Hello from the preStop handler"]

  ## The following settings are to configure the frequency of the liveness and startup probes when splitServicesToContainers set to true
  livenessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.event.internalPort }}/api/v1/system/liveness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}180{{ else }}0{{ end }}
      failureThreshold: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      periodSeconds: 10
      successThreshold: 1
  startupProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.event.internalPort }}/api/v1/system/readiness
      initialDelaySeconds: 30
      failureThreshold: 90
      periodSeconds: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
jfconnect:
  name: jfconnect
  enabled: true
  internalPort: 8030
  ## Extra environment variables that can be used to tune jfconnect to your needs.
  ## Uncomment and set value as needed
  extraEnvironmentVariables:
  # - name: MY_ENV_VAR
  #   value: ""
  resources: {}
  #  requests:
  #    memory: "100Mi"
  #    cpu: "100m"
  #  limits:
  #    memory: "1Gi"
  #    cpu: "1"

  # Add lifecycle hooks for jfconnect container
  lifecycle: {}
  # postStart:
  #   exec:
  #     command: ["/bin/sh", "-c", "echo Hello from the postStart handler"]
  # preStop:
  #   exec:
  #     command: ["/bin/sh","-c","echo Hello from the preStop handler"]

  ## The following settings are to configure the frequency of the liveness and startup probes when splitServicesToContainers set to true
  livenessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.jfconnect.internalPort }}/api/v1/system/liveness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}180{{ else }}0{{ end }}
      failureThreshold: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      periodSeconds: 10
      successThreshold: 1
  startupProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.jfconnect.internalPort }}/api/v1/system/readiness
      initialDelaySeconds: 30
      failureThreshold: 90
      periodSeconds: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
federation:
  # This is an experimental service which is not in production yet, therefore should not be enabled
  name: federation
  enabled: false
  embedded: false
  internalPort: 8025
  extraJavaOpts: ""
  # This section should be removed once rtfs service is GA
  database:
    port: 5432
    host: postgresql
    name: rtfs
    username: rtfs
    password: ""
  ## Extra environment variables that can be used to tune federation to your needs.
  ## Uncomment and set value as needed
  extraEnvironmentVariables:
  # - name: MY_ENV_VAR
  #   value: ""
  resources: {}
  #  requests:
  #    memory: "100Mi"
  #    cpu: "100m"
  #  limits:
  #    memory: "1Gi"
  #    cpu: "1"

  # Add lifecycle hooks for federation container
  lifecycle: {}
  # postStart:
  #   exec:
  #     command: ["/bin/sh", "-c", "echo Hello from the postStart handler"]
  # preStop:
  #   exec:
  #     command: ["/bin/sh","-c","echo Hello from the preStop handler"]

  ## The following settings are to configure the frequency of the liveness and startup probes when splitServicesToContainers set to true
  livenessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.federation.internalPort }}/artifactory/service/rtfs/api/v1/system/liveness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}180{{ else }}0{{ end }}
      failureThreshold: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      periodSeconds: 10
      successThreshold: 1
  startupProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.federation.internalPort }}/artifactory/service/rtfs/api/v1/system/readiness
      initialDelaySeconds: 30
      failureThreshold: 90
      periodSeconds: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
observability:
  name: observability
  enabled: true
  internalPort: 8036
  ## Extra environment variables that can be used to tune observability to your needs.
  ## Uncomment and set value as needed
  extraEnvironmentVariables:
  # - name: MY_ENV_VAR
  #   value: ""
  resources: {}
  #  requests:
  #    memory: "100Mi"
  #    cpu: "100m"
  #  limits:
  #    memory: "1Gi"
  #    cpu: "1"

  # Add lifecycle hooks for observability container
  lifecycle: {}
  # postStart:
  #   exec:
  #     command: ["/bin/sh", "-c", "echo Hello from the postStart handler"]
  # preStop:
  #   exec:
  #     command: ["/bin/sh","-c","echo Hello from the preStop handler"]

  ## The following settings are to configure the frequency of the liveness and startup probes when splitServicesToContainers set to true
  livenessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.observability.internalPort }}/api/v1/system/liveness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}180{{ else }}0{{ end }}
      failureThreshold: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      periodSeconds: 10
      successThreshold: 1
  startupProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl --fail --max-time {{ .Values.probes.timeoutSeconds }} http://localhost:{{ .Values.observability.internalPort }}/api/v1/system/readiness
      initialDelaySeconds: 30
      failureThreshold: 90
      periodSeconds: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
# MISSION_CONTROL
mc:
  enabled: false
  database:
    maxOpenConnections: 10
  idgenerator:
    maxOpenConnections: 2
  tomcat:
    connector:
      maxThreads: 50
      sendReasonPhrase: false
      extraConfig: 'acceptCount="100"'
# Nginx
nginx:
  enabled: false
  kind: Deployment
  name: nginx
  labels: {}
  replicaCount: 1
  minAvailable: 0
  podSecurityContext:
    enabled: true
    runAsUser: 104
    runAsGroup: 107
    fsGroup: 107
  containerSecurityContext:
    enabled: true
    runAsNonRoot: true
    privileged: false
    readOnlyRootFilesystem: false
    allowPrivilegeEscalation: false
    capabilities:
      drop: ["ALL"]
    seccompProfile:
      type: "RuntimeDefault"
  annotations: {}
  terminationGracePeriodSeconds: 30
  disableProxyBuffering: false
  # singleStackIPv6Cluster flag, which manages the Nginx configuration to enable listening on IPv6 and proxy.
  # If .Values.nginx.service.ipFamilies and .Values.artifactory.service.ipFamilies is configured for only IPv6, users need to enable this flag.
  singleStackIPv6Cluster: false
  deployment:
    annotations: {}
  # Note that by default we use appVersion to get image tag/version
  image:
    registry: releases-docker.jfrog.io
    repository: jfrog/nginx-artifactory-pro
    # tag:
    pullPolicy: IfNotPresent
  # Priority Class name to be used in deployment if provided
  priorityClassName:
  # Spread nginx pods evenly across your nodes or some other topology
  topologySpreadConstraints: []
  # - maxSkew: 1
  #   topologyKey: kubernetes.io/hostname
  #   whenUnsatisfiable: DoNotSchedule
  #   labelSelector:
  #     matchLabels:
  #       app: '{{ template "artifactory.name" . }}'
  #       release: '{{ .Release.Name }}'
  #       component: '{{ .Values.nginx.name }}'

  # Add lifecycle hooks for the nginx pods
  # For example, you can add a `preStop` hook that sends a SIGQUIT to nginx and wait for it to terminate gracefully
  lifecycle: {}
  # postStart:
  #   exec:
  #     command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /var/opt/jfrog/nginx/message"]
  # preStop:
  #   exec:
  #     command: ["/bin/sh","-c","nginx -s quit; while killall -0 nginx; do sleep 1; done"]

  # Sidecar containers for tailing Nginx logs
  loggers: []
  # - access.log
  # - error.log

  # Loggers containers resources
  loggersResources: {}
  #  requests:
  #    memory: "64Mi"
  #    cpu: "25m"
  #  limits:
  #    memory: "128Mi"
  #    cpu: "50m"

  # Logs options
  logs:
    stderr: false
    stdout: false
    level: warn
  ## A list of custom ports to expose on the NGINX pod. Follows the conventional Kubernetes yaml syntax for container ports.
  customPorts: []
  # customPorts:
  # - containerPort: 8066
  #   name: docker

  mainConf: |
    # Main Nginx configuration file
    worker_processes  4;

    {{- if .Values.nginx.logs.stderr }}
    error_log  stderr {{ .Values.nginx.logs.level }};
    {{- else -}}
    error_log  {{ .Values.nginx.persistence.mountPath }}/logs/error.log {{ .Values.nginx.logs.level }};
    {{- end }}
    pid        /var/run/nginx.pid;

    {{- if .Values.artifactory.ssh.enabled }}
    ## SSH Server Configuration
    stream {
      server {
        {{- if .Values.nginx.singleStackIPv6Cluster }}
        listen [::]:{{ .Values.nginx.ssh.internalPort }};
        {{- else -}}
        listen {{ .Values.nginx.ssh.internalPort }};
        {{- end }}
        proxy_pass {{ include "artifactory.fullname" . }}:{{ .Values.artifactory.ssh.externalPort }};
      }
    }
    {{- end }}

    events {
      worker_connections  1024;
    }

    http {
      include       /etc/nginx/mime.types;
      default_type  application/octet-stream;

      variables_hash_max_size 1024;
      variables_hash_bucket_size 64;
      server_names_hash_max_size 4096;
      server_names_hash_bucket_size 128;
      types_hash_max_size 2048;
      types_hash_bucket_size 64;
      proxy_read_timeout 2400s;
      client_header_timeout 2400s;
      client_body_timeout 2400s;
      proxy_connect_timeout 75s;
      proxy_send_timeout 2400s;
      proxy_buffer_size 128k;
      proxy_buffers 40 128k;
      proxy_busy_buffers_size 128k;
      proxy_temp_file_write_size 250m;
      proxy_http_version 1.1;
      client_body_buffer_size 128k;

      log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
      '$status $body_bytes_sent "$http_referer" '
      '"$http_user_agent" "$http_x_forwarded_for"';

      log_format timing 'ip = $remote_addr '
      'user = \"$remote_user\" '
      'local_time = \"$time_local\" '
      'host = $host '
      'request = \"$request\" '
      'status = $status '
      'bytes = $body_bytes_sent '
      'upstream = \"$upstream_addr\" '
      'upstream_time = $upstream_response_time '
      'request_time = $request_time '
      'referer = \"$http_referer\" '
      'UA = \"$http_user_agent\"';

      {{- if .Values.nginx.logs.stdout }}
      access_log /dev/stdout timing;
      {{- else -}}
      access_log {{ .Values.nginx.persistence.mountPath }}/logs/access.log timing;
      {{- end }}

      sendfile        on;
      #tcp_nopush     on;

      keepalive_timeout  65;

      #gzip  on;

      include /etc/nginx/conf.d/*.conf;

    }
  artifactoryConf: |
    {{- if .Values.nginx.https.enabled }}
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_certificate  {{ .Values.nginx.persistence.mountPath }}/ssl/tls.crt;
    ssl_certificate_key  {{ .Values.nginx.persistence.mountPath }}/ssl/tls.key;
    ssl_session_cache shared:SSL:1m;
    ssl_prefer_server_ciphers   on;
    {{- end }}
    ## server configuration
    server {
    {{- if .Values.nginx.internalPortHttps }}
      {{- if .Values.nginx.singleStackIPv6Cluster }}
      listen [::]:{{ .Values.nginx.internalPortHttps }} ssl;
      {{- else -}}
      listen {{ .Values.nginx.internalPortHttps }} ssl;
      {{- end }}
    {{- else -}}
      {{- if .Values.nginx.https.enabled }}
      {{- if .Values.nginx.singleStackIPv6Cluster }}
      listen [::]:{{ .Values.nginx.https.internalPort }} ssl;
      {{- else -}}
      listen {{ .Values.nginx.https.internalPort }} ssl;
      {{- end }}
      {{- end }}
    {{- end }}
    {{- if .Values.nginx.internalPortHttp }}
      {{- if .Values.nginx.singleStackIPv6Cluster }}
      listen [::]:{{ .Values.nginx.internalPortHttp }};
      {{- else -}}
      listen {{ .Values.nginx.internalPortHttp }};
      {{- end }}
    {{- else -}}
      {{- if .Values.nginx.http.enabled }}
      {{- if .Values.nginx.singleStackIPv6Cluster }}
      listen [::]:{{ .Values.nginx.http.internalPort }};
      {{- else -}}
      listen {{ .Values.nginx.http.internalPort }};
      {{- end }}
      {{- end }}
    {{- end }}
      server_name ~(?<repo>.+)\.{{ include "artifactory.fullname" . }} {{ include "artifactory.fullname" . }}
      {{- range .Values.ingress.hosts -}}
        {{- if contains "." . -}}
          {{ "" | indent 0 }} ~(?<repo>.+)\.{{ . }}
        {{- end -}}
      {{- end -}};

      if ($http_x_forwarded_proto = '') {
        set $http_x_forwarded_proto  $scheme;
      }
      set $host_port {{ .Values.nginx.https.externalPort }};
      if ( $scheme = "http" ) {
        set $host_port {{ .Values.nginx.http.externalPort }};
      }
      ## Application specific logs
      ## access_log /var/log/nginx/artifactory-access.log timing;
      ## error_log /var/log/nginx/artifactory-error.log;
      rewrite ^/artifactory/?$ / redirect;
      if ( $repo != "" ) {
        rewrite ^/(v1|v2)/(.*) /artifactory/api/docker/$repo/$1/$2 break;
      }
      chunked_transfer_encoding on;
      client_max_body_size 0;

      location / {
        proxy_read_timeout  900;
        proxy_pass_header   Server;
        proxy_cookie_path   ~*^/.* /;
        proxy_pass          {{ include "artifactory.scheme" . }}://{{ include "artifactory.fullname" . }}:{{ .Values.artifactory.externalPort }}/;
        {{- if .Values.nginx.service.ssloffload}}
        proxy_set_header    X-JFrog-Override-Base-Url $http_x_forwarded_proto://$host;
        {{- else }}
        proxy_set_header    X-JFrog-Override-Base-Url $http_x_forwarded_proto://$host:$host_port;
        proxy_set_header    X-Forwarded-Port  $server_port;
        {{- end }}
        proxy_set_header    X-Forwarded-Proto $http_x_forwarded_proto;
        proxy_set_header    Host              $http_host;
        proxy_set_header    X-Forwarded-For   $proxy_add_x_forwarded_for;
        {{- if .Values.nginx.disableProxyBuffering}}
        proxy_http_version 1.1;
        proxy_request_buffering off;
        proxy_buffering off;
        {{- end }}
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        location /artifactory/ {
          if ( $request_uri ~ ^/artifactory/(.*)$ ) {
            proxy_pass       http://{{ include "artifactory.fullname" . }}:{{ .Values.artifactory.externalArtifactoryPort }}/artifactory/$1;
          }
          proxy_pass         http://{{ include "artifactory.fullname" . }}:{{ .Values.artifactory.externalArtifactoryPort }}/artifactory/;
        }
        location /pipelines/ {
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $http_host;
          {{- if .Values.router.tlsEnabled }}
          proxy_pass  https://{{ include "artifactory.fullname" . }}:{{ .Values.router.internalPort }};
          {{- else }}
          proxy_pass  http://{{ include "artifactory.fullname" . }}:{{ .Values.router.internalPort }};
          {{- end }}
        }
      }
    }
  customInitContainers: ""
  customSidecarContainers: ""
  customVolumes: ""
  customVolumeMounts: ""
  customCommand:
  ##  allows overwriting the command for the nginx container.
  ##  defaults to [ 'nginx', '-g', 'daemon off;' ]

  service:
    ## For minikube, set this to NodePort, elsewhere use LoadBalancer
    type: ClusterIP
    ssloffload: false
    ## @param service.ipFamilyPolicy Controller Service ipFamilyPolicy (optional, cloud specific)
    ## This can be either SingleStack, PreferDualStack or RequireDualStack
    ## ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services
    ##
    ipFamilyPolicy: ""
    ## @param service.ipFamilies Controller Service ipFamilies (optional, cloud specific)
    ## This can be either ["IPv4"], ["IPv6"], ["IPv4", "IPv6"] or ["IPv6", "IPv4"]
    ## ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services
    ##
    ipFamilies: []
    ## For supporting whitelist on the Nginx LoadBalancer service
    ## Set this to a list of IP CIDR ranges
    ## Example: loadBalancerSourceRanges: ['10.10.10.5/32', '10.11.10.5/32']
    ## or pass from helm command line
    ## Example: helm install ... --set nginx.service.loadBalancerSourceRanges='{10.10.10.5/32,10.11.10.5/32}'
    loadBalancerSourceRanges: []
    annotations: {}
    ## Provide static ip address
    loadBalancerIP:
    ## There are two available options: “Cluster” (default) and “Local”.
    externalTrafficPolicy: Cluster
    ## If the type is NodePort you can set a fixed port
    # nodePort: 32082
    ## A list of custom ports to be exposed on nginx service. Follows the conventional Kubernetes yaml syntax for service ports.
    customPorts: []
    # - port: 8066
    #   targetPort: 8066
    #   protocol: TCP
    #   name: docker
  ## Renamed nginx internalPort 80,443 to 8080,8443 to support openshift
  http:
    enabled: true
    externalPort: 80
    internalPort: 8080
  https:
    enabled: true
    externalPort: 443
    internalPort: 8443
  ssh:
    internalPort: 1339
    externalPort: 1339
  # DEPRECATED: The following will be removed in a future release
  # externalPortHttp: 8080
  # internalPortHttp: 8080
  # externalPortHttps: 8443
  # internalPortHttps: 8443

  ## The following settings are to configure the frequency of the liveness and readiness probes.
  livenessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl -s -k --fail --max-time {{ .Values.probes.timeoutSeconds }} {{ include "nginx.scheme" . }}://localhost:{{ include "nginx.port" . }}/
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}180{{ else }}0{{ end }}
      periodSeconds: 10
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      failureThreshold: 5
      successThreshold: 1
  readinessProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl -s -k --fail --max-time {{ .Values.probes.timeoutSeconds }} {{ include "nginx.scheme" . }}://localhost:{{ include "nginx.port" . }}/router/api/v1/system/readiness
      initialDelaySeconds: {{ if semverCompare "<v1.20.0-0" .Capabilities.KubeVersion.Version }}90{{ else }}0{{ end }}
      periodSeconds: 10
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
      failureThreshold: 5
      successThreshold: 1
  startupProbe:
    enabled: true
    config: |
      exec:
        command:
          - sh
          - -c
          - curl -s -k --fail --max-time {{ .Values.probes.timeoutSeconds }} {{ include "nginx.scheme" . }}://localhost:{{ include "nginx.port" . }}/router/api/v1/system/readiness
      initialDelaySeconds: 3
      failureThreshold: 90
      periodSeconds: 5
      timeoutSeconds: {{ .Values.probes.timeoutSeconds }}
  ## The SSL secret that will be used by the Nginx pod
  # tlsSecretName: chart-example-tls
  ## Custom ConfigMap for nginx.conf
  customConfigMap:
  ## Custom ConfigMap for artifactory-ha.conf
  customArtifactoryConfigMap:
  persistence:
    mountPath: "/var/opt/jfrog/nginx"
    enabled: false
    ## A manually managed Persistent Volume and Claim
    ## Requires persistence.enabled: true
    ## If defined, PVC must be created manually before volume will be bound
    # existingClaim:

    accessMode: ReadWriteOnce
    size: 5Gi
    ## nginx data Persistent Volume Storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    # storageClassName: "-"
  resources: {}
  #  requests:
  #    memory: "250Mi"
  #    cpu: "100m"
  #  limits:
  #    memory: "250Mi"
  #    cpu: "500m"
  nodeSelector: {}
  tolerations: []
  affinity: {}
## Database configurations
## Use the wait-for-db init container. Set to false to skip
waitForDatabase: true
## Configuration values for the PostgreSQL dependency sub-chart
## ref: https://github.com/bitnami/charts/blob/master/bitnami/postgresql/README.md
postgresql:
  enabled: true
  image:
    registry: releases-docker.jfrog.io
    repository: bitnami/postgresql
    tag: 15.6.0-debian-11-r16
  postgresqlUsername: jfrogdbadmin
    #postgresqlPassword:
  extraEnv:
    - name: POSTGRESQL_PASSWORD
      valueFrom:
        secretKeyRef:
          name: jfrogdb-secrets
          key: POSTGRESQL_PASSWORD
  postgresqlDatabase: jfrogdb
  postgresqlExtendedConf:
    listenAddresses: "*"
    maxConnections: "1500"
  persistence:
    enabled: true
    size: 200Gi
    # existingClaim:
  service:
    port: 5432
  primary:
    nodeSelector: {}
    affinity: {}
    tolerations: []
  readReplicas:
    nodeSelector: {}
    affinity: {}
    tolerations: []
  resources: {}
  securityContext:
    enabled: true
  containerSecurityContext:
    enabled: true
    #  requests:
    #    memory: "512Mi"
    #    cpu: "100m"
    #  limits:
    #    memory: "1Gi"
    #    cpu: "500m"
## If NOT using the PostgreSQL in this chart (postgresql.enabled=false),
## specify custom database details here or leave empty and Artifactory will use embedded derby
database:
  ## To run Artifactory with any database other than PostgreSQL allowNonPostgresql set to true.
  allowNonPostgresql: false
  type: postgresql
  driver: org.postgresql.Driver
  ## If you set the url, leave host and port empty
  url: "jdbc:postgresql://postgresql-jfrog.cnyjdnwewotw.us-east-1.rds.amazonaws.com:5432/jfrogdb"
  ## If you would like this chart to create the secret containing the db
  ## password, use these values
  user: "postgres"
  password:
  ## If you have existing Kubernetes secrets containing db credentials, use
  ## these values
  secrets: 
    user:
      name: "rds-artifactory-username"
      key: "JF_SHARED_DATABASE_USERNAME"
    password:
      name: "rds-artifactory-password"
      key: "JF_SHARED_DATABASE_PASSWORD"
    url:
      name: "rds-artifactory-url"
      key: "JF_SHARED_DATABASE_URL"
# Filebeat Sidecar container
## The provided filebeat configuration is for Artifactory logs. It assumes you have a logstash installed and configured properly.
filebeat:
  enabled: false
  name: artifactory-filebeat
  image:
    repository: "docker.elastic.co/beats/filebeat"
    version: 7.16.2
  logstashUrl: "logstash:5044"
  livenessProbe:
    exec:
      command:
        - sh
        - -c
        - |
          #!/usr/bin/env bash -e
          curl --fail 127.0.0.1:5066
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
  readinessProbe:
    exec:
      command:
        - sh
        - -c
        - |
          #!/usr/bin/env bash -e
          filebeat test output
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 5
  resources: {}
  #    requests:
  #      memory: "100Mi"
  #      cpu: "100m"
  #    limits:
  #      memory: "100Mi"
  #      cpu: "100m"

  filebeatYml: |
    logging.level: info
    path.data: {{ .Values.artifactory.persistence.mountPath }}/log/filebeat
    name: artifactory-filebeat
    queue.spool:
      file:
        permissions: 0760
    filebeat.inputs:
    - type: log
      enabled: true
      close_eof: ${CLOSE:false}
      paths:
         - {{ .Values.artifactory.persistence.mountPath }}/log/*.log
      fields:
        service: "jfrt"
        log_type: "artifactory"
    output:
      logstash:
         hosts: ["{{ .Values.filebeat.logstashUrl }}"]
## Allows to add additional kubernetes resources
## Use --- as a separator between multiple resources
## For an example, refer - https://github.com/jfrog/log-analytics-prometheus/blob/master/helm/artifactory-values.yaml
additionalResources: ""
# Adding entries to a Pod's /etc/hosts file
# For an example, refer - https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases
hostAliases: []
#  - ip: "127.0.0.1"
#    hostnames:
#      - "foo.local"
#      - "bar.local"
#  - ip: "10.1.2.3"
#    hostnames:
#      - "foo.remote"
#      - "bar.remote"

## Toggling this feature is seamless and requires helm upgrade
## will enable all microservices to run in different containers in a single pod (by default it is true)
splitServicesToContainers: true
## Specify common probes parameters
probes:
  timeoutSeconds: 5


