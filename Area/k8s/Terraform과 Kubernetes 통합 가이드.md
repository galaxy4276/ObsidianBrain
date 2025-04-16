#k8s #terraform
## 1. Terraform 기초

### 1.1 Terraform이란?

Terraform은 HashiCorp에서 개발한 인프라스트럭처를 코드(Infrastructure as Code, IaC)로 관리하는 오픈소스 도구입니다. 선언적 언어를 사용하여 클라우드, 온프레미스 등 다양한 인프라 리소스를 프로비저닝하고 관리합니다.

**주요 특징:**

- **클라우드 공급자 독립적**: AWS, Azure, GCP, 기타 여러 공급자 지원
- **선언적 접근 방식**: 원하는 최종 상태를 정의하면 Terraform이 현재 상태와 비교하여 필요한 변경 사항을 적용
- **상태 관리**: 인프라 상태를 추적하여 변경 사항을 효율적으로 관리
- **모듈화 및 재사용**: 인프라 코드를 모듈화하여 재사용 가능

### 1.2 Terraform 핵심 개념

#### HCL(HashiCorp Configuration Language)

Terraform은 HCL을 사용하여 인프라를 정의합니다. 기본 구문은 다음과 같습니다:

```hcl
# 리소스 정의 예시
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  tags = {
    Name = "example-instance"
  }
}
```

#### 프로바이더

프로바이더는 특정 인프라 서비스(AWS, Azure, GCP 등)와 상호 작용하기 위한 플러그인입니다.

```hcl
# AWS 프로바이더 설정
provider "aws" {
  region = "us-west-2"
}
```

#### 리소스

리소스는 관리하려는 인프라 구성 요소입니다.

```hcl
resource "type" "name" {
  # 구성 옵션
}
```

#### 상태 관리

Terraform은 `.tfstate` 파일에 현재 인프라 상태를 저장합니다. 이 상태 파일을 통해 리소스 추적, 종속성 계산 등을 수행합니다.

#### 변수와 출력

```hcl
# 변수 정의
variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-west-2"
  type        = string
}

# 출력 정의
output "instance_ip" {
  value = aws_instance.example.public_ip
}
```

#### 모듈

모듈은 재사용 가능한 Terraform 코드 패키지입니다.

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  cidr_block = "10.0.0.0/16"
}
```

### 1.3 Terraform 기본 명령어

```bash
# 초기화
terraform init

# 검증
terraform validate

# 계획 확인
terraform plan

# 적용하기
terraform apply

# 삭제하기
terraform destroy

# 상태 확인
terraform state list
```

### 1.4 Terraform 프로젝트 구조

기본적인 Terraform 프로젝트 구조는 다음과 같습니다:

```
project/
├── main.tf          # 주요 리소스 정의
├── variables.tf     # 변수 정의
├── outputs.tf       # 출력 정의
├── providers.tf     # 프로바이더 설정
├── terraform.tfvars # 변수 값 설정
└── modules/         # 재사용 가능한 모듈
```

## 2. Kubernetes 기본 개념

### 2.1 Kubernetes란?

Kubernetes(K8s)는 컨테이너화된 애플리케이션의 배포, 확장 및 관리를 자동화하는 오픈소스 컨테이너 오케스트레이션 플랫폼입니다.

### 2.2 Kubernetes 핵심 리소스

- **Pod**: 가장 기본적인 배포 단위, 하나 이상의 컨테이너 포함
- **Deployment**: Pod의 배포와 업데이트를 관리
- **Service**: Pod 집합에 대한 네트워크 접근 정책 정의
- **ConfigMap/Secret**: 구성 데이터 및 민감한 정보 관리
- **Namespace**: Kubernetes 클러스터 내 가상 클러스터
- **Ingress**: HTTP/HTTPS 라우팅 규칙 관리
- **PersistentVolume**: 스토리지 리소스

## 3. Terraform으로 Kubernetes 관리하기

### 3.1 Kubernetes 프로바이더 설정

Terraform에서 Kubernetes 리소스를 관리하려면 Kubernetes 프로바이더를 설정해야 합니다:

```hcl
# providers.tf
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "kubernetes" {
  # 로컬 kubeconfig 사용
  config_path    = "~/.kube/config"
  config_context = "my-context"
  
  # 또는 클러스터 엔드포인트와 인증 정보 직접 지정
  # host                   = var.cluster_endpoint
  # client_certificate     = base64decode(var.client_certificate)
  # client_key             = base64decode(var.client_key)
  # cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}
```

### 3.2 Terraform으로 Kubernetes 클러스터 프로비저닝

#### AWS EKS 클러스터

```hcl
provider "aws" {
  region = var.region
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2
      
      instance_types = ["t3.medium"]
    }
  }
}
```

#### GCP GKE 클러스터

```hcl
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = var.region
  
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "my-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.region
  node_count = 3
  
  node_config {
    machine_type = "e2-medium"
  }
}
```

#### Azure AKS 클러스터

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "exampleaks"
  
  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }
  
  identity {
    type = "SystemAssigned"
  }
}
```

