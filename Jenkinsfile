// pipeline {
//     agent any
    
//     triggers {
//         cron('H */2 * * *') // Run every 2 hours
//     }
    
//     environment {
//         // הנתיב לקובץ הקונפיגורציה של K3d
//         KUBECONFIG = "${WORKSPACE}/kubeconfig-my-cluster.yaml"
//     }
    
//     stages {
//         stage('Verify K3d Connection') {
//             steps {
//                 script {
//                     sh '''
//                     echo "בדיקת חיבור ל-K3d..."
                    
//                     # בדיקה שהקלאסטר קיים
//                     if ! k3d cluster list | grep -q my-cluster; then
//                         echo "הקלאסטר 'my-cluster' לא קיים ב-K3d"
//                         echo "הסקריפט upload_cluster.sh כנראה נכשל ביצירת הקלאסטר"
//                         exit 1
//                     fi
                    
//                     # ייצא את הקונפיגורציה למשתנה סביבה
//                     export KUBECONFIG=${KUBECONFIG}
                    
//                     # בדיקת חיבור
//                     if ! kubectl get nodes; then
//                         echo "לא ניתן להתחבר לקלאסטר באמצעות kubectl"
//                         echo "ייתכן שקובץ ה-KUBECONFIG אינו תקין או שהקלאסטר אינו פעיל"
//                         exit 1
//                     fi
//                     '''
//                 }
//             }
//         }
        
//         stage('Deploy Application') {
//             steps {
//                 script {
//                     // פרוס את האפליקציה
//                     sh '''
//                     echo "פריסת האפליקציה..."
                    
//                     # הגדר את הקונפיגורציה לקוברנטיס
//                     export KUBECONFIG=$KUBECONFIG
                    
//                     # בדוק אילו קבצים קיימים
//                     ls -la k8s/
                    
//                     # נסה להשתמש בkustomize אם יש קובץ מתאים
//                     if [ -f k8s/kustomization.yaml ]; then
//                         kubectl apply -k k8s/
//                     else
//                         # אחרת החל כל קובץ YAML בנפרד
//                         for file in k8s/*.yaml; do
//                             if [ -f "$file" ]; then
//                                 echo "מחיל $file"
//                                 kubectl apply -f "$file" || echo "לא ניתן להחיל $file"
//                             fi
//                         done
//                     fi
                    
//                     # המתן שכל השירותים יהיו זמינים
//                     echo "ממתין שהאפליקציה תהיה מוכנה..."
//                     kubectl get deployments
//                     kubectl wait --for=condition=available --timeout=300s deployment --all || echo "לא כל השירותים זמינים"
//                     '''
//                 }
//             }
//         }
        
//         stage('Create Test Environment') {
//             steps {
//                 script {
//                     sh '''
//                     echo "יצירת סביבת בדיקות..."
                    
//                     # הגדר את הקונפיגורציה לקוברנטיס
//                     export KUBECONFIG=$KUBECONFIG
                    
//                     # יצירת הסיקרט עם משתני הסביבה לבדיקות
//                     cat <<EOF | kubectl apply -f -
// apiVersion: v1
// kind: Secret
// metadata:
//   name: e2e-env-secret
// type: Opaque
// stringData:
//   DB_HOST: "postgres-service"
//   DB_USER: "postgres"
//   DB_PASSWORD: "postgres"
//   API_URL: "http://backend-service/api/health"
//   FRONTEND_URL: "http://frontend-service"
// EOF
                    
//                     # בדוק אם קובץ ה-Pod קיים
//                     if [ -f "E2E_test/pod.yaml" ]; then
//                         echo "מפרס את Pod הבדיקות..."
//                         kubectl apply -f E2E_test/pod.yaml
                        
//                         # המתן שה-Pod יהיה מוכן
//                         echo "ממתין שה-Pod יהיה מוכן..."
//                         kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || echo "ה-Pod לא מוכן עדיין"
//                     else
//                         echo "קובץ pod.yaml לא נמצא ב-E2E_test/"
//                         exit 1
//                     fi
//                     '''
//                 }
//             }
//         }
        
//         stage('Run E2E Tests') {
//             steps {
//                 script {
//                     sh '''
//                     echo "הרצת בדיקות E2E..."
                    
//                     # הגדר את הקונפיגורציה לקוברנטיס
//                     export KUBECONFIG=$KUBECONFIG
                    
//                     # בדוק אם קובץ הבדיקה קיים
//                     if [ -f "E2E_test/test.sh" ]; then
//                         echo "מעתיק את סקריפט הבדיקה ל-Pod..."
//                         kubectl cp E2E_test/test.sh e2e-tests:/e2e-tests.sh
                        
//                         echo "מריץ את הבדיקות..."
//                         kubectl exec e2e-tests -- sh -c "chmod +x /e2e-tests.sh && /e2e-tests.sh"
//                     else
//                         echo "קובץ test.sh לא נמצא ב-E2E_test/"
//                         exit 1
//                     fi
//                     '''
//                 }
//             }
//         }
        
//         stage('Clean Up Test Environment') {
//             steps {
//                 script {
//                     sh '''
//                     echo "ניקוי סביבת הבדיקות..."
                    
//                     # הגדר את הקונפיגורציה לקוברנטיס
//                     export KUBECONFIG=$KUBECONFIG
                    
//                     kubectl delete pod e2e-tests --ignore-not-found
//                     kubectl delete secret e2e-env-secret --ignore-not-found
//                     '''
//                 }
//             }
//         }
//     }
    
