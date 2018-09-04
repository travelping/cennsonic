# Certificate Manager

To enable HTTPS on your HTTP service, you need to get a certificate from a
Certificate Authority (CA). The [Certificate Manager] automates process of
getting a certificate from [Let’s Encrypt].

## Installation

Installation depends on [Helm], please make sure it is installed.

Install:

```
$ helm install --name cert-manager --namespace cert-manager stable/cert-manager
```

<!-- Links -->

[Helm]: helm.md
[Let’s Encrypt]: https://letsencrypt.org/getting-started
[Certificate Manager]: https://cert-manager.readthedocs.io/en/latest/index.html
