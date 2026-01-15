## Install Knative Serving

### Download the Knative Serving CRDs
```shell
curl -L --output-dir ./serving -O https://github.com/knative/serving/releases/download/knative-v1.20.1/serving-crds.yaml
```

### Download the Knative Serving Core
```shell
curl -L --output-dir ./serving -O https://github.com/knative/serving/releases/download/knative-v1.20.1/serving-core.yaml
```

### Install Knative Serving
```shell
kubectl apply -f ./serving/serving-crds.yaml
```

```shell
kubectl apply -f ./serving/serving-core.yaml
```

## Install Networking Layer

### Download and Install the Istio
```shell
curl -L --output-dir ./networking -O https://github.com/knative-extensions/net-istio/releases/download/knative-v1.20.1/istio.yaml
```

```shell
kubectl apply -f ./networking/istio.yaml
```

### Install the Knative Istio Controller
```shell
curl -L --output-dir ./networking -O https://github.com/knative/net-istio/releases/download/knative-v1.20.1/net-istio.yaml
```

```shell
kubectl apply -f ./networking/net-istio.yaml
```

### Verify the Knative Networking Installation

The resource added in the knative-serving.
```shell
NAME                                        READY   STATUS    RESTARTS   AGE
pod/net-istio-controller-6978885fd5-ncvdv   1/1     Running   0          2m2s
pod/net-istio-webhook-6865ddd498-kt8bl      1/1     Running   0          2m1s

NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                   AGE
service/net-istio-webhook            ClusterIP   <cluster-ip>     <none>        9090/TCP,8008/TCP,443/TCP                 2m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/net-istio-controller   1/1     1            1           2m3s
deployment.apps/net-istio-webhook      1/1     1            1           2m2s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/net-istio-controller-6978885fd5   1         1         1       2m3s
replicaset.apps/net-istio-webhook-6865ddd498      1         1         1       2m2s
```

The resources added in the istio-system.
```shell
NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                                      AGE
service/knative-local-gateway   ClusterIP      <cluster-ip>     <none>           80/TCP,443/TCP                               3m56s
```

## Config DNS
```shell
kubectl --namespace istio-system get service istio-ingressgateway
```

Fetch the external ip. Configure the DNS A record to the IP.
```shell
# Replace knative.example.com with your domain suffix
kubectl patch configmap/config-domain \
  --namespace knative-serving \
  --type merge \
  --patch '{"data":{"<change-me>": ""}}'
```

## Configure HTTPS
### Config Cert Manager
```shell
kubectl apply -f cert-manager/knative-cloudflare-api-token-secret-staging.yaml
kubectl apply -f cert-manager/knative-lets-encrypt-cluster-issuer-staging.yaml
```

```shell
kubectl edit configmap config-certmanager -n knative-serving
```

Add this part:
```yaml
data:
  issuerRef: |
    kind: ClusterIssuer
    name: knative-lets-encrypt-cluster-issuer-staging
```

### Config Knative Network

```shell
kubectl edit configmap config-network -n knative-serving
```

Enable the External Domain TLS:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-network
  namespace: knative-serving
data:
   ...
   external-domain-tls: Enabled
   ...
```

Restart: 
```shell
kubectl rollout restart deploy/controller -n knative-serving
```

Configure whether to use the wildcard cert or not:
```shell
kubectl patch -n knative-serving configmap config-network -p '{
  "data": {
    "external-domain-tls": "Enabled",
    "namespace-wildcard-cert-selector": "{\"matchExpressions\":[{\"key\":\"networking.knative.dev/disableWildcardCert\",\"operator\":\"NotIn\",\"values\":[\"true\"]}]}"
  }
}'
```

Restart the controller:
```shell
kubectl rollout restart deploy/controller -n knative-serving
```

Label the ns if you don't want the wildcard cert:
```shell
kubectl label ns <change-me> networking.knative.dev/disableWildcardCert=true
```


Refer to: 
1. https://cert-manager.io/docs/configuration/acme/dns01/
2. https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/
3. https://knative.dev/docs/serving/encryption/configure-certmanager-integration/
4. https://knative.dev/docs/serving/encryption/external-domain-tls/

## Verify the Knative Service

```shell
kubectl create namespace test03

kn service create hello \
  --image ghcr.io/knative/helloworld-go:latest \
  --port 8080 \
  --env TARGET=World \
  -n test03
```

## Install Knative Eventing

### Download the Knative Eventing CRDs

```shell
curl -L --output-dir ./eventing -O https://github.com/knative/eventing/releases/download/knative-v1.20.0/eventing-crds.yaml
```

### Download the Knative Eventing Core

```shell
curl -L --output-dir ./eventing -O https://github.com/knative/eventing/releases/download/knative-v1.20.0/eventing-core.yaml
```

### Install Knative Eventing
```shell
kubectl apply -f ./eventing/eventing-crds.yaml
```

```shell
kubectl apply -f ./eventing/eventing-core.yaml
```

### Install Knative Eventing Kafka Broker

Controller plane:
```shell
curl -L --output-dir ./eventing -O https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.20.1/eventing-kafka-controller.yaml
```

```shell
kubectl apply -f ./eventing/eventing-kafka-controller.yaml
```

Data plane:
```shell
curl -L --output-dir ./eventing -O https://github.com/knative-extensions/eventing-kafka-broker/releases/download/knative-v1.20.1/eventing-kafka-broker.yaml
```

```shell
kubectl apply -f ./eventing/eventing-kafka-broker.yaml
```

# References
* https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/