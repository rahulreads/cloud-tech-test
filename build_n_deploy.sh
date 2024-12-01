#!/bin/bash

set -euo pipefail  # Enable strict error handling
set -x

# Variables
DOCKER_IMAGE_BACKEND="${DOCKER_IMAGE_BACKEND:-europe-west2-docker.pkg.dev/my-app-361806/cloud-test/backend-service}"
DOCKER_IMAGE_DATA="${DOCKER_IMAGE_BACKEND:-europe-west2-docker.pkg.dev/my-app-361806/cloud-test/data-service}"

DOCKER_IMAGE_TAG_BACKEND="${DOCKER_IMAGE_TAG_BACKEND:-latest}"  # Tag for backend service default is my own GCP artifact registry
DOCKER_IMAGE_TAG_DATA="${DOCKER_IMAGE_TAG_DATA:-latest}"       # Tag for data service default is my own GCP artifact registry
IMAGE_LIST_FILE="./image_list.txt"  # File to store image names
KUBECONFIG_PATH="${KUBECONFIG_PATH:-$HOME/.kube/config}"
KUBECONFIG_CONTENT="$(cat $HOME/.kube/config)"
ANSIBLE_PLAYBOOK_PATH="${ANSIBLE_PLAYBOOK_PATH:-ansible/playbooks}"


# Function to build and push Docker images using docker-compose
# Function to build images and capture names
function build_images_with_docker_compose() {
    echo "Building Docker images using docker-compose..."
    docker-compose build

    echo "Capturing image names..."
    docker images --format "{{.Repository}}:{{.Tag}}" | grep "cloud-tech-test-1_" > "${IMAGE_LIST_FILE}"
    echo "Image names captured in ${IMAGE_LIST_FILE}"
}

# Function to tag and push images
function tag_and_push_images() {
    echo "Tagging and pushing images..."

    while read -r image; do
        if [[ "${image}" == *"backend_service"* ]]; then
            new_tag="${DOCKER_IMAGE_BACKEND}:${DOCKER_IMAGE_TAG_BACKEND}"
        elif [[ "${image}" == *"data_service"* ]]; then
            new_tag="${DOCKER_IMAGE_DATA}:${DOCKER_IMAGE_TAG_DATA}"
        else
            echo "Unknown service for image: ${image}"
            continue
        fi

        echo "Tagging ${image} as ${new_tag}..."
        docker tag "${image}" "${new_tag}"

        echo "Pushing ${new_tag}..."
        docker push "${new_tag}"
    done < "${IMAGE_LIST_FILE}"

    echo "All images tagged and pushed successfully."
}

function configure_kubectl() {
    echo "Configuring kubectl..."
    if [ -n "${KUBECONFIG_CONTENT:-}" ]; then
        chmod 600 "${KUBECONFIG_PATH}"
        echo "Kubeconfig written to ${KUBECONFIG_PATH}"
    else
        echo "Error: KUBECONFIG_CONTENT is not set. Please set it before running this script."
        exit 1
    fi

    # Test connection to Kubernetes cluster
    if ! kubectl get nodes &>/dev/null; then
        echo "Error: Unable to connect to the Kubernetes cluster. Check your kubeconfig or cluster status."
        exit 1
    fi
    echo "Successfully connected to the Kubernetes cluster."
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
build_images_with_docker_compose
tag_and_push_images

configure_kubectl
deploy_with_helm

# Sleep to reflect external IP
sleep 60

run_health_check
monitor_resources
monitor_resources_with_label

echo "Deployment and monitoring completed successfully!"
