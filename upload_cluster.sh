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
# סקריפט להקמת קלאסטר Kubernetes עם K3D

# בדיקה אם kubectl מותקן, אם לא - התקנה
if ! command -v kubectl &> /dev/null; then
    echo "מתקין kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
fi

# מחיקת קלאסטר קיים (אם יש)
k3d cluster delete my-cluster 2>/dev/null

# יצירת קלאסטר חדש עם שני צמתים (1 שרת, 1 עובד) - ללא רישום חיצוני
k3d cluster create my-cluster --agents 1 -p "8080:80@loadbalancer"

# המתנה קצרה לאתחול הקלאסטר
sleep 10

# קבלת שמות הצמתים
MASTER_NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
WORKER_NODE=$(kubectl get nodes -o jsonpath='{.items[1].metadata.name}' 2>/dev/null)

# בדיקה אם הצמתים נמצאו
if [ -z "$MASTER_NODE" ]; then
    echo "שגיאה: לא נמצא צומת ראשי. ייתכן שהקלאסטר לא הוקם כראוי."
    kubectl get nodes
    exit 1
fi

# הצבת תגיות על הצמתים
echo "הגדרת שם לשרת הראשון: my-cluster..."
kubectl label nodes $MASTER_NODE kubernetes.io/hostname=my-cluster --overwrite

# בדיקה אם יש צומת עובד
if [ -n "$WORKER_NODE" ]; then
    echo "הגדרת שם לשרת השני: my-cluster-m02..."
    kubectl label nodes $WORKER_NODE kubernetes.io/hostname=my-cluster-m02 --overwrite
else
    echo "אזהרה: לא נמצא צומת עובד שני."
fi

# הצגת הצמתים ותגיותיהם
echo "מציג צמתים ותגיות:"
kubectl get nodes --show-labels

echo "הקלאסטר מוכן עם השרתים הבאים:"
echo "1. my-cluster - עבור מסד הנתונים"
if [ -n "$WORKER_NODE" ]; then
    echo "2. my-cluster-m02 - עבור הבקאנד והפרונטאנד"
fi

# יצירת קובץ kubeconfig במיקום ספציפי
mkdir -p ${WORKSPACE:-$(pwd)}
k3d kubeconfig get my-cluster > ${WORKSPACE:-$(pwd)}/kubeconfig