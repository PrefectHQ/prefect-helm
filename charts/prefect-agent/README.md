# prefect-agent

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2-latest](https://img.shields.io/badge/AppVersion-2--latest-informational?style=flat-square)

Prefect Agent application bundle

**Homepage:** <https://github.com/PrefectHQ>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| jamiezieziula | <jamie@prefect.io> |  |
| jimid27 | <jimi@prefect.io> |  |
| parkedwards | <edward@prefect.io> |  |
| jawnsy | <jonathan@prefect.io> |  |

## Source Code

* <https://github.com/PrefectHQ/prefect-helm>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 2.2.4 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| agent.affinity | object | `{}` | affinity for agent pods assignment |
| agent.apiConfig | string | `"cloud"` | one of 'cloud' or 'server' |
| agent.cloudApiConfig.accountId | string | `""` | prefect account ID |
| agent.cloudApiConfig.apiKeySecret.key | string | `"key"` | prefect API secret key |
| agent.cloudApiConfig.apiKeySecret.name | string | `"prefect-api-key"` | prefect API secret name |
| agent.cloudApiConfig.cloudUrl | string | `"https://api.prefect.cloud/api"` | prefect cloud API url; the full URL is constructed as https://cloudUrl/accounts/accountId/workspaces/workspaceId |
| agent.cloudApiConfig.workspaceId | string | `""` | prefect workspace ID |
| agent.clusterUid | string | `""` | unique cluster identifier, if none is provided this value will be infered at time of helm install |
| agent.config.http2 | bool | `true` | connect using HTTP/2 if the server supports it (experimental) |
| agent.config.prefetchSeconds | int | `10` | when querying for runs, how many seconds in the future can they be scheduled |
| agent.config.queryInterval | int | `5` | how often the agent will query for runs |
| agent.config.workPool | string | `""` | name of prefect workpool the agent will poll; if workpool or workqueues is not provided, we use the default queue |
| agent.config.workQueues | list | `[]` | names of prefect workqueues the agent will poll; if workpool or workqueues is not provided, we use the default queue |
| agent.containerSecurityContext.allowPrivilegeEscalation | bool | `false` | set agent containers' security context allowPrivilegeEscalation |
| agent.containerSecurityContext.readOnlyRootFilesystem | bool | `true` | set agent containers' security context readOnlyRootFilesystem |
| agent.containerSecurityContext.runAsNonRoot | bool | `true` | set agent containers' security context runAsNonRoot |
| agent.containerSecurityContext.runAsUser | int | `1001` | set agent containers' security context runAsUser |
| agent.extraContainers | list | `[]` | additional sidecar containers |
| agent.extraEnvVars | list | `[]` | array with extra environment variables to add to agent nodes |
| agent.extraEnvVarsCM | string | `""` | name of existing ConfigMap containing extra env vars to add to agent nodes |
| agent.extraEnvVarsSecret | string | `""` | name of existing Secret containing extra env vars to add to agent nodes |
| agent.extraVolumeMounts | list | `[]` | array with extra volumeMounts for the agent pod |
| agent.extraVolumes | list | `[]` | array with extra volumes for the agent pod |
| agent.image.debug | bool | `false` | enable agent image debug mode |
| agent.image.prefectTag | string | `"2-latest"` | prefect image tag (immutable tags are recommended) |
| agent.image.pullPolicy | string | `"IfNotPresent"` | agent image pull policy |
| agent.image.pullSecrets | list | `[]` | agent image pull secrets |
| agent.image.repository | string | `"prefecthq/prefect"` | agent image repository |
| agent.nodeSelector | object | `{}` | node labels for agent pods assignment |
| agent.podAnnotations | object | `{}` | extra annotations for agent pod |
| agent.podLabels | object | `{}` | extra labels for agent pod |
| agent.podSecurityContext.fsGroup | int | `1001` | set agent pod's security context fsGroup |
| agent.podSecurityContext.runAsNonRoot | bool | `true` | set agent pod's security context runAsNonRoot |
| agent.podSecurityContext.runAsUser | int | `1001` | set agent pod's security context runAsUser |
| agent.replicaCount | int | `1` | number of agent replicas to deploy |
| agent.resources.limits | object | `{"cpu":"1000m","memory":"1Gi"}` | the requested limits for the agent container |
| agent.resources.requests | object | `{"cpu":"100m","memory":"256Mi"}` | the requested resources for the agent container |
| agent.serverApiConfig.apiUrl | string | `"http://127.0.0.1:4200/api"` | prefect API url (PREFECT_API_URL); should be in-cluster URL if the agent is deployed in the same cluster as the API |
| agent.tolerations | list | `[]` | tolerations for agent pods assignment |
| commonAnnotations | object | `{}` | annotations to add to all deployed objects |
| commonLabels | object | `{}` | labels to add to all deployed objects |
| fullnameOverride | string | `"prefect-agent"` | fully override common.names.fullname |
| nameOverride | string | `""` | partially overrides common.names.name |
| namespaceOverride | string | `""` | fully override common.names.namespace |
| role.extraPermissions | list | `[]` | array with extra permissions to add to the agent role |
| serviceAccount.annotations | object | `{}` | additional service account annotations (evaluated as a template) |
| serviceAccount.create | bool | `true` | specifies whether a ServiceAccount should be created |
| serviceAccount.name | string | `""` | the name of the ServiceAccount to use. if not set and create is true, a name is generated using the common.names.fullname template |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
