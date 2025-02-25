# Upgrade guidelines

## > TBD

After version `TBD` the `prefect-server` chart has removed some exposed environment variables in favor of a more simplified configuration. In particular, the `prefectApiUrl` and `prefectApiHost` values have been removed in favor of the single `prefectUiApiUrl` value.

### Adjusting your configuration

#### API URLs

- `.Values.global.prefect.prefectApiUrl` => `.Values.server.uiConfig.prefectUiApiUrl`
- `.Values.global.prefect.prefectApiHost` => `.Values.server.uiConfig.prefectUiApiUrl`

Note: If you were using the default value for `prefectApiUrl` (i.e. `http://localhost:4200/api`) you do not need to make any changes, as the default value for `prefectUiApiUrl` is the same.

#### UI URL

`.Values.server.uiConfig.prefectUiUrl` has been removed altogether. This value was used solely for the purposes of printing out the UI URL during the installation process. It will now infer the UI URL from the `prefectUiApiUrl` value.

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
