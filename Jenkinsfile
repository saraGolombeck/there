
pipeline {
    agent any
    
    triggers {
        cron('H */2 * * *') // Runs every 2 hours
    }
    
    parameters {
        string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'Cluster name')
        string(name: 'NUM_AGENTS', defaultValue: '1', description: 'Number of worker nodes')
        string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'Port mapping')
        string(name: 'K3D_VERSION', defaultValue: 'latest', description: 'k3d version to install')
        string(name: 'KUBECTL_VERSION', defaultValue: 'latest', description: 'kubectl version to install')
        string(name: 'EMAIL_RECIPIENTS', defaultValue: 'sara.beck.dev@gmail.com', description: 'Email recipients for notifications')
    }
    
    environment {
        // Kubernetes configuration
        KUBECONFIG = "${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
        KUBE_DIR = "${HOME}/.kube"
        
        // Define single credential file for all E2E test environment variables
        E2E_CONFIG = credentials('e2e-config')
        
        // Paths for application files
        K8S_DIR = "${WORKSPACE}/k8s"
        
        // Paths for E2E test files
        E2E_TEST_DIR = "${WORKSPACE}/E2E_test"
        TEST_POD_YAML = "${E2E_TEST_DIR}/pod.yaml"
        TEST_SCRIPT = "${E2E_TEST_DIR}/test.sh"
        
        // Paths for test reports
        TEST_REPORTS_DIR = "${WORKSPACE}/test-reports"
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
    }
    
    stages {
        stage('Prepare k3d Environment') {
            steps {
                script {
                    echo "Preparing environment for k3d Kubernetes cluster"

                    
                    // Install k3d if not present or update
                    sh '''
                        if ! command -v k3d &> /dev/null; then
                            echo "k3d is not installed. Installing k3d..."
                            curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
                            echo "k3d installed successfully"
                        else
                            current_version=$(k3d version | grep k3d | cut -d' ' -f3)
                            echo "Current k3d version: $current_version"
                            
                            if [ "${params.K3D_VERSION}" != "latest" ] && [ "$current_version" != "${params.K3D_VERSION}" ]; then
                                echo "Updating k3d to version ${params.K3D_VERSION}..."
                                curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | K3D_INSTALL_VERSION="${params.K3D_VERSION}" bash
                            fi
                        fi
                        
                        k3d version
                    '''
                    
                    // Check for kubectl and get version information
                    sh '''
                        if command -v kubectl &> /dev/null; then
                            echo "kubectl is already installed"
                            kubectl version --client
                        else
                            echo "kubectl is not installed. Installing kubectl..."
                            if [ "${params.KUBECTL_VERSION}" = "latest" ]; then
                                # Get stable version without subshell command substitution
                                STABLE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
                                curl -LO "https://dl.k8s.io/release/${STABLE_VERSION}/bin/linux/amd64/kubectl"
                            else
                                curl -LO "https://dl.k8s.io/release/v${params.KUBECTL_VERSION}/bin/linux/amd64/kubectl"
                            fi
                            chmod +x kubectl
                            sudo mv kubectl /usr/local/bin/
                            echo "kubectl installed successfully"
                            kubectl version --client
                        fi
                    '''
                    
                    // Ensure .kube directory exists
                    sh "mkdir -p ${KUBE_DIR}"
                }
            }
        }
        
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
                    sh "mkdir -p ${KUBE_DIR}"
                    
                    // Create cluster
                    sh """
                        k3d cluster create ${params.CLUSTER_NAME} \\
                        --agents ${params.NUM_AGENTS} \\
                        --timeout 5m \\
                        --api-port 6443 \\
                        -p "${params.PORT_MAPPING}"
                    """
                    
                    // Create kubeconfig file
                    sh "k3d kubeconfig get ${params.CLUSTER_NAME} > ${KUBECONFIG}"
                    sh "chmod 600 ${KUBECONFIG}"
                    
                    // Fix kubeconfig - replace address with internal domain name
                    sh """
                        sed -i 's|server: https://0.0.0.0:6443|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' ${KUBECONFIG}
                    """
                    
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
                        export KUBECONFIG=${KUBECONFIG}
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
                    sh "kubectl apply -k ${K8S_DIR}"
                }
            }
        }
        
        stage('Create E2E test secrets') {
            steps {
                script {
                    // Parse the JSON config file
                    def config = readJSON file: "${E2E_CONFIG}"
                    
                    // Create secret from Jenkins credentials
                    sh """
                        cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: e2e-env-secret
type: Opaque
stringData:
  DB_HOST: "${config.DB_HOST}"
  DB_USER: "${config.DB_USER}"
  DB_PASSWORD: "${config.DB_PASSWORD}"
  API_URL: "${config.API_URL}"
  FRONTEND_URL: "${config.FRONTEND_URL}"
EOF
                    """
                }
            }
        }
        
        stage('Create test pod') {
            steps {
                script {
                    sh "kubectl apply -f ${TEST_POD_YAML}"
                    
                    // Wait for pod to be ready
                    sh "kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || true"
                }
            }
        }
        
        stage('Run E2E tests') {
            failFast true  // If any parallel stage fails, abort all remaining parallel stages
            parallel {
                stage('Database Test') {
                    steps {
                        script {
                            // Copy test script to pod
                            sh "kubectl cp ${TEST_SCRIPT} e2e-tests:/test.sh"
                            
                            // Grant execution permissions
                            sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
                            // Run database test
                            sh "kubectl exec e2e-tests -- bash /test.sh database"
                        }
                    }
                }
                
                stage('API Test') {
                    steps {
                        script {
                            // Copy test script to pod
                            sh "kubectl cp ${TEST_SCRIPT} e2e-tests:/test.sh"
                            
                            // Grant execution permissions
                            sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
                            // Run API test
                            sh "kubectl exec e2e-tests -- bash /test.sh api"
                        }
                    }
                }
                
                stage('Frontend Test') {
                    steps {
                        script {
                            // Copy test script to pod
                            sh "kubectl cp ${TEST_SCRIPT} e2e-tests:/test.sh"
                            
                            // Grant execution permissions
                            sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
                            // Run frontend test
                            sh "kubectl exec e2e-tests -- bash /test.sh frontend"
                        }
                    }
                }
            }
        }
        
        stage('Integration Test') {
            steps {
                script {
                    // Run integration test
                    sh "kubectl exec e2e-tests -- bash /test.sh integration"
                }
            }
        }
        
        stage('Generate Test Report') {
            steps {
                script {
                    echo "Collecting test results..."
                    
                    // Create directory for test reports
                    sh "mkdir -p ${TEST_REPORTS_DIR}"
                    
                    // Extract test results from pod
                    sh """
                        kubectl exec e2e-tests -- ls -la /tmp/ || true
                        for result in db_test_result.txt api_test_result.txt frontend_test_result.txt integration_test_result.txt; do
                            kubectl cp e2e-tests:/tmp/\$result ${TEST_REPORTS_DIR}/\$result 2>/dev/null || echo "Could not copy \$result"
                        done
                    """
                    
                    // Create a simple HTML report
                    sh """
                        echo "<html><head><title>E2E Test Results</title>" > ${TEST_REPORTS_DIR}/report.html
                        echo "<style>body{font-family:Arial;margin:20px}h1{color:#333}pre{background:#f5f5f5;padding:10px;border-radius:5px}</style>" >> ${TEST_REPORTS_DIR}/report.html
                        echo "</head><body><h1>E2E Test Results</h1>" >> ${TEST_REPORTS_DIR}/report.html
                        
                        echo "<h2>Summary</h2>" >> ${TEST_REPORTS_DIR}/report.html
                        echo "<pre>" >> ${TEST_REPORTS_DIR}/report.html
                        grep -H "" ${TEST_REPORTS_DIR}/*.txt 2>/dev/null || echo "No test results found" >> ${TEST_REPORTS_DIR}/report.html
                        echo "</pre>" >> ${TEST_REPORTS_DIR}/report.html
                        
                        echo "<h2>Detailed Results</h2>" >> ${TEST_REPORTS_DIR}/report.html
                        for file in ${TEST_REPORTS_DIR}/*.txt; do
                            if [ -f "\$file" ]; then
                                echo "<h3>\$(basename \$file)</h3>" >> ${TEST_REPORTS_DIR}/report.html
                                echo "<pre>" >> ${TEST_REPORTS_DIR}/report.html
                                cat "\$file" >> ${TEST_REPORTS_DIR}/report.html
                                echo "</pre>" >> ${TEST_REPORTS_DIR}/report.html
                            fi
                        done
                        
                        echo "</body></html>" >> ${TEST_REPORTS_DIR}/report.html
                    """
                    
                    // Archive the test report
                    archiveArtifacts artifacts: "${TEST_REPORTS_DIR}/**", allowEmptyArchive: true
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
            export KUBECONFIG=${KUBECONFIG}
            kubectl get pods
            """
            
            // Send success email notification
            emailext (
                subject: "SUCCESS: K3D Cluster '${params.CLUSTER_NAME}' - Build #${env.BUILD_NUMBER}",
                body: """
                <p>The K3D Kubernetes cluster setup and tests completed successfully!</p>
                <h3>Build Information</h3>
                <ul>
                    <li>Build Number: ${env.BUILD_NUMBER}</li>
                    <li>Cluster Name: ${params.CLUSTER_NAME}</li>
                    <li>Number of Agents: ${params.NUM_AGENTS}</li>
                    <li>Build URL: ${env.BUILD_URL}</li>
                </ul>
                
                <p>To connect to the cluster, use:</p>
                <pre>
                export KUBECONFIG=${KUBECONFIG}
                kubectl get pods
                </pre>
                
                <p>Test reports are available in the build artifacts.</p>
                """,
                to: "${params.EMAIL_RECIPIENTS}",
                attachmentsPattern: "${TEST_REPORTS_DIR}/report.html",
                mimeType: 'text/html'
            )
        }
        failure {
            echo 'K3D Kubernetes cluster setup or tests failed.'
            
            // Send failure email notification
            emailext (
                subject: "FAILURE: K3D Cluster '${params.CLUSTER_NAME}' - Build #${env.BUILD_NUMBER}",
                body: """
                <p>The K3D Kubernetes cluster setup or tests failed!</p>
                <h3>Build Information</h3>
                <ul>
                    <li>Build Number: ${env.BUILD_NUMBER}</li>
                    <li>Cluster Name: ${params.CLUSTER_NAME}</li>
                    <li>Number of Agents: ${params.NUM_AGENTS}</li>
                    <li>Build URL: ${env.BUILD_URL}</li>
                </ul>
                
                <p>Please check the console output for details about the failure.</p>
                <p><a href="${env.BUILD_URL}console">View Console Output</a></p>
                
                <p>Any available test reports are attached or can be viewed in the build artifacts.</p>
                """,
                to: "${params.EMAIL_RECIPIENTS}",
                attachmentsPattern: "${TEST_REPORTS_DIR}/report.html",
                mimeType: 'text/html'
            )
        }
        always {
            // Clean up resources regardless of build result
            script {
                echo "Build completed with result: ${currentBuild.result}"
            }
        }
    }
}