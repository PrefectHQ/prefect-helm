# orion-server

![Version: 0.0.3](https://img.shields.io/badge/Version-0.0.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

This helm chart deploys a Prefect Orion API and UI on Kubernetes

## Usage

### Installing released versions

The Helm chart is automatically versioned and released alongside Server.
For each Github Release of Server there is a corresponding version of the Helm chart.
The charts are hosted in a [Helm repository](https://helm.sh/docs/chart_repository/) deployed to the web courtesy of Github Pages.

1. Let you local Helm manager know about the repository.

    ```
    $ helm repo add prefecthq https://prefecthq.github.io/prefect-recipes
    ```

2. Sync versions available in the repo to your local cache.

    ```
    $ helm repo update
    ```

3. Search for available charts and versions

    ```
    $ helm search repo [name]
    ```

4. Install the Helm chart

    Using default options
    ```
    $ helm install prefecthq/prefect-server --generate-name
    ```

    Setting some typical flags for customization
    ```shell
    # The kubernetes namespace to install into, can be anything or excluded to install in the default namespace
    NAMESPACE=prefect-server
    # The Helm "release" name, can be anything but we recommend matching the chart name
    NAME=prefect-server
    # The path to your config that overrides values in `values.yaml`
    CONFIG_PATH=path/to/your/config.yaml
    # The chart version to install
    VERSION=2022.04.14

    helm install \
        --namespace $NAMESPACE \
        --version $VERSION \
        --values $CONFIG_PATH \
        $NAME \
        prefecthq/prefect-server
    ```

    _If chart installation fails, `--debug` can provide more information_

    See [Helm install docs](https://helm.sh/docs/helm/helm_install/) for all options.

**Homepage:** <https://github.com/PrefectHQ>

## Maintainers

| Name     | Email               | Url |
| -------- | ------------------- | --- |
| gabcoyne | <george@prefect.io> |     |

## Source Code

* <https://github.com/PrefectHQ/prefect-recipes>

## Requirements

| Repository                         | Name       | Version |
| ---------------------------------- | ---------- | ------- |
| https://charts.bitnami.com/bitnami | postgresql | ~11.6.2 |

## Values

| Key                                            | Type   | Default                                                                                                                                                    | Description                                                                      |
| ---------------------------------------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| annotations                                    | object | `{}`                                                                                                                                                       |                                                                                  |
| api.affinity                                   | object | `{}`                                                                                                                                                       |                                                                                  |
| api.autoscaling.enabled                        | bool   | `false`                                                                                                                                                    |                                                                                  |
| api.autoscaling.maxReplicas                    | int    | `100`                                                                                                                                                      |                                                                                  |
| api.autoscaling.minReplicas                    | int    | `1`                                                                                                                                                        |                                                                                  |
| api.autoscaling.targetCPUUtilizationPercentage | int    | `80`                                                                                                                                                       |                                                                                  |
| api.debug_enabled                              | bool   | `false`                                                                                                                                                    |                                                                                  |
| api.enabled                                    | bool   | `true`                                                                                                                                                     |                                                                                  |
| api.image.name                                 | string | `"prefecthq/prefect"`                                                                                                                                      |                                                                                  |
| api.image.pullPolicy                           | string | `"IfNotPresent"`                                                                                                                                           |                                                                                  |
| api.image.tag                                  | string | `"2.0b5-python3.8"`                                                                                                                                        | Overrides the image tag whose default is the chart appVersion.                   |
| api.ingress                                    | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"prefect.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Ingress configuration                                                            |
| api.nodeSelector                               | object | `{}`                                                                                                                                                       |                                                                                  |
| api.podAnnotations                             | object | `{}`                                                                                                                                                       |                                                                                  |
| api.podSecurityContext                         | object | `{}`                                                                                                                                                       |                                                                                  |
| api.replicaCount                               | int    | `1`                                                                                                                                                        |                                                                                  |
| api.resources                                  | object | `{}`                                                                                                                                                       |                                                                                  |
| api.securityContext                            | object | `{}`                                                                                                                                                       |                                                                                  |
| api.service.port                               | int    | `4200`                                                                                                                                                     |                                                                                  |
| api.service.type                               | string | `"ClusterIP"`                                                                                                                                              |                                                                                  |
| api.tolerations                                | list   | `[]`                                                                                                                                                       |                                                                                  |
| fullnameOverride                               | string | `""`                                                                                                                                                       |                                                                                  |
| imagePullSecrets                               | list   | `[]`                                                                                                                                                       |                                                                                  |
| nameOverride                                   | string | `""`                                                                                                                                                       |                                                                                  |
| postgresql.auth.database                       | string | `"orion"`                                                                                                                                                  |                                                                                  |
| postgresql.auth.existingSecret                 | string | `nil`                                                                                                                                                      |                                                                                  |
| postgresql.auth.password                       | string | `"HEREWEGO"`                                                                                                                                               |                                                                                  |
| postgresql.auth.username                       | string | `"prefect"`                                                                                                                                                |                                                                                  |
| postgresql.containerPorts.postgresql           | int    | `5432`                                                                                                                                                     |                                                                                  |
| postgresql.externalHostname                    | string | `""`                                                                                                                                                       |                                                                                  |
| postgresql.image.tag                           | string | `"14.3.0"`                                                                                                                                                 | Version tag, corresponds to tags at https://hub.docker.com/r/bitnami/postgresql/ |
| postgresql.initdbUser                          | string | `"postgres"`                                                                                                                                               | initial postgres user to create                                                  |
| postgresql.persistence.enabled                 | bool   | `false`                                                                                                                                                    | Enables a PVC that stores db between deployments                                 |
| postgresql.persistence.size                    | string | `"8Gi"`                                                                                                                                                    | Configures size of postgres PVC                                                  |
| postgresql.useSubChart                         | bool   | `true`                                                                                                                                                     |                                                                                  |
| prefectVersionTag                              | string | `"2.0b5-python3.8"`                                                                                                                                        |                                                                                  |
| serviceAccount.enabled                         | bool   | `true`                                                                                                                                                     |                                                                                  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.10.0](https://github.com/norwoodj/helm-docs/releases/v1.10.0)
