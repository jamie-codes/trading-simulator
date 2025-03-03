# Kubernetes-Based Trading System Simulator

This project demonstrates the deployment of a mock trading system on Kubernetes, with monitoring, logging, and auto-scaling features. It is designed to simulate a production-like environment using Kubernetes, Docker, free AWS tier, and observability tools like Prometheus, Grafana, and the EFK Stack.

---

## **Project Overview**

The goal of this project is to:
1. Deploy a Python-based trading simulator on Kubernetes.
2. Set up monitoring using Prometheus and Grafana to ensure system reliability.
3. Implement centralized logging using the EFK Stack (Elasticsearch, Fluentd, Kibana).
4. Implement auto-scaling to handle varying workloads.
5. Simulate high trading activity and optimize system performance.

---

## **Technologies Used**

- **Kubernetes**: For orchestration and scaling.
- **AWS EKS/EC2**: For hosting the Kubernetes cluster.
- **Docker**: For containerizing the trading application.
- **Python**: For the trading simulator.
- **Prometheus & Grafana**: For monitoring system performance.
- **EFK Stack**: For centralized logging (Elasticsearch, Fluentd, Kibana).
- **Helm**: For deploying monitoring tools.
- **Terraform**: For infrastructure as code (IaC) deployment.
- **PostreSQL**:  a backend for the trading simulator to store trade history and other persistent data.

---

## **Project Structure**
```

trading-simulator/
├── README.md                         # Updated project documentation
├── trading-app/                      # Python trading simulator code
│ ├── app.py                          # Updated Python application with structured logging
│ ├── Dockerfile                      # Dockerfile for containerizing the app
│ └── requirements.txt                # Updated Python dependencies
├── kubernetes/                       # Kubernetes manifests
│ ├── deployment.yaml                 # Deployment for the trading app
│ ├── postgresql-deployment.yaml      # Deployment for the PostgreSQL database
│ ├── postgresql-pvc.yaml             # Persistent Volume Claim for PostgreSQL
│ ├── postgresql-service.yaml         # Service for the PostgreSQL database
│ ├── hpa.yaml                        # Horizontal Pod Autoscaler config
│ └── service.yaml                    # Service for the trading app
├── terraform/                        # Terraform configuration files          
│ ├── provider.tf                     # AWS and Kubernetes providers
│ ├── eks-cluster.tf                  # EKS cluster setup
│ ├── prometheus.tf                   # Prometheus Helm chart
│ ├── postgresql.tf                   # PostgreSQL Helm chart
│ ├── grafana.tf                      # Grafana Helm chart
│ ├── efk.tf                          # EFK Stack (Elasticsearch, Fluentd, Kibana)
│ └── outputs.tf                      # Outputs for load balancer URLs
├── monitoring/                       # Prometheus and Grafana configurations
│ ├── prometheus-values.yaml          # Custom values for Prometheus Helm chart
│ ├── grafana-values.yaml             # Custom values for Grafana Helm chart
│ ├── ServiceMonitor.yaml             # Config to tell Prometheus where to scrape metrics
│ └── dashboards/                     # Grafana dashboard config
│   └── trading-app-dashboard.json  
├── logging/                          # Fluentd configurations
│ ├── fluentd-values.yaml             # Custom values for Fluentd Helm chart
│ └── fluentd-config.yaml             # Custom Fluentd configuration
└──scripts/
  ├── load-test.sh                    # Simulates high traffic for the trading application using `k6`.
  ├── setup-prometheus.sh             # Deploys Prometheus using Helm.
  ├── setup-grafana.sh                # Deploys Grafana using Helm.
  └── setup-efk.sh                    # Deploys the EFK Stack (Elasticsearch, Fluentd, Kibana) using Helm.
```

---


## **Setup Instructions**

