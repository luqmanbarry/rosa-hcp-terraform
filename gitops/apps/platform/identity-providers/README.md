# identity-providers

Configures cluster OAuth identity providers.

## Safety

The chart renders nothing unless `oauth.identityProviders` is populated.

## Supported Shapes

- OpenID
- LDAP

## Use

Supply real provider definitions and referenced secrets through stack-owned GitOps values.
