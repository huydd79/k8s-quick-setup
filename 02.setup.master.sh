#!/bin/bash
source ./00.configure.sh
check_ready

MASTER_IP_ADDRESS=$(hostname -I | awk '{print $1}')
CNI_CALICO_URL="https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml"

echo -e "${GREEN}--- 🚀 Starting Control Plane Initialization ---${NC}"
echo -e "${YELLOW}MASTER IP: ${MASTER_IP_ADDRESS} | POD CIDR: ${POD_CIDR}${NC}"

# 1. Kubeadm Init
sudo kubeadm init \
  --apiserver-advertise-address=$MASTER_IP_ADDRESS \
  --pod-network-cidr=$POD_CIDR \
  --cri-socket=unix:///var/run/crio/crio.sock \
  --upload-certs

# 2. Config Kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 3. Install Calico CNI with Dynamic CIDR
echo -e "\n${BLUE}## Installing Calico CNI...${NC}"
curl -L -s $CNI_CALICO_URL -o calico.template.yaml

sed -e "s|# - name: CALICO_IPV4POOL_CIDR|- name: CALICO_IPV4POOL_CIDR|g" \
    -e "s|#   value: \"192.168.0.0/16\"|  value: \"${POD_CIDR}\"|g" \
    calico.template.yaml > calico.tmp.yaml

kubectl apply -f calico.tmp.yaml
rm calico.template.yaml calico.tmp.yaml

echo -e "\n${GREEN}--- ✅ Initialization Complete ---${NC}"
sudo kubeadm token create --print-join-command