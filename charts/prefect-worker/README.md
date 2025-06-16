# prefect-worker

## Overview

[Workers](https://docs.prefect.io/latest/concepts/work-pools/#worker-overview) are lightweight polling services that retrieve scheduled runs from a work pool and execute them.

Workers each have a type corresponding to the execution environment to which they will submit flow runs. Workers are only able to join work pools that match their type. As a result, when deployments are assigned to a work pool, you know in which execution environment scheduled flow runs for that deployment will run.

## Installing the Chart

### Prerequisites

1. Add the Prefect Helm repository to your Helm client:

    ```bash
    helm repo add prefect https://prefecthq.github.io/prefect-helm
    helm repo update
    ```

2. Create a new namespace in your Kubernetes cluster to deploy the Prefect worker in:

    ```bash
    kubectl create namespace prefect
    ```

### Configuring a Worker for Prefect Cloud

1. Create a Kubernetes secret for a Prefect Cloud API key

    First create a file named `api-key.yaml` with the following contents:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: prefect-api-key
      namespace: prefect
    type: Opaque
    data:
      key:  <base64-encoded-api-key>
    ```

    Replace `<base64-encoded-api-key>` with your Prefect Cloud API key encoded in base64. The helm chart looks for a secret of this name and schema, this can be overridden in the `values.yaml`.

    You can use the following command to generate the base64-encoded value:

    ```bash
    echo -n "your-prefect-cloud-api-key" | base64
    ```

    Then apply the `api-key.yaml` file to create the Kubernetes secret:

    ```bash
    kubectl apply -f api-key.yaml
    ```

    Alternatively, you can create the Kubernetes secret via the cli with the following command. In this case, Kubernetes will take care of base64 encoding the value on your behalf:

    ```bash
    kubectl create secret generic prefect-api-key --from-literal=key=pnu_xxxx
    ```

2. Configure the Prefect worker values

    Create a `values.yaml` file to customize the Prefect worker configuration. Add the following contents to the file:

    ```yaml
    worker:
      cloudApiConfig:
        accountId: <target account ID>
        workspaceId: <target workspace ID>
      config:
        workPool: <target work pool name>
    ```

    These settings will ensure that the worker connects to the proper account, workspace, and work pool.
    View your Account ID and Workspace ID in your browser URL when logged into Prefect Cloud. For example: `https://app.prefect.cloud/account/abc-my-account-id-is-here/workspaces/123-my-workspace-id-is-here`

### Configuring a Worker for Self-managed Cloud (not to be confused with [Self-hosted Prefect Server](https://github.com/PrefectHQ/prefect-helm/tree/main/charts/prefect-worker#configuring-a-worker-for-prefect-server))

1. Create a Kubernetes secret for a Prefect Self-managed Cloud API key

    First create a file named `api-key.yaml` with the following contents:

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: prefect-api-key
      namespace: prefect
    type: Opaque
    data:
      key:  <base64-encoded-api-key>
    ```

    Replace `<base64-encoded-api-key>` with your Prefect Self-managed Cloud API key encoded in base64. The helm chart looks for a secret of this name and schema, this can be overridden in the `values.yaml`.

    You can use the following command to generate the base64-encoded value:

    ```bash
    echo -n "your-prefect-self-managed-cloud-api-key" | base64
    ```

    Then apply the `api-key.yaml` file to create the Kubernetes secret:

    ```bash
    kubectl apply -f api-key.yaml
    ```

    Alternatively, you can create the Kubernetes secret via the cli with the following command. In this case, Kubernetes will take care of base64 encoding the value on your behalf:

    ```bash
    kubectl create secret generic prefect-api-key --from-literal=key=pnu_xxxx
    ```

2. Configure the Prefect worker values

    Create a `values.yaml` file to customize the Prefect worker configuration. Add the following contents to the file:

    ```yaml
    worker:
      apiConfig: selfManagedCloud
      config:
        workPool: <target work pool name>
      selfManagedCloudApiConfig:
        apiUrl: "https://<DNS of Self-managed Cloud API>"
        accountId: <target account ID>
        workspaceId: <target workspace ID>
    ```

    These settings will ensure that the worker connects to the proper account, workspace, and work pool.
    View your Account ID and Workspace ID in your browser URL when logged into Prefect Cloud. For example: `https://self-managed-prefect.company/account/abc-my-account-id-is-here/workspaces/123-my-workspace-id-is-here`

### Configuring a Worker for Self-hosted Prefect Server

1. Configure the Prefect worker values

    Create a `values.yaml` file to customize the Prefect worker configuration. Add the following contents to the file:

    ```yaml
    worker:
      apiConfig: selfHostedServer
      config:
        workPool: <target work pool name>
      selfHostedServerApiConfig:
        apiUrl: <dns or ip address of the prefect-server pod here>
    ```

    These settings will ensure the worker connects with the local deployment of Self-hosted Prefect Server.
    If the Self-hosted Prefect Server pod is deployed in the same cluster, you can use the local Kubernetes DNS address to connect to it: `http://<prefect-server-service-name>.<namespace>.svc.cluster.local:<prefect-server-port>/api`. If the Self-hosted Prefect Server pod is deployed in a different cluster, set the apiUrl to the fully qualified domain name of the Self-hosted Prefect Server.

### Installing & Verifying Deployment of the Prefect Worker

1. Install the Prefect worker using Helm

    ```bash
    helm install prefect-worker prefect/prefect-worker --namespace=prefect -f values.yaml
    ```

2. Verify the deployment

    Check the status of your Prefect worker deployment:

    ```bash
    kubectl get pods -n prefect

    NAME                              READY   STATUS    RESTARTS       AGE
    prefect-worker-658f89bc49-jglvt   1/1     Running   0              25m
    ```

    You should see the Prefect worker pod running

## Additional Worker Configurations

### Basic Auth

Prefect documentation on [basic auth](https://docs.prefect.io/v3/develop/settings-and-profiles#security-settings)

Self-hosted Prefect servers can be equipped with a Basic Authentication string for an administrator/password combination. Assuming you are running a Self-hosted Prefect server with basic auth enabled, you can authenticate your worker with the same credentials.

The format of the auth string is `admin:<my-password>` (no brackets).

```yaml
worker:
  basicAuth:
    enabled: true
    authString: "admin:pass"
```

Alternatively, you can provide an existing Kubernetes Secret containing the auth string credentials. The secret must contain a key `auth-string` with the value of the auth string.

```sh
kubectl create secret generic prefect-basic-auth --from-literal=auth-string='admin:my-password'
```

```yaml
worker:
  basicAuth:
    enabled: true
    existingSecret: prefect-basic-auth
```

### Deploying multiple workers to a single namespace

If you want to run more than one worker in a single Kubernetes namespace, you will need to specify the `fullnameOverride` parameter at install time of one of the workers.

```yaml
fullnameOverride: prefect-worker-2
```

If you want the workers to share a service account, add the following to your `values.yaml`:

```yaml
fullnameOverride: prefect-worker-2
serviceAccount:
  create: false
  name: "prefect-worker"
```

### Configuring a Base Job Template on the Worker

The worker uses the [base job template](https://docs.prefect.io/v3/deploy/infrastructure-concepts/work-pools#base-job-template)
to create the Kubernetes job that executes your workflow. The base job template configuration can be modified by setting
`worker.config.baseJobTemplate.configuration`.

1. Define the base job template in a local file. To get a formatted template, run the following command & store locally in `base-job-template.json`:

```bash
# you may need to install `prefect-kubernetes` first
pip install prefect-kubernetes

prefect work-pool get-default-base-job-template --type kubernetes > base-job-template.json
```

2. Modify the base job template as needed. Keep in mind that modifications are not merged with the default template. The configuration
   you provide will replace the default configuration entirely. See [modifying the base job template](#modifying-the-base-job-template)
   for more information.

3. Install the chart as you usually would, making sure to use the `--set-file` command to pass in the `base-job-template.json` file as a paramater:

```bash
helm install prefect-worker prefect/prefect-worker -f values.yaml --set-file worker.config.baseJobTemplate.configuration=base-job-template.json
```

#### Modifying the Base Job Template

Modifying the base job template replaces the default configuration entirely.
Put differently, any provdied configuration is not merged with the default configuration.

For example, if you want to add an image pull secret to the base job template,
you would modify the `base-job-template.json` file to look like this:

```diff
{
 "job_configuration": {
   "job_manifest": {
     "spec": {
       "template": {
         "spec": {
+          "imagePullSecrets": [
+            {
+              "name": "my-pull-secret"
+            }
+          ]
         }
       }
     }
   }
 },
}
```

Here, you add `imagePullSecrets` into your existing configuration. Note that
the snippet is truncated for brevity. The full configuration should still be
provided.

Once applied, you can see the entire base job template in the UI by navigating
to `Account settings` > `Work Pools` > your work pool > three-dot menu in the
top right corner > `Edit` > `Base Job Template` section > `Advanced` tab.

#### Updating the Base Job Template

If a base job template is set through Helm (via either `worker.config.baseJobTemplate.configuration` or `worker.config.baseJobTemplate.existingConfigMapName`), we'll run an optional `initContainer` that will sync the template configuration to the work pool named in `worker.config.workPool`.

Any time the base job template is updated, the subsequent `initContainer` run will run `prefect work-pool update <work-pool-name> --base-job-template <template-json>` and sync this template to the API.

Please note that configuring the template via `baseJobTemplate.existingConfigMapName` will require a manual restart of the `prefect-worker` Deployment in order to kick off the `initContainer` - alternatively, you can use a tool like [reloader](https://github.com/stakater/Reloader) to automatically restart an associated Deployment.  However, configuring the template via `baseJobTemplate.configuration` value will automatically roll the Deployment on any update.

## Troubleshooting

### Setting `worker.clusterUid`

This chart attempts to generate a unique identifier for the cluster it is installing the worker on to use as metadata for your runs. Since Kubernetes [does not provide a "cluster ID" API](https://github.com/kubernetes/kubernetes/issues/44954), this chart will do so by [reading the `kube-system` namespace and parsing the immutable UID](https://github.com/PrefectHQ/prefect-helm/blob/main/charts/prefect-worker/templates/_helpers.tpl#L94-L105). [This mimics the functionality in the `prefect-kubernetes` library](https://github.com/PrefectHQ/prefect/blob/5f5427c410cd04505d7b2c701e2003f856044178/src/integrations/prefect-kubernetes/prefect_kubernetes/worker.py#L835-L859).

> [!NOTE]
> Reading the `kube-system` namespace requires a `ClusterRole` with `get` permissions on `namespaces`, as well as a `ClusterRoleBinding` to attach it to the actor running the helm install.
>
> A `Role` / `RoleBinding` may also be used, but it must exist in the `kube-system` namespace.

This chart does not offer a built-in way to assign these roles, as it does not make assumptions about your cluster's access controls to the `kube-system` namespace. If these permissions are not granted, you may see this error:

> HTTP response body: {"kind":"Status","apiVersion":"v1","metadata":{},"status":"Failure","message":"namespaces \"kube-system\" is forbidden: User \"system:serviceaccount:prefect:prefect-worker\" cannot get resource \"namespaces\" in API group \"\" in the namespace \"kube-system\"","reason":"Forbidden","details":{"name":"kube-system","kind":"namespaces"},"code":403}

In many cases, these role additions may be entirely infeasible due to overall access limitations. As an alternative, this chart offers a hard-coded override via the `worker.clusterUid` value.

Set this value to a user-provided unique ID - this bypasses the `kube-system` namespace lookup and utilizes your provided value as the cluster ID instead. Be sure to set this value consistently across your Prefect deployments that interact with the same cluster

```yaml
worker:
  # -- unique cluster identifier, if none is provided this value will be inferred at time of helm install
  clusterUid: "my-unique-cluster-id"
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
| https://charts.bitnami.com/bitnami | common | 2.31.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| commonAnnotations | object | `{}` | annotations to add to all deployed objects |
| commonLabels | object | `{}` | labels to add to all deployed objects |
| fullnameOverride | string | `"prefect-worker"` | fully override common.names.fullname |
| nameOverride | string | `""` | partially overrides common.names.name |
| namespaceOverride | string | `""` | fully override common.names.namespace |
| role.create | bool | `true` | specifies whether a Role should be created |
| role.extraPermissions | list | `[]` | array with extra permissions to add to the worker role |
| rolebinding.create | bool | `true` | specifies whether a RoleBinding should be created |
| serviceAccount.annotations | object | `{}` | additional service account annotations (evaluated as a template) |
| serviceAccount.create | bool | `true` | specifies whether a ServiceAccount should be created |
| serviceAccount.name | string | `""` | the name of the ServiceAccount to use. if not set and create is true, a name is generated using the common.names.fullname template |
| worker.affinity | object | `{}` | affinity for worker pods assignment |
| worker.apiConfig | string | `"cloud"` | one of 'cloud', 'selfManagedCloud', or 'selfHostedServer' |
| worker.autoscaling.enabled | bool | `false` | enable autoscaling for the worker |
| worker.autoscaling.maxReplicas | int | `1` | maximum number of replicas to scale up to |
| worker.autoscaling.minReplicas | int | `1` | minimum number of replicas to scale down to |
| worker.autoscaling.targetCPUUtilizationPercentage | int | `80` | target CPU utilization percentage for scaling the worker |
| worker.autoscaling.targetMemoryUtilizationPercentage | int | `80` | target memory utilization percentage for scaling the worker |
| worker.cloudApiConfig.accountId | string | `""` | prefect account ID |
| worker.cloudApiConfig.apiKeySecret.key | string | `"key"` | prefect API secret key |
| worker.cloudApiConfig.apiKeySecret.name | string | `"prefect-api-key"` | prefect API secret name |
| worker.cloudApiConfig.cloudUrl | string | `"https://api.prefect.cloud/api"` | prefect cloud API url; the full URL is constructed as https://cloudUrl/accounts/accountId/workspaces/workspaceId |
| worker.cloudApiConfig.workspaceId | string | `""` | prefect workspace ID |
| worker.clusterUid | string | `""` | unique cluster identifier, if none is provided this value will be inferred at time of helm install |
| worker.config.baseJobTemplate.configuration | string | `nil` | JSON formatted base job template. If data is provided here, the chart will generate a configmap and mount it to the worker pod |
| worker.config.baseJobTemplate.existingConfigMapName | string | `""` | the name of an existing ConfigMap containing a base job template. NOTE - the key must be 'baseJobTemplate.json' |
| worker.config.http2 | bool | `true` | connect using HTTP/2 if the server supports it (experimental) |
| worker.config.installPolicy | string | `"prompt"` | install policy to use workers from Prefect integration packages. |
| worker.config.limit | string | `nil` | maximum number of flow runs to start simultaneously (default: unlimited) |
| worker.config.name | string | `nil` | the name to give to the started worker. If not provided, a unique name will be generated. |
| worker.config.prefetchSeconds | int | `10` | when querying for runs, how many seconds in the future can they be scheduled |
| worker.config.queryInterval | int | `5` | how often the worker will query for runs |
| worker.config.type | string | `"kubernetes"` | specify the worker type |
| worker.config.workPool | string | `""` | the work pool that your started worker will poll. |
| worker.config.workQueues | list | `[]` | one or more work queue names for the worker to pull from. if not provided, the worker will pull from all work queues in the work pool |
| worker.containerSecurityContext.allowPrivilegeEscalation | bool | `false` | set worker containers' security context allowPrivilegeEscalation |
| worker.containerSecurityContext.capabilities | object | `{}` | set worker container's security context capabilities |
| worker.containerSecurityContext.readOnlyRootFilesystem | bool | `true` | set worker containers' security context readOnlyRootFilesystem |
| worker.containerSecurityContext.runAsNonRoot | bool | `true` | set worker containers' security context runAsNonRoot |
| worker.containerSecurityContext.runAsUser | int | `1001` | set worker containers' security context runAsUser |
| worker.dnsConfig.nameservers | list | `[]` | optional list of IP addresses that will be used as dns servers for the Pod |
| worker.dnsConfig.options | list | `[]` | optional list of dns options for the Pod |
| worker.dnsConfig.searches | list | `[]` | optional list of dns search domains for hostname lookup in the Pod |
| worker.dnsPolicy | string | `""` | optional dns policy for worker deployment |
| worker.extraArgs | list | `[]` | array with extra Arguments for the worker container to start with |
| worker.extraContainers | list | `[]` | additional sidecar containers |
| worker.extraEnvVars | list | `[]` | array with extra environment variables to add to worker nodes |
| worker.extraEnvVarsCM | string | `""` | name of existing ConfigMap containing extra env vars to add to worker nodes (deprecated, use extraEnvVarsCMs) |
| worker.extraEnvVarsCMs | list | `[]` | names of existing ConfigMaps containing extra env vars to add to worker nodes |
| worker.extraEnvVarsSecret | string | `""` | name of existing Secret containing extra env vars to add to worker nodes (deprecated, use extraEnvVarsSecrets) |
| worker.extraEnvVarsSecrets | list | `[]` | names of existing Secrets containing extra env vars to add to worker nodes |
| worker.extraVolumeMounts | list | `[]` | array with extra volumeMounts for the worker pod |
| worker.extraVolumes | list | `[]` | array with extra volumes for the worker pod |
| worker.image.debug | bool | `false` | enable worker image debug mode |
| worker.image.prefectTag | string | `"3-python3.11-kubernetes"` | prefect image tag (immutable tags are recommended) |
| worker.image.pullPolicy | string | `"IfNotPresent"` | worker image pull policy |
| worker.image.pullSecrets | list | `[]` | worker image pull secrets |
| worker.image.repository | string | `"prefecthq/prefect"` | worker image repository |
| worker.initContainer.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1001}` | security context for the sync-base-job-template initContainer |
| worker.initContainer.containerSecurityContext.allowPrivilegeEscalation | bool | `false` | set init containers' security context allowPrivilegeEscalation |
| worker.initContainer.containerSecurityContext.capabilities | object | `{}` | set init container's security context capabilities |
| worker.initContainer.containerSecurityContext.readOnlyRootFilesystem | bool | `true` | set init containers' security context readOnlyRootFilesystem |
| worker.initContainer.containerSecurityContext.runAsNonRoot | bool | `true` | set init containers' security context runAsNonRoot |
| worker.initContainer.containerSecurityContext.runAsUser | int | `1001` | set init containers' security context runAsUser |
| worker.initContainer.extraContainers | list | `[]` | additional sidecar containers |
| worker.initContainer.resources | object | `{}` | the resource specifications for the sync-base-job-template initContainer Defaults to the resources defined for the worker container |
| worker.livenessProbe.config.failureThreshold | int | `3` | The number of consecutive failures allowed before considering the probe as failed. |
| worker.livenessProbe.config.initialDelaySeconds | int | `10` | The number of seconds to wait before starting the first probe. |
| worker.livenessProbe.config.periodSeconds | int | `10` | The number of seconds to wait between consecutive probes. |
| worker.livenessProbe.config.successThreshold | int | `1` | The minimum consecutive successes required to consider the probe successful. |
| worker.livenessProbe.config.timeoutSeconds | int | `5` | The number of seconds to wait for a probe response before considering it as failed. |
| worker.livenessProbe.enabled | bool | `false` |  |
| worker.nodeSelector | object | `{}` | node labels for worker pods assignment |
| worker.podAnnotations | object | `{}` | extra annotations for worker pod |
| worker.podLabels | object | `{}` | extra labels for worker pod |
| worker.podSecurityContext.fsGroup | int | `1001` | set worker pod's security context fsGroup |
| worker.podSecurityContext.runAsNonRoot | bool | `true` | set worker pod's security context runAsNonRoot |
| worker.podSecurityContext.runAsUser | int | `1001` | set worker pod's security context runAsUser |
| worker.podSecurityContext.seccompProfile | object | `{"type":"RuntimeDefault"}` | set worker pod's seccomp profile |
| worker.priorityClassName | string | `""` | priority class name to use for the worker pods; if the priority class is empty or doesn't exist, the worker pods are scheduled without a priority class |
| worker.replicaCount | int | `1` | number of worker replicas to deploy |
| worker.resources.limits | object | `{"cpu":"1000m","memory":"1Gi"}` | the requested limits for the worker container |
| worker.resources.requests | object | `{"cpu":"100m","memory":"256Mi"}` | the requested resources for the worker container |
| worker.revisionHistoryLimit | int | `10` | the number of old ReplicaSets to retain to allow rollback |
| worker.selfHostedServerApiConfig.apiUrl | string | `""` | prefect API url (PREFECT_API_URL) |
| worker.selfHostedServerApiConfig.basicAuth.authString | string | `"admin:pass"` | basic auth credentials in the format admin:<your-password> (no brackets) |
| worker.selfHostedServerApiConfig.basicAuth.enabled | bool | `false` | enable basic auth for the worker, for an administrator/password combination. must be enabled on the server as well |
| worker.selfHostedServerApiConfig.basicAuth.existingSecret | string | `""` | name of existing secret containing basic auth credentials. takes precedence over authString. must contain a key `auth-string` with the value of the auth string |
| worker.selfManagedCloudApiConfig.accountId | string | `""` | prefect account ID |
| worker.selfManagedCloudApiConfig.apiKeySecret.key | string | `"key"` | prefect API secret key |
| worker.selfManagedCloudApiConfig.apiKeySecret.name | string | `"prefect-api-key"` | prefect API secret name |
| worker.selfManagedCloudApiConfig.apiUrl | string | `""` | prefect API url (PREFECT_API_URL) |
| worker.selfManagedCloudApiConfig.cloudApiUrl | string | `""` | This is used in self managed cloud instances to congfigure events and logs over websockets |
| worker.selfManagedCloudApiConfig.workspaceId | string | `""` | prefect workspace ID |
| worker.tolerations | list | `[]` | tolerations for worker pods assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
