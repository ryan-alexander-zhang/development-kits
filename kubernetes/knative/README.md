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

## Configure Knative Eventing

### Configure kafka-broker-config

> [!info] Configure How to Connect with Kafka Cluster

```yaml
apiVersion: v1
data:
  bootstrap.servers: my-cluster-kafka-bootstrap.kafka:9092
  default.topic.partitions: "10"
  default.topic.replication.factor: "3"
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/version: 1.20.1
  name: kafka-broker-config
  namespace: knative-eventing
```

### Configure config-br-defaults

> [!info] Default Configuration of Broker

```yaml
apiVersion: v1
data:
  default-br-config: |
    clusterDefault:
      brokerClass: MTChannelBasedBroker
      apiVersion: v1
      kind: ConfigMap
      name: config-br-default-channel
      namespace: knative-eventing
      delivery:
        retry: 10
        backoffPolicy: exponential
        backoffDelay: PT0.2S
kind: ConfigMap
metadata:
  annotations: {}
  labels:
    app.kubernetes.io/name: knative-eventing
    app.kubernetes.io/version: 1.20.0
  name: config-br-defaults
  namespace: knative-eventing
```

Can use `KafkaBroker` class to replace the `MTChannelBasedBroker`. And you need to change the ConfigMap to refer to the `kafka-borker-config`.
WARNING: The document used the `KafkaBroker`. But it's the `Kafka` actually. And if you use the Kafka Broker, there's no need to use the default channel config.

```yaml
apiVersion: v1
data:
  default-br-config: |
    clusterDefault:
      brokerClass: Kafka
      apiVersion: v1
      kind: ConfigMap
      name: kafka-broker-config
      namespace: knative-eventing
      delivery:
        retry: 10
        backoffPolicy: exponential
        backoffDelay: PT1S
kind: ConfigMap
```

### Configure sugar

Create the broker if the namespace has the label.

```yaml
apiVersion: v1
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################
    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the data block
    # to actually change the configuration.

    # namespace-selector specifies a LabelSelector which
    # determines which namespaces the Sugar Controller should operate upon
    # Use an empty value to disable the feature (this is the default):
    namespace-selector: ""

    # Use an empty object as a string to enable for all namespaces
    namespace-selector: "{}"

    # trigger-selector specifies a LabelSelector which
    # determines which triggers the Sugar Controller should operate upon
    # Use an empty value to disable the feature (this is the default):
    trigger-selector: ""

    # Use an empty object as string to enable for all triggers
    trigger-selector: "{}"
  namespace-selector: |
    matchExpressions:
    - key: "eventing.knative.dev/injection"
      operator: "In"
      values: ["enabled"]
kind: ConfigMap
metadata:
  annotations:
    knative.dev/example-checksum: 62dfac6f
  labels:
    app.kubernetes.io/name: knative-eventing
    app.kubernetes.io/version: 1.20.0
  name: config-sugar
  namespace: knative-eventing
```

Manually trigger:

```sh
kubectl label ns tenant-a eventing.knative.dev/injection=enabled --overwrite
```

### Configure Namespaced Kafka Broker

```yaml
apiVersion: eventing.knative.dev/v1
kind: Broker
metadata:
  name: default
  namespace: tenant-a
  annotations:
    eventing.knative.dev/broker.class: KafkaNamespaced  # 大小写敏感
spec:
  config:
    apiVersion: v1
    kind: ConfigMap
    name: kafka-broker-config
    # namespace: tenant-a  # 省略，默认就是 Broker 的 namespace
```

这里有个问题：必须创建一个 kafka-broker-config 到 Broker 的 Namespace 中，如果使用数据面隔离就不能复用 `knative-eventing` namespace 下的 `kafka-broker-config`。


Refer to the blog：[Knative Apache Kafka Broker with Isolated Data Plane - Knative](https://knative.dev/blog/articles/kafka-broker-with-isolated-data-plane/#isolated-data-plane)



# References
* https://knative.dev/docs/install/yaml-install/serving/install-serving-with-yaml/

