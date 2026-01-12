# Install
TODO For future.

```shell
helm repo add harbor https://helm.goharbor.io
```

```shell
helm repo update
```

```shell
helm install harbor harbor/harbor --version 1.16.4
```

```shell
# 2.12.4
helm pull harbor/harbor --version 1.16.4 --untar --destination ./
```

```shell
kubectl apply -f ./harbor-secret-staging.yaml
```

```shell
# Install manually with custom values
helm install harbor ./harbor \
  --namespace infra-harbor \
  --create-namespace \
  --values ./harbor-values-staging.yaml
```

```shell
# Update the Harbor chart
helm upgrade infra-harbor ./harbor \
  --namespace infra-harbor \
  --values ./harbor-values-staging.yaml
```