

# # #!/bin/bash
# # # # סקריפט להקמת קלאסטר Kubernetes עם K3D

# # # # בדיקה אם kubectl מותקן, אם לא - התקנה
# # # if ! command -v kubectl &> /dev/null; then
# # #     echo "מתקין kubectl..."
# # #     curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
# # #     chmod +x kubectl
# # #     mv kubectl /usr/local/bin/
# # # fi

# # # מחיקת קלאסטר קיים (אם יש)
# # k3d cluster delete my-cluster 2>/dev/null

# # # יצירת קלאסטר חדש עם שני צמתים (1 שרת, 1 עובד) - ללא רישום חיצוני
# # k3d cluster create my-cluster --agents 1 -p "9090:80@loadbalancer"

# # # המתנה קצרה לאתחול הקלאסטר
# # sleep 10

# # # קבלת שמות הצמתים
# # MASTER_NODE=$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
# # WORKER_NODE=$(kubectl get nodes -o jsonpath='{.items[1].metadata.name}' 2>/dev/null)

# # # בדיקה אם הצמתים נמצאו
# # if [ -z "$MASTER_NODE" ]; then
# #     echo "שגיאה: לא נמצא צומת ראשי. ייתכן שהקלאסטר לא הוקם כראוי."
# #     kubectl get nodes
# #     exit 1
# # fi

# # # הצבת תגיות על הצמתים
# # echo "הגדרת שם לשרת הראשון: my-cluster..."
# # kubectl label nodes $MASTER_NODE kubernetes.io/hostname=my-cluster --overwrite

# # # בדיקה אם יש צומת עובד
# # if [ -n "$WORKER_NODE" ]; then
# #     echo "הגדרת שם לשרת השני: my-cluster-m02..."
# #     kubectl label nodes $WORKER_NODE kubernetes.io/hostname=my-cluster-m02 --overwrite
# # else
# #     echo "אזהרה: לא נמצא צומת עובד שני."
# # fi

# # # הצגת הצמתים ותגיותיהם
# # echo "מציג צמתים ותגיות:"
# # kubectl get nodes --show-labels

# # echo "הקלאסטר מוכן עם השרתים הבאים:"
# # echo "1. my-cluster - עבור מסד הנתונים"
# # if [ -n "$WORKER_NODE" ]; then
# #     echo "2. my-cluster-m02 - עבור הבקאנד והפרונטאנד"
# # fi

# # # יצירת קובץ kubeconfig במיקום ספציפי
# # mkdir -p ${WORKSPACE:-$(pwd)}
# # k3d kubeconfig get my-cluster > ${WORKSPACE:-$(pwd)}/kubeconfig



# #!/bin/bash
# # סקריפט להקמת קלאסטר Kubernetes עם K3D

# # מחיקת קלאסטר קיים (אם יש)
# k3d cluster delete my-cluster 2>/dev/null

# # יצירת קלאסטר חדש עם שני צמתים (1 שרת, 1 עובד) - עם רישום פורט
# k3d cluster create my-cluster --agents 1 -p "9090:80@loadbalancer"

# # הגדרת ה-KUBECONFIG באופן מפורש
# export KUBECONFIG=$(k3d kubeconfig write my-cluster)
# echo "KUBECONFIG נקבע ל: $KUBECONFIG"

# # המתנה ארוכה יותר לאתחול הקלאסטר
# echo "ממתין 20 שניות לאתחול מלא של הקלאסטר..."
# sleep 20

# # בדיקה אם אפשר להתחבר לקלאסטר
# if kubectl get nodes &> /dev/null; then
#     echo "הקלאסטר פועל ומקושר כהלכה"
# else
#     echo "בעיית התחברות לקלאסטר. מנסה שוב עם תצורת KUBECONFIG חדשה..."
#     export KUBECONFIG="$HOME/.k3d/kubeconfig-my-cluster.yaml"
#     k3d kubeconfig get my-cluster > $KUBECONFIG
    
#     # בדיקה שנייה
#     if kubectl get nodes &> /dev/null; then
#         echo "הקלאסטר פועל כעת עם תצורת KUBECONFIG החדשה"
#     else
#         echo "שגיאה: עדיין לא ניתן להתחבר לקלאסטר"
#         exit 1
#     fi
# fi

# # קבלת שמות הצמתים
# MASTER_NODE=$(kubectl get nodes --no-headers | grep server | head -1 | awk '{print $1}')
# WORKER_NODE=$(kubectl get nodes --no-headers | grep agent | head -1 | awk '{print $1}')

# # בדיקה אם הצמתים נמצאו
# if [ -z "$MASTER_NODE" ]; then
#     echo "שגיאה: לא נמצא צומת ראשי. ייתכן שהקלאסטר לא הוקם כראוי."
#     kubectl get nodes
#     exit 1
# fi

# # הצבת תגיות על הצמתים
# echo "הגדרת שם לשרת הראשון: my-cluster..."
# kubectl label nodes $MASTER_NODE kubernetes.io/hostname=my-cluster --overwrite

# # בדיקה אם יש צומת עובד
# if [ -n "$WORKER_NODE" ]; then
#     echo "הגדרת שם לשרת השני: my-cluster-m02..."
#     kubectl label nodes $WORKER_NODE kubernetes.io/hostname=my-cluster-m02 --overwrite
# else
#     echo "אזהרה: לא נמצא צומת עובד שני."
# fi

