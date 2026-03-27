#!/usr/bin/env python3

import argparse
from pathlib import Path
import re
import sys

import yaml


def load_yaml(path):
    with open(path, "r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle)
    if data is None:
        return {}
    if not isinstance(data, dict):
        raise ValueError(f"{path} must contain a YAML mapping at the top level")
    return data


def expect_keys(data, required_keys, context):
    missing = [key for key in required_keys if key not in data]
    if missing:
        raise ValueError(f"{context} missing required keys: {', '.join(missing)}")


def expect_type(value, expected_type, context):
    if not isinstance(value, expected_type):
        expected = (
            expected_type.__name__
            if isinstance(expected_type, type)
            else "/".join(t.__name__ for t in expected_type)
        )
        raise ValueError(f"{context} must be of type {expected}")


def expect_non_empty_string(value, context):
    expect_type(value, str, context)
    if not value.strip():
        raise ValueError(f"{context} must not be empty")


def expect_bool(value, context):
    expect_type(value, bool, context)


def expect_string_map(value, context):
    expect_type(value, dict, context)
    for key, item in value.items():
        expect_non_empty_string(key, f"{context} key")
        expect_type(item, str, f"{context}[{key}]")


def expect_string_int_map(value, context):
    expect_type(value, dict, context)
    for key, item in value.items():
        expect_non_empty_string(key, f"{context} key")
        if not isinstance(item, (str, int)):
            raise ValueError(f"{context}[{key}] must be a string or integer")


def validate_business_metadata(business_metadata, context):
    expect_type(business_metadata, dict, context)
    expect_keys(
        business_metadata,
        ["owner", "cost_center", "compliance_tier"],
        context,
    )
    for key in ["owner", "cost_center", "compliance_tier"]:
        expect_non_empty_string(business_metadata[key], f"{context}.{key}")


def validate_network(network, context):
    expect_type(network, dict, context)
    expect_keys(network, ["vpc_lookup_tag", "base_dns_domain"], context)
    expect_non_empty_string(network["vpc_lookup_tag"], f"{context}.vpc_lookup_tag")
    expect_non_empty_string(network["base_dns_domain"], f"{context}.base_dns_domain")


def validate_acm(acm, context):
    expect_type(acm, dict, context)
    expect_keys(acm, ["hub_cluster_name", "labels"], context)
    expect_non_empty_string(acm["hub_cluster_name"], f"{context}.hub_cluster_name")
    expect_string_map(acm["labels"], f"{context}.labels")


def validate_machine_pools(machine_pools, context):
    expect_type(machine_pools, list, context)
    seen_names = set()
    for index, pool in enumerate(machine_pools):
        pool_context = f"{context}[{index}]"
        expect_type(pool, dict, pool_context)
        expect_keys(
            pool,
            ["name", "profile", "replicas", "autoscaling"],
            pool_context,
        )
        expect_non_empty_string(pool["name"], f"{pool_context}.name")
        expect_non_empty_string(pool["profile"], f"{pool_context}.profile")
        expect_type(pool["replicas"], int, f"{pool_context}.replicas")
        if pool["replicas"] < 0:
            raise ValueError(f"{pool_context}.replicas must be greater than or equal to 0")
        if pool["name"] in seen_names:
            raise ValueError(f"{pool_context}.name duplicates another machine pool")
        seen_names.add(pool["name"])

        if "instance_type" in pool:
            expect_non_empty_string(pool["instance_type"], f"{pool_context}.instance_type")
        if "labels" in pool:
            expect_string_map(pool["labels"], f"{pool_context}.labels")

        autoscaling = pool["autoscaling"]
        expect_type(autoscaling, dict, f"{pool_context}.autoscaling")
        expect_keys(
            autoscaling,
            ["enabled", "min_replicas", "max_replicas"],
            f"{pool_context}.autoscaling",
        )
        expect_bool(autoscaling["enabled"], f"{pool_context}.autoscaling.enabled")
        expect_type(
            autoscaling["min_replicas"],
            int,
            f"{pool_context}.autoscaling.min_replicas",
        )
        expect_type(
            autoscaling["max_replicas"],
            int,
            f"{pool_context}.autoscaling.max_replicas",
        )
        if autoscaling["min_replicas"] < 0 or autoscaling["max_replicas"] < 0:
            raise ValueError(
                f"{pool_context}.autoscaling min/max replicas must be greater than or equal to 0"
            )
        if autoscaling["min_replicas"] > autoscaling["max_replicas"]:
            raise ValueError(
                f"{pool_context}.autoscaling min_replicas must be less than or equal to max_replicas"
            )
        if autoscaling["enabled"] and not (
            autoscaling["min_replicas"] <= pool["replicas"] <= autoscaling["max_replicas"]
        ):
            raise ValueError(
                f"{pool_context}.replicas must fall within autoscaling min/max when autoscaling is enabled"
            )


def validate_gitops_config(gitops, overlays_root, context):
    expect_type(gitops, dict, context)
    expect_keys(
        gitops,
        ["overlay", "repository_url", "target_revision"],
        context,
    )
    expect_non_empty_string(gitops["overlay"], f"{context}.overlay")
    expect_non_empty_string(gitops["repository_url"], f"{context}.repository_url")
    expect_non_empty_string(gitops["target_revision"], f"{context}.target_revision")

    if not re.match(r"^(https://|ssh://|git@)", gitops["repository_url"]):
        raise ValueError(
            f"{context}.repository_url must be an HTTPS, SSH, or git@ URL"
        )

    overlay_path = overlays_root / gitops["overlay"]
    if not overlay_path.exists():
        raise ValueError(f"{context}.overlay does not exist under {overlays_root}")

    if "root_app_path" in gitops:
        expect_non_empty_string(gitops["root_app_path"], f"{context}.root_app_path")
        if not gitops["root_app_path"].startswith("gitops/overlays/"):
            raise ValueError(
                f"{context}.root_app_path must start with gitops/overlays/"
            )


def validate_resource_quota(resource_quota, context):
    expect_type(resource_quota, dict, context)
    expect_keys(resource_quota, ["hard"], context)
    expect_string_int_map(resource_quota["hard"], f"{context}.hard")
    if "name" in resource_quota:
        expect_non_empty_string(resource_quota["name"], f"{context}.name")


def validate_limit_range(limit_range, context):
    expect_type(limit_range, dict, context)
    expect_keys(limit_range, ["limits"], context)
    expect_type(limit_range["limits"], list, f"{context}.limits")
    if not limit_range["limits"]:
        raise ValueError(f"{context}.limits must not be empty")
    for index, item in enumerate(limit_range["limits"]):
        item_context = f"{context}.limits[{index}]"
        expect_type(item, dict, item_context)
        expect_non_empty_string(item.get("type", ""), f"{item_context}.type")
    if "name" in limit_range:
        expect_non_empty_string(limit_range["name"], f"{context}.name")


def validate_network_policy_defaults(network_policies, context):
    expect_type(network_policies, dict, context)
    allowed_keys = {
        "defaultDenyIngress",
        "defaultDenyEgress",
        "allowSameNamespaceIngress",
        "allowSameNamespaceEgress",
        "allowClusterDNS",
    }
    for key, value in network_policies.items():
        if key not in allowed_keys:
            raise ValueError(f"{context}.{key} is not a supported network policy toggle")
        expect_bool(value, f"{context}.{key}")


def validate_role_binding_subjects(subjects, context):
    expect_type(subjects, list, context)
    if not subjects:
        raise ValueError(f"{context} must not be empty")
    for index, subject in enumerate(subjects):
        subject_context = f"{context}[{index}]"
        expect_type(subject, dict, subject_context)
        expect_non_empty_string(subject.get("kind", ""), f"{subject_context}.kind")
        expect_non_empty_string(subject.get("name", ""), f"{subject_context}.name")


def validate_role_binding(binding, context):
    expect_type(binding, dict, context)
    expect_non_empty_string(binding.get("role", ""), f"{context}.role")
    if "name" in binding:
        expect_non_empty_string(binding["name"], f"{context}.name")

    subject_modes = 0
    if "group" in binding:
        expect_non_empty_string(binding["group"], f"{context}.group")
        subject_modes += 1
    if "serviceAccount" in binding:
        expect_type(binding["serviceAccount"], dict, f"{context}.serviceAccount")
        expect_non_empty_string(
            binding["serviceAccount"].get("name", ""),
            f"{context}.serviceAccount.name",
        )
        if "namespace" in binding["serviceAccount"]:
            expect_non_empty_string(
                binding["serviceAccount"]["namespace"],
                f"{context}.serviceAccount.namespace",
            )
        subject_modes += 1
    if "subjects" in binding:
        validate_role_binding_subjects(binding["subjects"], f"{context}.subjects")
        subject_modes += 1

    if subject_modes != 1:
        raise ValueError(
            f"{context} must define exactly one of group, serviceAccount, or subjects"
        )


def validate_namespace_onboarding_values(values, context):
    expect_type(values, dict, context)
    if "namespaces" in values:
        expect_type(values["namespaces"], list, f"{context}.namespaces")
        seen_names = set()
        for index, namespace in enumerate(values["namespaces"]):
            ns_context = f"{context}.namespaces[{index}]"
            expect_type(namespace, dict, ns_context)
            expect_non_empty_string(namespace.get("name", ""), f"{ns_context}.name")
            if namespace["name"] in seen_names:
                raise ValueError(f"{ns_context}.name duplicates another namespace")
            seen_names.add(namespace["name"])
            for key in ["displayName", "description", "nodeSelector"]:
                if key in namespace:
                    expect_non_empty_string(namespace[key], f"{ns_context}.{key}")
            if "labels" in namespace:
                expect_string_map(namespace["labels"], f"{ns_context}.labels")
            if "annotations" in namespace:
                expect_string_map(namespace["annotations"], f"{ns_context}.annotations")
            if "resourceQuota" in namespace:
                validate_resource_quota(namespace["resourceQuota"], f"{ns_context}.resourceQuota")
            if "limitRange" in namespace:
                validate_limit_range(namespace["limitRange"], f"{ns_context}.limitRange")
            if "networkPolicies" in namespace:
                validate_network_policy_defaults(
                    namespace["networkPolicies"], f"{ns_context}.networkPolicies"
                )
            if "roleBindings" in namespace:
                expect_type(namespace["roleBindings"], list, f"{ns_context}.roleBindings")
                for binding_index, binding in enumerate(namespace["roleBindings"]):
                    validate_role_binding(
                        binding,
                        f"{ns_context}.roleBindings[{binding_index}]",
                    )

    if "projectRequestTemplate" in values:
        template = values["projectRequestTemplate"]
        expect_type(template, dict, f"{context}.projectRequestTemplate")
        if "enabled" in template:
            expect_bool(template["enabled"], f"{context}.projectRequestTemplate.enabled")
        if "name" in template:
            expect_non_empty_string(template["name"], f"{context}.projectRequestTemplate.name")
        if "labels" in template:
            expect_string_map(template["labels"], f"{context}.projectRequestTemplate.labels")
        if "annotations" in template:
            expect_string_map(
                template["annotations"],
                f"{context}.projectRequestTemplate.annotations",
            )
        if "resourceQuota" in template and template["resourceQuota"]:
            validate_resource_quota(
                template["resourceQuota"],
                f"{context}.projectRequestTemplate.resourceQuota",
            )
        if "limitRange" in template and template["limitRange"]:
            validate_limit_range(
                template["limitRange"],
                f"{context}.projectRequestTemplate.limitRange",
            )
        if "networkPolicies" in template:
            validate_network_policy_defaults(
                template["networkPolicies"],
                f"{context}.projectRequestTemplate.networkPolicies",
            )


def validate_self_provisioner_values(values, context):
    expect_type(values, dict, context)
    if "disableSelfProvisioner" in values:
        expect_bool(values["disableSelfProvisioner"], f"{context}.disableSelfProvisioner")
    if "clusterAdminEmail" in values:
        expect_non_empty_string(values["clusterAdminEmail"], f"{context}.clusterAdminEmail")
    if "projectRequestTemplateName" in values and values["projectRequestTemplateName"] != "":
        expect_non_empty_string(
            values["projectRequestTemplateName"],
            f"{context}.projectRequestTemplateName",
        )


def validate_app_values(app_path, values, context):
    if app_path == "gitops/apps/platform/namespace-onboarding":
        validate_namespace_onboarding_values(values, context)
    if app_path == "gitops/apps/platform/self-provisioner":
        validate_self_provisioner_values(values, context)


def validate_cluster(cluster, overlays_root):
    expect_keys(
        cluster,
        [
            "cluster_name",
            "class_name",
            "aws_region",
            "business_metadata",
            "network",
            "acm",
            "gitops",
        ],
        "cluster.yaml",
    )

    for key in ["cluster_name", "class_name", "aws_region"]:
        expect_non_empty_string(cluster[key], f"cluster.yaml.{key}")

    validate_business_metadata(cluster["business_metadata"], "cluster.yaml.business_metadata")
    validate_network(cluster["network"], "cluster.yaml.network")
    validate_acm(cluster["acm"], "cluster.yaml.acm")
    validate_gitops_config(cluster["gitops"], overlays_root, "cluster.yaml.gitops")

    if "private_cluster" in cluster:
        expect_bool(cluster["private_cluster"], "cluster.yaml.private_cluster")
    if "multi_az" in cluster:
        expect_bool(cluster["multi_az"], "cluster.yaml.multi_az")
    if "machine_pools" in cluster:
        validate_machine_pools(cluster["machine_pools"], "cluster.yaml.machine_pools")


def validate_cluster_class(cluster_class, class_path, overlays_root):
    context = class_path.name
    expect_keys(
        cluster_class,
        [
            "class_name",
            "environment",
            "openshift_version",
            "private_cluster",
            "multi_az",
            "enable_acm_registration",
            "enable_gitops_bootstrap",
            "machine_pools",
        ],
        context,
    )
    expected_class_name = class_path.stem
    expect_non_empty_string(cluster_class["class_name"], f"{context}.class_name")
    if cluster_class["class_name"] != expected_class_name:
        raise ValueError(
            f"{context}.class_name must match filename stem {expected_class_name}"
        )
    expect_non_empty_string(cluster_class["environment"], f"{context}.environment")
    expect_non_empty_string(cluster_class["openshift_version"], f"{context}.openshift_version")
    expect_bool(cluster_class["private_cluster"], f"{context}.private_cluster")
    expect_bool(cluster_class["multi_az"], f"{context}.multi_az")
    expect_bool(
        cluster_class["enable_acm_registration"],
        f"{context}.enable_acm_registration",
    )
    expect_bool(
        cluster_class["enable_gitops_bootstrap"],
        f"{context}.enable_gitops_bootstrap",
    )
    validate_machine_pools(cluster_class["machine_pools"], f"{context}.machine_pools")


def validate_gitops(gitops, repo_root):
    expect_keys(gitops, ["applications"], "gitops.yaml")
    expect_type(gitops["applications"], list, "gitops.yaml.applications")

    seen_names = set()
    for index, app in enumerate(gitops["applications"]):
        context = f"gitops.yaml.applications[{index}]"
        expect_type(app, dict, context)
        expect_keys(app, ["name", "namespace", "syncWave"], context)

        for key in ["name", "namespace", "syncWave"]:
            expect_non_empty_string(app[key], f"{context}.{key}")
        if "enabled" in app:
            expect_bool(app["enabled"], f"{context}.enabled")

        if app["name"] in seen_names:
            raise ValueError(f"{context}.name duplicates another application")
        seen_names.add(app["name"])

        has_path = "path" in app
        has_chart = "chart" in app
        if has_path == has_chart:
            raise ValueError(f"{context} must define exactly one of path or chart")

        if has_path:
            expect_non_empty_string(app["path"], f"{context}.path")
            if not app["path"].startswith("gitops/apps/"):
                raise ValueError(f"{context}.path must start with gitops/apps/: {app['path']}")

            chart_path = repo_root / app["path"]
            if not chart_path.exists():
                raise ValueError(f"{context}.path does not exist: {app['path']}")
            if not (chart_path / "Chart.yaml").exists():
                raise ValueError(f"{context}.path is missing Chart.yaml: {app['path']}")
            if "valueFiles" in app:
                expect_type(app["valueFiles"], list, f"{context}.valueFiles")
                if not app["valueFiles"]:
                    raise ValueError(f"{context}.valueFiles must not be empty when set")
                for value_file_index, value_file in enumerate(app["valueFiles"]):
                    value_file_context = f"{context}.valueFiles[{value_file_index}]"
                    expect_non_empty_string(value_file, value_file_context)
                    value_file_path = repo_root / value_file
                    if not value_file_path.exists():
                        raise ValueError(f"{value_file_context} does not exist: {value_file}")
                    parsed_file_values = load_yaml(value_file_path)
                    validate_app_values(app["path"], parsed_file_values, value_file_context)
        else:
            expect_non_empty_string(app["chart"], f"{context}.chart")
            expect_non_empty_string(app.get("repoURL", ""), f"{context}.repoURL")
            expect_non_empty_string(app.get("targetRevision", ""), f"{context}.targetRevision")
            if not re.match(r"^https://", app["repoURL"]):
                raise ValueError(f"{context}.repoURL must be an HTTPS URL")
            if "valueFiles" in app:
                expect_type(app["valueFiles"], list, f"{context}.valueFiles")
                if not app["valueFiles"]:
                    raise ValueError(f"{context}.valueFiles must not be empty when set")
                for value_file_index, value_file in enumerate(app["valueFiles"]):
                    value_file_context = f"{context}.valueFiles[{value_file_index}]"
                    expect_non_empty_string(value_file, value_file_context)
                    value_file_path = repo_root / value_file
                    if not value_file_path.exists():
                        raise ValueError(f"{value_file_context} does not exist: {value_file}")
                    parsed_file_values = load_yaml(value_file_path)
                    if not isinstance(parsed_file_values, dict):
                        raise ValueError(
                            f"{value_file_context} must contain a YAML mapping at the top level"
                        )

        try:
            int(app["syncWave"])
        except ValueError as exc:
            raise ValueError(f"{context}.syncWave must be numeric text") from exc

        if "helmValues" in app:
            if not isinstance(app["helmValues"], str):
                raise ValueError(f"{context}.helmValues must be a YAML string block")
            parsed_values = yaml.safe_load(app["helmValues"]) if app["helmValues"].strip() else {}
            if parsed_values is None:
                parsed_values = {}
            if not isinstance(parsed_values, dict):
                raise ValueError(f"{context}.helmValues must decode to a YAML mapping")
            app_path = app.get("path", "")
            validate_app_values(app_path, parsed_values, f"{context}.helmValues")


def main():
    parser = argparse.ArgumentParser(description="Validate stack-owned cluster and gitops inputs.")
    parser.add_argument("--cluster", required=True, help="Path to cluster.yaml")
    parser.add_argument("--gitops-values", required=True, help="Path to gitops.yaml")
    parser.add_argument(
        "--catalog-root",
        default="catalog/cluster-classes",
        help="Path to cluster class catalog",
    )
    parser.add_argument(
        "--overlays-root",
        default="gitops/overlays",
        help="Path to GitOps overlay charts",
    )
    args = parser.parse_args()

    cluster_path = Path(args.cluster)
    gitops_path = Path(args.gitops_values)
    catalog_root = Path(args.catalog_root)
    overlays_root = Path(args.overlays_root)
    repo_root = Path(__file__).resolve().parent.parent

    if not cluster_path.exists():
        raise FileNotFoundError(f"cluster file not found: {cluster_path}")
    if not gitops_path.exists():
        raise FileNotFoundError(f"gitops file not found: {gitops_path}")
    if not catalog_root.exists():
        raise FileNotFoundError(f"catalog root not found: {catalog_root}")
    if not overlays_root.exists():
        raise FileNotFoundError(f"overlays root not found: {overlays_root}")

    cluster = load_yaml(cluster_path)
    gitops = load_yaml(gitops_path)

    class_name = cluster.get("class_name", "")
    class_path = catalog_root / f"{class_name}.yaml"
    if not class_path.exists():
        raise FileNotFoundError(f"cluster class not found: {class_path}")
    cluster_class = load_yaml(class_path)

    validate_cluster_class(cluster_class, class_path, overlays_root)
    validate_cluster(cluster, overlays_root)
    validate_gitops(gitops, repo_root)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover
        print(f"validation failed: {exc}", file=sys.stderr)
        raise
