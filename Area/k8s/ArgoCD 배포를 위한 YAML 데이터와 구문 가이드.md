#argo #k8s 
## 1. ArgoCD 아키텍처 개요

ArgoCD는 Kubernetes 환경에서 GitOps 방식의 지속적 배포(CD)를 구현하는 도구입니다. Git 저장소에 정의된 원하는 상태(Target State)와 클러스터의 실제 상태(Live State)를 지속적으로 비교하여 동기화하는 것이 주요 기능입니다.

### 1.1 주요 구성 요소

ArgoCD는 다음과 같은 주요 구성 요소로 이루어져 있습니다:

1. **API Server**: 웹 UI, CLI, 외부 시스템과의 상호작용을 담당하며, 인증 및 권한 관리를 수행합니다.
2. **Repository Server**: Git 저장소의 매니페스트를 로컬에 캐싱하여 다른 컴포넌트에 제공합니다.
3. **Application Controller**: 실제 Kubernetes 클러스터와 Git 저장소 상태를 지속적으로 비교하고 조정(Reconciliation)합니다.

![ArgoCD 아키텍처](https://argo-cd.readthedocs.io/en/stable/assets/argocd_architecture.png)

## 2. 핵심 리소스 정의

ArgoCD에서 배포를 위해 필요한 핵심 YAML 리소스는 다음과 같습니다:

### 2.1 Application

`Application` 리소스는 ArgoCD에서 배포할 애플리케이션 인스턴스를 정의합니다.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app            # 애플리케이션 이름
  namespace: argocd           # ArgoCD가 설치된 네임스페이스
  finalizers:
    - resources-finalizer.argocd.argoproj.io  # 애플리케이션 삭제 시 정리를 위한 finalizer
spec:
  project: default            # 애플리케이션이 속한 Project
  source:                     # 매니페스트 소스 정보
    repoURL: https://github.com/example/app.git
    targetRevision: HEAD      # 브랜치, 태그, 커밋 해시
    path: helm                # 매니페스트 경로
  destination:                # 배포 대상
    server: https://kubernetes.default.svc  # 클러스터 URL
    namespace: sample-app     # 배포 네임스페이스
  syncPolicy:                 # 동기화 정책
    automated:                # 자동 동기화 설정
      prune: true             # 제거된 리소스 자동 삭제
      selfHeal: true          # 수동 변경된 리소스 자동 복구
    syncOptions:              # 동기화 옵션
      - CreateNamespace=true  # 네임스페이스 자동 생성
```

### 2.2 AppProject

`AppProject` 리소스는 애플리케이션을 논리적으로 그룹화하고 권한 및 제약 조건을 관리합니다.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: sample-project        # 프로젝트 이름
  namespace: argocd           # ArgoCD가 설치된 네임스페이스
spec:
  sourceRepos:                # 허용되는 Git 저장소
    - '*'                     # 모든 저장소 허용 (실제 환경에서는 구체적으로 지정)
  destinations:               # 허용되는 배포 대상
    - namespace: sample-app   # 허용되는 네임스페이스
      server: https://kubernetes.default.svc  # 허용되는 클러스터
  clusterResourceWhitelist:   # 허용되는 클러스터 범위 리소스
    - group: '*'
      kind: '*'
  namespaceResourceBlacklist: # 금지되는 네임스페이스 범위 리소스
    - group: ''
      kind: ResourceQuota
  roles:                      # 프로젝트 역할 정의
    - name: project-admin
      description: Project Admin
      policies:
        - p, proj:sample-project:project-admin, applications, *, sample-project/*, allow
```

### 2.3 ApplicationSet

`ApplicationSet`은 여러 애플리케이션을 템플릿 기반으로 관리할 수 있게 해주는 리소스입니다.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: multi-cluster-apps
  namespace: argocd
spec:
  generators:                          # 파라미터 생성기
    - list:                            # 리스트 생성기 
        elements:
          - cluster: dev
            url: https://kubernetes.default.svc
          - cluster: prod
            url: https://prod-cluster.example.com
  template:                            # 템플릿 정의
    metadata:
      name: '{{cluster}}-app'
    spec:
      project: default
      source:
        repoURL: https://github.com/example/app.git
        targetRevision: HEAD
        path: '{{cluster}}'
      destination:
        server: '{{url}}'
        namespace: sample-app
```

## 3. 주요 설정 필드 설명

### 3.1 Source 필드

`source` 필드는 애플리케이션 구성을 가져올 소스를 정의합니다. 다양한 소스 타입에 따라 설정이 달라집니다.

#### 3.1.1 Git 저장소 설정

```yaml
source:
  repoURL: https://github.com/example/app.git
  targetRevision: HEAD
  path: kubernetes  # 저장소 내 매니페스트 경로
```

#### 3.1.2 Helm 차트 설정

```yaml
source:
  repoURL: https://charts.bitnami.com/bitnami
  chart: nginx
  targetRevision: 9.5.13
  helm:
    releaseName: my-nginx
    values: |
      service:
        type: NodePort
    valueFiles:
      - values-prod.yaml
    parameters:
      - name: replicaCount
        value: "3"
```

#### 3.1.3 Kustomize 설정

```yaml
source:
  repoURL: https://github.com/example/kustomize-app.git
  targetRevision: HEAD
  path: overlays/prod
  kustomize:
    namePrefix: "prod-"
    images:
      - name: nginx
        newTag: 1.19.3
    commonLabels:
      app: nginx
```

### 3.2 SyncPolicy 필드

`syncPolicy` 필드는 애플리케이션이 어떻게 동기화될지 정의합니다.

```yaml
syncPolicy:
  automated:
    prune: true        # 삭제된 리소스 자동 정리
    selfHeal: true     # 수동 변경 시 자동 복구
    allowEmpty: false  # 빈 디렉토리 허용 여부
  retry:
    limit: 5           # 재시도 횟수
    backoff:
      duration: 5s     # 초기 대기 시간
      factor: 2        # 증가 비율 
      maxDuration: 3m  # 최대 대기 시간
  syncOptions:
    - CreateNamespace=true            # 네임스페이스 자동 생성
    - PrunePropagationPolicy=foreground  # 리소스 삭제 전파 방식
    - PruneLast=true                  # 마지막에 프루닝 실행
    - ApplyOutOfSyncOnly=true         # 변경된 리소스만 적용
    - Validate=false                  # kubectl validation 비활성화
```

## 4. Generator 유형 및 사용법

ApplicationSet에서 사용하는 생성기(Generator)는 다양한 파라미터를 동적으로 생성합니다.

### 4.1 List Generator

정적인 값 목록을 기반으로 애플리케이션을 생성합니다.

```yaml
generators:
  - list:
      elements:
        - env: dev
          namespace: dev
        - env: staging
          namespace: staging
        - env: prod
          namespace: prod
```

### 4.2 Cluster Generator

ArgoCD에 등록된 클러스터를 기반으로 애플리케이션을 생성합니다.

```yaml
generators:
  - clusters:
      selector:
        matchLabels:
          environment: production
```

### 4.3 Git Generator

Git 저장소의 파일이나 디렉토리를 기반으로 애플리케이션을 생성합니다.

```yaml
generators:
  - git:
      repoURL: https://github.com/example/environments.git
      revision: HEAD
      directories:
        - path: environments/*
```

### 4.4 Matrix Generator

두 개 이상의 생성기를 조합하여 매트릭스 형태로 파라미터를 생성합니다.

```yaml
generators:
  - matrix:
      generators:
        - list:
            elements:
              - env: dev
              - env: prod
        - git:
            repoURL: https://github.com/example/services.git
            revision: HEAD
            files:
              - path: "services/*/config.json"
```

## 5. 구문 간 관계와 역할

### 5.1 Resource 관계도

ArgoCD에서의 리소스들의 관계는 다음과 같습니다:

1. **Project**: 애플리케이션 그룹과 제약 조건 정의
    
    - 여러 Application을 포함
    - 리소스 제한, 권한 관리
2. **Application**: 배포할 실제 애플리케이션 정의
    
    - Project에 속함
    - Source와 Destination으로 구성
3. **ApplicationSet**: 여러 Application의 템플릿 정의
    
    - Generator로 파라미터 생성
    - Template으로 Application 정의
4. **Config Maps**: ArgoCD 자체 설정
    
    - Repository 연결 정보
    - RBAC 설정
    - 커스텀 설정

### 5.2 구문 간 역할 분담

1. **Project YAML**:
    
    - 애플리케이션 그룹 정의
    - 소스 저장소 제한
    - 배포 대상 제한
    - 리소스 유형 제한
    - 역할 기반 접근 제어
2. **Application YAML**:
    
    - 구체적인 배포 구성 정의
    - 소스 위치 및 유형 지정
    - 배포 대상 지정
    - 동기화 정책 및 옵션 정의
    - 리소스 관리 방법 정의
3. **ApplicationSet YAML**:
    
    - 여러 애플리케이션의 템플릿 정의
    - 동적 파라미터 생성 규칙 정의
    - 멀티 클러스터/환경 관리 간소화
    - 템플릿으로 일관된 애플리케이션 생성
4. **Configuration YAML**:
    
    - ArgoCD 자체 설정 관리
    - 저장소 인증 정보 관리
    - RBAC 정책 관리
    - 동기화 설정 관리

## 6. 모범 사례 및 권장 패턴

### 6.1 애플리케이션 구성 분리

애플리케이션 소스 코드와 배포 구성을 별도의 Git 저장소로 분리하는 것이 권장됩니다:

- 명확한 감사 로그 유지
- 불필요한 CI 빌드 트리거 방지
- 액세스 권한 분리

### 6.2 환경별 구성 관리

환경별 구성을 관리하는 패턴:

1. **브랜치 기반**: 환경별로 별도의 브랜치 사용
2. **폴더 기반**: 단일 브랜치에서 환경별 폴더 사용
3. **Kustomize 오버레이**: 기본 구성과 환경별 오버레이 사용

### 6.3 App of Apps 패턴

상위 애플리케이션이 여러 하위 애플리케이션을 관리하는 패턴:

```yaml
# 상위 애플리케이션
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/apps.git
    targetRevision: HEAD
    path: apps
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

하위 애플리케이션은 상위 저장소의 해당 경로에 정의됩니다.

## 7. 예제 시나리오

### 7.1 기본 웹 애플리케이션 배포

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: web-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/web-app.git
    targetRevision: main
    path: kubernetes
  destination:
    server: https://kubernetes.default.svc
    namespace: web
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

### 7.2 멀티 환경 관리 (ApplicationSet 사용)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: web-app-environments
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: dev
            url: https://kubernetes.default.svc
          - env: staging
            url: https://staging-cluster.example.com
          - env: prod
            url: https://prod-cluster.example.com
  template:
    metadata:
      name: 'web-app-{{env}}'
      labels:
        env: '{{env}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/example/web-app.git
        targetRevision: main
        path: kubernetes/overlays/{{env}}
      destination:
        server: '{{url}}'
        namespace: web-{{env}}
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
```

### 7.3 Helm 차트 배포

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-ingress
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: nginx-ingress-controller
    targetRevision: 9.3.0
    helm:
      releaseName: nginx-ingress
      values: |
        controller:
          replicaCount: 2
          service:
            type: LoadBalancer
      parameters:
        - name: controller.ingressClassResource.name
          value: nginx
        - name: controller.metrics.enabled
          value: "true"
  destination:
    server: https://kubernetes.default.svc
    namespace: ingress-nginx
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## 8. 요약 및 결론

ArgoCD는 Kubernetes 환경에서 GitOps 방식의 지속적 배포를 구현하기 위한 강력한 도구입니다. 핵심 구성요소인 Application, Project, ApplicationSet을 통해 애플리케이션 배포를 효과적으로 관리할 수 있습니다.

YAML 구성을 통해 다양한 소스(Git, Helm, Kustomize 등)로부터 애플리케이션을 배포하고, 동기화 정책을 통해 자동화된 배포와 관리를 구현할 수 있습니다. 적절한 구조와 패턴을 적용함으로써 멀티 클러스터, 멀티 환경을 효율적으로 관리할 수 있습니다.

선언적 설정을 통해 배포 상태를 코드로 관리함으로써, 변경 사항의 추적과 감사가 용이하며, 반복 가능한 배포 프로세스를 구현할 수 있습니다.

## 참고 자료

- Argo CD 공식 문서[1](https://argo-cd.readthedocs.io/en/stable/)
- GitHub Argo CD 프로젝트[2](https://github.com/argoproj/argo-cd)

---

## Appendix: Supplementary Video Resources

![youtube](https://i.ytimg.com/vi/9_P7dANzXXk/hqdefault.jpg)![youtube](data:image/png;base64,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)

[ArgoCD] DevOps 엔지너어라면 알아야 할 GitOps!
