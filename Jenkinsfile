
// // // pipeline {
// // //     agent any
    
// // //     triggers {
// // //         cron('H */2 * * *') // Runs every 2 hours
// // //     }
    
// // //     parameters {
// // //         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'Cluster name')
// // //         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'Number of worker nodes')
// // //         string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'Port mapping')
// // //     }
    
// // //     environment {
// // //         KUBECONFIG = "${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
// // //     }
    
// // //     options {
// // //         timeout(time: 30, unit: 'MINUTES')
// // //     }
    
// // //     stages {
// // //         stage('Delete existing cluster') {
// // //             steps {
// // //                 script {
// // //                     sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Create new cluster') {
// // //             steps {
// // //                 script {
// // //                     sh "mkdir -p \${HOME}/.kube"
                    
// // //                     // Create cluster
// // //                     sh """
// // //                         k3d cluster create ${params.CLUSTER_NAME} \\
// // //                         --agents ${params.NUM_AGENTS} \\
// // //                         --timeout 5m \\
// // //                         --api-port 6443 \\
// // //                         -p "${params.PORT_MAPPING}"
// // //                     """
                    
// // //                     // Create kubeconfig file
// // //                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
// // //                     sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
// // //                     // Fix kubeconfig - replace address with internal domain name
// // //                     sh """
// // //                         sed -i 's|server: https://0.0.0.0:6443|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
// // //                     """
                    
// // //                     // Connect Jenkins container to k3d network
// // //                     sh "docker network connect k3d-${params.CLUSTER_NAME} \$HOSTNAME || true"
                    
// // //                     // Wait for cluster to stabilize
// // //                     sh "sleep 10"
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Set node labels') {
// // //             steps {
// // //                 script {
// // //                     sh """
// // //                         export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
// // //                         kubectl config use-context k3d-${params.CLUSTER_NAME}
                        
// // //                         # Get all nodes
// // //                         ALL_NODES=\$(kubectl get nodes --no-headers | awk '{print \$1}')
                        
// // //                         # Identify master and worker nodes
// // //                         for NODE in \$ALL_NODES; do
// // //                             if [ "\$(echo \$NODE | grep server)" != "" ]; then
// // //                                 kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
// // //                             elif [ "\$(echo \$NODE | grep agent)" != "" ]; then
// // //                                 kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite
// // //                             fi
// // //                         done
// // //                     """
// // //                 }
// // //             }
// // //         }

// // //         stage('Deploy application') {
// // //             steps {
// // //                 script {
// // //                     sh "kubectl apply -k k8s/"
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Create test pod') {
// // //             steps {
// // //                 script {
// // //                     sh "kubectl apply -f E2E_test/secret.yaml"
// // //                     sh "kubectl apply -f E2E_test/pod.yaml"
                    
// // //                     // Wait for pod to be ready
// // //                     sh "kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || true"
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Run E2E tests') {
// // //             steps {
// // //                 script {
// // //                     sh """
// // //                         # Copy test script to pod
// // //                         kubectl cp E2E_test/test.sh e2e-tests:/test.sh
                        
// // //                         # Grant execution permissions
// // //                         kubectl exec e2e-tests -- chmod +x /test.sh
                        
// // //                         # Run tests
// // //                         kubectl exec e2e-tests -- bash /test.sh
// // //                     """
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Cleanup') {
// // //             steps {
// // //                 script {
// // //                     sh "kubectl delete pod e2e-tests --ignore-not-found"
// // //                 }
// // //             }
// // //         }
// // //     }
    
// // //     post {
// // //         success {
// // //             echo """
// // //             K3D Kubernetes cluster setup and tests completed successfully!
            
// // //             To connect to the cluster, use:
// // //             export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
// // //             kubectl get pods
// // //             """
// // //         }
// // //         failure {
// // //             echo 'K3D Kubernetes cluster setup or tests failed.'
// // //         }
// // //     }
// // // }


// // // pipeline {
// // //     agent any
    
// // //     triggers {
// // //         cron('H */2 * * *') // Runs every 2 hours
// // //     }
    
