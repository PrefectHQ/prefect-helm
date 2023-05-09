# prefect-worker

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2-latest](https://img.shields.io/badge/AppVersion-2--latest-informational?style=flat-square)

Prefect Worker application bundle

**Homepage:** <https://github.com/PrefectHQ>

## Getting Started Guide

[Using Prefect Helm Chart for Prefect Workers](https://docs.prefect.io/latest/guides/deployment/helm-worker/)

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
| commonAnnotations | object | `{}` | annotations to add to all deployed objects |
| commonLabels | object | `{}` | labels to add to all deployed objects |
| fullnameOverride | string | `"prefect-worker"` | fully override common.names.fullname |
| nameOverride | string | `""` | partially overrides common.names.name |
| namespaceOverride | string | `""` | fully override common.names.namespace |
| role.extraPermissions | list | `[]` | array with extra permissions to add to the agent role |
| serviceAccount.annotations | object | `{}` | additional service account annotations (evaluated as a template) |
| serviceAccount.create | bool | `true` | specifies whether a ServiceAccount should be created |
| serviceAccount.name | string | `""` | the name of the ServiceAccount to use. if not set and create is true, a name is generated using the common.names.fullname template |
| worker.affinity | object | `{}` | affinity for agent pods assignment |
| worker.apiConfig | string | `"cloud"` | one of 'cloud' or 'server' |
| worker.cloudApiConfig.accountId | string | `""` | prefect account ID |
| worker.cloudApiConfig.apiKeySecret.key | string | `"key"` | prefect API secret key |
| worker.cloudApiConfig.apiKeySecret.name | string | `"prefect-api-key"` | prefect API secret name |
| worker.cloudApiConfig.cloudUrl | string | `"https://api.prefect.cloud/api"` | prefect cloud API url; the full URL is constructed as https://cloudUrl/accounts/accountId/workspaces/workspaceId |
| worker.cloudApiConfig.workspaceId | string | `""` | prefect workspace ID |
| worker.clusterUid | string | `""` | unique cluster identifier, if none is provided this value will be infered at time of helm install |
| worker.config.http2 | bool | `true` | connect using HTTP/2 if the server supports it (experimental) |
| worker.config.prefetchSeconds | int | `10` | when querying for runs, how many seconds in the future can they be scheduled |
| worker.config.queryInterval | int | `5` | how often the agent will query for runs |
| worker.config.workPool | string | `""` | name of prefect workpool the agent will poll; if workpool or workqueues is not provided, we use the default queue |
| worker.containerSecurityContext.allowPrivilegeEscalation | bool | `false` | set agent containers' security context allowPrivilegeEscalation |
| worker.containerSecurityContext.readOnlyRootFilesystem | bool | `true` | set agent containers' security context readOnlyRootFilesystem |
| worker.containerSecurityContext.runAsNonRoot | bool | `true` | set agent containers' security context runAsNonRoot |
| worker.containerSecurityContext.runAsUser | int | `1001` | set agent containers' security context runAsUser |
| worker.extraContainers | list | `[]` | additional sidecar containers |
| worker.extraEnvVars | list | `[]` | array with extra environment variables to add to agent nodes |
| worker.extraEnvVarsCM | string | `""` | name of existing ConfigMap containing extra env vars to add to agent nodes |
| worker.extraEnvVarsSecret | string | `""` | name of existing Secret containing extra env vars to add to agent nodes |
| worker.extraVolumeMounts | list | `[]` | array with extra volumeMounts for the agent pod |
| worker.extraVolumes | list | `[]` | array with extra volumes for the agent pod |
| worker.image.debug | bool | `false` | enable agent image debug mode |
| worker.image.prefectTag | string | `"2-python3.11-kubernetes"` | prefect image tag (immutable tags are recommended) |
| worker.image.pullPolicy | string | `"IfNotPresent"` | agent image pull policy |
| worker.image.pullSecrets | list | `[]` | agent image pull secrets |
| worker.image.repository | string | `"prefecthq/prefect"` | agent image repository |
| worker.nodeSelector | object | `{}` | node labels for agent pods assignment |
| worker.podAnnotations | object | `{}` | extra annotations for agent pod |
| worker.podLabels | object | `{}` | extra labels for agent pod |
| worker.podSecurityContext.fsGroup | int | `1001` | set agent pod's security context fsGroup |
| worker.podSecurityContext.runAsNonRoot | bool | `true` | set agent pod's security context runAsNonRoot |
| worker.podSecurityContext.runAsUser | int | `1001` | set agent pod's security context runAsUser |
| worker.replicaCount | int | `1` | number of agent replicas to deploy |
| worker.resources.limits | object | `{"cpu":"1000m","memory":"1Gi"}` | the requested limits for the agent container |
| worker.resources.requests | object | `{"cpu":"100m","memory":"256Mi"}` | the requested resources for the agent container |
| worker.serverApiConfig.apiUrl | string | `"http://127.0.0.1:4200/api"` | prefect API url (PREFECT_API_URL); should be in-cluster URL if the agent is deployed in the same cluster as the API |
| worker.tolerations | list | `[]` | tolerations for agent pods assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
