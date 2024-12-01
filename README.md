# DevOps Orchestration assessment

The repo containes:
- Backend Api dummy application
- Data Api dummy application
- Health check dummy script

## Objective:
Update the backend and orchestrate migrating the 2 apps and script to kubernetes clusters following best practices using the technologies in the instructions

### Tasks:
- Add a new backend api:
  - ```/download_external_logs``` makes a call to external service's api.
  - The external download API is dummy api, _you may leave it blank,_ however it requires $EXTERNAL_INTGERATION_KEY to authenticate
  - the external api has multiple enviroments so the integration key varies by enviroment
- Update the health check to fit the new archeticture
- Create helmchart for the stack
- Deployment via Ansible
- Monitoring Kubernetes Applications - Demonstrate how to monitor the node and Pod and containers resource utilization
- How to display only resource utilization for Pods with specific label (k8s-app=kube-Devops)


#### Submission Guidelines:
- Add the nessasory folder(s) and file(s).
- If needed you may change the code structure or content or add technolgies, but its **not** part of the assessment
- Ensure you include the necessary documentations with the relevant commands used.
- Use Git


Good Luck!



# SOLUTION :



This  repository is structured to facilitate the development, deployment, and monitoring of two dummy applications: `backend_service` and `data_service`. Below is an overview of the repository's structure:

```plaintext
cloud-tech-test/
├── ansible/
│   ├── playbooks/
│   │   ├── deploy-backend-service.yaml
│   │   └── deploy-data-service.yaml
├── backend_service/
│   ├── Dockerfile
│   ├── src/
│   │   └── main.py
├── data_service/
│   ├── Dockerfile
│   ├── src/
│   │   └── main.py
├── helm-charts/
│   ├── backend-service/
│   │   ├── Chart.yaml
│   │   ├── templates/
│   │   │   ├── deployment.yaml
│   │   │   └── service.yaml
│   │   └── values.yaml
│   ├── data-service/
│   │   ├── Chart.yaml
│   │   ├── templates/
│   │   │   ├── deployment.yaml
│   │   │   └── service.yaml
│   │   └── values.yaml
├── monitoring/
│   └── metrics-server/
│       └── components.yaml
├── build_n_deploy.sh
├── docker-compose.yml
├── health_check.sh
└── README.md
```

**Directory and File Descriptions:**

- **`ansible/`**: Contains Ansible playbooks for deploying the services.
  - **`playbooks/`**: Directory housing individual playbooks.
    - **`deploy-backend-service.yaml`**: Playbook to deploy the backend service.
    - **`deploy-data-service.yaml`**: Playbook to deploy the data service.

- **`backend_service/`**: Contains the backend service application.
  - **`Dockerfile`**: Instructions to build the backend service Docker image.
  - **`src/`**: Source code directory.
    - **`main.py`**: Main application code for the backend service.

- **`data_service/`**: Contains the data service application.
  - **`Dockerfile`**: Instructions to build the data service Docker image.
  - **`src/`**: Source code directory.
    - **`main.py`**: Main application code for the data service.

- **`helm-charts/`**: Contains Helm charts for Kubernetes deployments.
  - **`backend-service/`**: Helm chart for the backend service.
    - **`Chart.yaml`**: Metadata about the chart.
    - **`templates/`**: Kubernetes resource templates.
      - **`deployment.yaml`**: Deployment configuration.
      - **`service.yaml`**: Service configuration.
    - **`values.yaml`**: Default values for the chart.
  - **`data-service/`**: Helm chart for the data service.
    - **`Chart.yaml`**: Metadata about the chart.
    - **`templates/`**: Kubernetes resource templates.
      - **`deployment.yaml`**: Deployment configuration.
      - **`service.yaml`**: Service configuration.
    - **`values.yaml`**: Default values for the chart.

- **`monitoring/`**: Contains monitoring configurations.
  - **`metrics-server/`**: Configuration for the Kubernetes Metrics Server.
    - **`components.yaml`**: Deployment manifest for the Metrics Server.

- **`build_n_deploy.sh`**: Shell script to build Docker images, push them to a registry, and deploy services to Kubernetes.

- **`docker-compose.yml`**: Defines services for local development and testing using Docker Compose.

- **`health_check.sh`**: Script to perform health checks on the deployed services.




## How to use the build and deploy script.
Use the build_and_deploy.sh script to build and deploy the services.

###  Build and Deploy Script Instructions

This script automates the process of building Docker images, tagging and pushing them to a remote registry, configuring Kubernetes, deploying Helm charts via Ansible, running health checks, and monitoring Kubernetes resources.

---

### **Prerequisites**

