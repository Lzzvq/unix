#!/bin/zsh

# CONFIGURATION
CLUSTER_NAME="dev-cluster"
REGION="sfo3"
TTL_MINUTES=60
STATE_FILE="$HOME/.cluster-state"
WATCHER_PID_FILE="$HOME/.cluster-watcher.pid"

function notify() {
  osascript -e "display notification \"$1\" with title \"Cluster Manager\""
}

function stop_watcher() {
  if [[ -f "$WATCHER_PID_FILE" ]]; then
    kill $(cat "$WATCHER_PID_FILE") 2>/dev/null || true
    rm -f "$WATCHER_PID_FILE"
  fi
}

function watch_cluster_ttl() {
  local warned_10m=false
  local warned_5m=false

  while true; do
    [[ -f "$STATE_FILE" ]] || exit 0

    local current_time=$(date +%s)
    local delete_time=$(cat "$STATE_FILE")
    local remaining=$((delete_time - current_time))

    if (( remaining <= 0 )); then
      notify "Cluster is being destroyed"
      delete_cluster
      exit 0
    elif (( remaining <= 600 )) && [[ "$warned_10m" == false ]]; then
      notify "Cluster will be destroyed in 10 minutes."
      warned_10m=true
    elif (( remaining <= 300 )) && [[ "$warned_5m" == false ]]; then
      notify "Cluster will be destroyed in 5 minutes."
      warned_5m=true
    fi

    sleep 30
  done
}


function create_cluster() {
  echo "Creating Kubernetes cluster..."
  doctl kubernetes cluster create "$CLUSTER_NAME" --region "$REGION" --count 1 --size s-1vcpu-2gb --wait || return 1
  echo "Cluster created."

  notify "Cluster $CLUSTER_NAME has been created."

  local delete_time=$(($(date +%s) + TTL_MINUTES * 60))
  echo "$delete_time" > "$STATE_FILE"

  stop_watcher
  watch_cluster_ttl &
  echo $! > "$WATCHER_PID_FILE"
}

function delete_cluster() {
  echo "Destroying cluster..."

  echo "Checking for load balancers to delete..."
  lbs=$(doctl compute load-balancer list --format ID,Name --no-header | awk '{print $1}')
  for lb in $lbs; do
    echo "Deleting load balancer with ID: $lb"
    doctl compute load-balancer delete "$lb" --force
  done

  doctl kubernetes cluster delete "$CLUSTER_NAME" --force

  echo "Cleaning kubeconfig..."
  kubectl config delete-cluster "do-$REGION-$CLUSTER_NAME" || true
  kubectl config delete-context "do-$REGION-$CLUSTER_NAME" || true
  kubectl config delete-user "do-$REGION-$CLUSTER_NAME" || true

  echo "Cluster destroyed and kubeconfig cleaned."
  rm -f "$STATE_FILE"
  stop_watcher
}

function extend_cluster() {
  if [[ ! -f "$STATE_FILE" ]]; then
    echo "No active cluster to extend."
    exit 1
  fi

  local extend_minutes=$1
  local original_delete_time=$(cat "$STATE_FILE")
  local new_delete_time=$((original_delete_time + extend_minutes * 60))

  echo "$new_delete_time" > "$STATE_FILE"
  echo "Cluster extended by $extend_minutes minutes."

  stop_watcher
  watch_cluster_ttl &
  echo $! > "$WATCHER_PID_FILE"
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