// // //     parameters {
// // //         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'Cluster name')
// // //         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'Number of worker nodes')
// // //         string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'Port mapping')
// // //     }
    
// // //     environment {
// // //         KUBECONFIG = "${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
// // //     }
    
// // //     options {
// // //         timeout(time: 30, unit: 'MINUTES')
// // //     }
    
// // //     stages {
// // //         stage('Delete existing cluster') {
// // //             steps {
// // //                 script {
// // //                     sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Create new cluster') {
// // //             steps {
// // //                 script {
// // //                     sh "mkdir -p \${HOME}/.kube"
                    
// // //                     // Create cluster
// // //                     sh """
// // //                         k3d cluster create ${params.CLUSTER_NAME} \\
// // //                         --agents ${params.NUM_AGENTS} \\
// // //                         --timeout 5m \\
// // //                         --api-port 6443 \\
// // //                         -p "${params.PORT_MAPPING}"
// // //                     """
                    
// // //                     // Create kubeconfig file
// // //                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
// // //                     sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
// // //                     // Fix kubeconfig - replace address with internal domain name
// // //                     sh """
// // //                         sed -i 's|server: https://0.0.0.0:6443|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
// // //                     """
                    
// // //                     // Connect Jenkins container to k3d network
// // //                     sh "docker network connect k3d-${params.CLUSTER_NAME} \$HOSTNAME || true"
                    
// // //                     // Wait for cluster to stabilize
// // //                     sh "sleep 10"
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Set node labels') {
// // //             steps {
// // //                 script {
// // //                     sh """
// // //                         export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
// // //                         kubectl config use-context k3d-${params.CLUSTER_NAME}
                        
// // //                         # Get all nodes
// // //                         ALL_NODES=\$(kubectl get nodes --no-headers | awk '{print \$1}')
                        
// // //                         # Identify master and worker nodes
// // //                         for NODE in \$ALL_NODES; do
// // //                             if [ "\$(echo \$NODE | grep server)" != "" ]; then
// // //                                 kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
// // //                             elif [ "\$(echo \$NODE | grep agent)" != "" ]; then
// // //                                 kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite
// // //                             fi
// // //                         done
// // //                     """
// // //                 }
// // //             }
// // //         }

// // //         stage('Deploy application') {
// // //             steps {
// // //                 script {
// // //                     sh "kubectl apply -k k8s/"
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Create test pod') {
// // //             steps {
// // //                 script {
// // //                     sh "kubectl apply -f E2E_test/secret.yaml"
// // //                     sh "kubectl apply -f E2E_test/pod.yaml"
                    
// // //                     // Wait for pod to be ready
// // //                     sh "kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || true"
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Run E2E tests') {
// // //             failFast true  // If any parallel stage fails, abort all remaining parallel stages
// // //             parallel {
// // //                 stage('Database Test') {
// // //                     steps {
// // //                         script {
// // //                             // Copy test script to pod
// // //                             sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
// // //                             // Grant execution permissions
// // //                             sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
// // //                             // Run database test
// // //                             sh "kubectl exec e2e-tests -- bash /test.sh database"
// // //                         }
// // //                     }
// // //                 }
                
// // //                 stage('API Test') {
// // //                     steps {
// // //                         script {
// // //                             // Copy test script to pod
// // //                             sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
// // //                             // Grant execution permissions
// // //                             sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
// // //                             // Run API test
// // //                             sh "kubectl exec e2e-tests -- bash /test.sh api"
// // //                         }
// // //                     }
// // //                 }
                
// // //                 stage('Frontend Test') {
// // //                     steps {
// // //                         script {
// // //                             // Copy test script to pod
// // //                             sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
// // //                             // Grant execution permissions
// // //                             sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
// // //                             // Run frontend test
// // //                             sh "kubectl exec e2e-tests -- bash /test.sh frontend"
// // //                         }
// // //                     }
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Integration Test') {
// // //             steps {
// // //                 script {
// // //                     // Run integration test
// // //                     sh "kubectl exec e2e-tests -- bash /test.sh integration"
// // //                 }
// // //             }
// // //         }
        