//     post {
//         always {
//             echo 'Pipeline execution completed'
//         }
//         success {
//             echo 'All tests passed successfully'
//         }
//         failure {
//             echo 'Tests failed or pipeline encountered errors'
//         }
//     }
// }



pipeline {
    agent any
    
    triggers {
        cron('H */2 * * *') // הרצה כל שעתיים
    }
    
    environment {
        // הגדרת משתני סביבה גלובליים
        K3D_CLUSTER_NAME = "my-cluster"
        KUBECONFIG = "${WORKSPACE}/kubeconfig-${K3D_CLUSTER_NAME}.yaml"
    }
    
    stages {
        stage('Setup K3d') {
            steps {
                script {
                    // וידוא שהכלים הנדרשים מותקנים
                    sh '''
                        echo "בדיקת התקנת כלים..."
                        which k3d || { echo "k3d אינו מותקן"; exit 1; }
                        which kubectl || { echo "kubectl אינו מותקן"; exit 1; }
                    '''
                }
            }
        }
        
        stage('Create K3d Cluster') {
            steps {
                script {
                    sh '''
                        # מחיקת קלאסטר קיים (אם יש)
                        echo "מוחק קלאסטר קיים אם קיים..."
                        k3d cluster delete ${K3D_CLUSTER_NAME} 2>/dev/null || true
                        
                        # ניקוי קובץ KUBECONFIG הישן אם קיים
                        rm -f ${KUBECONFIG}
                        
                        # יצירת קלאסטר חדש עם הגדרות מתאימות לג׳נקינס
                        echo "יוצר קלאסטר K3d חדש..."
                        k3d cluster create ${K3D_CLUSTER_NAME} \
                            --agents 1 \
                            --registry-use registry.k3d:5000 \
                            -p "8080:80@loadbalancer" \
                            --kubeconfig-update-default=false \
                            --kubeconfig-switch-context=false \
                            --k3s-arg "--docker" \
                            --kubeconfig ${KUBECONFIG}
                        
                        # וידוא שקובץ הקונפיגורציה נוצר
                        if [ ! -f "${KUBECONFIG}" ]; then
                            echo "שגיאה: קובץ ה-KUBECONFIG לא נוצר"
                            exit 1
                        fi
                        
                        # הגדרת הרשאות לקובץ
                        chmod 644 ${KUBECONFIG}
                        
                        # הגדרת KUBECONFIG לשימוש בהמשך הסקריפט
                        export KUBECONFIG=${KUBECONFIG}
                        
                        # בדיקה שהקלאסטר עלה בהצלחה
                        echo "בודק שהקלאסטר פעיל..."
                        kubectl --kubeconfig=${KUBECONFIG} get nodes
                        if [ $? -ne 0 ]; then
                            echo "שגיאה בהתחברות לקלאסטר"
                            exit 1
                        fi
                    '''
                }
            }
        }
        
        stage('Configure Nodes') {
            steps {
                script {
                    sh '''
                        # הגדרת KUBECONFIG
                        export KUBECONFIG=${KUBECONFIG}
                        
                        # המתנה קצרה להתייצבות הקלאסטר
                        sleep 10
                        
                        # קבלת שמות הצמתים
                        NODES=($(kubectl --kubeconfig=${KUBECONFIG} get nodes -o jsonpath='{.items[*].metadata.name}'))
                        
                        if [ ${#NODES[@]} -lt 2 ]; then
                            echo "שגיאה: לא זוהו מספיק צמתים בקלאסטר"
                            kubectl --kubeconfig=${KUBECONFIG} get nodes
                            exit 1
                        fi
                        
                        MASTER_NODE=${NODES[0]}
                        WORKER_NODE=${NODES[1]}
                        
                        # הצבת תגיות על הצמתים
                        echo "הגדרת שם לשרת הראשון: my-cluster..."
                        kubectl --kubeconfig=${KUBECONFIG} label nodes $MASTER_NODE kubernetes.io/hostname=my-cluster --overwrite
                        
                        echo "הגדרת שם לשרת השני: my-cluster-m02..."
                        kubectl --kubeconfig=${KUBECONFIG} label nodes $WORKER_NODE kubernetes.io/hostname=my-cluster-m02 --overwrite
                        
                        # הצגת הצמתים ותגיותיהם
                        echo "מציג צמתים ותגיות:"
                        kubectl --kubeconfig=${KUBECONFIG} get nodes --show-labels
                    '''
                }
            }
        }
        
        stage('Verify Cluster') {
            steps {
                script {
                    sh '''
                        # הגדרת KUBECONFIG
                        export KUBECONFIG=${KUBECONFIG}
                        
                        echo "הקלאסטר מוכן עם שני שרתים:"
                        echo "1. my-cluster - עבור מסד הנתונים"
                        echo "2. my-cluster-m02 - עבור הבקאנד והפרונטאנד"
                        
                        # בדיקה שהקלאסטר פעיל ומגיב
                        kubectl --kubeconfig=${KUBECONFIG} get nodes
                        kubectl --kubeconfig=${KUBECONFIG} get pods -A
                        
                        # שמירת הקונפיגורציה להמשך שימוש
                        cp ${KUBECONFIG} ${WORKSPACE}/k3d-config-backup.yaml
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo "הקלאסטר הוקם בהצלחה!"
        }
        failure {
            echo "נכשל בהקמת הקלאסטר"
        }
        always {
            // שמירת קובץ הקונפיגורציה כארטיפקט
            archiveArtifacts artifacts: "kubeconfig-${K3D_CLUSTER_NAME}.yaml", allowEmptyArchive: true
        }
    }
}