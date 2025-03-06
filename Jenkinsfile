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
//                     ./upload_cluster.sh                    
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
    
    parameters {
        string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
        string(name: 'NUM_AGENTS', defaultValue: '1', description: 'מספר צמתי העבודה')
        string(name: 'PORT_MAPPING', defaultValue: '8080:80@loadbalancer', description: 'מיפוי פורטים')
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('בדיקת תוכנות נדרשות') {
            steps {
                script {
                    echo 'בודק אם כלים נדרשים מותקנים...'
                    
                    def k3dInstalled = sh(script: 'which k3d || echo "NOT_FOUND"', returnStdout: true).trim()
                    def kubectlInstalled = sh(script: 'which kubectl || echo "NOT_FOUND"', returnStdout: true).trim()
                    
                    if (k3dInstalled == 'NOT_FOUND') {
                        error 'K3D לא נמצא. יש להתקין אותו על סוכן Jenkins'
                    }
                    
                    if (kubectlInstalled == 'NOT_FOUND') {
                        error 'kubectl לא נמצא. יש להתקין אותו על סוכן Jenkins'
                    }
                    
                    echo 'כל הכלים הנדרשים מותקנים.'
                }
            }
        }
        
        stage('מחיקת קלאסטר קיים') {
            steps {
                script {
                    sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
                    echo 'קלאסטר קיים נמחק בהצלחה או לא נמצא.'
                }
            }
        }
        
        stage('יצירת קלאסטר חדש') {
            steps {
                script {
                    // יצירת הקלאסטר עם הפקודה המלאה
                    sh "k3d cluster create ${params.CLUSTER_NAME} --agents ${params.NUM_AGENTS} -p \"${params.PORT_MAPPING}\""
                    echo 'קלאסטר חדש נוצר בהצלחה.'
                    
                    // עדכון קובץ ה-kubeconfig באופן מפורש
                    sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/config"
                    sh "chmod 600 \${HOME}/.kube/config"
                    
                    // המתנה קצרה לאתחול המערכת
                    sh "sleep 30"
                    
                    // בדיקת מצב הקלאסטר ונסיונות חוזרים
                    def maxRetries = 5
                    def retryCount = 0
                    def clusterReady = false
                    
                    while (!clusterReady && retryCount < maxRetries) {
                        try {
                            // בדיקה אם אפשר להגיע ל-API
                            def apiStatus = sh(script: 'kubectl cluster-info', returnStatus: true)
                            
                            if (apiStatus == 0) {
                                echo "הקלאסטר מוכן והגישה ל-API עובדת."
                                clusterReady = true
                            } else {
                                retryCount++
                                echo "נסיון ${retryCount}/${maxRetries}: לא ניתן להגיע ל-API. ממתין 10 שניות..."
                                sh "sleep 10"
                            }
                        } catch (Exception e) {
                            retryCount++
                            echo "נסיון ${retryCount}/${maxRetries}: שגיאה: ${e.message}. ממתין 10 שניות..."
                            sh "sleep 10"
                        }
                    }
                    
                    if (!clusterReady) {
                        error "לא ניתן להתחבר ל-Kubernetes API לאחר ${maxRetries} נסיונות. בדוק את הגדרות הקלאסטר."
                    }
                    
                    // המתנה שהצמתים יהיו מוכנים, רק לאחר שה-API זמין
                    sh 'kubectl get nodes'
                    echo "ממתין שהצמתים יהיו מוכנים..."
                    sh 'kubectl wait --for=condition=ready node --all --timeout=300s || true'
                }
            }
        }
        
        stage('הגדרת תגיות לצמתים') {
            steps {
                script {
                    // קבלת שמות הצמתים ושמירה במשתנים
                    def masterNode = sh(script: 'kubectl get nodes -o jsonpath=\'{.items[0].metadata.name}\'', returnStdout: true).trim()
                    def workerNode = sh(script: 'kubectl get nodes -o jsonpath=\'{.items[1].metadata.name}\'', returnStdout: true).trim()
                    
                    echo "הגדרת שם לשרת הראשון: ${params.CLUSTER_NAME}..."
                    sh "kubectl label nodes ${masterNode} kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite"
                    
                    echo "הגדרת שם לשרת השני: ${params.CLUSTER_NAME}-m02..."
                    sh "kubectl label nodes ${workerNode} kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite"
                }
            }
        }
        
        stage('אימות קלאסטר') {
            steps {
                script {
                    echo "מציג צמתים ותגיות:"
                    sh 'kubectl get nodes --show-labels'
                    
                    echo "הקלאסטר מוכן עם שני שרתים:"
                    echo "1. ${params.CLUSTER_NAME} - עבור מסד הנתונים"
                    echo "2. ${params.CLUSTER_NAME}-m02 - עבור הבקאנד והפרונטאנד"
                }
            }
        }
    }
    
    post {
        success {
            echo 'הקמת קלאסטר K3D Kubernetes הושלמה בהצלחה!'
        }
        failure {
            echo 'הקמת קלאסטר K3D Kubernetes נכשלה. בדוק את הלוגים לפרטים נוספים.'
        }
        always {
            echo 'תהליך Jenkins Pipeline הסתיים.'
        }
    }
}