// // //         stage('Cleanup') {
// // //             steps {
// // //                 script {
// // //                     sh "kubectl delete pod e2e-tests --ignore-not-found"
// // //                 }
// // //             }
// // //         }
// // //     }
    
// // //     post {
// // //         success {
// // //             echo """
// // //             K3D Kubernetes cluster setup and tests completed successfully!
            
// // //             To connect to the cluster, use:
// // //             export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
// // //             kubectl get pods
// // //             """
// // //         }
// // //         failure {
// // //             echo 'K3D Kubernetes cluster setup or tests failed.'
// // //         }
// // //     }
// // // }




// // pipeline {
// //     agent any
    
// //     triggers {
// //         cron('H */2 * * *') // Runs every 2 hours
// //     }
    
// //     parameters {
// //         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'Cluster name')
// //         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'Number of worker nodes')
// //         string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'Port mapping')
// //         string(name: 'K3D_VERSION', defaultValue: 'latest', description: 'k3d version to install')
// //         string(name: 'KUBECTL_VERSION', defaultValue: 'latest', description: 'kubectl version to install')
// //     }
    
// //     environment {
// //         KUBECONFIG = "${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
// //     }
    
// //     options {
// //         timeout(time: 30, unit: 'MINUTES')
// //     }
    
// //     stages {
// //         stage('Prepare k3d Environment') {
// //             steps {
// //                 script {
// //                     echo "Preparing environment for k3d Kubernetes cluster"

                    
// //                     // Install k3d if not present or update
// //                     sh '''
// //                         if ! command -v k3d &> /dev/null; then
// //                             echo "k3d is not installed. Installing k3d..."
// //                             curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
// //                             echo "k3d installed successfully"
// //                         else
// //                             current_version=$(k3d version | grep k3d | cut -d' ' -f3)
// //                             echo "Current k3d version: $current_version"
                            
// //                             if [ "${params.K3D_VERSION}" != "latest" ] && [ "$current_version" != "${params.K3D_VERSION}" ]; then
// //                                 echo "Updating k3d to version ${params.K3D_VERSION}..."
// //                                 curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | K3D_INSTALL_VERSION="${params.K3D_VERSION}" bash
// //                             fi
// //                         fi
                        
// //                         k3d version
// //                     '''
                    
// //                     // Check for kubectl and get version information
// //                     sh '''
// //                         if command -v kubectl &> /dev/null; then
// //                             echo "kubectl is already installed"
// //                             kubectl version --client
// //                         else
// //                             echo "kubectl is not installed. Installing kubectl..."
// //                             if [ "${params.KUBECTL_VERSION}" = "latest" ]; then
// //                                 # Get stable version without subshell command substitution
// //                                 STABLE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
// //                                 curl -LO "https://dl.k8s.io/release/${STABLE_VERSION}/bin/linux/amd64/kubectl"
// //                             else
// //                                 curl -LO "https://dl.k8s.io/release/v${params.KUBECTL_VERSION}/bin/linux/amd64/kubectl"
// //                             fi
// //                             chmod +x kubectl
// //                             sudo mv kubectl /usr/local/bin/
// //                             echo "kubectl installed successfully"
// //                             kubectl version --client
// //                         fi
// //                     '''
                    
// //                     // Ensure .kube directory exists
// //                     sh "mkdir -p \${HOME}/.kube"
// //                 }
// //             }
// //         }
        
// //         stage('Delete existing cluster') {
// //             steps {
// //                 script {
// //                     sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
// //                 }
// //             }
// //         }
        
// //         stage('Create new cluster') {
// //             steps {
// //                 script {
// //                     sh "mkdir -p \${HOME}/.kube"
                    
// //                     // Create cluster
// //                     sh """
// //                         k3d cluster create ${params.CLUSTER_NAME} \\
// //                         --agents ${params.NUM_AGENTS} \\
// //                         --timeout 5m \\
// //                         --api-port 6443 \\
// //                         -p "${params.PORT_MAPPING}"
// //                     """
                    
