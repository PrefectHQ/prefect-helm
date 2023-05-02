# Prefect Helm Charts

## Description

This repository contains the official Prefect Helm chart for installing and configuring Prefect on Kubernetes. This chart supports multiple use cases of Prefect on Kubernetes depending on the values provided and chart selected including:

### [Prefect Worker](charts/prefect-worker/)

:rotating_light: Workers are a beta feature and are subject to change in future releases. :rotating_light:

[Workers](https://docs.prefect.io/latest/concepts/work-pools/#worker-overview) are lightweight polling services that retrieve scheduled runs from a work pool and execute them.

Workers are similar to agents, but offer greater control over infrastructure configuration and the ability to route work to specific types of execution environments.

Workers each have a type corresponding to the execution environment to which they will submit flow runs. Workers are only able to join work pools that match their type. As a result, when deployments are assigned to a work pool, you know in which execution environment scheduled flow runs for that deployment will run.

### [Prefect Agent](charts/prefect-agent/)

[Agent](https://docs.prefect.io/latest/concepts/work-pools/#agent-overview) processes are lightweight polling services that get scheduled work from a work pool and deploy the corresponding flow runs.

Agents poll for work every 15 seconds by default. This interval is configurable in your profile settings with the `PREFECT_AGENT_QUERY_INTERVAL` setting.

It is possible for multiple agent processes to be started for a single work pool. Each agent process sends a unique ID to the server to help disambiguate themselves and let users know how many agents are active.

### [Prefect Server](charts/prefect-server/)

[Prefect Server](https://docs.prefect.io/latest/host/#hosting-prefect-server) is an open source backend that makes it easy to observe and orchestrate your Prefect flows.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

### TL;DR

```shell-session
$ helm repo add prefect https://prefecthq.github.io/prefect-helm
$ helm search repo prefect
$ helm install my-release prefect/<chart>
```

### Installing released versions

Charts are automatically versioned and released together. The `appVersion` and `prefectTag` version are pinned at package time to the current release of Prefect 2.

The charts are hosted in a [Helm repository](https://helm.sh/docs/chart_repository/) deployed to the web courtesy of Github Pages.

1. Add the Prefect repository to Helm and list available charts and versions:

   ```shell-session
   $ helm repo add prefect https://prefecthq.github.io/prefect-helm/
   $ helm repo update
   $ helm search repo prefect
   ```

   **Note**: The repository includes a legacy `prefect-orion` chart, which no longer receives updates and will be removed in June 2023. Please use `prefect-server` instead.

1. Install the Helm chart

   Using default options

   ```shell-session
   $ helm install prefect/prefect-server --generate-name
   ```

   Setting some typical flags for customization

   ```bash
   # The kubernetes namespace to install into, can be anything or excluded to install in the default namespace
   NAMESPACE=prefect-server
   # The Helm "release" name, can be anything but we recommend matching the chart name
   NAME=prefect-server
   # The path to your config that overrides values in `values.yaml`
   CONFIG_PATH=path/to/your/config.yaml
   # The chart version to install
   VERSION=2023.03.30

   helm install \
     --namespace $NAMESPACE \
     --version $VERSION \
     --values $CONFIG_PATH \
     $NAME \
   prefect/prefect-server
   ```

If chart installation fails, run the same command with `--debug` to see additional diagnostic information.

Refer to the [Helm `install` documentation](https://helm.sh/docs/helm/helm_install/) for all options.

### Installing development versions

Development versions of the Helm chart will always be available directly from this Github repository.

1. Clone repository

1. Change to this directory

1. Download the chart dependencies

   ```shell-session
   $ helm dependency update
   ```

1. Install the chart

   ```shell-session
   $ helm install . --generate-name
   ```

### Upgrading

1. Look up the name of the last release

   ```shell-session
   $ helm list
   ```

1. Run the upgrade

   ```bash
   # Set this name to the name of your last Helm release
   NAME=prefect-server
   # Choose a version to upgrade to or omit the flag to use the latest version
   VERSION=2023.03.30

   helm upgrade $NAME prefect/prefect-server --version $VERSION
   ```

   For development versions, make sure your cloned repository is updated (`git pull`) and reference the local chart

   ```shell-session
   $ helm upgrade $NAME .
   ```

1. Upgrades can also be used enable features or change options

   ```bash
   NAME=prefect-server

   helm upgrade \
     $NAME \
     prefect/prefect-server
   ```

#### Important notes about upgrading

- Updates will only update infrastructure that is modified.
- You will need to continue to set any values that you set during the original install (e.g. `--set agent.enabled=true` or `--values path/to/config.yaml`).
- If you are using the postgresql subchart with an autogenerated password, it will complain that you have not provided that password for the upgrade.
  Export the password as the error asks then set it within the subchart using
  ```shell-session
  $ helm upgrade ... --set postgresql.postgresqlPassword=$POSTGRESQL_PASSWORD
  ```

## Options:

See comments in `values.yaml`.

### Security Context

By default, the agent and server run as an unprivileged user with a read-only root filesystem. You can customize the security context settings for both the agent and server in the `values.yaml` file for your use case.

If you need to install system packages or configure other settings at runtime, you can configure a writable filesystem and run as root by configuring the pod and container security context accordingly:

```yaml
  podSecurityContext:
    runAsUser: 0
    runAsNonRoot: false
    fsGroup: 0

  containerSecurityContext:
    runAsUser: 0
    # this must be false, since we are running as root
    runAsNonRoot: false
    # make the filesystem writable
    readOnlyRootFilesystem: false
    # this must be false, since we are running as root
    allowPrivilegeEscalation: false
```

If you are running in OpenShift, the default `restricted` security context constraint will prevent customization of the user. In this case, explicitly configure the `runAsUser` settings to `null` to use OpenShift-assigned settings:

```yaml
  podSecurityContext:
    runAsUser: null
    fsGroup: null

  containerSecurityContext:
    runAsUser: null
```

The other default settings, such as a read-only root filesystem, are suitable for an OpenShift environment.

## Additional Permissions for Prefect Agent

### Dask

If you are running flows on your agent’s pod (i.e. with Process infrastructure), and using the Dask task runner to create Dask Kubernetes clusters, you will need to grant the following permissions within `values.yaml`.

```yaml
role:
  extraPermissions:
    - apiGroups: [""]
      resources: ["pods", "services"]
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
    - apiGroups: ["policy"]
      resources: ["poddisruptionbudgets"]
      verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

## Version Support Policy

Prefect follows the [upstream Kubernetes support policy](https://kubernetes.io/releases/version-skew-policy/), meaning that we test against the three most recent minor version releases of Kubernetes. The charts may be compatible with older releases of Kubernetes, however, we do not test against those versions and may choose to reject issues or patches to add support.

The chart repository also includes a deprecated `prefect-orion` chart, which no longer receives updates. Please upgrade to `prefect-server` at your earliest convenience. We will remove all published versions of `prefect-server` from our Helm repository, on or after May 31st, 2023.

## Troubleshooting

### The database deploys correctly but other services fail with "bad password"

If you are using the subchart deployed database with persistence enabled, it is likely the password for the user has persisted between deployments in the PVC for the database but the secret has been regenerated by the Helm chart and does not match. Deploy and set the 'postgresql.auth.existingSecret' option or set a constant password at `postgresql.auth.password`.

## Contributing

Contributions to the Prefect Helm Charts are always welcome! We welcome your help - whether it's adding new functionality,
tweaking documentation, or anything in between.

### Documentation

Please make sure that your changes have been linted & the chart documentation has been updated.  The easiest way to accomplish this is by installing [`pre-commit`](https://pre-commit.com/).

### Testing & Validation

Make sure that any new functionality is well tested!  You can do this by installing the chart locally, see [above](https://github.com/PrefectHQ/prefect-helm#installing-development-versions) for how to do this.

### Opening a PR

A helpful PR explains WHAT changed and WHY the change is important. Please take time to make your PR descriptions as helpful as possible. If you are opening a PR from a forked repository - please follow [these](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/allowing-changes-to-a-pull-request-branch-created-from-a-fork) docs to allow `prefect-helm` maintainers to push commits to your local branch.
