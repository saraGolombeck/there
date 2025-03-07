
// pipeline {
//     agent any
    
//     triggers {
//         cron('H */2 * * *') // רץ כל שעתיים
//     }
    
//     parameters {
//         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
//         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'מספר צמתי העבודה')
//         string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'מיפוי פורטים')
//     }
    
//     environment {
//         KUBECONFIG = "${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
//         SECRET_YAML_PATH = "${WORKSPACE}/secret.yaml"
//         TEST_POD_YAML_PATH = "${WORKSPACE}/E2E_test/pod.yaml"
//         TEST_SCRIPT_PATH = "${WORKSPACE}/E2E_test/test.sh"
//     }
    
//     options {
//         timeout(time: 30, unit: 'MINUTES')
//     }
    
//     stages {
//         stage('מחיקת קלאסטר קיים') {
//             steps {
//                 script {
//                     sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
//                 }
//             }
//         }
        
//         stage('יצירת קלאסטר חדש') {
//             steps {
//                 script {
//                     sh "mkdir -p \${HOME}/.kube"
                    
//                     // יצירת הקלאסטר
//                     sh """
//                         k3d cluster create ${params.CLUSTER_NAME} \\
//                         --agents ${params.NUM_AGENTS} \\
//                         --timeout 5m \\
//                         --api-port 6443 \\
//                         -p "${params.PORT_MAPPING}"
//                     """
                    
//                     // יצירת קובץ kubeconfig
//                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
//                     sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
//                     // תיקון קובץ kubeconfig - החלפת הכתובת לשם הדומיין הפנימי של serverlb
//                     sh """
//                         # החלפת 0.0.0.0 בשם הדומיין הפנימי של serverlb
//                         sed -i 's|server: https://0.0.0.0:6443|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
//                         # בדיקת התיקון
//                         grep "server:" \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//                     """
                    
//                     // חיבור קונטיינר Jenkins לרשת של k3d
//                     sh """
//                         # בדיקה אם הקונטיינר כבר מחובר לרשת
//                         docker network connect k3d-${params.CLUSTER_NAME} \$HOSTNAME || echo "כבר מחובר לרשת"
//                     """
                    
//                     // המתנה להתייצבות הקלאסטר
//                     sh "sleep 10"
                    
//                     // בדיקה שהקלאסטר נגיש
//                     sh """
//                         kubectl --kubeconfig=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config get nodes
//                     """
//                 }
//             }
//         }
        


// stage('הגדרת תגיות לצמתים') {
//     steps {
//         script {
//             sh """
//                 export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//                 kubectl config use-context k3d-${params.CLUSTER_NAME}
//             """
            
//             sh """
//                 # קבלת כל הצמתים
//                 ALL_NODES=\$(kubectl get nodes --no-headers | awk '{print \$1}')
                
//                 # זיהוי צומת מאסטר (server) וצומת עבודה (agent)
//                 for NODE in \$ALL_NODES; do
//                     if [[ "\$NODE" == *"server"* ]]; then
//                         echo "צומת מאסטר (שרת): \$NODE"
//                         # לצומת המאסטר - תווית שתשמש את הפוסטגרס
//                         kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
//                     elif [[ "\$NODE" == *"agent"* ]]; then
//                         echo "צומת עבודה (סוכן): \$NODE"
//                         # לצומת העבודה - תווית שתשמש את הבקאנד והפרונטאנד
//                         kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite
//                     fi
//                 done
                
//                 # הצגת התגיות לאימות
//                 echo "תגיות הצמתים:"
//                 kubectl get nodes --show-labels
//             """
//         }
//     }
// }

//         stage('הפעלת האפליקציה') {
//             steps {
//                 script {
//                     sh """
//                         kubectl apply -k k8s/
//                     """
//                 }
//             }
//         }
        
// stage('י 2 צירת פוד בדיקות') {
//     steps {
//         script {
//             // בדיקה שקובץ pod.yaml קיים
//             sh "ls -la ${WORKSPACE}/E2E_test/pod.yaml"
//             sh "kubectl apply -f E2E_test/secret.yaml"
//             // יישום הפוד ישירות מהקובץ הקיים
//             sh "kubectl apply -f ${WORKSPACE}/E2E_test/pod.yaml"
            
//             // המתנה שהפוד יהיה מוכן
//             sh """
//                 echo "ממתין שפוד הבדיקות יהיה מוכן..."
//                 sleep 10
//                 kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || true
//                 kubectl get pods
//             """
//         }
//     }
// }
// stage('הרצת בדיקות E2E') {
//     steps {
//         script {
//             // העתקת סקריפט הבדיקות והרצתו
//             sh """
//                 # העתקת סקריפט הבדיקות לפוד
//                 kubectl cp E2E_test/test.sh e2e-tests:/test.sh
                
//                 # בדיקה שהקובץ אכן הועתק
//                 kubectl exec e2e-tests -- ls -la /
                
//                 # הענקת הרשאות הרצה
//                 kubectl exec e2e-tests -- chmod +x /test.sh
                
//                 # בדיקה נוספת של הרשאות
//                 kubectl exec e2e-tests -- ls -la /test.sh
                
//                 # הרצת הבדיקות עם sh מפורש
//                 echo "מריץ בדיקות..."
//                 kubectl exec e2e-tests -- bash /test.sh
//             """
//         }
//     }
// }

//         stage('אימות הקלאסטר') {
//             steps {
//                 script {
//                     sh """
//                         echo "בדיקת הקלאסטר הסופית:"
//                         kubectl cluster-info
                        
//                         echo "רשימת צמתים:"
//                         kubectl get nodes
                        
