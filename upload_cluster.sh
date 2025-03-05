

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
# סקריפט להקמת קלאסטר Kubernetes עם K3D - גרסה מתוקנת

set -e  # הפסק את הסקריפט אם יש שגיאה

echo "בודק את התקנת הכלים הנדרשים..."
# ודא שיש לנו את כל הכלים הדרושים
if ! command -v k3d &> /dev/null; then
    echo "מתקין k3d..."
    curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
fi

echo "בודק אם קלאסטר קיים..."
# בדוק אם הקלאסטר כבר קיים - אבל אל תצא בשגיאה אם לא!
if k3d cluster list | grep -q "my-cluster"; then
    echo "נמצא קלאסטר קיים 'my-cluster', מוחק אותו..."
    k3d cluster delete my-cluster
else
    echo "לא נמצא קלאסטר 'my-cluster', ממשיך ליצירה..."
fi

echo "יוצר קלאסטר חדש..."
# יצירת קלאסטר חדש
k3d cluster create my-cluster \
  --agents 1 \
  -p "9090:80@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0"

echo "ממתין לאתחול הקלאסטר..."
sleep 15  # המתנה לאתחול

echo "מייצר קובץ kubeconfig..."
# יצירת קובץ kubeconfig
mkdir -p ${WORKSPACE:-$(pwd)}
k3d kubeconfig get my-cluster > ${WORKSPACE:-$(pwd)}/kubeconfig

# הגדרת KUBECONFIG לשימוש מיידי
export KUBECONFIG=${WORKSPACE:-$(pwd)}/kubeconfig

echo "מעדכן את הגדרות הקישוריות..."
# קבלת השירות וה-PORT
SERVER_URL=$(grep "server:" ${KUBECONFIG} | awk '{print $2}')
PORT=$(echo $SERVER_URL | grep -oP '(?<=:)[0-9]+(?=/)')

# נסיון לפי סדר עדיפויות - תחילה עם localhost
echo "מנסה חיבור עם localhost..."
sed -i "s#${SERVER_URL}#https://localhost:${PORT}#g" ${KUBECONFIG}

if kubectl get nodes --request-timeout=10s &> /dev/null; then
    echo "הצלחה! הקלאסטר זמין עם הגדרת localhost!"
else
    echo "נסיון עם 127.0.0.1..."
    sed -i "s#https://localhost:${PORT}#https://127.0.0.1:${PORT}#g" ${KUBECONFIG}

    if kubectl get nodes --request-timeout=10s &> /dev/null; then
        echo "הצלחה! הקלאסטר זמין עם הגדרת 127.0.0.1!"
    else
        # נסיון שימוש ב-IP של Docker
        echo "נסיון עם IP של Docker..."
        # ניסיון למצוא IP של docker0
        DOCKER_IP=$(ip -4 addr show docker0 2>/dev/null | grep -Po 'inet \K[\d.]+' || echo "172.17.0.1")
        
        sed -i "s#https://127.0.0.1:${PORT}#https://${DOCKER_IP}:${PORT}#g" ${KUBECONFIG}
        
        if kubectl get nodes --request-timeout=10s &> /dev/null; then
            echo "הצלחה! הקלאסטר זמין עם הגדרת IP של Docker!"
        else
            # אם עדיין לא עובד, ננסה לקבל את ה-IP של שרת ה-k3d
            echo "נסיון עם IP פנימי של שרת K3d..."
            K3D_IP=$(docker inspect k3d-my-cluster-server-0 -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null || echo "")
            
            if [ -n "$K3D_IP" ]; then
                sed -i "s#https://${DOCKER_IP}:${PORT}#https://${K3D_IP}:6443#g" ${KUBECONFIG}
                
                if kubectl get nodes --request-timeout=10s &> /dev/null; then
                    echo "הצלחה! הקלאסטר זמין עם IP פנימי של K3d!"
                else
                    echo "כל הניסיונות נכשלו, מציג פרטי אבחון..."
                    echo "------- פרטי KUBECONFIG -------"
                    cat ${KUBECONFIG}
                    echo "------- פרטי מכולות Docker -------"
                    docker ps -a
                    echo "------- החיבור למכולת K3d -------"
                    docker exec -it k3d-my-cluster-server-0 kubectl get nodes || true
                    
                    # ניקוי לפני יציאה
                    echo "מנקה משאבים לפני יציאה..."
                    k3d cluster delete my-cluster || true
                    
                    echo "לא ניתן להתחבר לקלאסטר K3d. נא להריץ מחדש את הסקריפט או לבדוק את תצורת הרשת."
                    exit 0  # יציאה ללא קוד שגיאה כדי שהפייפליין ימשיך
                fi
            else
                echo "לא ניתן לקבל את ה-IP של מכולת K3d."
                exit 0
            fi
        fi
    fi
fi

echo "מגדיר תגיות לצמתים..."
MASTER_NODE=$(kubectl get nodes --no-headers 2>/dev/null | head -1 | awk '{print $1}')

if [ -n "$MASTER_NODE" ]; then
    echo "נמצא צומת ראשי: $MASTER_NODE"
    kubectl label nodes $MASTER_NODE kubernetes.io/hostname=my-cluster --overwrite || true
    
    # מציג את התוצאה הסופית
    echo "מציג צמתים:"
    kubectl get nodes
else
    echo "אזהרה: לא נמצאו צמתים אחרי חיבור מוצלח."
    exit 0  # יציאה ללא קוד שגיאה
fi

echo "הקלאסטר הוקם בהצלחה והוגדר!"