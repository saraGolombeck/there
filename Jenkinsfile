// pipeline {
//     agent any

//     triggers {
//         cron('H */2 * * *') // Run every 2 hours
//     }

//     environment {
//         KUBECONFIG_PATH = "${WORKSPACE}/kubeconfig"
//         SECRET_YAML_PATH = "${WORKSPACE}/secret.yaml"
//         TEST_POD_YAML_PATH = "${WORKSPACE}/E2E_test/test-pod.yaml"
//     }

//     stages {
//         stage('Setup Environment') {
//             steps {
//                 script {
//                     // Retrieve kubeconfig from Jenkins secret
//                     withCredentials([file(credentialsId: 'kubeconfig-credential-id', variable: 'KUBECONFIG_SECRET')]) {
//                         sh "cp $KUBECONFIG_SECRET $KUBECONFIG_PATH"
//                     }

//                     // Retrieve secret YAML from Jenkins secret
//                     withCredentials([file(credentialsId: 'secret-yaml-credential-id', variable: 'SECRET_YAML')]) {
//                         sh "cp $SECRET_YAML $SECRET_YAML_PATH"
//                     }

//                     // Export kubeconfig for kubectl
//                     sh "export KUBECONFIG=$KUBECONFIG_PATH"
//                 }
//             }
//         }

//         stage('Apply Secrets and Deploy Test Pod') {
//             steps {
//                 script {
//                     // Apply the secret
//                     sh "kubectl apply -f $SECRET_YAML_PATH"

//                     // Deploy the test pod
//                     sh "kubectl apply -f $TEST_POD_YAML_PATH"
//                 }
//             }
//         }

//         stage('Run E2E Tests') {
//             steps {
//                 script {
//                     // Copy the E2E test script to the test pod
//                     sh '''
//                     kubectl cp E2E_test/e2e-tests.sh e2e-tests:/e2e-tests.sh
//                     kubectl exec -it e2e-tests -- sh -c "chmod +x /e2e-tests.sh && /e2e-tests.sh"
//                     '''
//                 }
//             }
//         }

//         stage('Clean Up') {
//             steps {
//                 script {
//                     // Delete the test pod and secret
//                     sh '''
//                     kubectl delete pod e2e-tests --ignore-not-found
//                     kubectl delete -f $SECRET_YAML_PATH --ignore-not-found
//                     '''
//                 }
//             }
//         }
//     }

//     post {
//         always {
//             echo 'Pipeline execution completed'
//         }
//         cleanup {
//             script {
//                 // Remove temporary kubeconfig
//                 sh "rm -f $KUBECONFIG_PATH $SECRET_YAML_PATH"
//             }
//         }
//     }
// }

pipeline {
    agent any
    
    triggers {
        cron('H */2 * * *') // Run every 2 hours
    }
    
    environment {
        KUBECONFIG_PATH = "${WORKSPACE}/kubeconfig"
        TEST_POD_YAML_PATH = "${WORKSPACE}/E2E_test/pod.yaml"
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                sshagent(['github']) {
                    sh 'rm -rf gitops'
                    sh 'git clone git@github.com:le7-devops/gitops.git'
                    sh 'cd gitops'
                }
            }
        }
        
        stage('Setup K3d Environment') {
            steps {
                script {
                    // Install K3d if not present
                    sh '''
                    cd gitops
                    if ! command -v k3d &> /dev/null; then
                        wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
                    fi
                    '''
                    
                    // Run the existing setup-cluster.sh script
                    sh '''
                    cd gitops
                    chmod +x ./upload_cluster.sh
                    ./upload_cluster.sh
                    
                    # Save kubeconfig for future stages
                    k3d kubeconfig get my-cluster > ${KUBECONFIG_PATH}
                    export KUBECONFIG=${KUBECONFIG_PATH}
                    '''
                }
            }
        }
        
        stage('Deploy Application') {
            steps {
                script {
                    // Set kubeconfig
                    sh "export KUBECONFIG=${KUBECONFIG_PATH}"
                    
                    // Deploy application using kustomize or direct yaml files
                    sh '''
                    cd gitops
                    # Apply all configurations from k8s directory
                    if [ -f k8s/kustomization.yaml ]; then
                        kubectl apply -k k8s/
                    else
                        # Apply individual files if no kustomization exists
                        kubectl apply -f k8s/config-and-secrets.yaml
                        kubectl apply -f k8s/postgres-deployment.yaml
                        kubectl apply -f k8s/backend-deployment.yaml
                        kubectl apply -f k8s/frontend-deployment.yaml
                    fi
                    
                    # Wait for deployments to be ready
                    kubectl wait --for=condition=available --timeout=300s deployment --all
                    '''
                }
            }
        }
        
        stage('Create Test Environment') {
            steps {
                script {
                    // Set kubeconfig
                    sh "export KUBECONFIG=${KUBECONFIG_PATH}"
                    
                    // Create secret with environment variables for tests
                    sh '''
                    cd gitops
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
                    '''
                    
                    // Deploy the test pod
                    sh "kubectl apply -f ${TEST_POD_YAML_PATH}"
                    
                    // Wait for pod to be ready
                    sh "kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s"
                }
            }
        }
        
        stage('Run E2E Tests') {
            steps {
                script {
                    // Set kubeconfig
                    sh "export KUBECONFIG=${KUBECONFIG_PATH}"
                    
                    // Copy the E2E test script to the test pod
                    sh '''
                    cd gitops
                    kubectl cp E2E_test/test.sh e2e-tests:/e2e-tests.sh
                    kubectl exec e2e-tests -- sh -c "chmod +x /e2e-tests.sh && /e2e-tests.sh"
                    '''
                }
            }
        }
        
        stage('Clean Up Test Environment') {
            steps {
                script {
                    // Set kubeconfig
                    sh "export KUBECONFIG=${KUBECONFIG_PATH}"
                    
                    // Delete the test pod and secret
                    sh '''
                    cd gitops
                    kubectl delete pod e2e-tests --ignore-not-found
                    kubectl delete secret e2e-env-secret --ignore-not-found
                    '''
                }
            }
        }
        
        stage('Push Version to Git') {
            steps {
                sshagent(['github']) {
                    script {
                        sh '''
                        cd gitops
                        git config user.email "your-email@example.com"
                        git config user.name "Your Name"
                        git tag -a v$(date +"%Y%m%d%H%M%S") -m "Automated version update"
                        git push --tags
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
        }
        cleanup {
            script {
                // Clean up temporary files
                sh "rm -f ${KUBECONFIG_PATH}"
            }
        }
    }
}