// //                     // Create kubeconfig file
// //                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
// //                     sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
// //                     // Fix kubeconfig - replace address with internal domain name
// //                     sh """
// //                         sed -i 's|server: https://0.0.0.0:6443|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
// //                     """
                    
// //                     // Connect Jenkins container to k3d network
// //                     sh "docker network connect k3d-${params.CLUSTER_NAME} \$HOSTNAME || true"
                    
// //                     // Wait for cluster to stabilize
// //                     sh "sleep 10"
// //                 }
// //             }
// //         }
        
// //         stage('Set node labels') {
// //             steps {
// //                 script {
// //                     sh """
// //                         export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
// //                         kubectl config use-context k3d-${params.CLUSTER_NAME}
                        
// //                         # Get all nodes
// //                         ALL_NODES=\$(kubectl get nodes --no-headers | awk '{print \$1}')
                        
// //                         # Identify master and worker nodes
// //                         for NODE in \$ALL_NODES; do
// //                             if [ "\$(echo \$NODE | grep server)" != "" ]; then
// //                                 kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
// //                             elif [ "\$(echo \$NODE | grep agent)" != "" ]; then
// //                                 kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite
// //                             fi
// //                         done
// //                     """
// //                 }
// //             }
// //         }

// //         stage('Deploy application') {
// //             steps {
// //                 script {
// //                     sh "kubectl apply -k k8s/"
// //                 }
// //             }
// //         }
        
// //         stage('Create test pod') {
// //             steps {
// //                 script {
// //                     sh "kubectl apply -f E2E_test/secret.yaml"
// //                     sh "kubectl apply -f E2E_test/pod.yaml"
                    
// //                     // Wait for pod to be ready
// //                     sh "kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || true"
// //                 }
// //             }
// //         }
        
// //         stage('Run E2E tests') {
// //             failFast true  // If any parallel stage fails, abort all remaining parallel stages
// //             parallel {
// //                 stage('Database Test') {
// //                     steps {
// //                         script {
// //                             // Copy test script to pod
// //                             sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
// //                             // Grant execution permissions
// //                             sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
// //                             // Run database test
// //                             sh "kubectl exec e2e-tests -- bash /test.sh database"
// //                         }
// //                     }
// //                 }
                
// //                 stage('API Test') {
// //                     steps {
// //                         script {
// //                             // Copy test script to pod
// //                             sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
// //                             // Grant execution permissions
// //                             sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
// //                             // Run API test
// //                             sh "kubectl exec e2e-tests -- bash /test.sh api"
// //                         }
// //                     }
// //                 }
                
// //                 stage('Frontend Test') {
// //                     steps {
// //                         script {
// //                             // Copy test script to pod
// //                             sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
// //                             // Grant execution permissions
// //                             sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
// //                             // Run frontend test
// //                             sh "kubectl exec e2e-tests -- bash /test.sh frontend"
// //                         }
// //                     }
// //                 }
// //             }
// //         }
        
// //         stage('Integration Test') {
// //             steps {
// //                 script {
// //                     // Run integration test
// //                     sh "kubectl exec e2e-tests -- bash /test.sh integration"
// //                 }
// //             }
// //         }
        
        
// //         stage('Cleanup') {
// //             steps {
// //                 script {
// //                     sh "kubectl delete pod e2e-tests --ignore-not-found"
// //                 }
// //             }
// //         }
// //     }
    
// //     post {
// //         success {
// //             echo """
// //             K3D Kubernetes cluster setup and tests completed successfully!
            
// //             To connect to the cluster, use:
// //             export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
// //             kubectl get pods
// //             """
// //         }
// //         failure {
// //             echo 'K3D Kubernetes cluster setup or tests failed.'
// //         }
// //     }
// // }




// pipeline {
//     agent any
    
//     triggers {
//         cron('H */2 * * *') // Runs every 2 hours
//     }
    
//     parameters {
//         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'Cluster name')
//         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'Number of worker nodes')
//         string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'Port mapping')
//         string(name: 'K3D_VERSION', defaultValue: 'latest', description: 'k3d version to install')
//         string(name: 'KUBECTL_VERSION', defaultValue: 'latest', description: 'kubectl version to install')
//     }
    
