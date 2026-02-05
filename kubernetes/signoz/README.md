# Installation SigNoz

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
  --values ./signoz-values-staging.yaml \
  --set clickhouse.zookeeper.persistence.size=20Gi \
  --set clickhouse.zookeeper.persistence.dataLogDir.size=20Gi
```

```shell
# Update the SigNoz chart
helm upgrade signoz ./signoz \
  --namespace infra-signoz \
  --values ./signoz-values-staging.yaml \
  --set clickhouse.zookeeper.persistence.size=20Gi \
  --set clickhouse.zookeeper.persistence.dataLogDir.size=20Gi
```

```shell
# Delete the SigNoz
helm uninstall signoz --namespace infra-signoz
```

# Deploy Result

```shell
NAME: signoz
LAST DEPLOYED: Thu Feb  5 14:19:21 2026
NAMESPACE: infra-signoz
STATUS: deployed
REVISION: 1
NOTES:
1. You have just deployed SigNoz cluster:

- signoz version: 'v0.107.0'
- otel-collector version: 'v0.129.12'

2. Get the application URL by running these commands:

  export POD_NAME=$(kubectl get pods --namespace infra-signoz -l "app.kubernetes.io/name=signoz,app.kubernetes.io/instance=signoz,app.kubernetes.io/component=signoz" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace infra-signoz port-forward $POD_NAME 8080:8080
```

# Install kube-infra

```shell
helm pull signoz/k8s-infra --version 0.15.0 --untar --destination ./
```

```shell
# Install manually with custom values
helm install k8s-infra ./k8s-infra \
  --namespace infra-k8s-infra \
  --create-namespace \
  --values ./k8s-infra-values-staging.yaml
```

# Deploy Result
```shell
NAME: k8s-infra
LAST DEPLOYED: Thu Feb  5 16:04:41 2026
NAMESPACE: infra-k8s-infra
STATUS: deployed
REVISION: 1
NOTES:
You have just deployed k8s-infra chart:

- otel-agent version: '0.139.0'
- otel-deployment version: '0.139.0'
```