#!/bin/zsh

# CONFIGURATION
CLUSTER_NAME="auto-cluster"
REGION="sfo3"
TTL_MINUTES=60
STATE_FILE="$HOME/.cluster-state"

function notify() {
  osascript -e "display notification \"$1\" with title \"Cluster Manager\""
}

function create_cluster() {
  echo "Creating Kubernetes cluster..."
  doctl kubernetes cluster create "$CLUSTER_NAME" --region "$REGION" --count 1 --size s-1vcpu-2gb --wait || return 1
  echo "Cluster created."

  local delete_time=$(($(date +%s) + TTL_MINUTES * 60))
  echo "$delete_time" > "$STATE_FILE"

  ( sleep $((TTL_MINUTES * 60 - 600)); notify "Cluster will be destroyed in 10 minutes." ) &
  ( sleep $((TTL_MINUTES * 60 - 300)); notify "Cluster will be destroyed in 5 minutes." ) &
  ( sleep $((TTL_MINUTES * 60)); delete_cluster ) &
}

function delete_cluster() {
  echo "Destroying cluster..."
  doctl kubernetes cluster delete "$CLUSTER_NAME" --force

  echo "Cleaning kubeconfig..."
  kubectl config delete-cluster "do-$REGION-$CLUSTER_NAME" || true
  kubectl config delete-context "do-$REGION-$CLUSTER_NAME" || true
  kubectl config delete-user "do-$REGION-$CLUSTER_NAME" || true

  echo "Cluster destroyed and kubeconfig cleaned."
  rm -f "$STATE_FILE"
}

function extend_cluster() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "No active cluster to extend."
    exit 1
  fi

  local extend_minutes=$1
  local current_time=$(date +%s)
  local original_delete_time=$(cat "$STATE_FILE")
  local new_delete_time=$((original_delete_time + extend_minutes * 60))

  echo "$new_delete_time" > "$STATE_FILE"
  echo "Cluster extended by $extend_minutes minutes."

  ( sleep $((extend_minutes * 60 - 600)); notify "Extended cluster will be destroyed in 10 minutes." ) &
  ( sleep $((extend_minutes * 60 - 300)); notify "Extended cluster will be destroyed in 5 minutes." ) &
  ( sleep $((extend_minutes * 60)); delete_cluster ) &
}

case "$1" in
  create)
    TTL_MINUTES=${2:-60}
    create_cluster
    ;;
  delete)
    delete_cluster
    ;;
  extend)
    extend_cluster ${2:-30}
    ;;
  *)
    echo "Usage: cluster {create [minutes]|delete|extend [minutes]}"
    ;;
esac