//     environment {
//         KUBECONFIG = "${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
//         // Define single credential file for all E2E test environment variables
//         E2E_CONFIG = credentials('e2e-config')
//     }
    
//     options {
//         timeout(time: 30, unit: 'MINUTES')
//     }
    
//     stages {
//         stage('Prepare k3d Environment') {
//             steps {
//                 script {
//                     echo "Preparing environment for k3d Kubernetes cluster"

                    
//                     // Install k3d if not present or update
//                     sh '''
//                         if ! command -v k3d &> /dev/null; then
//                             echo "k3d is not installed. Installing k3d..."
//                             curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
//                             echo "k3d installed successfully"
//                         else
//                             current_version=$(k3d version | grep k3d | cut -d' ' -f3)
//                             echo "Current k3d version: $current_version"
                            
//                             if [ "${params.K3D_VERSION}" != "latest" ] && [ "$current_version" != "${params.K3D_VERSION}" ]; then
//                                 echo "Updating k3d to version ${params.K3D_VERSION}..."
//                                 curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | K3D_INSTALL_VERSION="${params.K3D_VERSION}" bash
//                             fi
//                         fi
                        
//                         k3d version
//                     '''
                    
//                     // Check for kubectl and get version information
//                     sh '''
//                         if command -v kubectl &> /dev/null; then
//                             echo "kubectl is already installed"
//                             kubectl version --client
//                         else
//                             echo "kubectl is not installed. Installing kubectl..."
//                             if [ "${params.KUBECTL_VERSION}" = "latest" ]; then
//                                 # Get stable version without subshell command substitution
//                                 STABLE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
//                                 curl -LO "https://dl.k8s.io/release/${STABLE_VERSION}/bin/linux/amd64/kubectl"
//                             else
//                                 curl -LO "https://dl.k8s.io/release/v${params.KUBECTL_VERSION}/bin/linux/amd64/kubectl"
//                             fi
//                             chmod +x kubectl
//                             sudo mv kubectl /usr/local/bin/
//                             echo "kubectl installed successfully"
//                             kubectl version --client
//                         fi
//                     '''
                    
//                     // Ensure .kube directory exists
//                     sh "mkdir -p \${HOME}/.kube"
//                 }
//             }
//         }
        
//         stage('Delete existing cluster') {
//             steps {
//                 script {
//                     sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
//                 }
//             }
//         }
        
//         stage('Create new cluster') {
//             steps {
//                 script {
//                     sh "mkdir -p \${HOME}/.kube"
                    
//                     // Create cluster
//                     sh """
//                         k3d cluster create ${params.CLUSTER_NAME} \\
//                         --agents ${params.NUM_AGENTS} \\
//                         --timeout 5m \\
//                         --api-port 6443 \\
//                         -p "${params.PORT_MAPPING}"
//                     """
                    
//                     // Create kubeconfig file
//                     sh "k3d kubeconfig get ${params.CLUSTER_NAME} > \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
//                     sh "chmod 600 \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                    
//                     // Fix kubeconfig - replace address with internal domain name
//                     sh """
//                         sed -i 's|server: https://0.0.0.0:6443|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//                     """
                    
//                     // Connect Jenkins container to k3d network
//                     sh "docker network connect k3d-${params.CLUSTER_NAME} \$HOSTNAME || true"
                    
//                     // Wait for cluster to stabilize
//                     sh "sleep 10"
//                 }
//             }
//         }
        
//         stage('Set node labels') {
//             steps {
//                 script {
//                     sh """
//                         export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//                         kubectl config use-context k3d-${params.CLUSTER_NAME}
                        
//                         # Get all nodes
//                         ALL_NODES=\$(kubectl get nodes --no-headers | awk '{print \$1}')
                        
//                         # Identify master and worker nodes
//                         for NODE in \$ALL_NODES; do
//                             if [ "\$(echo \$NODE | grep server)" != "" ]; then
//                                 kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME} --overwrite
//                             elif [ "\$(echo \$NODE | grep agent)" != "" ]; then
//                                 kubectl label nodes \$NODE kubernetes.io/hostname=${params.CLUSTER_NAME}-m02 --overwrite
//                             fi
//                         done
//                     """
//                 }
//             }
//         }

