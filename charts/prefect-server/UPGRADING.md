# Upgrade guidelines

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
