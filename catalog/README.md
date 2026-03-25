# Catalog

The catalog holds reusable defaults that can be referenced by cluster instances in `stacks/`.

- `cluster-classes/`: approved cluster profiles such as `dev`, `qa`, `prod`, and `prod-dr`
- `machine-pool-classes/`: approved machine pool profiles reused by cluster classes or instances

These files are human-authored source input, not generated artifacts.

Use YAML for the catalog because it is easier for reviewers to read and edit in pull requests.
