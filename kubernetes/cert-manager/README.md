# Helm

## Directly

```shell
helm install \
  cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version v1.19.2 \
  --namespace infra-cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

## Result
```shell
Pulled: quay.io/jetstack/charts/cert-manager:v1.19.2
Digest: sha256:6f7f2d9065fdecb25ae5b1124169cdf0e94092931e2f43f46db8b06a29432b94
NAME: cert-manager
LAST DEPLOYED: Thu Jan  8 17:41:11 2026
NAMESPACE: infra-cert-manager
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
⚠️  WARNING: New default private key rotation policy for Certificate resources.
The default private key rotation policy for Certificate resources was
changed to `Always` in cert-manager >= v1.18.0.
Learn more in the [1.18 release notes](https://cert-manager.io/docs/releases/release-notes/release-notes-1.18).

cert-manager v1.19.2 has been deployed successfully!

In order to begin issuing certificates, you will need to set up a ClusterIssuer
or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).

More information on the different types of issuers and how to configure them
can be found in our documentation:

https://cert-manager.io/docs/configuration/

For information on how to configure cert-manager to automatically provision
Certificates for Ingress resources, take a look at the `ingress-shim`
documentation:

https://cert-manager.io/docs/usage/ingress/
```