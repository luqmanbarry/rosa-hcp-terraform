# global-cluster-pull-secret

This module merges extra registry credentials into the global cluster pull secret.

The extra pull secret data should come from an `ExternalSecret` in the same values file.

Use:

- `imageRegistry.globalPullSecret.target_secret_name` for the Secret name the CronJob reads
- `imageRegistry.globalPullSecret.externalSecrets` for the `ExternalSecret` resources that create that Secret

This chart keeps its `ExternalSecret` manifests in `templates/external-secrets.yaml`.

That file includes a default AWS Secrets Manager example and notes for the other supported provider patterns.
