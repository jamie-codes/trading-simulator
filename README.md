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
│ └── service.yaml                    # Service for the trading app
├──terraform/                         # Terraform configuration files          
│ ├── provider.tf                     # AWS and Kubernetes providers
│ ├── eks-cluster.tf                  # EKS cluster setup
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
  ├── load-test.sh                    # Script for load testing using `k6`
  ├── setup-prometheus.sh             # Script to set up Prometheus
  ├── setup-grafana.sh                # Script to set up Grafana
  └── setup-efk.sh                    # Script to set up the EFK Stack
```

---


## **Setup Instructions**

### **1. Prerequisites**
- An AWS account (free tier is sufficient).
- `kubectl` installed and configured.
   - Follow steps here: [install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- `helm` installed.
   - Follow steps here: [install Helm charts](https://docs.aws.amazon.com/eks/latest/userguide/helm.html)
- Docker installed.
 ```
   sudo yum update
   sudo yum search docker
   sudo yum info docker
   sudo yum install docker
   # Add group membership to all to run all docker commands
   sudo usermod -a -G docker ec2-user
   id ec2-user
   # Reload a Linux user's group assignments to docker w/o logout
   newgrp docker
   # Enable docker service at boot time
   sudo systemctl enable docker.service
   # Start the Docker service
   sudo systemctl start docker.service
```

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
   ```bash
   cd trading-simulator
   docker build -t jamiecodes/trading-simulator:1.0 .
   docker push jamiecodes/trading-simulator:1.0
     ```
2. Deploy the application to Kubernetes
 ```
   kubectl apply -f kubernetes/deployment.yaml
   kubectl apply -f kubernetes/service.yaml
   kubectl apply -f kubernetes/hpa.yaml
```
### **4. Configure `kubectl`**
- `eksctl` should automatically configure `kubectl` to connect to your EKS cluster.
- Verify the configuration:
  ```bash
  kubectl config current-context

### **5. Set Up Monitoring and Logging**
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

### **6. Terraform Setup**
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
     Open `http://localhost:9090` in your browser.

### **7. Load Testing**
To simulate high traffic to help test the scalability of the trading simulator, use the load testing script:

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

---

## **To be added (20/02/2025)**

- **Terraform**: For infrastructure as code (IaC) deployment.
- **PostgreSQL**: database as a backend.
