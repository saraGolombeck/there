pipeline {
    agent any

    environment {
        KUBECONFIG_PATH = "${WORKSPACE}/kubeconfig"
        SECRET_YAML_PATH = "${WORKSPACE}/secret.yaml"
        TEST_POD_YAML_PATH = "${WORKSPACE}/E2E_test/test-pod.yaml"
    }

    stages {
        stage('Setup Environment') {
            steps {
                script {
                    // Retrieve kubeconfig from Jenkins secret
                    withCredentials([file(credentialsId: 'kubeconfig-credential-id', variable: 'KUBECONFIG_SECRET')]) {
                        sh "cp $KUBECONFIG_SECRET $KUBECONFIG_PATH"
                    }

                    // Retrieve secret YAML from Jenkins secret
                    withCredentials([file(credentialsId: 'secret-yaml-credential-id', variable: 'SECRET_YAML')]) {
                        sh "cp $SECRET_YAML $SECRET_YAML_PATH"
                    }

                    // Export kubeconfig for kubectl
                    sh "export KUBECONFIG=$KUBECONFIG_PATH"
                }
            }
        }

        stage('Apply Secrets and Deploy Test Pod') {
            steps {
                script {
                    // Apply the secret
                    sh "kubectl apply -f $SECRET_YAML_PATH"

                    // Deploy the test pod
                    sh "kubectl apply -f $TEST_POD_YAML_PATH"
                }
            }
        }

        stage('Run E2E Tests') {
            steps {
                script {
                    // Copy the E2E test script to the test pod
                    sh '''
                    kubectl cp E2E_test/e2e-tests.sh e2e-tests:/e2e-tests.sh
                    kubectl exec -it e2e-tests -- sh -c "chmod +x /e2e-tests.sh && /e2e-tests.sh"
                    '''
                }
            }
        }

        stage('Clean Up') {
            steps {
                script {
                    // Delete the test pod and secret
                    sh '''
                    kubectl delete pod e2e-tests --ignore-not-found
                    kubectl delete -f $SECRET_YAML_PATH --ignore-not-found
                    '''
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
                // Remove temporary kubeconfig
                sh "rm -f $KUBECONFIG_PATH $SECRET_YAML_PATH"
            }
        }
    }
}
