# Kubernetes-Based Trading System Simulator

This project demonstrates the deployment of a mock trading system on Kubernetes, with monitoring, logging, and auto-scaling features. It is designed to simulate a production-like environment using Kubernetes, Docker, free AWS tier, and monitoring tools.

---

## **Project Overview**

The goal of this project is to:
1. Deploy a Python-based trading simulator on Kubernetes.
2. Set up monitoring and logging to ensure system reliability.
3. Implement auto-scaling to handle varying workloads.
4. Simulate high trading activity and optimize system performance.

---

## **Technologies Used**

- **Kubernetes**: For orchestration and scaling.
- **AWS EKS/EC2**: For hosting the Kubernetes cluster.
- **Docker**: For containerizing the trading application.
- **Python**: For the trading simulator.

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
```
### **4: Configure `kubectl`**
- `eksctl` should automatically configure `kubectl` to connect to your EKS cluster.
- Verify the configuration:
  ```bash
  kubectl config current-context
 ```
---

## **To be added (14/02/2025)**

- **Prometheus & Grafana**: For monitoring system performance.
- **Fluentd/EFK Stack**: For centralized logging.
- **Helm**: For deploying monitoring tools.
