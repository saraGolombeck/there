

// pipeline {
//     agent any
    
//     parameters {
//         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
//         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'מספר צמתי העבודה')
//         string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'מיפוי פורטים')
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
//                         --api-port 9999 \\
//                         -p "${params.PORT_MAPPING}"
//                     """
                    
//                     // יצירת קובץ kubeconfig
//                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
//                     sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
//                     // הנקודה הקריטית - תיקון קובץ kubeconfig
//                     sh """
//                         # החלפת הכתובת לכתובת הפנימית של serverlb
//                         sed -i 's|server: https://0.0.0.0:9999|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
//                         # בדיקת התיקון
//                         grep "server:" \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//                     """
                    
//                     // חיבור קונטיינר Jenkins לרשת של k3d
//                     sh """
//                         # חיבור הקונטיינר לרשת k3d
//                         docker network connect k3d-${params.CLUSTER_NAME} jenkins_jenkins_1 || true
//                     """
                    
//                     // המתנה להתייצבות הקלאסטר
//                     sh "sleep 30"
//                 }
//             }
//         }
        
//         // stage('הגדרת תגיות לצמתים') {
//         //     steps {
//         //         script {
//         //             sh """
//         //                 export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//         //                 kubectl config use-context k3d-${params.CLUSTER_NAME}
//         //             """
                    
//         //             sh "sleep 10"  // המתנה נוספת לוודא שהקלאסטר יציב
                    
//         //             sh """
//         //                 export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
//         //                 # קבלת רשימת הצמתים
//         //                 MASTER_NODE=\$(kubectl get nodes --no-headers | head -1 | awk '{print \$1}')
                        
//         //                 # הגדרת תגית לצומת הראשי
//         //                 if [ ! -z "\$MASTER_NODE" ]; then
//         //                     kubectl label nodes \$MASTER_NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
//         //                 fi
                        
//         //                 # טיפול בצמתי עבודה (אם יש יותר מצומת אחד)
//         //                 ADDITIONAL_NODES=\$(kubectl get nodes --no-headers | tail -n +2 | awk '{print \$1}')
//         //                 if [ ! -z "\$ADDITIONAL_NODES" ]; then
//         //                     NODE_INDEX=2
//         //                     echo "\$ADDITIONAL_NODES" | while read -r NODE; do
//         //                         kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m0\$NODE_INDEX --overwrite
//         //                         NODE_INDEX=\$((NODE_INDEX + 1))
//         //                     done
//         //                 fi
//         //             """
//         //         }
//         //     }
//         // }
//         stage('הגדרת תגיות לצמתים') {
//     steps {
//         script {
//             sh """
//                 export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//                 kubectl config use-context k3d-${params.CLUSTER_NAME}
//             """
            
//             sh "sleep 10"  // המתנה נוספת לוודא שהקלאסטר יציב
            
//             sh """
//                 export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                
//                 # קבלת כל הצמתים
//                 ALL_NODES=\$(kubectl get nodes --no-headers | awk '{print \$1}')
                
//                 # הגדרת התגית לצומת הראשי
//                 MASTER_NODE=\$(echo "\$ALL_NODES" | head -1)
//                 kubectl label nodes \$MASTER_NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
                
//                 # טיפול בצמתי עבודה
//                 WORKER_NODES=\$(echo "\$ALL_NODES" | tail -n +2)
//                 if [ ! -z "\$WORKER_NODES" ]; then
//                     for NODE in \$WORKER_NODES; do
//                         # לפי הקבצים שלך, צריכים לפחות צומת-עבודה אחד עם תגית my-cluster-m02
//                         kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite
//                         break
//                     done
//                 fi
                
//                 # הצגת התגיות
//                 echo "תגיות הצמתים:"
//                 kubectl get nodes --show-labels
//             """
//         }
//     }
// }        
//         stage('אימות הקלאסטר') {
//             steps {
//                 script {
//                     sh """
//                         export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
//                         echo "בדיקת הקלאסטר שנוצר:"
//                         kubectl cluster-info
                        
//                         echo "רשימת צמתים:"
//                         kubectl get nodes
                        
//                         echo "תגיות הצמתים:"
//                         kubectl get nodes --show-labels
                        
//                         echo "מצב רכיבי המערכת:"
//                         kubectl get pods -n kube-system
//                     """
//                 }
//             }
//         }
//     }
    
//     post {
//         success {
//             echo """
//             הקמת קלאסטר K3D Kubernetes הושלמה בהצלחה!
            
//             להתחברות לקלאסטר, השתמש בפקודה:
//             export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//             kubectl get nodes
//             """
//         }
//         failure {
//             echo 'הקמת קלאסטר K3D Kubernetes נכשלה.'
//         }
//     }
// }
//UNITED





