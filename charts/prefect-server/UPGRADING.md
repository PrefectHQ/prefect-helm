# Upgrade guidelines

## PostgreSQL subchart 12.x -> 18.x

The bundled Bitnami PostgreSQL subchart was upgraded from `12.12.10` to `18.8.5`. This upgrade is intentionally **non-destructive by default**: the bundled PostgreSQL engine stays on the 14.x line and no data migration is triggered by a routine `helm upgrade`. (The pinned engine image was also moved from `14.13.0` to `14.18.0`, the final pg14 patch release; this is an in-place patch bump and requires no data migration.)

**No action is required for most operators.** If you use an external or managed database (`postgresql.enabled: false` or the `externalDatabase` block), this change does not affect you at all.

### What changed

- The subchart template machinery, values schema, and security defaults are now current with the 18.x line. The values surface is compatible: the `auth.*`, `architecture`, `primary.initdb`, and `primary.persistence` keys are unchanged.
- The engine image remains pinned to `docker.io/bitnamilegacy/postgresql:14.18.0`. The 18.x subchart otherwise defaults to `bitnami/postgresql:latest` (engine 17.x), which (a) is no longer freely pullable after the 2025-08-28 Bitnami catalog change and (b) would require a destructive PostgreSQL 15 -> 17 data migration. Pinning to the legacy 14.x image avoids both. Note that `bitnamilegacy` is a frozen archive that receives no new builds, so `14.18.0` is the latest pullable pinned pg14 image; a future move to a maintained image source (or an engine upgrade) will be needed.

### Tightened security context

The 18.x StatefulSet ships stricter pod/container `securityContext` defaults than 12.x:

| Setting | 12.x | 18.x |
| --- | --- | --- |
| `runAsGroup` | `0` | `1001` |
| `readOnlyRootFilesystem` | unset | `true` |
| `privileged` | unset | `false` |
| `fsGroupChangePolicy` | unset | `Always` |

These are compatible with (and more compliant under) the Kubernetes `restricted` Pod Security Standard. However, if you supply custom `postgresql.primary.containerSecurityContext` overrides, or init scripts that write outside a mounted volume, note that `readOnlyRootFilesystem: true` and the non-root `runAsGroup` may require adjustment.

### Opt-in: upgrading the bundled engine to PostgreSQL 17

The bundled DB is **not intended for production** (see the README). If you nevertheless run on the bundled default and want to move the engine to 17.x, this is a **manual, destructive migration** — PostgreSQL 15 -> 17 is not an in-place data-directory upgrade. Do not simply raise `postgresql.image.tag`; that will leave a pod that refuses to start against an existing 14.x `PGDATA`.

A safe path:

1. Scale down or quiesce the Prefect server so no writes are in flight.
2. `pg_dump` (or `pg_dumpall`) the existing database from the running 14.x pod.
3. Remove the old PVC (this is the destructive step; take a backup first).
4. Set `postgresql.image.repository`/`tag` to the desired 17.x image and re-install.
5. Restore the dump into the new instance with `pg_restore`/`psql`.
6. Restart the Prefect server and verify migrations complete.

For any real workload, prefer an external or managed PostgreSQL via the `externalDatabase` block instead of the bundled subchart.

## Health probe defaults

The server startup, liveness, and readiness probes are enabled by default. After upgrading, Kubernetes will restart a server container that does not respond to `/api/health` and remove a server pod from service endpoints when `/api/ready` cannot connect to the database.

The configured Prefect image must expose these endpoints without authentication. Prefect 3.1.8 through 3.1.12 protects both endpoints when basic auth is enabled, so Kubernetes probes receive a `401` response. Upgrade Prefect or disable the probes to preserve the previous behavior:

```yaml
server:
  startupProbe:
    enabled: false
  livenessProbe:
    enabled: false
  readinessProbe:
    enabled: false
```

## Gateway API Support

This release introduces support for [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) as an alternative to the traditional Ingress API for exposing the Prefect server. Gateway API is the successor to Ingress and provides more advanced routing capabilities.

### What's New

- **Gateway API Support**: New `gateway` and `httproute` configuration sections enable Gateway API resources
- **Mutual Exclusivity**: Gateway API and Ingress are mutually exclusive - only one can be enabled at a time
- **Backward Compatible**: Gateway API is disabled by default; existing Ingress configurations continue to work
- **TLS Support**: Full TLS configuration including automatic HTTP to HTTPS redirect
- **Advanced Routing**: Support for custom hostnames, labels, annotations, and infrastructure configuration

### Should You Migrate?

