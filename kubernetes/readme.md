## Build and push the Docker image
```
bash
docker build -t jamiecodes/trading-simulator:1.0 .
docker push jamiecodes/trading-simulator:1.0
```
## Apply Kubernetes manifests
```
bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f kubernetes/hpa.yaml
```
## Verify the HPA:
```
bash
kubectl get hpa
```
Output should look similar to the below
```
NAME              REFERENCE                TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
trading-app-hpa   Deployment/trading-app   0%/50%    2         10        2          10s
```