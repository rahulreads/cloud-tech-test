#!/bin/bash

set -euo pipefail  # Enable strict error handling

# Variables
DOCKER_IMAGE_REPO="${DOCKER_IMAGE_REPO:-your-docker-registry/data-service}"  # Replace with your Docker registry
DOCKER_IMAGE_TAG="${DOCKER_IMAGE_TAG:-latest}"
KUBECONFIG_PATH="${KUBECONFIG_PATH:-~/.kube/config}"
ANSIBLE_PLAYBOOK_PATH="${ANSIBLE_PLAYBOOK_PATH:-ansible/playbooks}"
DOCKERFILE_PATH="${DOCKERFILE_PATH:-.}"

# Functions
function build_docker_image() {
    echo "Building Docker image..."
    docker build -t "${DOCKER_IMAGE_REPO}:${DOCKER_IMAGE_TAG}" "${DOCKERFILE_PATH}"
    docker tag "${DOCKER_IMAGE_REPO}:${DOCKER_IMAGE_TAG}" "${DOCKER_IMAGE_REPO}:latest"
}

function push_docker_image() {
    echo "Pushing Docker image to registry..."
    docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}" "${DOCKER_IMAGE_REPO}"
    docker push "${DOCKER_IMAGE_REPO}:${DOCKER_IMAGE_TAG}"
    docker push "${DOCKER_IMAGE_REPO}:latest"
}

function configure_kubectl() {
    echo "Configuring kubectl..."
    if [ -n "${KUBECONFIG_CONTENT}" ]; then
        echo "${KUBECONFIG_CONTENT}" > "${KUBECONFIG_PATH}"
        chmod 600 "${KUBECONFIG_PATH}"
    fi
    kubectl get nodes  # Test connection to Kubernetes cluster
}

function install_metrics_server() {
    echo "Installing Metrics Server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    echo "Waiting for Metrics Server to become ready..."
    kubectl rollout status -n kube-system deployment/metrics-server
}

function deploy_with_helm() {
    echo "Deploying Helm charts using Ansible playbooks..."
    ansible-playbook "${ANSIBLE_PLAYBOOK_PATH}/deploy-backend-service.yaml"
    ansible-playbook "${ANSIBLE_PLAYBOOK_PATH}/deploy-data-service.yaml"
}

function run_health_check() {
    echo "Running health check script..."
    bash health_check.sh
}

function monitor_resources() {
    echo "Monitoring node and Pod resource utilization..."
    kubectl top nodes
    kubectl top pods --all-namespaces
}

function monitor_resources_with_label() {
    local label_selector="k8s-app=kube-Devops"
    echo "Displaying resource utilization for Pods with label '${label_selector}'..."
    kubectl top pods --all-namespaces --selector="${label_selector}"
}

# Main Execution
build_docker_image
push_docker_image
configure_kubectl
install_metrics_server
deploy_with_helm
run_health_check
monitor_resources
monitor_resources_with_label

echo "Deployment and monitoring completed successfully!"