**Gateway API is optional.** Your existing Ingress configuration will continue to work without any changes. Consider migrating if:

- You want to use advanced Gateway API features (e.g., traffic splitting, header matching)
- Your cluster already uses Gateway API for other applications
- You prefer the more expressive Gateway API resource model

### Migration from Ingress to Gateway API

If you want to migrate from Ingress to Gateway API:

1. **Prerequisites**:
   - Ensure Gateway API CRDs are installed (v1.0.0 or later)
   - Have a GatewayClass available (e.g., from Istio, Envoy Gateway, etc.)

2. **Update your values.yaml**:

```yaml
gateway:
  enabled: true
  className: "your-gateway-class"  # Replace with your GatewayClass name

ingress:
  enabled: false

httproute:
  hostnames:
    - "your-existing-hostname.example.com"
  tls:
    redirect: true  # Optional: enable HTTP to HTTPS redirect
```

3. **Test the migration**:
   - Deploy the updated chart to a test environment
   - Verify traffic flows correctly through the Gateway
   - Check Gateway and HTTPRoute status: `kubectl get gateway,httproute -n <namespace>`

4. **Rollback if needed**:
   - Simply re-enable Ingress and disable Gateway in your values

For detailed configuration options, see the [Gateway API Configuration section in the README](./README.md#gateway-api-configuration).

### Important Notes

- Gateway API and Ingress cannot be enabled simultaneously
- The `gateway.className` field is required when Gateway API is enabled
- Gateway API requires the CRDs to be available in your cluster

---

## > 2025.8.21160848

After version 2025.8.21160848, the chart automatically handles database migrations during upgrades using a pre-upgrade hook when in multi-server mode.

See the README.md file for more details.

## > 2025.7.31204438

After version 2025.7.31204438, we have migrated the `postgresql` image from the existing `bitnami` repo image to the `bitnamilegacy` repo image.
This change should not have any breaking change implications unless there is a need to whitelist that new docker registry.
The change is required per https://github.com/bitnami/charts/issues/35164.

## > 2025.3.7033449

After version 2025.3.7033449, there have been several breaking changes to the `prefect-server` chart:
- The `prefectApiUrl` and `prefectApiHost` values have been removed in favor of the single `prefectUiApiUrl` value.
- `.Values.server.uiConfig.prefectUiUrl` has been removed.
- `.Values.server.uiConfig.prefectUiEnabled` has been removed.

### Adjusting your configuration

#### API URLs

- `.Values.global.prefect.prefectApiUrl` => `.Values.server.uiConfig.prefectUiApiUrl`
- `.Values.global.prefect.prefectApiHost` => `.Values.server.uiConfig.prefectUiApiUrl`

Note: If you were using the default value for `prefectApiUrl` (i.e. `http://localhost:4200/api`) you do not need to make any changes, as the default value for `prefectUiApiUrl` is the same.

#### UI URL

`.Values.server.uiConfig.prefectUiUrl` has been removed altogether. This value was used solely for the purposes of printing out the UI URL during the installation process. It will now infer the UI URL from the `prefectUiApiUrl` value.

#### Disabling the UI

If you would like to disable the UI, you can pass this configuration via the `env` key.

```yaml
server:
  env:
    - name: PREFECT_UI_ENABLED
      value: 'false'
```

---

## > 2025.1.23213604

After version `2025.1.23213604`, the `prefect-server` chart [introduces the option to run background services as a separate deployment](https://github.com/PrefectHQ/prefect-helm/pull/425). Due to the numerous shared values between the `server` and `background-services` deployments, the `values.yaml` file has been consolidated in the following ways:

### Introduction of `global.prefect` key in `values.yaml`

`.Values.global.prefect` will contain shared configurations, many of which used to live under `.Values.server`, specifically:

- `.Values.server.image` => `.Values.global.prefect.image`
- `.Values.server.prefectApiUrl` => `.Values.global.prefect.prefectApiUrl`
- `.Values.server.prefectApiHost` => `.Values.global.prefect.prefectApiHost`

**Before**

```yaml
server:
  image:
    repository: prefecthq/prefect
    prefectTag: 3-latest
    pullPolicy: IfNotPresent
    pullSecrets: []
  prefectApiUrl: http://localhost:4200/api
  prefectApiHost: 0.0.0.0
```

**After**

```yaml
global:
  prefect:
    image:
      repository: prefecthq/prefect
      prefectTag: 3-latest
      pullPolicy: IfNotPresent
      pullSecrets: []
    prefectApiUrl: http://localhost:4200/api
    prefectApiHost: 0.0.0.0
```
