#!/bin/zsh

# CONFIGURATION
CLUSTER_NAME="macos-k8s"
DEFAULT_TTL_MINUTES=60
NOTIFY_CMD="osascript -e 'display notification \"$1\" with title \"Kubernetes Cluster\"'"
DOCTL_PATH="$(which doctl)"

# STATE FILE
STATE_FILE="$HOME/.cluster_ttl"

# Create cluster
create_cluster() {
  local ttl_minutes=${1:-$DEFAULT_TTL_MINUTES}

  echo "Creating cluster '$CLUSTER_NAME' with TTL of $ttl_minutes minutes..."
  $DOCTL_PATH kubernetes cluster create $CLUSTER_NAME --count=1 --size=s-1vcpu-2gb --wait
  
  echo "Cluster created. Switching context..."
  $DOCTL_PATH kubernetes cluster kubeconfig save $CLUSTER_NAME

  # Schedule deletion
  schedule_deletion $ttl_minutes

  echo "Cluster scheduled for deletion in $ttl_minutes minutes."
}

# Schedule deletion with background process
schedule_deletion() {
  local ttl_minutes=$1
  local ttl_seconds=$((ttl_minutes * 60))
  local notify_10=$((ttl_seconds - 600))
  local notify_5=$((ttl_seconds - 300))

  echo $ttl_seconds > $STATE_FILE

  (
    sleep $notify_10 && eval $NOTIFY_CMD "Cluster will be deleted in 10 minutes" &
    sleep $notify_5 && eval $NOTIFY_CMD "Cluster will be deleted in 5 minutes" &
    sleep $ttl_seconds && $DOCTL_PATH kubernetes cluster delete $CLUSTER_NAME --force &
  ) &
}

# Extend TTL
extend_ttl() {
  if [ ! -f "$STATE_FILE" ]; then
    echo "No cluster deletion scheduled."
    return 1
  fi

  local additional_minutes=$1
  local remaining_seconds=$(cat $STATE_FILE)
  local new_ttl_minutes=$(( (remaining_seconds / 60) + additional_minutes ))
  
  echo "Extending cluster lifetime by $additional_minutes minutes (new TTL: $new_ttl_minutes minutes)..."
  schedule_deletion $new_ttl_minutes
}

# Entrypoint
case "$1" in
  create)
    create_cluster $2
    ;;
  extend)
    if [ -z "$2" ]; then
      echo "Usage: cluster extend <minutes>"
      exit 1
    fi
    extend_ttl $2
    ;;
  *)
    echo "Usage: cluster create [minutes] | cluster extend <minutes>"
    ;;
esac