pipeline {
    agent any
    
    triggers {
        cron('H */2 * * *') // רץ כל שעתיים
    }
    
    parameters {
        string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
        string(name: 'NUM_AGENTS', defaultValue: '1', description: 'מספר צמתי העבודה')
        string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'מיפוי פורטים')
    }
    
    environment {
        KUBECONFIG = "${WORKSPACE}/kubeconfig"
        SECRET_YAML_PATH = "${WORKSPACE}/secret.yaml"
        TEST_POD_YAML_PATH = "${WORKSPACE}/E2E_test/pod.yaml"
        TEST_SCRIPT_PATH = "${WORKSPACE}/E2E_test/test.sh"
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('מחיקת קלאסטר קיים') {
            steps {
                script {
                    sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
                }
            }
        }
        
        stage('יצירת קלאסטר חדש') {
            steps {
                script {
                    sh "mkdir -p \${HOME}/.kube"
                    
                    // יצירת הקלאסטר
                    sh """
                        k3d cluster create ${params.CLUSTER_NAME} \\
                        --agents ${params.NUM_AGENTS} \\
                        --timeout 5m \\
                        --api-port 6444 \\
                        -p "${params.PORT_MAPPING}"
                    """
                    
                    // יצירת קובץ kubeconfig
                    sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
                    // תיקון קובץ kubeconfig
                    sh """
                        # החלפת הכתובת לכתובת הפנימית של serverlb
                        sed -i 's|server: https://0.0.0.0:9999|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6444|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
                        # בדיקת התיקון
                        grep "server:" \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                    """
                    
                    // חיבור קונטיינר Jenkins לרשת של k3d
                    sh """
                        # חיבור הקונטיינר לרשת k3d
                        docker network connect k3d-${params.CLUSTER_NAME} jenkins_jenkins_1 || true
                    """
                    
                    // המתנה להתייצבות הקלאסטר
                    sh "sleep 5"
                    
                    // הגדרת משתנה סביבה KUBECONFIG לשימוש בשלבים הבאים
                    env.KUBECONFIG = "\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                }
            }
        }
        
        stage('הגדרת תגיות לצמתים') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        kubectl config use-context k3d-${params.CLUSTER_NAME}
                    """
                    
                    sh "sleep 10"  // המתנה נוספת לוודא שהקלאסטר יציב
                    
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
                        # קבלת כל הצמתים
                        ALL_NODES=\$(kubectl get nodes --no-headers | awk '{print \$1}')
                        
                        # הגדרת התגית לצומת הראשי (שעליו ירוץ הפוסטגרס)
                        MASTER_NODE=\$(echo "\$ALL_NODES" | head -1)
                        echo "צומת ראשי: \$MASTER_NODE"
                        kubectl label nodes \$MASTER_NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
                        
                        # טיפול בצמתי עבודה (שעליהם ירוצו הבקאנד והפרונטאנד)
                        WORKER_NODES=\$(echo "\$ALL_NODES" | tail -n +2)
                        if [ ! -z "\$WORKER_NODES" ]; then
                            for NODE in \$WORKER_NODES; do
                                echo "צומת עבודה: \$NODE"
                                kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite
                                break  # מספיק צומת עבודה אחד
                            done
                        else
                            echo "אזהרה: אין צמתי עבודה. הבקאנד והפרונטאנד לא יוכלו לרוץ עם ה-nodeSelector הנוכחי."
                        fi
                        
                        # הצגת התגיות
                        echo "תגיות הצמתים:"
                        kubectl get nodes --show-labels
                    """
                }
            }
        }
        
        stage('הפעלת האפליקציה') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
                        kubectl apply -k k8s/
                        

                    """
                }
            }
        }
        
        stage('יצירת פוד בדיקות') {
            steps {
                script {
                    // יצירת פוד הבדיקות עם הסביבה המתאימה
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
                        cat <<EOF > ${WORKSPACE}/e2e-test-pod.yaml
                        apiVersion: v1
                        kind: Pod
                        metadata:
                          name: e2e-tests
                        spec:
                          containers:
                          - name: e2e-tests
                            image: alpine:latest
                            command: [ "sh", "-c", "apk add --no-cache curl postgresql-client && sleep 3600" ]
                            env:
                            - name: DB_HOST
                              value: "db"
                            - name: DB_USER
                              valueFrom:
                                secretKeyRef:
                                  name: db-secret
                                  key: POSTGRES_USER
                            - name: DB_PASSWORD
                              valueFrom:
                                secretKeyRef:
                                  name: db-secret
                                  key: POSTGRES_PASSWORD
                            - name: API_URL
                              value: "http://be:3010/api/health"
                            - name: FRONTEND_URL
                              value: "http://fe"
                        EOF
                        
                        kubectl apply -f ${WORKSPACE}/e2e-test-pod.yaml
                        
                        echo "המתנה לעליית פוד הבדיקות..."
                        sleep 20
                        kubectl get pod e2e-tests
                    """
                }
            }
        }
        
        stage('הרצת בדיקות E2E') {
            steps {
                script {
                    // העתקת סקריפט הבדיקות לפוד
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
                        # העתקת סקריפט הבדיקות לפוד
                        kubectl cp ${TEST_SCRIPT_PATH} e2e-tests:/test.sh
                        
                        # הענקת הרשאות הרצה
                        kubectl exec e2e-tests -- chmod +x /test.sh
                        
                        # הרצת הבדיקות
                        echo "מריץ בדיקות..."
                        kubectl exec e2e-tests -- sh -c '/test.sh'
                    """
                }
            }
        }
        
        stage('אימות הקלאסטר') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
                        echo "בדיקת הקלאסטר הסופית:"
                        kubectl cluster-info
                        
                        echo "רשימת צמתים:"
                        kubectl get nodes
                        
                        echo "רשימת פודים:"
                        kubectl get pods --all-namespaces
                        
                        echo "רשימת שירותים:"
                        kubectl get services
                    """
                }
            }
        }
        
        stage('ניקוי') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
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
            הקמת קלאסטר K3D Kubernetes והרצת בדיקות הושלמו בהצלחה!
            
            להתחברות לקלאסטר, השתמש בפקודה:
            export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
            kubectl get pods
            """
        }
        failure {
            echo 'הקמת קלאסטר K3D Kubernetes או הרצת הבדיקות נכשלו.'
        }
        always {
            echo 'הסרת קבצים זמניים...'
            sh "rm -f ${WORKSPACE}/e2e-test-pod.yaml"
        }
    }
}