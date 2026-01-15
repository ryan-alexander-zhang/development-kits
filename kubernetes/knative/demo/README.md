```shell
kubectl create ns test06
kubectl label ns test06 eventing.knative.dev/injection=enabled --overwrite
```

```shell
kn service create event-display -n test06 --image gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
```

```shell
kn trigger create test-trigger-01 -n test06 --sink ksvc:event-display:test06 
```

```shell
kn source ping create test-ping-source-01 -n test06 -d '{"message":"tick from PingSource"}' -s broker:default
```

Clear resource:
```shell
kn source ping delete test-ping-source-01 -n test06
kn trigger delete test-trigger-01 -n test06
kn service delete event-display -n test06
```


```shell
kubectl logs -n knative-eventing deploy/kafka-broker-receiver --tail=200 -f
```