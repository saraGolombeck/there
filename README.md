# GitOps

## Install k8s cluster

### Preparing your MASTER Nodes

    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.26.5+k3s1 sh -s - --docker   --node-name master --write-kubeconfig ~/.kube/config --write-kubeconfig-mode 600


### Preparing your WORKER Nodes

You need to extract a token from the master that will be used to join the nodes to the master.

On the master node:

    sudo cat /var/lib/rancher/k3s/server/node-token

You will then obtain a token that looks like:

    K1078f2861628c95aa328595484e77f831adc3b58041e9ba9a8b2373926c8b034a3::server:417a7c6f46330b601954d0aaaa1d0f5b

#### Install k3s on worker nodes:

    curl -sfL http://get.k3s.io | K3S_URL=https://<master_IP>:6443 K3S_TOKEN=<join_token> sh -s - --docker --node-name worker

Where master_IP is the IP of the master node and join_token is the token obtained from the master. e.g:

    curl -sfL http://get.k3s.io | K3S_URL=https://172.16.10.3:6443 K3S_TOKEN=K1078f2861628c95aa328595484e77f831adc3b58041e9ba9a8b2373926c8b034a3::server:417a7c6f46330b601954d0aaaa1d0f5b sh -s - --docker  --node-name worker


To verify that our nodes have successfully been added to the cluster, run :

    sudo kubectl get nodes

resource: https://docs.k3s.io/quick-start