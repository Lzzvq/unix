#!/bin/bash
set -euo pipefail

CLUSTER_NAME="learning-cluster"
REGION="sfo2"
NODE_SIZE="s-1vcpu-2gb"
NODE_COUNT=1

create_cluster() {
    echo "Creating cluster $CLUSTER_NAME..."
    doctl kubernetes cluster create "$CLUSTER_NAME" --region "$REGION" --size "$NODE_SIZE" --count "$NODE_COUNT"
    
    echo "Updating kubeconfig..."
    doctl kubernetes cluster kubeconfig save "$CLUSTER_NAME"
    
    echo "Cluster created and kubeconfig updated."
}

delete_cluster() {
    echo "deleteing cluster $CLUSTER_NAME..."
    doctl kubernetes cluster delete "$CLUSTER_NAME" --force

    echo "Cleaning kubeconfig..."
    kubectl config delete-cluster "do-$REGION-$CLUSTER_NAME" || true
    kubectl config delete-context "do-$REGION-$CLUSTER_NAME" || true
    kubectl config delete-user "do-$REGION-$CLUSTER_NAME" || true

    echo "Cluster deleteed and kubeconfig cleaned."
}

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 {create|delete}"
    exit 1
fi

case "$1" in
    create)
        create_cluster
        ;;
    delete)
        delete_cluster
        ;;
    *)
        echo "Invalid argument: $1"
        echo "Usage: $0 {create|delete}"
        exit 1
        ;;
esac