//                         echo "רשימת פודים:"
//                         kubectl get pods --all-namespaces
                        
//                         echo "רשימת שירותים:"
//                         kubectl get services
//                     """
//                 }
//             }
//         }
        
//         stage('ניקוי') {
//             steps {
//                 script {
//                     sh """
//                         # מחיקת פוד הבדיקות
//                         kubectl delete pod e2e-tests --ignore-not-found
//                     """
//                 }
//             }
//         }
//     }
    
//     post {
//         success {
//             echo """
//             הקמת קלאסטר K3D Kubernetes והרצת בדיקות הושלמו בהצלחה!
            
//             להתחברות לקלאסטר, השתמש בפקודה:
//             export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//             kubectl get pods
//             """
//         }
//         failure {
//             echo 'הקמת קלאסטר K3D Kubernetes או הרצת הבדיקות נכשלו.'
//         }
//         always {
//             echo 'הסרת קבצים זמניים...'
//             sh "rm -f ${WORKSPACE}/e2e-test-pod.yaml"
//         }
//     }
// }






///with



pipeline {
    agent any
    
    triggers {
        cron('H */2 * * *') // רץ כל שעתיים
    }
    
    parameters {
        string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
        string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'מיפוי פורטים')
    }
    
    environment {
        // שימוש בקרדנשיאלס לקובץ הקונפיג
        KUBE_CONFIG_ID = 'k3d-cluster-credentials'
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('בדיקת זמינות הקלאסטר') {
            steps {
                withKubeConfig([credentialsId: env.KUBE_CONFIG_ID, contextName: "k3d-${params.CLUSTER_NAME}"]) {
                    sh """
                        echo "בודק גישה לקלאסטר ${params.CLUSTER_NAME}..."
                        kubectl get nodes
                        if [ \$? -ne 0 ]; then
                            echo "שגיאה: לא ניתן להתחבר לקלאסטר ${params.CLUSTER_NAME}"
                            exit 1
                        fi
                        echo "התחברות לקלאסטר ${params.CLUSTER_NAME} הצליחה"
                    """
                }
            }
        }
        
        stage('הפעלת האפליקציה') {
            steps {
                withKubeConfig([credentialsId: env.KUBE_CONFIG_ID, contextName: "k3d-${params.CLUSTER_NAME}"]) {
                    sh """
                        kubectl apply -k k8s/
                        
                        # המתנה להתייצבות הפודים
                        echo "ממתין להתייצבות האפליקציה..."
                        sleep 10
                        kubectl get pods
                    """
                }
            }
        }
        
        stage('יצירת פוד בדיקות') {
            steps {
                withKubeConfig([credentialsId: env.KUBE_CONFIG_ID, contextName: "k3d-${params.CLUSTER_NAME}"]) {
                    sh """
                        # בדיקה שקובץ pod.yaml קיים
                        ls -la ${WORKSPACE}/E2E_test/pod.yaml
                        
                        # יישום הסקרט
                        kubectl apply -f E2E_test/secret.yaml
                        
                        # יישום הפוד ישירות מהקובץ הקיים
                        kubectl apply -f ${WORKSPACE}/E2E_test/pod.yaml
                        
                        # המתנה שהפוד יהיה מוכן
                        echo "ממתין שפוד הבדיקות יהיה מוכן..."
                        sleep 10
                        kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || true
                        kubectl get pods
                    """
                }
            }
        }
        
        stage('הרצת בדיקות E2E') {
            steps {
                withKubeConfig([credentialsId: env.KUBE_CONFIG_ID, contextName: "k3d-${params.CLUSTER_NAME}"]) {
                    sh """
                        # העתקת סקריפט הבדיקות לפוד
                        kubectl cp E2E_test/test.sh e2e-tests:/test.sh
                        
                        # בדיקה שהקובץ אכן הועתק
                        kubectl exec e2e-tests -- ls -la /
                        
                        # הענקת הרשאות הרצה
                        kubectl exec e2e-tests -- chmod +x /test.sh
                        
                        # הרצת הבדיקות עם bash מפורש
                        echo "מריץ בדיקות..."
                        kubectl exec e2e-tests -- bash /test.sh
                    """
                }
            }
        }
        
        stage('אימות האפליקציה') {
            steps {
                withKubeConfig([credentialsId: env.KUBE_CONFIG_ID, contextName: "k3d-${params.CLUSTER_NAME}"]) {
                    sh """
                        echo "בדיקת האפליקציה:"
                        kubectl get pods
                        
                        echo "רשימת שירותים:"
                        kubectl get services
                        
                        echo "לוגים של הפודים:"
                        for pod in \$(kubectl get pods -o name | grep -v 'e2e-tests'); do
                            echo "\\n==== לוגים של \$pod ===="
                            kubectl logs \$pod --tail=20
                        done
                    """
                }
            }
        }
        
        stage('ניקוי') {
            steps {
                withKubeConfig([credentialsId: env.KUBE_CONFIG_ID, contextName: "k3d-${params.CLUSTER_NAME}"]) {
                    sh """
                        # מחיקת פוד הבדיקות
                        kubectl delete pod e2e-tests --ignore-not-found
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo """
            הפעלת האפליקציה על קלאסטר K3D Kubernetes והרצת בדיקות הושלמו בהצלחה!
            
            הקלאסטר ${params.CLUSTER_NAME} פעיל ומריץ את האפליקציה.
            """
        }
        failure {
            echo 'הפעלת האפליקציה או הרצת הבדיקות נכשלו.'
        }
        always {
            echo 'הסרת קבצים זמניים...'
            sh "rm -f ${WORKSPACE}/e2e-test-pod.yaml"
        }
    }
}