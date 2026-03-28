#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: run_cluster_workflow.sh --cluster-dir <path> --artifact-dir <path> --mode <validate|plan|apply> [--backend true|false]
EOF
}

CLUSTER_DIR=""
ARTIFACT_DIR=""
MODE=""
BACKEND="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cluster-dir)
      CLUSTER_DIR="${2:-}"
      shift 2
      ;;
    --artifact-dir)
      ARTIFACT_DIR="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --backend)
      BACKEND="${2:-}"
      shift 2
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$CLUSTER_DIR" || -z "$ARTIFACT_DIR" || -z "$MODE" ]]; then
  usage
  exit 2
fi

if [[ ! -d "$CLUSTER_DIR" ]]; then
  echo "cluster directory not found: $CLUSTER_DIR" >&2
  exit 1
fi

case "$MODE" in
  validate|plan|apply)
    ;;
  *)
    echo "unsupported mode: $MODE" >&2
    exit 1
    ;;
esac

scripts/check_required_ci_tools.sh bash git jq python3 terraform helm rg oc

mkdir -p "$ARTIFACT_DIR"

python3 scripts/validate_stack_inputs.py \
  --cluster "$CLUSTER_DIR/cluster.yaml" \
  --gitops-values "$CLUSTER_DIR/gitops.yaml"

python3 scripts/render_effective_config.py \
  --cluster "$CLUSTER_DIR/cluster.yaml" \
  --gitops-values "$CLUSTER_DIR/gitops.yaml" \
  --output-dir "$ARTIFACT_DIR"

cp "$ARTIFACT_DIR/terraform.auto.tfvars.json" "$CLUSTER_DIR/terraform.auto.tfvars.json"

if [[ "$BACKEND" == "true" ]]; then
  terraform -chdir="$CLUSTER_DIR" init
else
  terraform -chdir="$CLUSTER_DIR" init -backend=false
fi

terraform -chdir="$CLUSTER_DIR" validate

case "$MODE" in
  validate)
    ;;
  plan)
    terraform -chdir="$CLUSTER_DIR" plan -out=tfplan
    terraform -chdir="$CLUSTER_DIR" show -json tfplan > "$ARTIFACT_DIR/terraform-plan.json"
    terraform -chdir="$CLUSTER_DIR" show -no-color tfplan > "$ARTIFACT_DIR/terraform-plan.txt"
    ;;
  apply)
    terraform -chdir="$CLUSTER_DIR" plan -out=tfplan
    terraform -chdir="$CLUSTER_DIR" show -json tfplan > "$ARTIFACT_DIR/terraform-plan.json"
    terraform -chdir="$CLUSTER_DIR" show -no-color tfplan > "$ARTIFACT_DIR/terraform-plan.txt"
    terraform -chdir="$CLUSTER_DIR" apply -auto-approve tfplan
    terraform -chdir="$CLUSTER_DIR" output -json > "$ARTIFACT_DIR/terraform-outputs.json"
    ;;
esac
