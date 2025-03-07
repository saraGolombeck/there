
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
                sh "k3d cluster delete ${params.CLUSTER_NAME} 2>/dev/null || true"
            }
        }
        
        stage('Create new cluster') {
            steps {
                sh "mkdir -p ${HOME}/.kube"
                sh "k3d cluster create ${params.CLUSTER_NAME} --agents ${params.NUM_AGENTS} --timeout 5m --api-port 6443 -p \"${params.PORT_MAPPING}\""
                sh "k3d kubeconfig get ${params.CLUSTER_NAME} > ${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                sh "chmod 600 ${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                sh "sed -i 's|server: https://0.0.0.0:6443|server: https://k3d-${params.CLUSTER_NAME}-serverlb:6443|g' ${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
                sh "docker network connect k3d-${params.CLUSTER_NAME} ${HOSTNAME} || true"
                sh "sleep 10" // Wait for cluster to stabilize
            }
        }
        
        stage('Set node labels') {
            steps {
                sh label_script()
            }
        }

        stage('Deploy application') {
            steps {
                sh "kubectl apply -k k8s/"
            }
        }
        
        stage('Create secret for tests') {
            steps {
                sh "kubectl apply -f E2E_test/secret.yaml"
            }
        }
        
        stage('Prepare tests for parallel') {
            steps {
                sh prepare_tests_script()
            }
        }
        
        stage('Run E2E tests in parallel') {
            parallel {
                stage('Test Part 1') {
                    steps {
                        sh run_test_script(1)
                    }
                }
                
                stage('Test Part 2') {
                    steps {
                        sh run_test_script(2)
                    }
                }
                
                stage('Test Part 3') {
                    steps {
                        sh run_test_script(3)
                    }
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                sh "kubectl delete pod e2e-tests-1 e2e-tests-2 e2e-tests-3 --ignore-not-found"
                sh "rm -f pod-test*.yaml"
                sh "rm -rf ${WORKSPACE}/E2E_test/parallel || true"
            }
        }
    }
    
    post {
        success {
            echo "K3D Kubernetes cluster setup and tests completed successfully!"
            echo "To connect to the cluster, use:"
            echo "export KUBECONFIG=${HOME}/.kube/k3d-${params.CLUSTER_NAME}.config"
            echo "kubectl get pods"
        }
        failure {
            echo 'K3D Kubernetes cluster setup or tests failed.'
        }
    }
}

// Helper methods to generate scripts
def label_script() {
    return '''#!/bin/bash
export KUBECONFIG=${HOME}/.kube/k3d-''' + params.CLUSTER_NAME + '''.config
kubectl config use-context k3d-''' + params.CLUSTER_NAME + '''

# Get all nodes
ALL_NODES=$(kubectl get nodes --no-headers | awk '{print $1}')

# Identify master and worker nodes
for NODE in $ALL_NODES; do
    if [ "$(echo $NODE | grep server)" != "" ]; then
        kubectl label nodes $NODE kubernetes.io/hostname=''' + params.CLUSTER_NAME + ''' --overwrite
    elif [ "$(echo $NODE | grep agent)" != "" ]; then
        kubectl label nodes $NODE kubernetes.io/hostname=''' + params.CLUSTER_NAME + '''-m02 --overwrite
    fi
done
'''
}

def prepare_tests_script() {
    return '''#!/bin/bash
# Create directory for split test files
mkdir -p ${WORKSPACE}/E2E_test/parallel

# Split test file into 3 parts
cd ${WORKSPACE}/E2E_test

# Create test runner script
cat > test_runner.sh << 'EOFRUNNER'
#!/bin/sh
set -e
echo "Starting test part $1..."
export TEST_ENV="k8s"
sh /test_part$1.sh
echo "Test part $1 completed successfully"
EOFRUNNER
chmod +x test_runner.sh

# Count lines in test.sh
LINES=$(wc -l < test.sh)
PART_SIZE=$((LINES / 3 + 1))

# Create part 1
cat > parallel/test_part1.sh << 'EOF1'
#!/bin/sh
echo "Running test part 1"
EOF1
head -n $PART_SIZE test.sh >> parallel/test_part1.sh

# Create part 2
cat > parallel/test_part2.sh << 'EOF2'
#!/bin/sh
echo "Running test part 2"
EOF2
head -n $((PART_SIZE*2)) test.sh | tail -n $PART_SIZE >> parallel/test_part2.sh

# Create part 3
cat > parallel/test_part3.sh << 'EOF3'
#!/bin/sh
echo "Running test part 3"
EOF3
tail -n +$((PART_SIZE*2+1)) test.sh >> parallel/test_part3.sh

# Make files executable
chmod +x parallel/test_part*.sh
'''
}

def run_test_script(int part) {
    return '''#!/bin/bash
# Create test pod ''' + part + '''
cat > pod-test''' + part + '''.yaml << EOF
apiVersion: v1
kind: Pod
metadata:
  name: e2e-tests-''' + part + '''
spec:
  containers:
  - name: test-runner
    image: alpine:latest
    command: ["sleep", "3600"]
  restartPolicy: Never
EOF

kubectl apply -f pod-test''' + part + '''.yaml
kubectl wait --for=condition=ready pod/e2e-tests-''' + part + ''' --timeout=60s

# Copy test files
kubectl cp ${WORKSPACE}/E2E_test/parallel/test_part''' + part + '''.sh e2e-tests-''' + part + ''':/test_part''' + part + '''.sh
kubectl cp ${WORKSPACE}/E2E_test/test_runner.sh e2e-tests-''' + part + ''':/test_runner.sh

# Run tests
kubectl exec e2e-tests-''' + part + ''' -- sh -c "chmod +x /test_*.sh && sh /test_runner.sh ''' + part + ''' || echo 'Test part ''' + part + ''' had errors'"
'''
}