# Installation

```shell
helm repo add signoz https://charts.signoz.io
```

```shell
helm repo update
```

```shell
helm pull signoz/signoz --version 0.107.0 --untar --destination ./
```

```shell
# Install manually with custom values
helm install signoz ./signoz \
  --namespace infra-signoz \
  --create-namespace \
  --values ./signoz-values-staging.yaml
```

```shell
helm install signoz signoz/signoz \
   --namespace <namespace> --create-namespace \
   --wait \
   --timeout 1h \
   -f values.yaml
```