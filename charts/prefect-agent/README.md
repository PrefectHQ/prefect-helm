
Prefect-agent
===========

Prefect orion application bundle


## Configuration

The following table lists the configurable parameters of the Prefect-agent chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `prefectVersionTag` |  | `"2.0b7-python3.8"` |
| `agent.apiUrl` |  | `"beta.prefect.io"` |
| `agent.workQueueName` |  | `"kubernetes"` |
| `agent.prefectCloudAccount` |  | `null` |
| `agent.image.name` |  | `"prefecthq/prefect"` |
| `agent.image.pullPolicy` |  | `"IfNotPresent"` |
| `agent.image.tag` |  | `"2.0b7-python3.8"` |
| `agent.serviceAccount.create` |  | `true` |
| `agent.serviceAccount.annotations` |  | `{}` |
| `agent.serviceAccount.name` |  | `""` |
| `agent.podAnnotations` |  | `{}` |
| `agent.podSecurityContext` |  | `{}` |
| `agent.securityContext` |  | `{}` |
| `agent.replicaCount` |  | `1` |
| `agent.resources` |  | `{}` |
| `agent.autoscaling.enabled` |  | `false` |
| `agent.autoscaling.minReplicas` |  | `1` |
| `agent.autoscaling.maxReplicas` |  | `10` |
| `agent.autoscaling.targetCPUUtilizationPercentage` |  | `80` |
| `agent.nodeSelector` |  | `{}` |
| `agent.tolerations` |  | `[]` |
| `agent.affinity` |  | `{}` |
| `serviceAccount.enabled` |  | `true` |
| `imagePullSecrets` |  | `[]` |
| `nameOverride` |  | `""` |
| `fullnameOverride` |  | `""` |
| `annotations` |  | `{}` |




