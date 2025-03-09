
k3d cluster delete my-cluster 2>/dev/null
k3d registry delete k3d-registry 2>/dev/null

# יצירת רג'יסטרי
k3d registry create registry.k3d --port 5000

k3d cluster create my-cluster --agents 1 --registry-use registry.k3d:5000 -p "8080:80@loadbalancer"


MASTER_NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
WORKER_NODE=$(kubectl get nodes -o jsonpath='{.items[1].metadata.name}')

kubectl label nodes $MASTER_NODE kubernetes.io/hostname=my-cluster --overwrite

kubectl label nodes $WORKER_NODE kubernetes.io/hostname=my-cluster-m02 --overwrite

kubectl get nodes --show-labels