### 3.3 Terraform으로 Kubernetes 리소스 관리

클러스터가 프로비저닝되면 Terraform으로 Kubernetes 리소스를 직접 관리할 수 있습니다:

#### Namespace 생성

```hcl
resource "kubernetes_namespace" "example" {
  metadata {
    name = "example-namespace"
  }
}
```

#### Deployment 생성

```hcl
resource "kubernetes_deployment" "example" {
  metadata {
    name      = "example-deployment"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  
  spec {
    replicas = 3
    
    selector {
      match_labels = {
        app = "example"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "example"
        }
      }
      
      spec {
        container {
          name  = "example"
          image = "nginx:1.21"
          
          port {
            container_port = 80
          }
          
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "0.25"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}
```

#### Service 생성

```hcl
resource "kubernetes_service" "example" {
  metadata {
    name      = "example-service"
    namespace = kubernetes_namespace.example.metadata[0].name
  }
  
  spec {
    selector = {
      app = "example"
    }
    
    port {
      port        = 80
      target_port = 80
    }
    
    type = "ClusterIP"
  }
}
```

### 3.4 Helm 차트 배포하기

Terraform Helm 프로바이더를 사용하여 Helm 차트를 배포할 수 있습니다:

```hcl
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "example" {
  name       = "example"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  namespace  = kubernetes_namespace.example.metadata[0].name
  
  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  
  values = [
    file("values.yaml")
  ]
}
```

## 4. 통합 패턴 및 모범 사례

### 4.1 모듈화 및 재사용

Terraform 코드를 모듈화하여 재사용성을 높이세요:

```
modules/
├── eks/            # EKS 클러스터 모듈
├── k8s-namespace/  # 네임스페이스 및 기본 리소스 모듈
├── k8s-app/        # 애플리케이션 배포 모듈
└── monitoring/     # 모니터링 스택 모듈
```

모듈 사용 예시:

```hcl
module "app_namespace" {
  source = "./modules/k8s-namespace"
  
  name = "application"
}

module "web_app" {
  source = "./modules/k8s-app"
  
  namespace     = module.app_namespace.name
  app_name      = "web"
  image         = "nginx:1.21"
  replicas      = 3
  service_type  = "ClusterIP"
}
```

### 4.2 상태 관리 전략

원격 상태 저장소를 사용하여 팀 협업을 개선하세요:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "k8s-infra/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 4.3 CI/CD 파이프라인과의 통합

Terraform과 Kubernetes를 CI/CD 파이프라인에 통합하는 예시 (GitHub Actions):

```yaml
name: Terraform & Kubernetes Deployment

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      
      - name: Terraform Init
        run: terraform init
      
      - name: Terraform Plan
        run: terraform plan -out=tfplan
      
      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
      
      - name: Configure kubectl
        uses: azure/k8s-set-context@v1
        with:
          kubeconfig: ${{ secrets.KUBE_CONFIG }}
      
      - name: Verify Deployment
        run: kubectl get pods -n application
```

### 4.4 멀티 환경 관리

Terraform 워크스페이스 또는 디렉토리 구조를 사용하여 여러 환경을 관리하세요:

```
environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
```

## 5. 실제 예제

### 5.1 완전한 인프라 + Kubernetes 애플리케이션 배포

아래는 AWS EKS 클러스터를 생성하고 애플리케이션을 배포하는 완전한 예제입니다:

```hcl
# providers.tf
provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# VPC 모듈
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  
  name = "eks-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# EKS 클러스터 모듈
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"
  
  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  cluster_endpoint_public_access = true
  
  eks_managed_node_groups = {
    default = {
      min_size     = 2
      max_size     = 5
      desired_size = 2
      
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
}

# Kubernetes 네임스페이스
resource "kubernetes_namespace" "app" {
  metadata {
    name = "my-application"
  }
  
  depends_on = [module.eks]
}

# Kubernetes Deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "my-app"
    namespace = kubernetes_namespace.app.metadata[0].name
    
    labels = {
      app = "my-app"
    }
  }
  
  spec {
    replicas = 3
    
    selector {
      match_labels = {
        app = "my-app"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "my-app"
        }
      }
      
      spec {
        container {
          name  = "my-app"
          image = "nginx:1.21"
          
          port {
            container_port = 80
          }
          
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "0.25"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
  
  depends_on = [kubernetes_namespace.app]
}

# Kubernetes Service
resource "kubernetes_service" "app" {
  metadata {
    name      = "my-app"
    namespace = kubernetes_namespace.app.metadata[0].name
  }
  
  spec {
    selector = {
      app = "my-app"
    }
    
    port {
      port        = 80
      target_port = 80
    }
    
    type = "LoadBalancer"
  }
  
  depends_on = [kubernetes_deployment.app]
}

# Helm 차트 배포
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true
  
  set {
    name  = "grafana.enabled"
    value = "true"
  }
  
  depends_on = [module.eks]
}
```

