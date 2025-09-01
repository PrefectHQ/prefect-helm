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

### Basic Auth

Prefect documentation on [basic auth](https://docs.prefect.io/v3/develop/settings-and-profiles#security-settings)

Self-hosted Prefect servers can be equipped with a Basic Authentication string for an administrator/password combination.

The format of the auth string is `admin:<my-password>` (no brackets).

```yaml
server:
  basicAuth:
    enabled: true
    authString: "admin:pass"
```

Alternatively, you can provide an existing Kubernetes Secret containing the auth string credentials. The secret must contain a key `auth-string` with the value of the auth string.

```sh
kubectl create secret generic prefect-basic-auth --from-literal=auth-string='admin:my-password'
```

```yaml
server:
  basicAuth:
    enabled: true
    existingSecret: prefect-basic-auth
```

## Background Services Configuration

The Prefect server includes background services related to scheduling and
cleanup. By default, these run in the same deployment as the web server, but
they can be separated for better resource management and scalability.

Support for this separation was added to provide a path to scaling your deployment as your usage grows.
If you are orchestrating a lot of work, you may need more web services to handle requests than background
services to field the increased API requests.

By default, the web services and background services share a connection pool to the
database, but their connection needs are very different and even antagonistic
with each other at times. Splitting the background services out also allows you
to tune the database connections for each deployment (pool size, timeout, etc.),
which can help with the database load.

The separate deployment for background services is currently limited to one replica
because it has not been optimized for running multiple copies. Additionally, many background
services run on a loop between 5 and 60 seconds, so if they go down, Kubernetes should bring
them back up after a health check without much disruption.

Splitting the background services is optional, and is likely not necessary if
you are not having any issues with your setup.

To run background services in a separate deployment:

```yaml
backgroundServices:
  runAsSeparateDeployment: true

# Use the bundled Redis chart
# See the next section for more details on other deployment options
redis:
  enabled: true
```

This configuration is recommended when:
- You're experiencing database connection pool contention
- You need different scaling policies for the web server and background services
- You want to monitor and manage resource usage separately

You can read more about this architecture in the [How to scale self-hosted Prefect](https://docs.prefect.io/v3/advanced/self-hosted) guide.

## Redis Configuration

This section applies when enabling the use of Background Services.

For a simple deployment, you can use the bundled Redis chart by setting the following:

```yaml
redis:
  enabled: true
```

This will automatically configure the Prefect server and background services to use the bundled Redis instance with the correct connection string information.

If you want to use the bundled Redis chart but need to customize the configuration, you can do so by providing additional values under the `redis` section. For example:

```yaml
redis:
  enabled: true

  auth:
    # set a custom password for the Redis instance
    password: "dontpanic!"
```

You can find additional configuration values in the [Bitnami Redis chart values.yaml file](https://github.com/bitnami/charts/blob/main/bitnami/redis/values.yaml).

### Using an External Redis Instance

If you want to use an existing or external Redis instance, do not set `redis.enabled`. Provide the connection details in the `backgroundServices.messaging.redis` section:

```yaml
backgroundServices:
  runAsSeparateDeployment: true
  messaging:
    redis:
      host: external.redis.host.example.com
      username: marvin
      password: paranoid!
```

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

3. Set the connection string in the existing secret following this format - `?ssl=verify-ca` is crucial:
    ```
    postgresql+asyncpg://{username}:{password}@{hostname}/{database}?ssl=verify-ca
    ```

### Database Migrations

The chart automatically handles database migrations during upgrades using a pre-upgrade hook. When you upgrade the chart, it will:

1. Run `prefect server database upgrade -y` before updating the main deployment
2. Ensure your database schema is compatible with the new Prefect version
3. Block the upgrade if migrations fail

**Important Notes:**
- Migrations only run for PostgreSQL deployments (not SQLite)
- The migration job uses the same database credentials as your main deployment
- **Downgrades require manual intervention** - if you need to rollback, you may need to manually run database downgrade commands
- For more details, see [Prefect's database migration documentation](https://docs.prefect.io/v3/advanced/self-hosted#database-migrations)

#### Migration Configuration

The migration behavior can be customized through the `migrations` section in your values.

For example, to disable automatic migrations (not recommended):

```yaml
migrations:
  # Enable/disable automatic migrations (default: true)
  enabled: false
```

Consult the `values.yaml` file for additional configuration options such as resource requests/limits, backoff limits, and timeouts.

## SQLite Configuration

SQLite can be used as an alternative to PostgreSQL. As mentioned in the
[documentation on hosting Prefect](https://docs-3.prefect.io/v3/manage/self-host),
SQLite is only recommended for lightweight, single-server deployments.

To use SQLite for the database, provide the following configuration values:

```yaml
postgresql:
  enabled: false
sqlite:
  enabled: true
```

More configuration options are available in [`values.yaml`](./values.yaml).

By default, a PersistentVolumeClaim persists the SQLite database file between
Pod restarts.

Note that enabling SQLite enforces 1 replica in the Deployment, and disables
the HorizontalPodAutoscaler.

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
| https://charts.bitnami.com/bitnami | common | 2.31.4 |
| https://charts.bitnami.com/bitnami | postgresql | 16.7.27 |
| https://charts.bitnami.com/bitnami | redis | 22.0.4 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backgroundServices.affinity | object | `{}` | affinity for background-services pod assignment |
| backgroundServices.args | list | `[]` | Custom container command arguments |
| backgroundServices.command | list | `[]` | Custom container entrypoint |
| backgroundServices.containerSecurityContext.allowPrivilegeEscalation | bool | `false` | set background-services containers' security context allowPrivilegeEscalation |
| backgroundServices.containerSecurityContext.capabilities | object | `{}` | set background-services container's security context capabilities |
| backgroundServices.containerSecurityContext.readOnlyRootFilesystem | bool | `true` | set background-services containers' security context readOnlyRootFilesystem |
| backgroundServices.containerSecurityContext.runAsNonRoot | bool | `true` | set background-services containers' security context runAsNonRoot |
| backgroundServices.containerSecurityContext.runAsUser | int | `1001` | set background-services containers' security context runAsUser |
| backgroundServices.debug | bool | `false` | sets PREFECT_DEBUG_MODE |
| backgroundServices.env | list | `[]` | array with environment variables to add to background-services container |
| backgroundServices.extraContainers | list | `[]` | additional sidecar containers |
| backgroundServices.extraEnvVarsCM | string | `""` | name of existing ConfigMap containing extra env vars to add to background-services pod |
| backgroundServices.extraEnvVarsSecret | string | `""` | name of existing Secret containing extra env vars to add to background-services pod |
| backgroundServices.extraVolumeMounts | list | `[]` | array with extra volumeMounts for the background-services pod |
| backgroundServices.extraVolumes | list | `[]` | array with extra volumes for the background-services pod |
| backgroundServices.loggingLevel | string | `"WARNING"` | sets PREFECT_LOGGING_SERVER_LEVEL |
| backgroundServices.messaging.broker | string | `"prefect_redis.messaging"` | messaging broker class to use for background services |
| backgroundServices.messaging.cache | string | `"prefect_redis.messaging"` | messaging cache class to use for background services |
| backgroundServices.messaging.redis | object | `{"db":0,"host":"","password":"","port":6379,"ssl":false,"username":""}` | settings for redis broker/cache change these if not using the built-in redis subchart |
| backgroundServices.messaging.redis.db | int | `0` | redis database number |
| backgroundServices.messaging.redis.host | string | `""` | redis hostname if using the built-in redis subchart, this will be automatically set to the redis subchart's service name |
| backgroundServices.messaging.redis.password | string | `""` | redis password, leave empty to use default if using the built-in redis subchart, this will be automatically set to the redis subchart's password value |
| backgroundServices.messaging.redis.port | int | `6379` | redis port |
| backgroundServices.messaging.redis.ssl | bool | `false` | use TLS for redis connection |
| backgroundServices.messaging.redis.username | string | `""` | redis username, leave empty to use no authentication if using the built-in redis subchart, this will be automatically set to the redis subchart's username value |
| backgroundServices.nodeSelector | object | `{}` | node labels for background-services pod assignment |
| backgroundServices.podAnnotations | object | `{}` | extra annotations for background-services pod |
| backgroundServices.podLabels | object | `{}` | extra labels for background-services pod |
| backgroundServices.podSecurityContext.fsGroup | int | `1001` | set background-services pod's security context fsGroup |
| backgroundServices.podSecurityContext.runAsNonRoot | bool | `true` | set background-services pod's security context runAsNonRoot |
| backgroundServices.podSecurityContext.runAsUser | int | `1001` | set background-services pod's security context runAsUser |
| backgroundServices.priorityClassName | string | `""` | priority class name to use for the background-services pods; if the priority class is empty or doesn't exist, the background-services pods are scheduled without a priority class |
| backgroundServices.resources.limits | object | `{"cpu":"1","memory":"1Gi"}` | the requested limits for the background-services container |
| backgroundServices.resources.requests | object | `{"cpu":"500m","memory":"512Mi"}` | the requested resources for the background-services container |
| backgroundServices.revisionHistoryLimit | int | `10` | the number of old ReplicaSets to retain to allow rollback |
| backgroundServices.runAsSeparateDeployment | bool | `false` |  |
| backgroundServices.serviceAccount.annotations | object | `{}` | additional service account annotations (evaluated as a template) |
| backgroundServices.serviceAccount.create | bool | `true` | specifies whether a service account should be created |
| backgroundServices.serviceAccount.name | string | `""` | the name of the service account to use. if not set and create is true, a name is generated using the common.names.fullname template with "-background-services" appended |
| backgroundServices.tolerations | list | `[]` | tolerations for background-services pod assignment |
| commonAnnotations | object | `{}` | annotations to add to all deployed objects |
| commonLabels | object | `{}` | labels to add to all deployed objects |
| fullnameOverride | string | `"prefect-server"` | fully override common.names.fullname |
| global.prefect.env | list | `[]` | array with environment variables to add to all deployments |
| global.prefect.image.prefectTag | string | `"3-latest"` | prefect image tag (immutable tags are recommended) |
| global.prefect.image.pullPolicy | string | `"IfNotPresent"` | prefect image pull policy |
| global.prefect.image.pullSecrets | list | `[]` | prefect image pull secrets |
| global.prefect.image.repository | string | `"prefecthq/prefect"` | prefect image repository |
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
| migrations.backoffLimit | int | `5` | job backoff limit (number of retries) |
| migrations.command | string | `"prefect server database upgrade -y\n"` | commands to run for database migrations (default: prefect server database upgrade -y) |
| migrations.enabled | bool | `true` | enable automatic database migrations during chart upgrades |
| migrations.entrypoint | list | `["/bin/sh","-c"]` | custom container entrypoint for the migration job |
| migrations.env | list | `[]` | additional environment variables for the migration job |
| migrations.extraVolumeMounts | list | `[]` | additional volume mounts for the migration job |
| migrations.extraVolumes | list | `[]` | additional volumes for the migration job |
| migrations.resources | object | `{"limits":{"cpu":"500m","memory":"256Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | job resources configuration |
| migrations.restartPolicy | string | `"Never"` | job restart policy |
| migrations.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1001}` | job security context configuration |
| migrations.timeoutSeconds | int | `300` | job timeout in seconds (default: 300 seconds / 5 minutes) |
| nameOverride | string | `""` | partially overrides common.names.name |
| namespaceOverride | string | `""` | fully override common.names.namespace |
| postgresql.auth.database | string | `"server"` | name for a custom database |
| postgresql.auth.enablePostgresUser | bool | `false` | determines whether an admin user is created within postgres |
| postgresql.auth.password | string | `"prefect-rocks"` | password for the custom user. Ignored if `auth.existingSecret` with key `password` is provided |
| postgresql.auth.username | string | `"prefect"` | name for a custom user |
| postgresql.enabled | bool | `true` | enable use of bitnami/postgresql subchart |
| postgresql.image.repository | string | `"bitnamilegacy/postgresql"` | Image repository.  Defaults to legacy bitnami repository for postgres 14.13.0 availability. |
| postgresql.image.tag | string | `"14.13.0"` | Version tag, corresponds to tags at https://hub.docker.com/layers/bitnamilegacy/postgresql/ |
| postgresql.primary.initdb.user | string | `"postgres"` | specify the PostgreSQL username to execute the initdb scripts |
| postgresql.primary.persistence.enabled | bool | `false` | enable PostgreSQL Primary data persistence using PVC |
| redis.architecture | string | `"standalone"` | Redis architecture Note: Prefect currently only supports standalone Redis deployments. |
| redis.enabled | bool | `false` | enable use of bitnami/redis subchart if backgroundServices.runAsSeparateDeployment=true, you must set this to true or provide your own redis instance |
| redis.image.repository | string | `"bitnamilegacy/redis"` | Image repository.  Defaults to legacy bitnami repository for redis 8.2.1 availability. |
| redis.image.tag | string | `"8.2.1"` | Version tag, corresponds to tags at https://hub.docker.com/r/bitnami/redis/ |
| secret.create | bool | `true` | whether to create a Secret containing the PostgreSQL connection string |
| secret.database | string | `""` | database for the PostgreSQL connection string |
| secret.host | string | `""` | host for the PostgreSQL connection string |
| secret.name | string | `""` | name for the Secret containing the PostgreSQL connection string To provide an existing Secret, provide a name and set `create=false` |
| secret.password | string | `""` | password for the PostgreSQL connection string |
| secret.port | string | `""` | port for the PostgreSQL connection string |
| secret.username | string | `""` | username for the PostgreSQL connection string |
| server.affinity | object | `{}` | affinity for server pods assignment |
| server.apiBasePath | string | `"/api"` | sets PREFECT_SERVER_API_BASE_PATH |
| server.args | list | `[]` | Custom container command arguments |
| server.autoscaling.enabled | bool | `false` | enable autoscaling for server |
| server.autoscaling.maxReplicas | int | `100` | maximum number of server replicas |
| server.autoscaling.minReplicas | int | `1` | minimum number of server replicas |
| server.autoscaling.targetCPU | int | `80` | target CPU utilization percentage |
| server.autoscaling.targetMemory | int | `80` | target Memory utilization percentage |
| server.basicAuth.authString | string | `"admin:pass"` | basic auth credentials in the format admin:<your-password> (no brackets) |
| server.basicAuth.enabled | bool | `false` | enable basic auth for the server, for an administrator/password combination |
| server.basicAuth.existingSecret | string | `""` | name of existing secret containing basic auth credentials. takes precedence over authString. must contain a key `auth-string` with the value of the auth string |
| server.command | list | `[]` | Custom container entrypoint |
| server.containerSecurityContext.allowPrivilegeEscalation | bool | `false` | set server containers' security context allowPrivilegeEscalation |
| server.containerSecurityContext.capabilities | object | `{}` | set server container's security context capabilities |
| server.containerSecurityContext.readOnlyRootFilesystem | bool | `true` | set server containers' security context readOnlyRootFilesystem |
| server.containerSecurityContext.runAsNonRoot | bool | `true` | set server containers' security context runAsNonRoot |
| server.containerSecurityContext.runAsUser | int | `1001` | set server containers' security context runAsUser |
| server.debug | bool | `false` | sets PREFECT_DEBUG_MODE |
| server.env | list | `[]` | array with environment variables to add to server deployment |
| server.extraArgs | list | `[]` | array with extra Arguments for the server container to start with |
| server.extraContainers | list | `[]` | additional sidecar containers |
| server.extraEnvVarsCM | string | `""` | name of existing ConfigMap containing extra env vars to add to server nodes |
| server.extraEnvVarsSecret | string | `""` | name of existing Secret containing extra env vars to add to server nodes |
| server.extraVolumeMounts | list | `[]` | array with extra volumeMounts for the server pod |
| server.extraVolumes | list | `[]` | array with extra volumes for the server pod |
| server.livenessProbe.config.failureThreshold | int | `3` | The number of consecutive failures allowed before considering the probe as failed. |
| server.livenessProbe.config.initialDelaySeconds | int | `10` | The number of seconds to wait before starting the first probe. |
| server.livenessProbe.config.periodSeconds | int | `10` | The number of seconds to wait between consecutive probes. |
| server.livenessProbe.config.successThreshold | int | `1` | The minimum consecutive successes required to consider the probe successful. |
| server.livenessProbe.config.timeoutSeconds | int | `5` | The number of seconds to wait for a probe response before considering it as failed. |
| server.livenessProbe.enabled | bool | `false` |  |
| server.loggingLevel | string | `"WARNING"` | sets PREFECT_LOGGING_SERVER_LEVEL |
| server.nodeSelector | object | `{}` | node labels for server pods assignment |
| server.podAnnotations | object | `{}` | extra annotations for server pod |
| server.podLabels | object | `{}` | extra labels for server pod |
| server.podSecurityContext.fsGroup | int | `1001` | set server pod's security context fsGroup |
| server.podSecurityContext.runAsNonRoot | bool | `true` | set server pod's security context runAsNonRoot |
| server.podSecurityContext.runAsUser | int | `1001` | set server pod's security context runAsUser |
| server.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | set server pod's seccomp profile |
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
| server.uiConfig.prefectUiApiUrl | string | `"http://localhost:4200/api"` | sets PREFECT_UI_API_URL; If you want to connect to the UI from somewhere external to the cluster (i.e. via an ingress), you need to set this value to the ingress URL (e.g. http://app.internal.prefect.com/api). You can find additional documentation on this here - https://docs.prefect.io/v3/manage/self-host#ui |
| server.uiConfig.prefectUiStaticDirectory | string | `"/ui_build"` | sets PREFECT_UI_STATIC_DIRECTORY |
| server.updateStrategy | object | `{"type":"RollingUpdate"}` | Specifies the strategy used to replace old Pods by new ones. Type can be "Recreate" or "RollingUpdate". Setting this to "Recreate" is useful when database is on a mounted volume that can only be attached to a single node at a time. |
| service.annotations | object | `{}` | additional custom annotations for server service |
| service.clusterIP | string | `""` | service Cluster IP |
| service.externalTrafficPolicy | string | `"Cluster"` | service external traffic policy |
| service.extraPorts | list | `[]` |  |
| service.nodePort | string | `""` | service port if defining service as type nodeport |
| service.port | int | `4200` | service port |
| service.targetPort | int | `4200` | target port of the server pod; also sets PREFECT_SERVER_API_PORT |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount.annotations | object | `{}` | additional service account annotations (evaluated as a template) |
| serviceAccount.create | bool | `true` | specifies whether a service account should be created |
| serviceAccount.name | string | `""` | the name of the service account to use. if not set and create is true, a name is generated using the common.names.fullname template |
| sqlite.enabled | bool | `false` | enable use of the embedded SQLite database |
| sqlite.persistence.enabled | bool | `true` | enable SQLite data persistence using PVC |
| sqlite.persistence.size | string | `"1Gi"` | size for the PVC |
| sqlite.persistence.storageClassName | string | `""` | storage class name for the PVC |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
