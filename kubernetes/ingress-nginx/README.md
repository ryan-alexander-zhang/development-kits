# Helm

Check the version.

## Local
```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

helm pull ingress-nginx/ingress-nginx --version 4.14.1 --untar --destination ./

kubectl create namespace infra-ingress-nginx

helm install ingress-nginx ./ingress-nginx \
  --namespace infra-ingress-nginx \
  --create-namespace
```

## Directly

```shell
helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.14.1 -n infra-ingress-nginx
```

## Result

```shell
NAME: ingress-nginx
LAST DEPLOYED: Thu Jan  8 17:27:47 2026
NAMESPACE: infra-ingress-nginx
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The ingress-nginx controller has been installed.
It may take a few minutes for the load balancer IP to be available.
You can watch the status by running 'kubectl get service --namespace infra-ingress-nginx ingress-nginx-controller --output wide --watch'

An example Ingress that makes use of the controller:
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: example
    namespace: foo
  spec:
    ingressClassName: nginx
    rules:
      - host: www.example.com
        http:
          paths:
            - pathType: Prefix
              backend:
                service:
                  name: exampleService
                  port:
                    number: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
      - hosts:
        - www.example.com
        secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```


# References
* [ingress-nginx 4.14.1 · kubernetes/ingress-nginx](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx)
* [GitHub - kubernetes/ingress-nginx: Ingress NGINX Controller for Kubernetes](https://github.com/kubernetes/ingress-nginx)