# # הצגת הצמתים ותגיותיהם
# echo "מציג צמתים ותגיות:"
# kubectl get nodes --show-labels

# echo "הקלאסטר מוכן עם השרתים הבאים:"
# echo "1. my-cluster - עבור מסד הנתונים"
# if [ -n "$WORKER_NODE" ]; then
#     echo "2. my-cluster-m02 - עבור הבקאנד והפרונטאנד"
# fi

# # יצירת קובץ kubeconfig במיקום הנדרש
# mkdir -p ${WORKSPACE:-$(pwd)}
# k3d kubeconfig get my-cluster > ${WORKSPACE:-$(pwd)}/kubeconfig
# echo "נוצר קובץ kubeconfig חדש ב: ${WORKSPACE:-$(pwd)}/kubeconfig"

#!/bin/bash
# סקריפט להקמת קלאסטר Kubernetes עם K3D

# מחיקת קלאסטר קיים (אם יש)
k3d cluster delete my-cluster 2>/dev/null

# יצירת קלאסטר חדש עם שני צמתים (1 שרת, 1 עובד) עם הגדרות רשת מפורשות
k3d cluster create my-cluster \
  --agents 1 \
  -p "9090:80@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0" \
  --network=host

# המתנה לאתחול הקלאסטר
echo "ממתין 20 שניות לאתחול מלא של הקלאסטר..."
sleep 20

# יצירת קובץ kubeconfig במיקום הנדרש
mkdir -p ${WORKSPACE:-$(pwd)}
k3d kubeconfig get my-cluster > ${WORKSPACE:-$(pwd)}/kubeconfig

# הגדרת KUBECONFIG לשימוש מיידי
export KUBECONFIG=${WORKSPACE:-$(pwd)}/kubeconfig

# קבלת IP של הרשת הפנימית של דוקר
DOCKER_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')
if [ -z "$DOCKER_IP" ]; then
    DOCKER_IP=$(ip route | awk '/default/ { print $3 }')
fi

echo "IP של רשת Docker שנמצא: $DOCKER_IP"

# תיקון ה-KUBECONFIG - החלפת 0.0.0.0 בכתובת IP של דוקר
SERVER_URL=$(grep "server:" ${KUBECONFIG} | awk '{print $2}')
PORT=$(echo $SERVER_URL | grep -oP '(?<=:)[0-9]+(?=/)')
NEW_SERVER_URL="https://$DOCKER_IP:$PORT"

sed -i "s#${SERVER_URL}#${NEW_SERVER_URL}#g" ${KUBECONFIG}
echo "עדכון כתובת השרת ב-kubeconfig: ${SERVER_URL} -> ${NEW_SERVER_URL}"

# בדיקה עם השינוי החדש
echo "מנסה להתחבר עם הקונפיגורציה החדשה..."
if kubectl get nodes; then
    echo "הקלאסטר פועל ומקושר כהלכה עם התצורה החדשה!"
else
    echo "עדיין יש בעיית התחברות. מנסה פתרון אחר..."
    
    # נסיון עם localhost
    sed -i "s#${NEW_SERVER_URL}#https://localhost:$PORT#g" ${KUBECONFIG}
    
    if kubectl get nodes; then
        echo "הקלאסטר פועל עם הגדרת localhost!"
    else
        echo "נסיון עם 127.0.0.1 במקום localhost..."
        sed -i "s#https://localhost:$PORT#https://127.0.0.1:$PORT#g" ${KUBECONFIG}
        
        if kubectl get nodes; then
            echo "הקלאסטר פועל עם הגדרת 127.0.0.1!"
        else
            echo "לא הצלחנו להתחבר לקלאסטר. הדפסת פרטי תצורה:"
            cat ${KUBECONFIG}
            
            echo "בדיקת קישוריות ל- $PORT:"
            nc -zv localhost $PORT || echo "לא ניתן להתחבר ל- localhost:$PORT"
            
            echo "מנסה להתחבר ישירות לשרת k3d..."
            docker exec k3d-my-cluster-server-0 k3s kubectl get nodes || true
            
            # הדפסת IP של מכולות k3d
            echo "IP של מכולות k3d:"
            docker inspect k3d-my-cluster-server-0 -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
            
            K3D_SERVER_IP=$(docker inspect k3d-my-cluster-server-0 -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
            if [ -n "$K3D_SERVER_IP" ]; then
                echo "נסיון עם IP פנימי של שרת k3d: $K3D_SERVER_IP"
                sed -i "s#https://127.0.0.1:$PORT#https://$K3D_SERVER_IP:6443#g" ${KUBECONFIG}
                kubectl get nodes || echo "גם זה לא עבד"
            fi
            
            exit 1
        fi
    fi
fi

# המשך הסקריפט רק אם הצלחנו להתחבר
echo "מגדיר תגיות לצמתים..."
MASTER_NODE=$(kubectl get nodes --no-headers 2>/dev/null | head -1 | awk '{print $1}')

if [ -n "$MASTER_NODE" ]; then
    echo "נמצא צומת ראשי: $MASTER_NODE"
    kubectl label nodes $MASTER_NODE kubernetes.io/hostname=my-cluster --overwrite
    
    # מציג את התוצאה הסופית
    echo "מציג צמתים:"
    kubectl get nodes
else
    echo "שגיאה: לא נמצא צומת ראשי אחרי תיקון ה-kubeconfig."
    exit 1
fi

echo "הקלאסטר הוקם בהצלחה והוגדר!"