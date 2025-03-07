
// pipeline {
//     agent any
    
//     triggers {
//         cron('H */2 * * *') // Runs every 2 hours
//     }
    
//     parameters {
//         string(name: 'CLUSTER_NAME', defaultValue: 'my-cluster', description: 'Cluster name')
//         string(name: 'NUM_AGENTS', defaultValue: '1', description: 'Number of worker nodes')
//         string(name: 'PORT_MAPPING', defaultValue: '2222:80@loadbalancer', description: 'Port mapping')
//     }
    
//     environment {
//         KUBECONFIG = "${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
//     }
    
//     options {
//         timeout(time: 30, unit: 'MINUTES')
//     }
    
//     stages {
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
        
//         stage('Create test pod') {
//             steps {
//                 script {
//                     sh "kubectl apply -f E2E_test/secret.yaml"
//                     sh "kubectl apply -f E2E_test/pod.yaml"
                    
//                     // Wait for pod to be ready
//                     sh "kubectl wait --for=condition=ready pod/e2e-tests --timeout=60s || true"
//                 }
//             }
//         }
        
//         stage('Run E2E tests') {
//             steps {
//                 script {
//                     sh """
//                         # Copy test script to pod
//                         kubectl cp E2E_test/test.sh e2e-tests:/test.sh
                        
//                         # Grant execution permissions
//                         kubectl exec e2e-tests -- chmod +x /test.sh
                        
//                         # Run tests
//                         kubectl exec e2e-tests -- bash /test.sh
//                     """
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
        
        stage('Create secret for tests') {
            steps {
                script {
                    sh "kubectl apply -f E2E_test/secret.yaml"
                }
            }
        }
        
        stage('Prepare tests for parallel execution') {
            steps {
                script {
                    sh """
                        # Create directory for split test files
                        mkdir -p ${WORKSPACE}/E2E_test/parallel
                        
                        # Split test file into 3 parts (assuming test.sh contains multiple test cases)
                        cd ${WORKSPACE}/E2E_test
                        
                        # Count total number of test cases (assumed to be marked with "test_case" comment)
                        TOTAL_TESTS=\$(grep -c "test_case" test.sh || echo 0)
                        
                        # Calculate tests per file (at least 1)
                        TESTS_PER_FILE=\$(( (TOTAL_TESTS + 2) / 3 ))
                        if [ \$TESTS_PER_FILE -lt 1 ]; then
                            TESTS_PER_FILE=1
                        fi
                        
                        # Create test runner script template
                        cat > test_runner_template.sh << 'EOL'
#!/bin/bash
set -e
echo "Starting test part \$1..."
# Setup common environment
export TEST_ENV="k8s"
# Run the specific test part
source /test_part\$1.sh
echo "Test part \$1 completed successfully"
EOL
                        
                        # Split test file into 3 parts
                        csplit --prefix="parallel/test_part" --suffix-format="%1d.sh" test.sh "/test_case/" "\$TESTS_PER_FILE" "{2}" 2>/dev/null || true
                        
                        # If split didn't work properly (not enough test_case markers), just create 3 copies
                        if [ ! -f parallel/test_part1.sh ]; then
                            cat test.sh > parallel/test_part0.sh
                            cp parallel/test_part0.sh parallel/test_part1.sh
                            cp parallel/test_part0.sh parallel/test_part2.sh
                        fi
                        
                        # Make split files executable
                        chmod +x parallel/test_part*.sh
                        chmod +x test_runner_template.sh
                    """
                }
            }
        }
        
        stage('Run E2E tests in parallel') {
            parallel {
                stage('Test Part 1') {
                    steps {
                        script {
                            sh """
                                # Create test pod 1
                                cat > pod-test1.yaml << EOL
apiVersion: v1
kind: Pod
metadata:
  name: e2e-tests-1
spec:
  containers:
  - name: test-runner
    image: alpine:latest
    command: ["sleep", "3600"]
  restartPolicy: Never
EOL
                                kubectl apply -f pod-test1.yaml
                                kubectl wait --for=condition=ready pod/e2e-tests-1 --timeout=60s

                                # Copy test files
                                kubectl cp ${WORKSPACE}/E2E_test/parallel/test_part0.sh e2e-tests-1:/test_part0.sh
                                kubectl cp ${WORKSPACE}/E2E_test/test_runner_template.sh e2e-tests-1:/test_runner.sh
                                
                                # Run tests
                                kubectl exec e2e-tests-1 -- sh -c "chmod +x /test_*.sh && /test_runner.sh 0"
                            """
                        }
                    }
                }
                
                stage('Test Part 2') {
                    steps {
                        script {
                            sh """
                                # Create test pod 2
                                cat > pod-test2.yaml << EOL
apiVersion: v1
kind: Pod
metadata:
  name: e2e-tests-2
spec:
  containers:
  - name: test-runner
    image: alpine:latest
    command: ["sleep", "3600"]
  restartPolicy: Never
EOL
                                kubectl apply -f pod-test2.yaml
                                kubectl wait --for=condition=ready pod/e2e-tests-2 --timeout=60s

                                # Copy test files
                                kubectl cp ${WORKSPACE}/E2E_test/parallel/test_part1.sh e2e-tests-2:/test_part1.sh
                                kubectl cp ${WORKSPACE}/E2E_test/test_runner_template.sh e2e-tests-2:/test_runner.sh
                                
                                # Run tests
                                kubectl exec e2e-tests-2 -- sh -c "chmod +x /test_*.sh && /test_runner.sh 1"
                            """
                        }
                    }
                }
                
                stage('Test Part 3') {
                    steps {
                        script {
                            sh """
                                # Create test pod 3
                                cat > pod-test3.yaml << EOL
apiVersion: v1
kind: Pod
metadata:
  name: e2e-tests-3
spec:
  containers:
  - name: test-runner
    image: alpine:latest
    command: ["sleep", "3600"]
  restartPolicy: Never
EOL
                                kubectl apply -f pod-test3.yaml
                                kubectl wait --for=condition=ready pod/e2e-tests-3 --timeout=60s

                                # Copy test files
                                kubectl cp ${WORKSPACE}/E2E_test/parallel/test_part2.sh e2e-tests-3:/test_part2.sh
                                kubectl cp ${WORKSPACE}/E2E_test/test_runner_template.sh e2e-tests-3:/test_runner.sh
                                
                                # Run tests
                                kubectl exec e2e-tests-3 -- sh -c "chmod +x /test_*.sh && /test_runner.sh 2"
                            """
                        }
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                script {
                    sh """
                        # Delete test pods
                        kubectl delete pod e2e-tests-1 e2e-tests-2 e2e-tests-3 --ignore-not-found
                        
                        # Clean up temporary files
                        rm -f pod-test*.yaml
                        rm -rf ${WORKSPACE}/E2E_test/parallel
                    """
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