#k8s 

Kubernetes 클러스터를 처음부터 제대로 구축하기 위한 종합 가이드입니다. `kubeadm reset` 후 클러스터를 재구성할 때 발생할 수 있는 문제들을 방지하는 데 도움이 될 것입니다.

## 1. 사전 준비 사항

### 1.1 시스템 요구 사항

**최소 요구 사항 (노드당):**

- 2 CPU 코어 이상
- 2GB RAM 이상
- 20GB 디스크 공간 이상
- 인터넷 연결
- 모든 노드 간 통신 가능한 네트워크

### 1.2 모든 노드에서 실행해야 할 기본 설정

```bash
Copy# 호스트 이름 설정 (각 노드마다 고유해야 함)
sudo hostnamectl set-hostname [호스트이름]

# /etc/hosts 파일에 모든 노드 추가
sudo nano /etc/hosts
# 예시:
# 192.168.50.167 master-node
# 192.168.50.168 worker-node1
# ...

# SELinux 설정 (사용 중인 경우)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# 방화벽 설정 (필요한 경우)
sudo systemctl stop firewalld
sudo systemctl disable firewalld
# 또는 포트만 열기
# sudo firewall-cmd --permanent --add-port=6443/tcp 10250/tcp 10251/tcp 10252/tcp 2379/tcp 2380/tcp 8472/udp
# sudo firewall-cmd --reload

# swap 비활성화
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# IP 포워딩 활성화
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# br_netfilter 모듈 로드
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 필요한 sysctl 매개변수 설정
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

```

### 1.3 컨테이너 런타임 설치 (모든 노드)

**containerd 설치 (권장):**

```bash
Copy# 필요한 패키지 설치
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Docker 리포지토리 추가 (containerd를 위해)
curl -fsSL <https://download.docker.com/linux/ubuntu/gpg> | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] <https://download.docker.com/linux/ubuntu> $(lsb_release -cs) stable"

# containerd 설치
sudo apt-get update
sudo apt-get install -y containerd.io

# containerd 설정
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# containerd 설정 파일 수정 - systemd cgroup 드라이버 사용
sudo sed -i 's/SystemdCgroup \\= false/SystemdCgroup \\= true/g' /etc/containerd/config.toml

# containerd 재시작
sudo systemctl restart containerd
sudo systemctl enable containerd

```

## 2. Kubernetes 컴포넌트 설치

### 2.1 kubeadm, kubelet, kubectl 설치 (모든 노드)

**Ubuntu/Debian:**

```bash
Copy# Kubernetes 리포지토리 키 추가
curl -fsSL <https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key> | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Kubernetes 리포지토리 추가
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] <https://pkgs.k8s.io/core:/stable:/v1.31/deb/> /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 패키지 설치
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# 자동 업데이트 방지
sudo apt-mark hold kubelet kubeadm kubectl

```

**CentOS/RHEL:**

```bash
Copycat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.31/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl
EOF

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

```

## 3. 클러스터 초기화 및 설정

### 3.1 마스터 노드 초기화

```bash
Copy# 클러스터 초기화 (Flannel 사용 시)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs --v=5

# 만약 문제가 발생한다면 --ignore-preflight-errors 옵션 추가 가능
# sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs --ignore-preflight-errors=all

```

### 3.2 kubeconfig 설정 (마스터 노드)

```bash
Copymkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 확인
kubectl get nodes

```

### 3.3 네트워크 플러그인 설치 (마스터 노드)

**Flannel (간단한 설정):**

```bash
Copykubectl apply -f <https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml>

```

**Calico (더 많은 기능):**

```bash
Copykubectl apply -f <https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml>

```

### 3.4 워커 노드 조인

마스터 노드에서 토큰 생성:

```bash
Copykubeadm token create --print-join-command

```

출력된 명령어를 워커 노드에서 실행:

```bash
Copysudo kubeadm join 192.168.50.167:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

```

### 3.5 클러스터 상태 확인 (마스터 노드)

```bash
Copykubectl get nodes
kubectl get pods --all-namespaces

```

## 4. 클러스터 리셋 후 재구성

만약 `kubeadm reset`을 수행했다면, 다음 단계를 따라 완전히 정리한 후 재구성합니다:

### 4.1 모든 노드에서 철저한 정리

