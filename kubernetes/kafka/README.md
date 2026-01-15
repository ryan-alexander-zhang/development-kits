# Strimzi

## Download Strimzi Release
```shell
https://github.com/strimzi/strimzi-kafka-operator/releases
```

## Installing

### Update the namespace
```shell
sed -i '' 's/namespace: .*/namespace: infra-kafka/' strimzi-0.49.1/install/cluster-operator/*RoleBinding*.yaml
```

### Install the operator
```shell
kubectl create -f strimzi-0.49.1/install/cluster-operator -n infra-kafka
```

Check the status.
```shell
kubectl get deployments -n infra-kafka
```

### Install the Kafka Cluster

Three nodes:
```shell
kubectl apply -f strimzi-0.49.1/examples/kafka/kafka-persistent.yaml -n infra-kafka
```

Single node:
```shell
kubectl apply -f strimzi-0.49.1/examples/kafka/kafka-single-node.yaml -n infra-kafka
```

### TODO Configuration for Topic/User Operator