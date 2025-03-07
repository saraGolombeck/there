
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

pipeline {
    agent any
    
    triggers {
        cron('H */2 * * *') // Runs every 2 hours
    }
    
    parameters {
        string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'Cluster name')
        string(name: 'NUM_AGENTS', defaultValue: '1', description: 'Number of worker nodes')
        string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'Port mapping')
    }
    
    environment {
        KUBECONFIG = "${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('Delete existing cluster') {
            steps {
                script {
                    sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
                }
            }
        }
        
        stage('Create new cluster') {
            steps {
                script {
                    sh "mkdir -p \${HOME}/.kube"
                    
                    // Create cluster
                    sh """
                        k3d cluster create ${params.CLUSTER_NAME} \\
                        --agents ${params.NUM_AGENTS} \\
                        --timeout 5m \\
                        --api-port 6443 \\
                        -p "${params.PORT_MAPPING}"
                    """
                    
                    // Create kubeconfig file
                    sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
                    // Fix kubeconfig - replace address with internal domain name
                    // sh """
                    //     sed -i 's|server: https://0.0.0.0:6443|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                    // """
                    
                    // Connect Jenkins container to k3d network
                    sh "docker network connect k3d-${params.CLUSTER_NAME} \$HOSTNAME || true"
                    
                    // Wait for cluster to stabilize
                    sh "sleep 10"
                }
            }
        }
        
        stage('Set node labels') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        kubectl config use-context k3d-${params.CLUSTER_NAME}
                        
                        # Get all nodes
                        ALL_NODES=\$(kubectl get nodes --no-headers | awk '{print \$1}')
                        
                        # Identify master and worker nodes
                        for NODE in \$ALL_NODES; do
                            if [ "\$(echo \$NODE | grep server)" != "" ]; then
                                kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
                            elif [ "\$(echo \$NODE | grep agent)" != "" ]; then
                                kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite
                            fi
                        done
                    """
                }
            }
        }

        stage('Deploy application') {
            steps {
                script {
                    sh "kubectl apply -k k8s/"
                }
            }
        }
        
        stage('Create test pod') {
            steps {
                script {
                    sh "kubectl apply -f E2E_test/secret.yaml"
                    sh "kubectl apply -f E2E_test/pod.yaml"
                    
                    // Wait for pod to be ready
                    sh "kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || true"
                }
            }
        }
        
        stage('Run E2E tests') {
            steps {
                script {
                    sh """
                        # Copy test script to pod
                        kubectl cp E2E_test/test.sh e2e-tests:/test.sh
                        
                        # Grant execution permissions
                        kubectl exec e2e-tests -- chmod +x /test.sh
                        
                        # Run tests
                        kubectl exec e2e-tests -- bash /test.sh
                    """
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    sh "kubectl delete pod e2e-tests --ignore-not-found"
                }
            }
        }
    }
    
    post {
        success {
            echo """
            K3D Kubernetes cluster setup and tests completed successfully!
            
            To connect to the cluster, use:
            export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
            kubectl get pods
            """
        }
        failure {
            echo 'K3D Kubernetes cluster setup or tests failed.'
        }
    }
}