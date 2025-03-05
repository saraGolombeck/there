pipeline {
    agent any
    
    triggers {
        cron('H */2 * * *') // Run every 2 hours
    }
    
    environment {
        // הנתיב לקובץ הקונפיגורציה של K3d
        KUBECONFIG = "${WORKSPACE}/kubeconfig-my-cluster.yaml"
    }
    
    stages {
        stage('Verify K3d Connection') {
            steps {
                script {
                    sh '''
                    echo "בדיקת חיבור ל-K3d..."
                    ./upload_cluster.sh                    
                    # ייצא את הקונפיגורציה למשתנה סביבה
                    export KUBECONFIG=${KUBECONFIG}
                    
                    # בדיקת חיבור
                    if ! kubectl get nodes; then
                        echo "לא ניתן להתחבר לקלאסטר באמצעות kubectl"
                        echo "ייתכן שקובץ ה-KUBECONFIG אינו תקין או שהקלאסטר אינו פעיל"
                        exit 1
                    fi
                    '''
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                script {
                    // פרוס את האפליקציה
                    sh '''
                    echo "פריסת האפליקציה..."
                    
                    # הגדר את הקונפיגורציה לקוברנטיס
                    export KUBECONFIG=$KUBECONFIG
                    
                    # בדוק אילו קבצים קיימים
                    ls -la k8s/
                    
                    # נסה להשתמש בkustomize אם יש קובץ מתאים
                    if [ -f k8s/kustomization.yaml ]; then
                        kubectl apply -k k8s/
                    else
                        # אחרת החל כל קובץ YAML בנפרד
                        for file in k8s/*.yaml; do
                            if [ -f "$file" ]; then
                                echo "מחיל $file"
                                kubectl apply -f "$file" || echo "לא ניתן להחיל $file"
                            fi
                        done
                    fi
                    
                    # המתן שכל השירותים יהיו זמינים
                    echo "ממתין שהאפליקציה תהיה מוכנה..."
                    kubectl get deployments
                    kubectl wait --for=condition=available --timeout=300s deployment --all || echo "לא כל השירותים זמינים"
                    '''
                }
            }
        }
        
        stage('Create Test Environment') {
            steps {
                script {
                    sh '''
                    echo "יצירת סביבת בדיקות..."
                    
                    # הגדר את הקונפיגורציה לקוברנטיס
                    export KUBECONFIG=$KUBECONFIG
                    
                    # יצירת הסיקרט עם משתני הסביבה לבדיקות
                    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: e2e-env-secret
type: Opaque
stringData:
  DB_HOST: "postgres-service"
  DB_USER: "postgres"
  DB_PASSWORD: "postgres"
  API_URL: "http://backend-service/api/health"
  FRONTEND_URL: "http://frontend-service"
EOF
                    
                    # בדוק אם קובץ ה-Pod קיים
                    if [ -f "E2E_test/pod.yaml" ]; then
                        echo "מפרס את Pod הבדיקות..."
                        kubectl apply -f E2E_test/pod.yaml
                        
                        # המתן שה-Pod יהיה מוכן
                        echo "ממתין שה-Pod יהיה מוכן..."
                        kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || echo "ה-Pod לא מוכן עדיין"
                    else
                        echo "קובץ pod.yaml לא נמצא ב-E2E_test/"
                        exit 1
                    fi
                    '''
                }
            }
        }
        
        stage('Run E2E Tests') {
            steps {
                script {
                    sh '''
                    echo "הרצת בדיקות E2E..."
                    
                    # הגדר את הקונפיגורציה לקוברנטיס
                    export KUBECONFIG=$KUBECONFIG
                    
                    # בדוק אם קובץ הבדיקה קיים
                    if [ -f "E2E_test/test.sh" ]; then
                        echo "מעתיק את סקריפט הבדיקה ל-Pod..."
                        kubectl cp E2E_test/test.sh e2e-tests:/e2e-tests.sh
                        
                        echo "מריץ את הבדיקות..."
                        kubectl exec e2e-tests -- sh -c "chmod +x /e2e-tests.sh && /e2e-tests.sh"
                    else
                        echo "קובץ test.sh לא נמצא ב-E2E_test/"
                        exit 1
                    fi
                    '''
                }
            }
        }
        
        stage('Clean Up Test Environment') {
            steps {
                script {
                    sh '''
                    echo "ניקוי סביבת הבדיקות..."
                    
                    # הגדר את הקונפיגורציה לקוברנטיס
                    export KUBECONFIG=$KUBECONFIG
                    
                    kubectl delete pod e2e-tests --ignore-not-found
                    kubectl delete secret e2e-env-secret --ignore-not-found
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
        }
        success {
            echo 'All tests passed successfully'
        }
        failure {
            echo 'Tests failed or pipeline encountered errors'
        }
    }
}