# prometheus-prefect-exporter

## Overview

This chart deploys a [Prometheus Exporter](https://github.com/PrefectHQ/prometheus-prefect-exporter) for Prefect Server, providing relevant metrics from your deployed Prefect Server instance.
Shoutout to @ialejandro for the original work on this chart!

## Installing the Chart

### Prerequisites

1. Add the Prefect Helm repository to your Helm client:

    ```bash
    helm repo add prefect https://prefecthq.github.io/prefect-helm
    helm repo update
    ```

2. Deploy a Prefect Server instance using the [Prefect Server Helm chart](https://github.com/PrefectHQ/prefect-helm/tree/main/charts/prefect-server)

### Install the Prefect Exporter chart

1. Configure the Prefect exporter values as needed
    Create a `values.yaml` file to customize the Prometheus Prefect Exporter configuration.

2. Install the chart
    ```bash
    helm install prometheus-prefect-exporter prefect/prometheus-prefect-exporter --namespace=<PREFECT_SERVER_NAMESPACE> -f values.yaml
    ```

3. Verify the deployment

    Check the status of your Prometheus Prefect Exporter deployment:

    ```bash
    kubectl get pods -n prefect

    NAME                                  READY   STATUS    RESTARTS       AGE
    prometheus-prefect-exporter-76vxqnq   1/1     Running   0              25m
    ```

    You should see the Prometheus Prefect Exporter pod running

## Additional Exporter Configurations

### Basic Auth

Prefect documentation on [basic auth](https://docs.prefect.io/v3/develop/settings-and-profiles#security-settings)

Self-hosted Prefect servers can be equipped with a Basic Authentication string for an administrator/password combination. Assuming you are running a self-hosted server with basic auth enabled, you can authenticate your exporter with the same credentials.

The format of the auth string is `admin:<my-password>` (no brackets).

```yaml
basicAuth:
    enabled: true
    authString: "admin:pass"
```

Alternatively, you can provide an existing Kubernetes Secret containing the auth string credentials. The secret must contain a key `auth-string` with the value of the auth string.

```sh
kubectl create secret generic prefect-basic-auth --from-literal=auth-string='admin:my-password'
```

```yaml
basicAuth:
    enabled: true
    existingSecret: prefect-basic-auth
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
| affinity | object | `{}` | Affinity for pod assignment |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling with CPU or memory utilization percentage |
| basicAuth.authString | string | `"admin:pass"` | basic auth credentials in the format admin:<your-password> (no brackets) |
| basicAuth.enabled | bool | `false` | enable basic auth for the exporter, for an administrator/password combination. must be enabled on the server as well |
| basicAuth.existingSecret | string | `""` | name of existing secret containing basic auth credentials. takes precedence over authString. must contain a key `auth-string` with the value of the auth string |
| csrfAuth | bool | `false` | Enable CSRF authentication (Only set to true if Prefect Server has CSRF enabled) |
| env | object | `{}` | Environment variables to configure application |
| fullnameOverride | string | `""` | String to fully override common.names.fullname template |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"prefecthq/prometheus-prefect-exporter","tag":"1.1.0"}` | Image registry |
| imagePullSecrets | list | `[]` | Global Docker registry secret names as an array |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Ingress configuration to expose app |
| livenessProbe | bool | `false` | Enable livenessProbe |
| nameOverride | string | `""` | String to partially override common.names.fullname template (will maintain the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| pagination | object | `{"enabled":true,"limit":200}` | Pagination settings. If enabled, the exporter will paginate the API requests to Prefect Server which uses more resources.  Remember to increase the resources for the exporter if enabled. |
| podAnnotations | object | `{}` | Pod annotations |
| podDisruptionBudget | object | `{}` | Limits the number of Pods of a replicated application that are down simultaneously from voluntary disruptions |
| podSecurityContext | object | `{}` | To specify security settings for a Pod |
| prefectApiUrl | string | `"http://prefect-server.prefect.svc.cluster.local:4200/api"` | Prefect API URL to connect to for metrics |
| prometheusRule.additionalLabels | object | `{}` |  |
| prometheusRule.enabled | bool | `false` |  |
| prometheusRule.rules | list | `[]` |  |
| readinessProbe | bool | `false` | Enable readinessProbe |
| replicaCount | int | `1` | Number of replicas |
| resources | object | `{}` | The resources limits and requested |
| revisionHistoryLimit | int | `10` | the number of old ReplicaSets to retain to allow rollback |
| securityContext | object | `{}` | Defines privilege and access control settings for a Pod or Container |
| service | object | `{"port":80,"targetPort":8000,"type":"ClusterIP"}` | Kubernetes servide to expose Pod |
| service.port | int | `80` | Kubernetes Service port |
| service.targetPort | int | `8000` | Pod expose port |
| service.type | string | `"ClusterIP"` | Kubernetes Service type. Allowed values: NodePort, LoadBalancer or ClusterIP |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Enable creation of ServiceAccount |
| serviceMonitor | object | `{"additionalLabels":{},"enabled":false,"interval":"30s","metricRelabelings":[],"relabelings":[],"scrapeTimeout":"10s"}` | Enable ServiceMonitor to get metrics ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/api.md#servicemonitor |
| serviceMonitor.enabled | bool | `false` | Enable or disable |
| tolerations | list | `[]` | Tolerations for pod assignment |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
