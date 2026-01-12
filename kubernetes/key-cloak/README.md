# Helm

## Local

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

```shell
helm pull bitnami/keycloak --version 25.2.0 --untar --destination ./
```

```shell
kubectl create namespace infra-keycloak
```

```shell
kubectl apply -f ./keycloak-secret-staging.yaml  
```

```shell
# Install manually with custom values
helm install keycloak ./keycloak \
  --namespace infra-keycloak \
  --create-namespace \
  --values ./keycloak-values-staging.yaml \
  --set image.repository=bitnamilegacy/keycloak \
  --set keycloakConfigCli.image.repository=bitnamilegacy/keycloak-config-cli \
  --set postgresql.image.repository=bitnamilegacy/postgresql \
  --set postgresql.volumePermissions.image.repository=bitnamilegacy/os-shell \
  --set postgresql.metrics.image.repository=bitnamilegacy/postgres-exporter
```

### Fix image issue of bitnami/keycloak

```shell
# Fix bitnami repo to bitnamilegacy
# https://github.com/bitnami/charts/issues/35164#:~:text=Q%3A%20How%20can%20I%20get%20continued%20support%20for%20Helm%20charts%3F
grep 'repository.*REPOSITORY_NAME/' keycloak/README.md | awk -F'\`' '{print $2, $(NF-1)}'
```

```shell
--set image.repository=bitnamilegacy/keycloak \
--set keycloakConfigCli.image.repository=bitnamilegacy/keycloak-config-cli \
```

```shell
# Update the KeyCloak and PostgresSQL chart
helm upgrade keycloak ./keycloak \
  --namespace infra-keycloak \
  --values ./keycloak-values-staging.yaml \
  --set image.repository=bitnamilegacy/keycloak \
  --set keycloakConfigCli.image.repository=bitnamilegacy/keycloak-config-cli \
  --set postgresql.image.repository=bitnamilegacy/postgresql \
  --set postgresql.volumePermissions.image.repository=bitnamilegacy/os-shell \
  --set postgresql.metrics.image.repository=bitnamilegacy/postgres-exporter
```