1. **Environment Setup**:
   - Ensure you have the following tools installed and accessible in your system:
     - `docker`
     - `docker-compose`
     - `kubectl`
     - `ansible`
     - `helm`

2. **Docker Registry Authentication**:
   - Log in to the Docker registry before running the script:


3. **Kubernetes Configuration**:
   - Ensure your Kubernetes cluster is accessible via `kubectl`.
   - Set the `KUBECONFIG_PATH` environment variable if your kubeconfig file is not at the default location (`~/.kube/config`).


4. **Ansible Configuration**:
   - Verify that the Ansible playbooks (`deploy-backend-service.yaml` and `deploy-data-service.yaml`) are correctly configured in the path specified by the `ANSIBLE_PLAYBOOK_PATH` variable.

5. **Metrics Server**:
   - Install Metrics Server to monitor resource utilization:
     ```bash
     kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
     kubectl rollout status -n kube-system deployment/metrics-server

---

### **Environment Variables**

Set the following environment variables before running the script:

| **Variable**            | **Description**                                                                               | **Default**                |
|--------------------------|-----------------------------------------------------------------------------------------------|----------------------------|
| `DOCKER_IMAGE_TAG_BACKEND` | The tag to use for the backend service Docker image.                                           | `latest`                   |
| `DOCKER_IMAGE_TAG_DATA`    | The tag to use for the data service Docker image.                                              | `latest`                   |
| `KUBECONFIG_PATH`         | Path to the kubeconfig file for accessing the Kubernetes cluster.                              | `~/.kube/config`           |
| `KUBECONFIG_CONTENT`      | The content of the kubeconfig file. Ensure this variable is set for the script to work.         | Content of kubeconfig file |
| `ANSIBLE_PLAYBOOK_PATH`   | Path to the directory containing Ansible playbooks for Helm deployment.                        | `ansible/playbooks`        |

---

### **Config Files**

1. **`docker-compose.yml`**:
   Ensure your `docker-compose.yml` file is correctly configured with the `backend_service` and `data_service` configurations. It should include:
   - Build contexts
   - Dockerfile paths
   - Port mappings
   - Environment variables

2. **Ansible Playbooks**:
   - `deploy-backend-service.yaml`: Deploys the Helm chart for the backend service.
   - `deploy-data-service.yaml`: Deploys the Helm chart for the data service.

---

### **How to Run**

1. **Set Environment Variables**:
   - Example:
     ```bash
     export DOCKER_IMAGE_TAG_BACKEND=v1.0.0
     export DOCKER_IMAGE_TAG_DATA=v1.0.0
     export KUBECONFIG_PATH=$HOME/.kube/config
     export KUBECONFIG_CONTENT="$(cat $HOME/.kube/config)"
     export ANSIBLE_PLAYBOOK_PATH="ansible/playbooks"
     ```

2. **Run the Script**:
   Execute the script:
   ```bash
   bash build_and_deploy.sh
   ```

3. **Monitor the Output**:
   - The script logs all actions, including:
     - Docker image builds, tags, and pushes.
     - Kubernetes connectivity.
     - Helm deployments via Ansible.
     - Health checks and resource monitoring.

---

### **Monitoring Kubernetes Resources**

The script includes functionality to monitor Kubernetes resources:

1. **Node and Pod Resource Utilization**:
   - Displays node and pod-level resource usage using `kubectl top`:
     ```bash
     kubectl top nodes
     kubectl top pods --all-namespaces
     ```

2. **Filter Resource Utilization by Label**:
   - Displays resource usage for pods with a specific label:
     ```bash
     kubectl top pods --all-namespaces --selector="k8s-app=kube-Devops"
     ```

---

### **Troubleshooting**

1. **Docker Build or Push Issues**:
   - Ensure Docker is authenticated to the correct registry.
   - Check that `docker-compose.yml` paths and configurations are correct.

2. **Kubernetes Connectivity**:
   - Ensure `kubectl` is configured correctly with the kubeconfig file.
   - Verify cluster accessibility:
     ```bash
     kubectl get nodes
     ```

3. **Helm Deployment Errors**:
   - Ensure Helm charts and values are correctly configured.
   - Use the following command to debug:
     ```bash
     helm status <release-name> -n default
     ```

4. **Health Check Failures**:
   - Verify the external IP for the services is accessible.
   - Use `curl` to test the health check endpoints:
     ```bash
     curl http://<external-ip>/health_check
     ```

---

### **Future Improvements**

- Automate image tagging with Git commit hashes or CI/CD pipeline variables.
- Add logging for each step to track execution details.
- Enhance monitoring by integrating with tools like Prometheus and Grafana.

---

