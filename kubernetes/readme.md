# Build and push the Docker image
```
bash
Copy
Edit
docker build -t jamiecodes/trading-simulator:1.0 .
docker push jamiecodes/trading-simulator:1.0
```
# Apply Kubernetes manifests
```
bash
Copy
Edit
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```
