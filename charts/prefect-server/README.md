# prefect-server

Prefect server application bundle

**Homepage:** <https://github.com/PrefectHQ>

## Installing the Chart

To install the chart with the release name `prefect-server`:

```console
helm repo add prefect https://prefecthq.github.io/prefect-helm
helm install prefect-server prefect/prefect-server
```

## Prefect Configuration

### Container Port // Port Forwarding

Without making any modifications to the `values.yaml` file, you can access the Prefect UI by port forwarding either the Server `pod` or `service` with the following command and visiting [http:localhost:4200](http:localhost:4200):
```console
kubectl port-forward svc/prefect-server 4200:4200
```

Note: If you choose to make modifications to either the `server.prefectApiUrl` or `service.port`, make sure to update the other value with the updated port!

## PostgreSQL Configuration

### Handling Connection Secrets

#### Using the bundled PostgreSQL chart

By default, Bitnami's PostgreSQL Helm Chart will be deployed. This is **not intended for production use**, and is only
included to provide a functional proof of concept installation.

In this scenario, you'll need to provide _either one_ of the following fields:

1. `postgresql.auth.password`: a password you want to set for the prefect user (default: `prefect-rocks`)

2. `postgresql.auth.existingSecret`: name of an existing secret in your cluster with the following field:

    - `connection-string`: fully-quallified connection string in the format of `postgresql+asyncpg://{username}:{password}@{hostname}/{database}`
        - username = `postgresql.auth.username`
        - hostname = `<release-name>-postgresql.<release-namespace>:<postgresql.containerPorts.postgresql>`
        - database = `postgresql.auth.database`

Two secrets are created when not providing an existing secret name:
1. `prefect-server-postgresql-connection`: used by the prefect-server deployment to connect to the postgresql database.

2. `<release-name>-postgresql-0`: defines the `postgresql.auth.username`'s password on the postgresql server to allow successful authentication from the prefect server.

#### Using an external instance of PostgreSQL

If you want to disable the bundled PostgreSQL chart and use an external instance, provide the following configuration:

```yaml
prefect-server:
  postgresql:
    enabled: false

  secret:
    # Option 1: provide the name of an existing secret following the instructions above.
    create: false
    name: <existing secret name>

    # Option 2: provide the connection string details directly
    create: true
    username: myuser
    password: mypass
    host: myhost.com
    port: 1234
    database: mydb
```

### Connecting with SSL configured