### **1. Prerequisites**
- An AWS account (free tier is sufficient).
- `kubectl` installed and configured.
   - Follow steps here: [install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- `helm` installed.
   - Follow steps here: [install Helm charts](https://docs.aws.amazon.com/eks/latest/userguide/helm.html)
- `Docker` installed.
  - Follow steps here: [Install Docker](https://docs.docker.com/get-docker/).

- **Python 3.8 or higher**: Ensure Python is installed and compatible with the trading simulator.
- **Terraform v1.0 or higher**: Ensure Terraform is installed (see section 7 below) and compatible with the provided configurations.
- **AWS Free Tier**: Be mindful of AWS Free Tier limits to avoid unexpected charges.

### **2. Set Up Kubernetes Cluster**
  - Create an EKS cluster using the AWS Management Console or `eksctl`.
  - Configure `kubectl` to connect to your EKS cluster.

1. **Install `eksctl`**:
   - `eksctl` is a CLI tool for creating and managing EKS clusters.
   - Install it using the following command:
     ```bash
     curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
     sudo mv /tmp/eksctl /usr/local/bin
     eksctl version
     ```

2. **Install `awscli`**:
   - Install the AWS CLI and configure it with your credentials:
     ```bash
     curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
     unzip awscliv2.zip
     sudo ./aws/install
     aws configure
     ```

### **3. Create an EKS Cluster**
*Note that that users need to configure their AWS CLI with the correct credentials and region as per above before running eksctl.*
1. **Create a Cluster**:
   - Use `eksctl` to create a cluster with default settings:
     ```bash
     eksctl create cluster --name trading-cluster --region eu-north-1 --nodegroup-name trading-nodes --node-type t3.micro --nodes 2
     ```
   - This command:
     - Creates an EKS cluster named `trading-cluster` in the `eu-north-1` region.
     - Sets up a node group with 2 `t3.micro` instances (Free Tier eligible).
     - Automatically configures `kubectl` to connect to the cluster.

2. **Verify the Cluster**:
   - Check if the cluster is running:
     ```bash
     kubectl get nodes
     ```
   - You should see 2 nodes in the `Ready` state.

### **3. Deploy the Trading Simulator**
1. Build the Docker image for the trading simulator:
   Ensure you have a Docker Hub account or another container registry to push the image. 

   ```bash
   cd trading-simulator
   docker build -t <your-dockerhub-username>/trading-simulator:1.0 .
   docker push <your-dockerhub-username>/trading-simulator:1.0
     ```
2. Deploy the application to Kubernetes
 ```
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/service.yaml
   kubectl apply -f kubernetes/hpa.yaml
```
### **4. Access the Trading Simulator**
1. Get the load balancer URL for the trading simulator:
   ```bash
   kubectl get svc trading-app-service -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
   ```
2. Open the URL in your browser to access the trading simulator. 

### **5. Configure `kubectl`**
- `eksctl` should automatically configure `kubectl` to connect to your EKS cluster.
- Verify the configuration:
  ```bash
  kubectl config current-context

### **6. Set Up Monitoring and Logging**
1. **Prometheus**:
   - Run the script to set up Prometheus:
     ```bash
     chmod +x scripts/setup-prometheus.sh
     ./scripts/setup-prometheus.sh
     ```

2. **Grafana**:
   - Run the script to set up Grafana:
     ```bash
     chmod +x scripts/setup-grafana.sh
     ./scripts/setup-grafana.sh
     ```

3. **EFK Stack**:
   - Run the script to set up the EFK Stack:
     ```bash
     chmod +x scripts/setup-efk.sh
     ./scripts/setup-efk.sh
     ```

4. **Verify the Setup**:
   - Access Prometheus:
     ```bash
     kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090 -n monitoring
     ```
     Open `http://localhost:9090` in your browser.

   - Access Grafana:
     - Get the Grafana admin password:
       ```bash
       kubectl get secret grafana -o jsonpath="{.data.admin-password}" -n monitoring | base64 --decode
       ```
     - Port-forward the Grafana service:
       ```bash
       kubectl port-forward svc/grafana 3000 -n monitoring
       ```
     - Open `http://localhost:3000` in your browser and log in with the username `admin` and the password from the previous step.

   - Access Kibana:
     - Get the Kibana load balancer URL:
       ```bash
       kubectl get svc kibana -n logging -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
       ```
     - Open the URL in your browser.

### **7. Terraform Setup**
Terraform is used to automate the setup of the EKS cluster, Prometheus, Grafana, and the EFK Stack. Below details the setup of this part:

1. **Install Terraform**:
```
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```
Verify the installation:
```
terraform --version
```

2. **Initialize Terraform**:
Navigate to the terraform directory and initialize Terraform to download the required providers:
```
cd terraform
terraform init
```

3. **Apply the Terraform Configuration**
Apply the Terraform configuration to create the EKS cluster
```
terraform apply
```

4. **Verify the Setup**
- *EKS Cluster*:
  Verify that the EKS cluster is running:
     ```bash
     kubectl get nodes
     ```

- *Prometheus*:
  Access Prometheus:     
     ```bash
     kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090 -n monitoring
     ```
     Open `http://localhost:9090` in your browser.

- *Grafana*:
  Get the Grafana admin password:     
     ```bash
     kubectl get secret grafana -o jsonpath="{.data.admin-password}" -n monitoring | base64 --decode
     ```
     Port-forward the Grafana service:
     ```bash
     kubectl port-forward svc/grafana 3000 -n monitoring
     ```
     Open http://localhost:3000 in your browser.

- *EFK Stack*:
  Step 1: Access Kibana
    Get the Kibana load balancer URL:
     ```bash
     terraform output kibana_load_balancer_url
     ```
  Open the URL in your browser.
  Log in to Kibana.
  Configure an index pattern to start visualising logs.
    - Create an index pattern for logstash under *Stack Management > Index Patterns*

  Step 2: Verify Elasticsearch
    Check the Elasticsearch endpoint:
     ```bash
     terraform output elasticsearch_endpoint
     ```
     Use `curl` or a browser to verify Elasticsearch is running:
     ```bash
     curl http://elasticsearch-master.logging.svc.cluster.local:9200
     ```
  Step 3: Verify Fluentd
    Check the Fluentd logs:
    ```bash
     kubectl logs -l app=fluentd -n logging
     ```
     Ensure Fluentd is sending logs to Elasticsearch.

### **8. Add PostgreSQL Database**
To add the PostgreSQL database as a backend for the trading simulator:

1. **Deploy PostgreSQL**:
   ```bash
   kubectl apply -f kubernetes/postgresql-deployment.yaml
   kubectl apply -f kubernetes/postgresql-pvc.yaml
   kubectl apply -f kubernetes/postgresql-service.yaml
   ``` 

2. **Verify PostgreSQL**:
Check if the PostgreSQL pod is running:
   ```bash
   kubectl get pods -l app=postgresql
   ```
Access the PostgreSQL database:
   ```sql
   kubectl exec -it <postgresql-pod-name> -- psql -U user -d trading
   ```

3. **Update the Trading Simulator**:
Rebuild and push the Docker image:
  ```bash
  docker build -t <your-dockerhub-username>/trading-simulator:1.0 .
  docker push <your-dockerhub-username>/trading-simulator:1.0
  ```

Redeploy the trading application:
  ```bash
  kubectl apply -f kubernetes/deployment.yaml
  ```

4. **Verify the Setup**:
Check if the trading application is connected to PostgreSQL:
```bash
kubectl logs <trading-app-pod-name>
```
(Alternatively check the logs on Kibana)


### **9. Load Testing**
To simulate high traffic for the trading simulator, use the `load-test.sh` script. This script uses **k6** to send a high volume of requests to the trading simulator and measures its performance under load.

1. **Install k6**:
   - For Linux:
     ```bash
     sudo apt-get install k6
     ```

2. **Run the Load Test**:
   - Run the load test script:
     ```bash
     chmod +x scripts/load-test.sh
     ./scripts/load-test.sh
     ```

3. **Check Results**:
   - The script will output metrics like:
     - **Requests per second (RPS)**: The number of requests handled per second.
     - **Error rate**: The percentage of failed requests.
     - **Latency**: The average response time.
   - We can use these metrics to identify performance bottlenecks and optimize the system.


---

### **10. Future Additions**
Some potential future additions that I will look into prioritising and implementing.:

- **CI/CD Pipeline**: using tools like Jenkins, GitHub Actions, or ArgoCD to automate the build, test, and deployment process.
- **Automated Testing**: add unit tests, integration tests, and end-to-end tests for the trading application, using a testing framework like pytest or unittest.
- **Secrets Management**: Use HashiCorp Vault or AWS Secrets Manager to manage sensitive data (e.g., database credentials, API keys).
- **Chaos Testing**: Use Chaos Mesh or Gremlin to simulate failures (e.g., pod crashes, network latency, database outages) and to test the system's resilience and recovery mechanisms.
- **Custom Metrics**: Use Prometheus exporters or custom instrumentation in the Python application and add custom metrics to track certain values (e.g., trade volume, profit/loss, latency).
- **Alerting**: enhance the existing alerting by setting up Prometheus Alertmanager to send alerts for critical conditions (e.g., high error rates, low trade volume).
- **Real-Time Data**: Integrate with a real-time market data API (e.g., Alpha Vantage, Yahoo Finance) to simulate realistic trading scenarios. Use WebSockets or Kafka for real-time data streaming.
- **User Interface**: Build a web-based dashboard using React or Vue.js to visualize trading activity, metrics, and logs. Integrate this with Grafana and Kibana for advanced visualizations.


