

pipeline {
    agent any
    
    parameters {
        string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'שם הקלאסטר')
        string(name: 'NUM_AGENTS', defaultValue: '1', description: 'מספר צמתי העבודה')
        string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'מיפוי פורטים')
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
                        --api-port 9999 \\
                        -p "${params.PORT_MAPPING}"
                    """
                    
                    // יצירת קובץ kubeconfig
                    sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
                    // הנקודה הקריטית - תיקון קובץ kubeconfig
                    sh """
                        # החלפת הכתובת לכתובת הפנימית של serverlb
                        sed -i 's|server: https://0.0.0.0:9999|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
                        # בדיקת התיקון
                        grep "server:" \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                    """
                    
                    // חיבור קונטיינר Jenkins לרשת של k3d
                    sh """
                        # חיבור הקונטיינר לרשת k3d
                        docker network connect k3d-${params.CLUSTER_NAME} jenkins_jenkins_1 || true
                    """
                    
                    // המתנה להתייצבות הקלאסטר
                    sh "sleep 30"
                }
            }
        }
        
        // stage('הגדרת תגיות לצמתים') {
        //     steps {
        //         script {
        //             sh """
        //                 export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
        //                 kubectl config use-context k3d-${params.CLUSTER_NAME}
        //             """
                    
        //             sh "sleep 10"  // המתנה נוספת לוודא שהקלאסטר יציב
                    
        //             sh """
        //                 export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
        //                 # קבלת רשימת הצמתים
        //                 MASTER_NODE=\$(kubectl get nodes --no-headers | head -1 | awk '{print \$1}')
                        
        //                 # הגדרת תגית לצומת הראשי
        //                 if [ ! -z "\$MASTER_NODE" ]; then
        //                     kubectl label nodes \$MASTER_NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
        //                 fi
                        
        //                 # טיפול בצמתי עבודה (אם יש יותר מצומת אחד)
        //                 ADDITIONAL_NODES=\$(kubectl get nodes --no-headers | tail -n +2 | awk '{print \$1}')
        //                 if [ ! -z "\$ADDITIONAL_NODES" ]; then
        //                     NODE_INDEX=2
        //                     echo "\$ADDITIONAL_NODES" | while read -r NODE; do
        //                         kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m0\$NODE_INDEX --overwrite
        //                         NODE_INDEX=\$((NODE_INDEX + 1))
        //                     done
        //                 fi
        //             """
        //         }
        //     }
        // }
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
                
                # הגדרת התגית לצומת הראשי
                MASTER_NODE=\$(echo "\$ALL_NODES" | head -1)
                kubectl label nodes \$MASTER_NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
                
                # טיפול בצמתי עבודה
                WORKER_NODES=\$(echo "\$ALL_NODES" | tail -n +2)
                if [ ! -z "\$WORKER_NODES" ]; then
                    for NODE in \$WORKER_NODES; do
                        # לפי הקבצים שלך, צריכים לפחות צומת-עבודה אחד עם תגית my-cluster-m02
                        kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite
                        break
                    done
                fi
                
                # הצגת התגיות
                echo "תגיות הצמתים:"
                kubectl get nodes --show-labels
            """
        }
    }
}        
        stage('אימות הקלאסטר') {
            steps {
                script {
                    sh """
                        export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                        
                        echo "בדיקת הקלאסטר שנוצר:"
                        kubectl cluster-info
                        
                        echo "רשימת צמתים:"
                        kubectl get nodes
                        
                        echo "תגיות הצמתים:"
                        kubectl get nodes --show-labels
                        
                        echo "מצב רכיבי המערכת:"
                        kubectl get pods -n kube-system
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo """
            הקמת קלאסטר K3D Kubernetes הושלמה בהצלחה!
            
            להתחברות לקלאסטר, השתמש בפקודה:
            export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
            kubectl get nodes
            """
        }
        failure {
            echo 'הקמת קלאסטר K3D Kubernetes נכשלה.'
        }
    }
}