```bash
Copy# kubeadm reset
sudo kubeadm reset -f

# 모든 컨테이너 중지/제거
sudo crictl rm -f $(sudo crictl ps -a -q) 2>/dev/null || true
sudo crictl rmi -f $(sudo crictl images -q) 2>/dev/null || true

# Kubernetes 디렉토리 정리
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/cni
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube

# iptables 규칙 정리
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -X

# CNI 인터페이스 제거
sudo ip link delete flannel.1 2>/dev/null || true
sudo ip link delete cni0 2>/dev/null || true

# 서비스 재시작
sudo systemctl restart containerd
sudo systemctl restart kubelet

```

### 4.2 클러스터 재구성

위의 3. 클러스터 초기화 및 설정 단계를 따라 다시 구성합니다.

## 5. 문제 해결 및 검증

### 5.1 kubelet 로그 확인

```bash
Copysudo journalctl -u kubelet -n 100

```

### 5.2 API 서버 상태 확인

```bash
Copykubectl get componentstatuses

```

### 5.3 파드 및 서비스 상태 확인

```bash
Copykubectl get pods -A
kubectl get services -A

```

### 5.4 네트워크 검증

```bash
Copy# DNS 연결 확인
kubectl run test-dns --image=busybox:1.28 -- sleep 3600
kubectl exec -it test-dns -- nslookup kubernetes.default

```

### 5.5 일반적인 문제 해결

**문제: 노드가 NotReady 상태**

- 네트워크 플러그인이 제대로 설치되었는지 확인
- kubelet 로그 확인

**문제: 파드가 Pending 상태**

- 노드의 리소스 상태 확인
- 네트워크 또는 저장소 문제 확인

**문제: 파드가 ImagePullBackOff 상태**

- 인터넷 연결 확인
- 이미지 이름과 태그 확인

**문제: 파드가 CrashLoopBackOff 상태**

- 파드 로그 확인: `kubectl logs <pod-name>`
- 파드 상세 정보 확인: `kubectl describe pod <pod-name>`

## 6. 추가 구성 (선택사항)

### 6.1 대시보드 설치

```bash
Copykubectl apply -f <https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml>

# 대시보드 접근을 위한 사용자 생성
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# 접근 토큰 확인
kubectl -n kubernetes-dashboard create token admin-user

```

### 6.2 MetalLB 로드 밸런서 (베어메탈 환경용)

```bash
Copykubectl apply -f <https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml>

# IP 주소 풀 설정
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.50.240-192.168.50.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF

```

### 6.3 Ingress 컨트롤러 설치 (NGINX)

```bash
Copykubectl apply -f <https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/cloud/deploy.yaml>

```

## 7. 클러스터 유지 관리

### 7.1 정기적인 백업

etcd 데이터베이스를 정기적으로 백업:

```bash
Copysudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \\
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \\
  --cert=/etc/kubernetes/pki/etcd/server.crt \\
  --key=/etc/kubernetes/pki/etcd/server.key \\
  snapshot save /tmp/etcd-snapshot-$(date +%Y-%m-%d).db

```

### 7.2 업그레이드

Kubernetes 구성 요소를 정기적으로 업그레이드:

```bash
Copy# kubeadm 업그레이드 계획 확인
sudo kubeadm upgrade plan

# kubeadm 업그레이드 적용
sudo kubeadm upgrade apply v1.xx.y

# kubelet 및 kubectl 업그레이드
sudo apt-get update
sudo apt-get install -y kubelet=1.xx.y-00 kubectl=1.xx.y-00
sudo systemctl daemon-reload
sudo systemctl restart kubelet

```

## 결론

이 가이드를 따라 Kubernetes 클러스터를 처음부터 올바르게 구성하고, `kubeadm reset` 이후 재구성 시 발생할 수 있는 문제들을 방지할 수 있습니다. 시스템 요구 사항을 충족하고 모든 사전 요구 사항을 올바르게 설정하는 것이 성공적인 클러스터 구축의 핵심입니다.

특히 IP 포워딩, 방화벽 설정, swap 비활성화, cgroup 드라이버 설정 등의 기본 설정은 클러스터가 안정적으로 작동하는 데 매우 중요합니다. 문제가 발생하면 로그를 꼼꼼히 확인하고 한 단계씩 진행하면서 문제를 해결하세요.