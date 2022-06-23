
Prefect-orion
===========

Prefect orion application bundle


## Configuration

The following table lists the configurable parameters of the Prefect-orion chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `prefectVersionTag` |  | `"2.0b7-python3.8"` |
| `api.enabled` |  | `true` |
| `api.service.type` |  | `"ClusterIP"` |
| `api.service.port` |  | `4200` |
| `api.replicaCount` |  | `1` |
| `api.image.name` |  | `"prefecthq/prefect"` |
| `api.image.pullPolicy` |  | `"IfNotPresent"` |
| `api.image.tag` |  | `"2.0b7-python3.8"` |
| `api.debug_enabled` |  | `false` |
| `api.autoscaling.enabled` |  | `false` |
| `api.autoscaling.minReplicas` |  | `1` |
| `api.autoscaling.maxReplicas` |  | `100` |
| `api.autoscaling.targetCPUUtilizationPercentage` |  | `80` |
| `api.ingress.enabled` |  | `false` |
| `api.ingress.className` |  | `""` |
| `api.ingress.annotations` |  | `{}` |
| `api.ingress.hosts` |  | `[{"host": "prefect.local", "paths": [{"path": "/", "pathType": "ImplementationSpecific"}]}]` |
| `api.ingress.tls` |  | `[]` |
| `api.nodeSelector` |  | `{}` |
| `api.tolerations` |  | `[]` |
| `api.affinity` |  | `{}` |
| `api.podAnnotations` |  | `{}` |
| `api.podSecurityContext` |  | `{}` |
| `api.securityContext` |  | `{}` |
| `api.resources` |  | `{}` |
| `postgresql.auth.database` |  | `"orion"` |
| `postgresql.auth.username` |  | `"prefect"` |
| `postgresql.auth.password` |  | `"HEREWEGO"` |
| `postgresql.auth.existingSecret` |  | `null` |
| `postgresql.containerPorts.postgresql` |  | `5432` |
| `postgresql.externalHostname` |  | `""` |
| `postgresql.useSubChart` |  | `true` |
| `postgresql.persistence.enabled` |  | `false` |
| `postgresql.persistence.size` |  | `"8Gi"` |
| `postgresql.initdbUser` |  | `"postgres"` |
| `postgresql.image.tag` |  | `"14.3.0"` |
| `serviceAccount.enabled` |  | `true` |




