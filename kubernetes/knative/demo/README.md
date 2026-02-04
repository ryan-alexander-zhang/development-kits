## Create Namespace and Label it
```shell
kubectl create ns test06
kubectl label ns test07 eventing.knative.dev/injection=enabled --overwrite
```

## Create Event Display Knative Service to Debug
```shell
kn service create event-display -n test07 --image gcr.io/knative-releases/knative.dev/eventing/cmd/event_display
```

## Create Trigger
The ksvc sink:
```shell
kn trigger create test-trigger-01 -n test06 --sink ksvc:event-display:test06 
```

The uri sink:
```shell
# URL
kn trigger create url-trigger-01 -n test06 --sink https://hello.test03.staging-ali.hiverun.io
```

## Create PingSource
```shell
kn source ping create test-ping-source-01 -n test06 -d '{"message":"tick from PingSource"}' -s broker:default --schedule '*/2 * * * *'
```


## Cleanup
Clear resource:
```shell
kn source ping delete test-ping-source-01 -n test06
kn trigger delete test-trigger-01 -n test06
kn service delete event-display -n test06
```