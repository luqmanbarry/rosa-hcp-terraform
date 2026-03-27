# identity-providers

Configures cluster OAuth identity providers.

## Safety

The chart renders nothing unless `oauth.identityProviders` is populated.

## Supported Shapes

- OpenID
- LDAP

## Use

Supply real provider definitions through the cluster values file.

If a provider needs a Kubernetes `Secret`, define the matching `ExternalSecret` in the same values file under `externalSecrets`.
