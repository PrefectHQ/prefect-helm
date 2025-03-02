# Upgrade guidelines

## > TBD

After version TBD, there have been several breaking changes to the `prefect-worker` chart:
- The allowed values for the `apiConfig` key changed from `cloud`, `server`, or `selfManaged` to `cloud`, `selfHostedServer`, and `selfManagedCloud`.
- `.Values.worker.server` => `.Values.worker.selfHostedServerApiConfig`
- `.Values.worker.basicAuth` => `.Values.worker.selfHostedServerApiConfig.basicAuth`

### Adjusting Your Configuration

#### Self Hosted Server Configuration

**Before**

```yaml
worker:
  basicAuth:
    ...
  apiConfig: server
  server:
    ...
```

**After**

```yaml
worker:
  apiConfig: selfHostedServer
  selfHostedServerApiConfig:
    basicAuth:
      ...
```

#### Self Managed Cloud Configuration

**Before**

```yaml
worker:
  apiConfig: selfManaged
  ...
```

**After**

```yaml
worker:
  apiConfig: selfManagedCloud
  ...
```

### UI URL in NOTES.txt

The UI URL related values (`Values.worker.serverApiConfig.uiUrl` and `.Values.worker.selfManagedCloudApiConfig.uiUrl`) have been removed. These values were previously only used in the NOTES.txt file to provide a link to the Prefect UI.

---

## > 2025.1.28020410

After version `2025.1.28020410`, the `prefect-worker` chart renamed the `selfHostedCloudApiConfig` key to `selfManagedCloudApiConfig`.

**Before**

```yaml
worker:
  selfHostedCloudApiConfig:
    apiUrl: ""
    accountId: ""
    workspaceId: ""
    apiKeySecret:
      name: prefect-api-key
      key: key
    cloudApiUrl: ""
    uiUrl: ""
```

**After**

```yaml
worker:
  selfManagedCloudApiConfig:
    apiUrl: ""
    accountId: ""
    workspaceId: ""
    apiKeySecret:
      name: prefect-api-key
      key: key
    cloudApiUrl: ""
    uiUrl: ""
```