1. Mount the relevant certificate to `/home/prefect/.postgresql` so that it can be found by `asyncpg`. This is the default location postgresql expects per their [documentation](https://www.postgresql.org/docs/current/libpq-ssl.html).
    ```yaml
    prefect-server:
      server:
        extraVolumes:
          - name: db-ssl-secret
            secret:
              secretName: db-ssl-secret
              defaultMode: 384
        extraVolumeMounts:
          - name: db-ssl-secret
            mountPath: "/home/prefect/.postgresql"
            readOnly: true
      postgresql:
        enabled: false
        auth:
          existingSecret: external-db-connection-string
    ```

2. Create a secret to hold the ca certificate for the database with the key `root.crt`
    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: db-ssl-secret
    data:
      root.crt: BASE64ENCODECERTIFICATE=
    type: Opaque
    ```

3. Set the connection string in the existing secret following this format - `?ssl=verify-ca` is cruicial:
    ```
    postgresql+asyncpg://{username}:{password}@{hostname}/{database}?ssl=verify-ca
    ```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jamiezieziula | <jamie@prefect.io> |  |
| jimid27 | <jimi@prefect.io> |  |
| parkedwards | <edward@prefect.io> |  |
| mitchnielsen | <mitchell@prefect.io> |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 2.26.0 |
| https://charts.bitnami.com/bitnami | postgresql | 12.12.10 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonAnnotations | object | `{}` | annotations to add to all deployed objects |
| commonLabels | object | `{}` | labels to add to all deployed objects |
| fullnameOverride | string | `"prefect-server"` | fully override common.names.fullname |
| ingress.annotations | object | `{}` | additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress (Kubernetes 1.18+) |
| ingress.enabled | bool | `false` | enable ingress record generation for server |
| ingress.extraHosts | list | `[]` | an array with additional hostname(s) to be covered with the ingress record |
| ingress.extraPaths | list | `[]` | an array with additional arbitrary paths that may need to be added to the ingress under the main host |
| ingress.extraRules | list | `[]` | additional rules to be covered with this ingress record |
| ingress.extraTls | list | `[]` | an array with additional tls configuration to be added to the ingress record |
| ingress.host.hostname | string | `"prefect.local"` | default host for the ingress record |
| ingress.host.path | string | `"/"` | default path for the ingress record |
| ingress.host.pathType | string | `"ImplementationSpecific"` | ingress path type |
| ingress.selfSigned | bool | `false` | create a TLS secret for this ingress record using self-signed certificates generated by Helm |
| ingress.servicePort | string | `"server-svc-port"` | port for the ingress' main path |
| ingress.tls | bool | `false` | enable TLS configuration for the host defined at `ingress.host.hostname` parameter |
| nameOverride | string | `""` | partially overrides common.names.name |
| namespaceOverride | string | `""` | fully override common.names.namespace |
| postgresql.auth.database | string | `"server"` | name for a custom database |
| postgresql.auth.enablePostgresUser | bool | `false` | determines whether an admin user is created within postgres |
| postgresql.auth.password | string | `"prefect-rocks"` | password for the custom user. Ignored if `auth.existingSecret` with key `password` is provided |
| postgresql.auth.username | string | `"prefect"` | name for a custom user |
| postgresql.enabled | bool | `true` | enable use of bitnami/postgresql subchart |
| postgresql.image.tag | string | `"14.3.0"` | Version tag, corresponds to tags at https://hub.docker.com/r/bitnami/postgresql/ |
| postgresql.primary.initdb.user | string | `"postgres"` | specify the PostgreSQL username to execute the initdb scripts |
| postgresql.primary.persistence.enabled | bool | `false` | enable PostgreSQL Primary data persistence using PVC |
| secret.create | bool | `true` | whether to create a Secret containing the PostgreSQL connection string |
| secret.database | string | `""` | database for the PostgreSQL connection string |
| secret.host | string | `""` | host for the PostgreSQL connection string |
| secret.name | string | `""` | name for the Secret containing the PostgreSQL connection string To provide an existing Secret, provide a name and set `create=false` |
| secret.password | string | `""` | password for the PostgreSQL connection string |
| secret.port | string | `""` | port for the PostgreSQL connection string |
| secret.username | string | `""` | username for the PostgreSQL connection string |
| server.affinity | object | `{}` | affinity for server pods assignment |
| server.autoscaling.enabled | bool | `false` | enable autoscaling for server |
| server.autoscaling.maxReplicas | int | `100` | maximum number of server replicas |
| server.autoscaling.minReplicas | int | `1` | minimum number of server replicas |
| server.autoscaling.targetCPU | int | `80` | target CPU utilization percentage |
| server.autoscaling.targetMemory | int | `80` | target Memory utilization percentage |
| server.containerSecurityContext.allowPrivilegeEscalation | bool | `false` | set server containers' security context allowPrivilegeEscalation |
| server.containerSecurityContext.capabilities | object | `{}` | set server container's security context capabilities |
| server.containerSecurityContext.readOnlyRootFilesystem | bool | `true` | set server containers' security context readOnlyRootFilesystem |
| server.containerSecurityContext.runAsNonRoot | bool | `true` | set server containers' security context runAsNonRoot |
| server.containerSecurityContext.runAsUser | int | `1001` | set server containers' security context runAsUser |
| server.debug | bool | `false` | enable server debug mode |
| server.env | list | `[]` | array with environment variables to add to server nodes |
| server.extraArgs | list | `[]` | array with extra Arguments for the server container to start with |
| server.extraContainers | list | `[]` | additional sidecar containers |
| server.extraEnvVarsCM | string | `""` | name of existing ConfigMap containing extra env vars to add to server nodes |
| server.extraEnvVarsSecret | string | `""` | name of existing Secret containing extra env vars to add to server nodes |
| server.extraVolumeMounts | list | `[]` | array with extra volumeMounts for the server pod |
| server.extraVolumes | list | `[]` | array with extra volumes for the server pod |
| server.image.prefectTag | string | `"3-latest"` | prefect image tag (immutable tags are recommended) |
| server.image.pullPolicy | string | `"IfNotPresent"` | server image pull policy |
| server.image.pullSecrets | list | `[]` | server image pull secrets |
| server.image.repository | string | `"prefecthq/prefect"` | server image repository |
| server.livenessProbe.config.failureThreshold | int | `3` | The number of consecutive failures allowed before considering the probe as failed. |
| server.livenessProbe.config.initialDelaySeconds | int | `10` | The number of seconds to wait before starting the first probe. |
| server.livenessProbe.config.periodSeconds | int | `10` | The number of seconds to wait between consecutive probes. |
| server.livenessProbe.config.successThreshold | int | `1` | The minimum consecutive successes required to consider the probe successful. |
| server.livenessProbe.config.timeoutSeconds | int | `5` | The number of seconds to wait for a probe response before considering it as failed. |
| server.livenessProbe.enabled | bool | `false` |  |
| server.loggingLevel | string | `"WARNING"` |  |
| server.nodeSelector | object | `{}` | node labels for server pods assignment |
| server.podAnnotations | object | `{}` | extra annotations for server pod |
| server.podLabels | object | `{}` | extra labels for server pod |
| server.podSecurityContext.fsGroup | int | `1001` | set server pod's security context fsGroup |
| server.podSecurityContext.runAsNonRoot | bool | `true` | set server pod's security context runAsNonRoot |
| server.podSecurityContext.runAsUser | int | `1001` | set server pod's security context runAsUser |
| server.prefectApiHost | string | `"0.0.0.0"` | sets PREFECT_SERVER_API_HOST |
| server.prefectApiUrl | string | `"http://localhost:4200/api"` | sets PREFECT_API_URL |
| server.priorityClassName | string | `""` | priority class name to use for the server pods; if the priority class is empty or doesn't exist, the server pods are scheduled without a priority class |
| server.readinessProbe.config.failureThreshold | int | `3` | The number of consecutive failures allowed before considering the probe as failed. |
| server.readinessProbe.config.initialDelaySeconds | int | `10` | The number of seconds to wait before starting the first probe. |
| server.readinessProbe.config.periodSeconds | int | `10` | The number of seconds to wait between consecutive probes. |
| server.readinessProbe.config.successThreshold | int | `1` | The minimum consecutive successes required to consider the probe successful. |
| server.readinessProbe.config.timeoutSeconds | int | `5` | The number of seconds to wait for a probe response before considering it as failed. |
| server.readinessProbe.enabled | bool | `false` |  |
| server.replicaCount | int | `1` | number of server replicas to deploy |
| server.resources.limits | object | `{"cpu":"1","memory":"1Gi"}` | the requested limits for the server container |
| server.resources.requests | object | `{"cpu":"500m","memory":"512Mi"}` | the requested resources for the server container |
| server.revisionHistoryLimit | int | `10` | the number of old ReplicaSets to retain to allow rollback |
| server.tolerations | list | `[]` | tolerations for server pods assignment |
| server.uiConfig.enabled | bool | `true` | set PREFECT_UI_ENABLED; enable the UI on the server |
| server.uiConfig.prefectUiApiUrl | string | `""` | sets PREFECT_UI_API_URL |
| server.uiConfig.prefectUiStaticDirectory | string | `"/ui_build"` | sets PREFECT_UI_STATIC_DIRECTORY |
| server.uiConfig.prefectUiUrl | string | `""` | sets PREFECT_UI_URL |
| service.annotations | object | `{}` |  |
| service.clusterIP | string | `""` | service Cluster IP |
| service.externalTrafficPolicy | string | `"Cluster"` | service external traffic policy |
| service.extraPorts | list | `[]` |  |
| service.nodePort | string | `""` | service port if defining service as type nodeport |
| service.port | int | `4200` | service port |
| service.targetPort | int | `4200` | target port of the server pod; also sets PREFECT_SERVER_API_PORT |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount.annotations | object | `{}` | additional service account annotations (evaluated as a template) |
| serviceAccount.create | bool | `true` | specifies whether a ServiceAccount should be created |
| serviceAccount.name | string | `""` | the name of the ServiceAccount to use. if not set and create is true, a name is generated using the common.names.fullname template |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)
