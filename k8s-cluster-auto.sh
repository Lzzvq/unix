#!/bin/bash#!/bin/bash

# I was having trouble with the osascript notifications until I went into script editor, then ran the display notification command there. Once I did that and allowed notifications from the apps, notifications seem to be working

set -euo pipefail

CLUSTER_NAME="my-cluster"
REGION="nyc3"
NODE_SIZE="s-1vcpu-2gb"
NODE_COUNT=1

create_cluster() {
    echo "Creating cluster $CLUSTER_NAME..."
    doctl kubernetes cluster create "$CLUSTER_NAME" --region "$REGION" --size "$NODE_SIZE" --count "$NODE_COUNT"
    
    echo "Updating kubeconfig..."
    doctl kubernetes cluster kubeconfig save "$CLUSTER_NAME"
    
    echo "Cluster created and kubeconfig updated."

    if [[ -n "${1:-}" ]]; then
        auto_sleep_after "$1"
    fi
}

destroy_cluster() {
    echo "Destroying cluster $CLUSTER_NAME..."
    doctl kubernetes cluster delete "$CLUSTER_NAME" --force

    echo "Cleaning kubeconfig..."
    kubectl config delete-cluster "do-$REGION-$CLUSTER_NAME" || true
    kubectl config delete-context "do-$REGION-$CLUSTER_NAME" || true
    kubectl config delete-user "do-$REGION-$CLUSTER_NAME" || true

    echo "Cluster destroyed and kubeconfig cleaned."
}

auto_sleep_after() {
    MINUTES="$1"

    echo "Auto-sleep scheduled: destroy in $MINUTES minutes."

    # Schedule delete
    echo "/Users/jimmycheney/Documents/Career/1000-hours/linux/k8s-cluster-auto.sh delete" | at now + "$MINUTES" minutes

    # Schedule warning 10 min before
    WARN_MINUTES=$(( MINUTES - 10 ))
    if (( WARN_MINUTES > 0 )); then
        echo "/usr/bin/osascript -e 'display notification \"K8s cluster \\\"$CLUSTER_NAME\\\" will be deleted in 10 minutes. Run \\\"cluster extend N\\\" to extend.\" with title \"K8s Auto-Sleep Warning\"'" | at now + "$WARN_MINUTES" minutes
    fi
}

extend_auto_sleep() {
    if [[ -z "${1:-}" ]]; then
        echo "Usage: cluster extend <minutes>"
        exit 1
    fi

    echo "Extending auto-sleep by $1 minutes..."
    auto_sleep_after "$1"
}

# Main dispatch
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 {create|delete|sleep|extend} and a value greater than 11" 
    exit 1
fi

case "$1" in
    create)
        create_cluster "$2"
        ;;
    delete)
        destroy_cluster
        ;;
    sleep)
        auto_sleep_after "$2"
        ;;
    extend)
        extend_auto_sleep "$2"
        ;;
    *)
        echo "Invalid argument: $1"
        exit 1
        ;;
esac
