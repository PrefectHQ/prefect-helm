# Upgrade guidelines

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
