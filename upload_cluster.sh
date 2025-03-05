# #!/bin/bash
# # Script to set up a Kubernetes cluster with K3D

# # מחיקת קלאסטר קיים (אם יש)
# k3d cluster delete my-cluster 2>/dev/null

# # יצירת קלאסטר חדש עם שני צמתים (1 שרת, 1 עובד)
# k3d cluster create my-cluster --agents 1 --registry-use registry.k3d:5000 -p "8080:80@loadbalancer"

# # קבלת שמות הצמתים

# MASTER_NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')
# WORKER_NODE=$(kubectl get nodes -o jsonpath='{.items[1].metadata.name}')

# # הצבת תגיות על הצמתים
# echo "הגדרת שם לשרת הראשון: my-cluster..."
# kubectl label nodes $MASTER_NODE kubernetes.io/hostname=my-cluster --overwrite

# echo "הגדרת שם לשרת השני: my-cluster-m02..."
# kubectl label nodes $WORKER_NODE kubernetes.io/hostname=my-cluster-m02 --overwrite

# # הצגת הצמתים ותגיותיהם
# echo "מציג צמתים ותגיות:"
# kubectl get nodes --show-labels

# echo "הקלאסטר מוכן עם שני שרתים:"
# echo "1. my-cluster - עבור מסד הנתונים"
# echo "2. my-cluster-m02 - עבור הבקאנד והפרונטאנד"






#!/bin/bash
# Script to set up a Kubernetes cluster with K3D

# מחיקת קלאסטר קיים (אם יש)
k3d cluster delete my-cluster 2>/dev/null || true

# יצירת קלאסטר חדש עם שני צמתים (1 שרת, 1 עובד)
k3d cluster create my-cluster \
  --agents 1 \
  --registry-use registry.k3d:5000 \
  -p "8080:80@loadbalancer" \
  --kubeconfig-update-default=false \
  --kubeconfig-switch-context=false

# ייצוא הקונפיגורציה
KUBECONFIG_FILE="$PWD/kubeconfig-my-cluster.yaml"
k3d kubeconfig get my-cluster > ${KUBECONFIG_FILE}
export KUBECONFIG=${KUBECONFIG_FILE}

# קבלת שמות הצמתים
echo "ממתין לזמינות הצמתים..."
kubectl --kubeconfig=${KUBECONFIG_FILE} wait --for=condition=Ready nodes --all --timeout=60s

NODES=($(kubectl --kubeconfig=${KUBECONFIG_FILE} get nodes -o jsonpath='{.items[*].metadata.name}'))
if [ ${#NODES[@]} -lt 2 ]; then
  echo "שגיאה: לא זוהו מספיק צמתים בקלאסטר"
  kubectl --kubeconfig=${KUBECONFIG_FILE} get nodes
  exit 1
fi

MASTER_NODE=${NODES[0]}
WORKER_NODE=${NODES[1]}

# הצבת תגיות על הצמתים
echo "הגדרת שם לשרת הראשון: my-cluster..."
kubectl --kubeconfig=${KUBECONFIG_FILE} label nodes $MASTER_NODE kubernetes.io/hostname=my-cluster --overwrite

echo "הגדרת שם לשרת השני: my-cluster-m02..."
kubectl --kubeconfig=${KUBECONFIG_FILE} label nodes $WORKER_NODE kubernetes.io/hostname=my-cluster-m02 --overwrite

# הצגת הצמתים ותגיותיהם
echo "מציג צמתים ותגיות:"
kubectl --kubeconfig=${KUBECONFIG_FILE} get nodes --show-labels

echo "הקלאסטר מוכן עם שני שרתים:"
echo "1. my-cluster - עבור מסד הנתונים"
echo "2. my-cluster-m02 - עבור הבקאנד והפרונטאנד"