//         stage('Deploy application') {
//             steps {
//                 script {
//                     sh "kubectl apply -k k8s/"
//                 }
//             }
//         }
        
//         stage('Create E2E test secrets') {
//             steps {
//                 script {
//                     // Parse the JSON config file
//                     def config = readJSON file: "${E2E_CONFIG}"
                    
//                     // Create secret from Jenkins credentials
//                     sh """
//                         cat << EOF | kubectl apply -f -
// apiVersion: v1
// kind: Secret
// metadata:
//   name: e2e-env-secret
// type: Opaque
// stringData:
//   DB_HOST: "${config.DB_HOST}"
//   DB_USER: "${config.DB_USER}"
//   DB_PASSWORD: "${config.DB_PASSWORD}"
//   API_URL: "${config.API_URL}"
//   FRONTEND_URL: "${config.FRONTEND_URL}"
// EOF
//                     """
//                 }
//             }
//         }
        
//         stage('Create test pod') {
//             steps {
//                 script {
//                     sh "kubectl apply -f E2E_test/pod.yaml"
                    
//                     // Wait for pod to be ready
//                     sh "kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || true"
//                 }
//             }
//         }
        
//         stage('Run E2E tests') {
//             failFast true  // If any parallel stage fails, abort all remaining parallel stages
//             parallel {
//                 stage('Database Test') {
//                     steps {
//                         script {
//                             // Copy test script to pod
//                             sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
//                             // Grant execution permissions
//                             sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
//                             // Run database test
//                             sh "kubectl exec e2e-tests -- bash /test.sh database"
//                         }
//                     }
//                 }
                
//                 stage('API Test') {
//                     steps {
//                         script {
//                             // Copy test script to pod
//                             sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
//                             // Grant execution permissions
//                             sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
//                             // Run API test
//                             sh "kubectl exec e2e-tests -- bash /test.sh api"
//                         }
//                     }
//                 }
                
//                 stage('Frontend Test') {
//                     steps {
//                         script {
//                             // Copy test script to pod
//                             sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
//                             // Grant execution permissions
//                             sh "kubectl exec e2e-tests -- chmod +x /test.sh"
                            
//                             // Run frontend test
//                             sh "kubectl exec e2e-tests -- bash /test.sh frontend"
//                         }
//                     }
//                 }
//             }
//         }
        
//         stage('Integration Test') {
//             steps {
//                 script {
//                     // Run integration test
//                     sh "kubectl exec e2e-tests -- bash /test.sh integration"
//                 }
//             }
//         }
        
//         stage('Generate Test Report') {
//             steps {
//                 script {
//                     echo "Collecting test results..."
                    
//                     // Create directory for test reports
//                     sh "mkdir -p test-reports"
                    
//                     // Extract test results from pod
//                     sh '''
//                         kubectl exec e2e-tests -- ls -la /tmp/ || true
//                         for result in db_test_result.txt api_test_result.txt frontend_test_result.txt integration_test_result.txt; do
//                             kubectl cp e2e-tests:/tmp/$result test-reports/$result 2>/dev/null || echo "Could not copy $result"
//                         done
//                     '''
                    
//                     // Create a simple HTML report
//                     sh '''
//                         echo "<html><head><title>E2E Test Results</title>" > test-reports/report.html
//                         echo "<style>body{font-family:Arial;margin:20px}h1{color:#333}pre{background:#f5f5f5;padding:10px;border-radius:5px}</style>" >> test-reports/report.html
//                         echo "</head><body><h1>E2E Test Results</h1>" >> test-reports/report.html
                        
//                         echo "<h2>Summary</h2>" >> test-reports/report.html
//                         echo "<pre>" >> test-reports/report.html
//                         grep -H "" test-reports/*.txt 2>/dev/null || echo "No test results found" >> test-reports/report.html
//                         echo "</pre>" >> test-reports/report.html
                        