### 5.2 AWS EKS와 애플리케이션 아키텍처 다이어그램

```
                          +------------------------+
                          |                        |
                          |   AWS Cloud            |
                          |                        |
+----------------------+  |  +------------------+  |
|                      |  |  |                  |  |
|  Terraform           |---->|  EKS Cluster     |  |
|                      |  |  |                  |  |
+----------------------+  |  +------------------+  |
                          |          |             |
                          |          v             |
                          |  +------------------+  |
                          |  |                  |  |
                          |  |  Node Group      |  |
                          |  |                  |  |
                          |  +------------------+  |
                          |          |             |
                          |          v             |
                          |  +------------------+  |
                          |  |                  |  |
                          |  |  Kubernetes      |  |
                          |  |  Resources       |  |
                          |  |  - Namespace     |  |
                          |  |  - Deployment    |  |
                          |  |  - Service       |  |
                          |  |  - Ingress       |  |
                          |  |                  |  |
                          |  +------------------+  |
                          |                        |
                          +------------------------+
```

## 6. 문제 해결 및 팁

### 6.1 일반적인 문제

1. **상태 락 이슈**:
    
    ```bash
    # 강제로 상태 락 해제 (백엔드가 DynamoDB인 경우)
    terraform force-unlock LOCK_ID
    ```
    
2. **프로바이더 인증 문제**:
    
    - AWS 프로바이더: `aws configure` 또는 환경 변수 설정
    - Kubernetes 프로바이더: kubeconfig 경로 확인
3. **의존성 문제**:
    
    - `depends_on` 속성 사용하여 명시적 의존성 정의
    - 특히 클러스터 생성 후 Kubernetes 리소스를 관리할 때 중요

### 6.2 성능 및 유지 관리 팁

1. **Terraform 계획 파일 사용**:
    
    ```bash
    terraform plan -out=tfplan
    terraform apply tfplan
    ```
    
2. **세분화된 모듈 설계**:
    
    - 인프라 레이어와 Kubernetes 리소스 레이어 분리
    - 변경 빈도에 따라 모듈 설계
3. **상태 파일 분리**:
    
    - 인프라 상태와 애플리케이션 상태 분리 고려
    - 여러 팀이 협업할 때 유용
4. **임포트 기능 활용**:
    
    ```bash
    # 기존 리소스 가져오기
    terraform import kubernetes_namespace.example example-namespace
    ```
    
5. **변수 파일 분리**:
    
    - 환경별 변수 파일 사용
    - 민감한 정보는 별도 관리

### 6.3 고급 기능 활용

1. **terraform-provider-kubectl**:
    
    - 복잡한 Kubernetes 매니페스트를 YAML로 관리
2. **Data Sources 활용**:
    
    ```hcl
    data "kubernetes_service" "example" {
      metadata {
        name      = "example"
        namespace = "default"
      }
    }
    
    output "service_ip" {
      value = data.kubernetes_service.example.status.0.load_balancer.0.ingress.0.ip
    }
    ```
    
3. **for_each와 count 사용**:
    
    ```hcl
    resource "kubernetes_namespace" "environments" {
      for_each = toset(["dev", "staging", "prod"])
      
      metadata {
        name = each.key
      }
    }
    ```
    
4. **로컬 값 활용**:
    
    ```hcl
    locals {
      common_labels = {
        environment = var.environment
        managed_by  = "terraform"
      }
    }
    
    resource "kubernetes_deployment" "example" {
      metadata {
        name   = "example"
        labels = merge(local.common_labels, { app = "example" })
      }
      # ...
    }
    ```
    

---

이 가이드는 Terraform과 Kubernetes의 통합에 대한 기본적인 이해를 제공합니다. 실제 구현 시에는 프로젝트 요구사항과 환경에 맞게 조정하세요.

Terraform과 Kubernetes의 조합은 인프라와 애플리케이션 배포를 코드로 관리하는 강력한 방법을 제공하며, 이를 통해 인프라 프로비저닝부터 애플리케이션 배포까지 일관된 워크플로우를 구축할 수 있습니다.

---

---

## Appendix: Supplementary Video Resources

![youtube](https://i.ytimg.com/vi/oqxQr1e1Qxs/hqdefault.jpg)![youtube](data:image/png;base64,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)

Demystifying Kubernetes networking using Terraform

1 month ago

![youtube](https://i.ytimg.com/vi_webp/u59WdYrkiJI/maxresdefault.webp)![youtube](data:image/png;base64,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)

Complete CI/CD with Terraform and Kubernetes | Kubernetes ...

Jan 9, 2023

![youtube](https://i.ytimg.com/vi_webp/ZBhm9X9BgcA/maxresdefault.webp)![youtube](data:image/png;base64,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)

Deploy to Kubernetes using Terraform provider

Jun 13, 2022