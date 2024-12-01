### **Monitoring Overview**

Set up monitoring for Kubernetes clusters using **Prometheus** and **Grafana**.

#### **Node and Pod Resource Utilization**
- Use **Prometheus** to scrape metrics from Kubernetes components.
- Visualize CPU and memory usage of nodes and pods using **Grafana dashboards**.
- Example Queries:
  - **Node CPU Usage**: 
    ```promql
    sum(rate(node_cpu_seconds_total[5m])) by (node)
    ```
  - **Pod Memory Usage**:
    ```promql
    sum(container_memory_usage_bytes{namespace="default"}) by (pod)
    ```