//                         echo "<h2>Detailed Results</h2>" >> test-reports/report.html
//                         for file in test-reports/*.txt; do
//                             if [ -f "$file" ]; then
//                                 echo "<h3>$(basename $file)</h3>" >> test-reports/report.html
//                                 echo "<pre>" >> test-reports/report.html
//                                 cat "$file" >> test-reports/report.html
//                                 echo "</pre>" >> test-reports/report.html
//                             fi
//                         done
                        
//                         echo "</body></html>" >> test-reports/report.html
//                     '''
                    
//                     // Archive the test report
//                     archiveArtifacts artifacts: 'test-reports/**', allowEmptyArchive: true
//                 }
//             }
//         }

//         stage('Cleanup') {
//             steps {
//                 script {
//                     sh "kubectl delete pod e2e-tests --ignore-not-found"
//                 }
//             }
//         }
//     }
    
//     post {
//         success {
//             echo """
//             K3D Kubernetes cluster setup and tests completed successfully!
            
//             To connect to the cluster, use:
//             export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
//             kubectl get pods
//             """
//         }
//         failure {
//             echo 'K3D Kubernetes cluster setup or tests failed.'
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
        string(name: 'K3D_VERSION', defaultValue: 'latest', description: 'k3d version to install')
        string(name: 'KUBECTL_VERSION', defaultValue: 'latest', description: 'kubectl version to install')
        string(name: 'sara.beck.dev@gmail.com', defaultValue: 'team@example.com', description: 'Email recipients for notifications')
    }
    
    environment {
        KUBECONFIG = "${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
        // Define single credential file for all E2E test environment variables
        E2E_CONFIG = credentials('e2e-config')
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
                    sh "mkdir -p \${HOME}/.kube"
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
                    sh """
                        sed -i 's|server: https://0.0.0.0:6443|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' \${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
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
                    sh "kubectl apply -f E2E_test/pod.yaml"
                    
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
                            sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
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
                            sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
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
                            sh "kubectl cp E2E_test/test.sh e2e-tests:/test.sh"
                            
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
                    sh "mkdir -p test-reports"
                    
                    // Extract test results from pod
                    sh '''
                        kubectl exec e2e-tests -- ls -la /tmp/ || true
                        for result in db_test_result.txt api_test_result.txt frontend_test_result.txt integration_test_result.txt; do
                            kubectl cp e2e-tests:/tmp/$result test-reports/$result 2>/dev/null || echo "Could not copy $result"
                        done
                    '''
                    
                    // Create a simple HTML report
                    sh '''
                        echo "<html><head><title>E2E Test Results</title>" > test-reports/report.html
                        echo "<style>body{font-family:Arial;margin:20px}h1{color:#333}pre{background:#f5f5f5;padding:10px;border-radius:5px}</style>" >> test-reports/report.html
                        echo "</head><body><h1>E2E Test Results</h1>" >> test-reports/report.html
                        
                        echo "<h2>Summary</h2>" >> test-reports/report.html
                        echo "<pre>" >> test-reports/report.html
                        grep -H "" test-reports/*.txt 2>/dev/null || echo "No test results found" >> test-reports/report.html
                        echo "</pre>" >> test-reports/report.html
                        
                        echo "<h2>Detailed Results</h2>" >> test-reports/report.html
                        for file in test-reports/*.txt; do
                            if [ -f "$file" ]; then
                                echo "<h3>$(basename $file)</h3>" >> test-reports/report.html
                                echo "<pre>" >> test-reports/report.html
                                cat "$file" >> test-reports/report.html
                                echo "</pre>" >> test-reports/report.html
                            fi
                        done
                        
                        echo "</body></html>" >> test-reports/report.html
                    '''
                    
                    // Archive the test report
                    archiveArtifacts artifacts: 'test-reports/**', allowEmptyArchive: true
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
                export KUBECONFIG=\${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config
                kubectl get pods
                </pre>
                
                <p>Test reports are available in the build artifacts.</p>
                """,
                to: "${params.EMAIL_RECIPIENTS}",
                attachmentsPattern: 'test-reports/report.html',
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
                attachmentsPattern: 'test-reports/report.html',
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