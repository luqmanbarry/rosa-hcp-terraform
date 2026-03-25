#!/usr/bin/env python3

import argparse
import json
from pathlib import Path
import sys
import yaml


REQUIRED_CLUSTER_KEYS = [
    "cluster_name",
    "class_name",
    "aws_region",
    "network",
    "acm",
    "gitops",
]


def deep_merge(base, override):
    if isinstance(base, dict) and isinstance(override, dict):
        merged = dict(base)
        for key, value in override.items():
            if key in merged:
                merged[key] = deep_merge(merged[key], value)
            else:
                merged[key] = value
        return merged
    return override


def load_data(path):
    with open(path, "r", encoding="utf-8") as handle:
        suffix = path.suffix.lower()
        if suffix in [".yaml", ".yml"]:
            return yaml.safe_load(handle)
        if suffix == ".json":
            return json.load(handle)
        raise ValueError(f"unsupported input format: {path}")


def validate_cluster(cluster):
    missing = [key for key in REQUIRED_CLUSTER_KEYS if key not in cluster]
    if missing:
        raise ValueError(f"missing required cluster keys: {', '.join(missing)}")


def main():
    parser = argparse.ArgumentParser(
        description="Render effective cluster configuration from class and stack inputs."
    )
    parser.add_argument("--cluster", required=True, help="Path to cluster.yaml")
    parser.add_argument(
        "--gitops-values",
        default="",
        help="Optional path to stack-local gitops.yaml values",
    )
    parser.add_argument(
        "--catalog-root",
        default="catalog/cluster-classes",
        help="Path to cluster class catalog",
    )
    parser.add_argument(
        "--output-dir",
        required=True,
        help="Directory for generated artifacts",
    )
    args = parser.parse_args()

    cluster_path = Path(args.cluster)
    catalog_root = Path(args.catalog_root)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    cluster = load_data(cluster_path)
    validate_cluster(cluster)

    class_path = catalog_root / f"{cluster['class_name']}.yaml"
    if not class_path.exists():
        raise FileNotFoundError(f"cluster class not found: {class_path}")

    cluster_class = load_data(class_path)
    effective = deep_merge(cluster_class, cluster)
    effective["source"] = {
        "cluster_file": str(cluster_path),
        "class_file": str(class_path),
    }

    if args.gitops_values:
        gitops_values_path = Path(args.gitops_values)
        if gitops_values_path.exists():
            effective.setdefault("gitops", {})
            effective["gitops"]["values"] = load_data(gitops_values_path)
            effective["source"]["gitops_values_file"] = str(gitops_values_path)

    build_metadata = {
        "cluster_name": effective["cluster_name"],
        "class_name": effective["class_name"],
        "environment": effective.get("environment"),
        "openshift_version": effective.get("openshift_version"),
    }

    with open(output_dir / "effective-config.json", "w", encoding="utf-8") as handle:
        json.dump(effective, handle, indent=2, sort_keys=True)
        handle.write("\n")

    with open(output_dir / "build-metadata.json", "w", encoding="utf-8") as handle:
        json.dump(build_metadata, handle, indent=2, sort_keys=True)
        handle.write("\n")

    with open(output_dir / "terraform.auto.tfvars.json", "w", encoding="utf-8") as handle:
        json.dump(effective, handle, indent=2, sort_keys=True)
        handle.write("\n")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # pragma: no cover
        print(f"render failed: {exc}", file=sys.stderr)
        raise
