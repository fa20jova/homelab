#!/bin/sh

set -e

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[!] Missing dependency: $1"
        return 1
    fi
}

install_helm() {
    echo "[+] Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
}

install_k3s() {
    echo "[+] Installing K3s server..."
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik" sh -

    echo "[+] Creating kubeconfig..."
    mkdir -p ~/.kube
    cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    chmod 600 ~/.kube/config

    echo "[+] K3s installed."
}

wait_for_k3s() {
    echo "[+] Waiting for Kubernetes API to respond..."
    for i in $(seq 1 20); do
        if kubectl get nodes >/dev/null 2>&1; then
            echo "[+] Kubernetes is ready."
            return
        fi
        echo "    retrying in 3s..."
        sleep 3
    done
    echo "[!] Kubernetes did not become ready. Exiting."
    exit 1
}

echo "[*] Checking dependencies..."

if ! command -v helm >/dev/null 2>&1; then
    install_helm
else
    echo "[+] Helm present."
fi

if ! command -v kubectl >/dev/null 2>&1; then
    echo "[!] kubectl missing — installing k3s will provide it."
fi

if ! command -v k3s >/dev/null 2>&1; then
    install_k3s
else
    echo "[+] K3s is already installed."
fi

wait_for_k3s

echo "[*] Installing MetalLB..."
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

kubectl wait --namespace metallb-system --for=condition=available deploy/controller --timeout=120s

kubectl apply -f kubernetes/metallb/address-pool.yaml
echo "[+] MetalLB ready."

echo "[*] Installing Longhorn..."
helm repo add longhorn https://charts.longhorn.io >/dev/null
helm repo update >/dev/null

helm upgrade --install longhorn longhorn/longhorn \
    -n longhorn-system --create-namespace \
    -f kubernetes/longhorn/values.yaml

kubectl wait -n longhorn-system \
    --for=condition=ready pod \
    --selector=app=longhorn-ui \
    --timeout=180s

echo "[+] Longhorn ready."

echo "[*] Deploying core namespaces..."
kubectl apply -f kubernetes/home/
kubectl apply -f kubernetes/ai/
kubectl apply -f kubernetes/media/
kubectl apply -f kubernetes/dashboard/

echo "[+] Core namespaces deployed."

echo "[*] Deploying media stack..."
kubectl apply -f kubernetes/media/longhorn/
kubectl apply -f kubernetes/media/jellyfin/
kubectl apply -f kubernetes/media/qbittorrent/
kubectl apply -f kubernetes/media/radarr/
kubectl apply -f kubernetes/media/sonarr/
kubectl apply -f kubernetes/media/prowlarr/

echo "[+] Media stack deployed."

echo "[*] Deploying dashboard..."
kubectl apply -f kubernetes/dashboard/

echo "[+] Dashboard deployed."

echo "[*] Deploying AI workloads..."
kubectl apply -f kubernetes/ai/

echo "[+] AI workloads deployed."

echo ""
echo "============================================"
echo "   HOMELAB CLUSTER BOOTSTRAP COMPLETE"
echo "============================================"
echo ""
echo "[+] MetalLB LoadBalancer IP Range Active"
echo "[+] Longhorn Persistent Storage Ready"
echo "[+] Media Stack Online"
echo "[+] Home Assistant Online"
echo "[+] Dashboard Online"
echo "[+] AI Workloads Ready"
echo ""
echo "Cluster is fully initialized."
