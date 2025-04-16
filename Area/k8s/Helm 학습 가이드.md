#k8s #helm
## Helm 소개

### Helm이란?

Helm은 Kubernetes 패키지 관리자로, 애플리케이션을 Kubernetes 클러스터에 배포하고 관리하는 것을 단순화합니다. Helm은 여러 Kubernetes 리소스를 묶어 하나의 유닛(Chart)으로 관리할 수 있게 해줍니다.

### Helm의 역할

- **복잡한 애플리케이션 배포 단순화**: 여러 Kubernetes 매니페스트 파일을 하나의 패키지로 관리
- **구성 관리**: 애플리케이션의 다양한 환경(개발, 스테이징, 프로덕션)에 대한 구성 관리 지원
- **릴리스 관리**: 애플리케이션 업그레이드, 롤백, 히스토리 추적 기능 제공
- **배포 표준화**: 조직 내에서 일관된 방식으로 애플리케이션 배포 가능
- **의존성 관리**: 애플리케이션 간 의존성 관리 지원

### Helm의 발전 역사

- **Helm 1**: 최초 버전, Tiller라는 서버 컴포넌트와 클라이언트로 구성
- **Helm 2**: Tiller 서버를 통한 중앙화된 관리 모델 도입
- **Helm 3**: 보안 강화를 위해 Tiller 제거, 사용자 권한 기반 모델로 전환

## Helm 설치 및 시작하기

### Helm 설치하기

다양한 OS에서 Helm을 설치하는 방법:

**Linux (스크립트 사용)**:

```bash
Copycurl <https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3> | bash

```

**macOS (Homebrew)**:

```bash
Copybrew install helm

```

**Windows (Chocolatey)**:

```bash
Copychoco install kubernetes-helm

```

**Windows (Scoop)**:

```bash
Copyscoop install helm

```

### 설치 확인

```bash
Copyhelm version

```

### Helm 리포지토리 추가하기

```bash
Copy# 공식 Helm 안정 리포지토리 추가
helm repo add stable <https://charts.helm.sh/stable>

# Bitnami 리포지토리 추가 (많은 애플리케이션 제공)
helm repo add bitnami <https://charts.bitnami.com/bitnami>

# 리포지토리 업데이트
helm repo update

```

### 첫 번째 차트 배포하기

```bash
Copy# Nginx 차트 검색
helm search repo nginx

# Bitnami의 Nginx 차트 배포
helm install my-nginx bitnami/nginx

# 배포 상태 확인
helm list
kubectl get all | grep nginx

```

## Helm의 핵심 개념

### Chart

Chart는 Kubernetes 리소스를 설치하는 데 필요한 정보를 포함하는 Helm 패키지입니다.

**특징**:

- 여러 Kubernetes 리소스 정의 파일 포함
- 템플릿 기능 지원
- 버전 관리 가능
- 재사용 가능한 구성 요소

### Release

Release는 Kubernetes 클러스터에 배포된 Chart의 인스턴스입니다.

**특징**:

- 고유한 릴리스 이름으로 식별
- 특정 구성으로 배포됨
- 버전 히스토리 관리
- 업그레이드 및 롤백 가능

### Repository

Repository는 Chart를 공유하고 저장하는 장소입니다.

**특징**:

- 공개 또는 비공개 저장소 가능
- Chart 패키지(압축 파일) 보관
- 인덱스 파일로 관리
- HTTP 프로토콜 사용

### Values

Values는 Chart의 기본값을 사용자 설정으로 재정의할 수 있는 시스템입니다.

**특징**:

- YAML 형식으로 제공
- 계층 구조 지원
- 다양한 방법으로 값 주입 가능
- 환경별 구성 분리 가능

## Helm Chart 구조 이해하기

### 기본 Chart 구조

```
mychart/
  ├── Chart.yaml           # 차트 메타데이터
  ├── values.yaml          # 기본 구성 값
  ├── templates/           # 템플릿 디렉토리
  │   ├── deployment.yaml  # Kubernetes 리소스 템플릿
  │   ├── service.yaml
  │   ├── _helpers.tpl     # 템플릿 헬퍼 함수
  │   └── NOTES.txt        # 사용 지침
  ├── charts/              # 의존성 차트 (하위 차트)
  ├── .helmignore          # 패키징 시 무시할 파일 패턴
  └── README.md            # 문서

```

### Chart.yaml 파일

Chart의 메타데이터를 정의합니다:

```yaml
CopyapiVersion: v2             # Helm API 버전 (v2는 Helm 3용)
name: mychart              # 차트 이름
version: 0.1.0             # 차트 버전
description: My first Helm chart
type: application          # application 또는 library
appVersion: "1.0.0"        # 앱 버전 (차트 버전과 별개)
dependencies:              # 의존성 정의
  - name: mysql
    version: 8.8.6
    repository: <https://charts.bitnami.com/bitnami>
    condition: mysql.enabled
maintainers:               # 유지보수자 정보
  - name: Your Name
    email: your.email@example.com

```

### values.yaml 파일

Chart의 기본 구성 값을 정의합니다:

```yaml
Copy# 기본 복제본 수
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "latest"

service:
  type: ClusterIP
  port: 80

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi

```

### 템플릿 디렉토리

Kubernetes 리소스 템플릿을 포함합니다:

**deployment.yaml 예시**:

```yaml
CopyapiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "mychart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "mychart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          ports:
            - containerPort: {{ .Values.service.port }}

```

## Helm 명령어 마스터하기

### 기본 명령어

```bash
Copy# 차트 검색
helm search repo [keyword]      # 추가된 리포지토리에서 검색
helm search hub [keyword]       # Helm Hub에서 검색

# 차트 정보 확인
helm show chart bitnami/nginx   # 차트 메타데이터 보기
helm show values bitnami/nginx  # 차트 기본값 보기
helm show readme bitnami/nginx  # 차트 README 보기
helm show all bitnami/nginx     # 모든 정보 보기

# 차트 배포
helm install [release-name] [chart]            # 기본값으로 배포
helm install -f values.yaml [release-name] [chart]  # 값 파일 사용
helm install --set key=value [release-name] [chart] # 개별 값 설정

# 릴리스 관리
helm list                       # 배포된 릴리스 목록
helm status [release-name]      # 릴리스 상태 확인
helm get values [release-name]  # 릴리스 구성 값 확인
helm get manifest [release-name] # 생성된 매니페스트 확인

# 릴리스 업그레이드 및 롤백
helm upgrade [release-name] [chart]        # 릴리스 업그레이드
helm rollback [release-name] [revision]    # 이전 버전으로 롤백
helm history [release-name]                # 릴리스 이력 보기

# 릴리스 제거
helm uninstall [release-name]   # 릴리스 삭제

```

### 고급 명령어

```bash
Copy# 차트 개발
helm create [chart-name]        # 새 차트 생성
helm package [chart-dir]        # 차트 패키징
helm lint [chart-dir]           # 차트 검증

# 템플릿 렌더링
helm template [release-name] [chart]       # 템플릿 렌더링 결과 확인
helm template --debug [release-name] [chart] # 디버그 정보 포함

# 배포 시뮬레이션
helm install --dry-run --debug [release-name] [chart]

# 의존성 관리
helm dependency update [chart]  # 차트 의존성 업데이트
helm dependency build [chart]   # 차트 의존성 빌드
helm dependency list [chart]    # 차트 의존성 목록 보기

# 리포지토리 관리
helm repo add [name] [url]      # 리포지토리 추가
helm repo list                  # 리포지토리 목록
helm repo remove [name]         # 리포지토리 제거
helm repo update                # 리포지토리 인덱스 업데이트

```

## 나만의 Helm Chart 만들기

### 첫 번째 차트 생성

```bash
Copy# 기본 차트 구조 생성
helm create mychart

# 생성된 구조 확인
ls -la mychart/

```

### Chart 사용자 정의하기

**values.yaml 수정**:

```yaml
Copy# 기본값 수정
replicaCount: 2

image:
  repository: nginx
  tag: "1.19.10"

service:
  type: NodePort
  port: 80

```

**templates/deployment.yaml 수정**:

```yaml
Copy# 필요에 따라 템플릿 수정
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mychart.fullname" . }}
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
    app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
spec:
  replicas: {{ .Values.replicaCount }}
  # ... 나머지 내용 생략 ...

```

### Chart 테스트 및 디버깅

```bash
Copy# 템플릿 렌더링 확인
helm template mychart

# 문법 검사
helm lint mychart

# 테스트 배포 (dry-run)
helm install --dry-run --debug my-release ./mychart

# 실제 배포
helm install my-release ./mychart

```

### Chart 패키징 및 공유

```bash
Copy# Chart 패키징
helm package mychart

# 패키지 검증
helm template mychart-0.1.0.tgz

# 로컬 리포지토리 생성 및 배포
mkdir -p ~/helm-repo
mv mychart-0.1.0.tgz ~/helm-repo
helm repo index ~/helm-repo --url <https://example.com/helm-repo>

```

## Chart 의존성 관리

### 의존성 선언

**Chart.yaml에 의존성 추가**:

```yaml
Copydependencies:
  - name: mysql
    version: 8.8.6
    repository: <https://charts.bitnami.com/bitnami>
    condition: mysql.enabled
  - name: redis
    version: 12.7.4
    repository: <https://charts.bitnami.com/bitnami>
    condition: redis.enabled

```

### 의존성 관리 명령어

```bash
Copy# 의존성 업데이트
helm dependency update mychart

# 의존성 상태 확인
helm dependency list mychart

```

### 의존성 구성 관리

**values.yaml에서 의존성 구성**:

```yaml
Copy# 의존성 활성화/비활성화
mysql:
  enabled: true
  # MySQL 차트의 값 재정의
  auth:
    rootPassword: "mysecretpassword"
    database: myapp

redis:
  enabled: false

```

## Helm 템플릿 작성법

### 템플릿 문법 기초

Helm은 Go 템플릿 라이브러리를 사용합니다:

```yaml
Copy# 기본 변수 참조
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  release: {{ .Release.Name }}

# 조건문
{{- if .Values.service.enabled }}
# 서비스 정의
{{- end }}

# 반복문
spec:
  containers:
  {{- range .Values.containers }}
  - name: {{ .name }}
    image: {{ .image }}
  {{- end }}

```

### 내장 객체

Helm 템플릿에서 사용할 수 있는 주요 객체:

- **.Values**: values.yaml 및 명령줄 값
- **.Release**: 릴리스 정보 (이름, 네임스페이스, 리비전 등)
- **.Chart**: Chart.yaml 정보
- **.Files**: 차트 내 파일 접근
- **.Capabilities**: Kubernetes 버전 등 클러스터 정보
- **.Template**: 현재 템플릿 정보

```yaml
Copy# 예시
apiVersion: {{ .Capabilities.APIVersions.Has "batch/v1" | ternary "batch/v1" "batch/v1beta1" }}
kind: CronJob
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}

```

### 함수와 파이프라인

```yaml
Copy# 문자열 함수
app: {{ .Values.app | lower | trunc 63 }}

# 기본값 설정
image: {{ .Values.image | default "nginx:latest" }}

# 들여쓰기
spec:
  template:
    metadata:
      labels:
        {{- include "mychart.labels" . | nindent 8 }}

```

### 네임드 템플릿 (부분 템플릿)

_helpers.tpl 파일에 재사용 가능한 템플릿 정의:

```yaml
Copy{{/* 공통 레이블 생성 */}}
{{- define "mychart.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

# 사용 방법:
metadata:
  labels:
    {{- include "mychart.labels" . | nindent 4 }}

```

## Helm Hook 활용하기

### Hook 이해하기

Hook은 Helm 릴리스 라이프사이클의 특정 시점에 작업을 실행할 수 있게 합니다:

- `pre-install`: 템플릿이 렌더링된 후, 쿠버네티스에 전송되기 전
- `post-install`: 모든 리소스가 쿠버네티스에 로드된 후
- `pre-delete`: 삭제 작업 전
- `post-delete`: 삭제 작업 후
- `pre-upgrade`, `post-upgrade`: 업그레이드 시
- `pre-rollback`, `post-rollback`: 롤백 시
- `test`: 테스트 실행 시

### Hook 작성 예시

```yaml
CopyapiVersion: batch/v1
kind: Job
metadata:
  name: {{ .Release.Name }}-db-init
  annotations:
    "helm.sh/hook": post-install
    "helm.sh/hook-weight": "5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      containers:
      - name: db-init
        image: postgres:13
        command: ["psql", "-c", "CREATE DATABASE app;"]
      restartPolicy: Never

```

### Hook 우선순위 및 정책

- **[helm.sh/hook-weight](http://helm.sh/hook-weight)**: 실행 순서 지정 (낮은 숫자가 먼저 실행)
- **[helm.sh/hook-delete-policy](http://helm.sh/hook-delete-policy)**: Hook 자원 삭제 정책
    - `hook-succeeded`: 성공 시 삭제
    - `hook-failed`: 실패 시 삭제
    - `before-hook-creation`: 새 훅 실행 전 삭제

## 실전 예제 및 모범 사례

### 멀티 티어 애플리케이션 차트

**웹 애플리케이션 + 데이터베이스 + 캐시 구성**:

```
webapp/
  ├── Chart.yaml
  ├── values.yaml
  ├── templates/
  │   ├── deployment.yaml
  │   ├── service.yaml
  │   ├── ingress.yaml
  │   ├── configmap.yaml
  │   ├── secret.yaml
  │   └── NOTES.txt
  └── charts/
      ├── mysql-8.8.6.tgz
      └── redis-12.7.4.tgz

```

**values.yaml 구성**:

```yaml
CopyreplicaCount: 2

image:
  repository: myapp
  tag: "1.0.0"

ingress:
  enabled: true
  host: myapp.example.com

config:
  apiUrl: "/api/v1"
  logLevel: "info"

# 의존성 구성
mysql:
  enabled: true
  auth:
    database: myapp
    username: myapp

redis:
  enabled: true
  auth:
    enabled: true

```

### 환경별 구성 관리

**환경별 values 파일 생성**:

```
values/
  ├── values-dev.yaml
  ├── values-staging.yaml
  └── values-prod.yaml

```

**values-dev.yaml**:

```yaml
CopyreplicaCount: 1
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

```

**values-prod.yaml**:

```yaml
CopyreplicaCount: 3
resources:
  limits:
    cpu: 1
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

```

**환경별 배포**:

```bash
Copyhelm install myapp-dev ./myapp -f values/values-dev.yaml
helm install myapp-prod ./myapp -f values/values-prod.yaml

```

### Helm Chart 모범 사례

1. **버전 관리**:
    - 시맨틱 버전 관리 사용 (X.Y.Z)
    - Chart 버전과 앱 버전 분리
2. **값 구성**:
    - 기본값은 작동하도록 설정
    - 모든 구성 가능한 값에 주석 추가
    - 중첩된 값 구조 사용
3. **템플릿 작성**:
    - 재사용 가능한 템플릿 조각 활용
    - 적절한 들여쓰기 유지
    - 주석을 통한 문서화
4. **보안**:
    - 민감한 정보는 Secret 사용
    - 최소 권한 원칙 적용
    - 컨테이너 보안 컨텍스트 설정
5. **테스트**:
    - 단위 테스트 포함
    - CI/CD 파이프라인 연동
    - 차트 린팅 자동화

## Helm 3과 Helm 2의 차이점

### 주요 아키텍처 변경

|기능|Helm 2|Helm 3|
|---|---|---|
|아키텍처|클라이언트-서버 (Tiller)|클라이언트만 존재|
|보안 모델|Tiller가 권한 관리|Kubernetes RBAC 사용|
|릴리스 정보 저장|ConfigMap|Secret|
|릴리스 네임스페이스|전역|네임스페이스 범위|
|Chart API 버전|v1|v2|

### 주요 변경 사항

1. **Tiller 제거**:
    - Helm 2: Tiller가 클러스터에서 관리자 권한으로 실행
    - Helm 3: Tiller 없이 사용자 권한으로 직접 API 서버와 통신
2. **릴리스 관리**:
    - Helm 2: 네임스페이스에 관계없이 릴리스 이름은 고유해야 함
    - Helm 3: 네임스페이스 내에서만 릴리스 이름이 고유하면 됨
3. **의존성 관리**:
    - Helm 2: requirements.yaml 별도 파일 사용
    - Helm 3: Chart.yaml 내에 의존성 정의
4. **Push 명령어 제거**:
    - Helm 2: `helm push` 명령어 제공
    - Helm 3: 외부 플러그인으로 대체
5. **3-way 전략적 병합**:
    - Helm 3: 더 나은 업그레이드 및 롤백 지원을 위한 개선된 병합 전략

## 자주 발생하는 문제 해결

### 일반적인 오류 및 해결 방법

1. **차트 설치 실패**:
    
    ```
    Error: INSTALLATION FAILED: cannot re-use a name that is still in use
    
    ```
    
    - 해결: `helm list --all` 로 확인 후 삭제하거나 다른 이름 사용
2. **리포지토리 접근 오류**:
    
    ```
    Error: looks like "<https://charts.example.com>" is not a valid chart repository
    
    ```
    
    - 해결: URL 확인, 네트워크 연결 확인, `helm repo update` 실행
3. **템플릿 렌더링 오류**:
    
    ```
    Error: template: mychart/templates/deployment.yaml:15:13:
    executing "mychart/templates/deployment.yaml" at <.Values.image.tag>: nil pointer evaluating interface {}.tag
    
    ```
    
    - 해결: 값이 없으면 기본값 지정 `{{ .Values.image.tag | default "latest" }}`
4. **버전 충돌**:
    
    ```
    Error: UPGRADE FAILED: current release manifest contains removed kubernetes api(s)
    
    ```
    
    - 해결: 차트 API 버전 업데이트 또는 호환성 확인

### 디버깅 기법

1. **템플릿 디버깅**:
    
    ```bash
    Copy# 템플릿 출력 확인
    helm template --debug mychart
    
    # 특정 값으로 템플릿 렌더링
    helm template --set key=value mychart
    
    ```
    
2. **설치 디버깅**:
    
    ```bash
    Copy# 설치 시뮬레이션
    helm install --dry-run --debug myrelease mychart
    
    ```
    
3. **값 확인**:
    
    ```bash
    Copy# 현재 사용 중인 값 확인
    helm get values myrelease
    
    ```
    
4. **로그 확인**:
    
    ```bash
    Copy# 설치된 Pod 로그 확인
    kubectl logs $(kubectl get pods -l app.kubernetes.io/instance=myrelease -o name)
    
    ```
    

## 추가 학습 자료

### 공식 문서 및 튜토리얼

- [Helm 공식 문서](https://helm.sh/docs/)
- [Helm GitHub 리포지토리](https://github.com/helm/helm)
- [Helm Hub](https://artifacthub.io/)
- [Helm 퀵스타트 가이드](https://helm.sh/docs/intro/quickstart/)
- [Helm 차트 개발 팁과 트릭](https://helm.sh/docs/howto/charts_tips_and_tricks/)

### 책 및 강의

- [Helm: 쿠버네티스 패키지 관리자 완벽 가이드](https://amzn.com/1492083712)
- [쿠버네티스로 클라우드 네이티브 애플리케이션 구축하기](https://www.manning.com/books/cloud-native-applications-in-kubernetes)
- [Udemy - Helm 마스터 클래스](https://www.udemy.com/course/helm-masterclass/)
- [Linux Foundation - Kubernetes 패키징 및 배포 관리를 위한 Helm](https://training.linuxfoundation.org/training/kubernetes-packaging-applications-helm-lfs244/)

### 커뮤니티 및 블로그

- [Helm Slack 커뮤니티](https://kubernetes.slack.com/messages/helm)
- [CNCF Helm 프로젝트](https://www.cncf.io/projects/helm/)
- [Bitnami Engineering Blog](https://engineering.bitnami.com/tags/helm/)
- [DigitalOcean Kubernetes 튜토리얼](https://www.digitalocean.com/community/tutorials/how-to-install-software-on-kubernetes-clusters-with-the-helm-3-package-manager)

### 실습 프로젝트

1. **기본 웹 애플리케이션 배포**:
    - NGINX + MySQL + Redis 조합으로 간단한 웹 애플리케이션 차트 생성
2. **마이크로서비스 아키텍처**:
    - 프런트엔드, 백엔드 API, 데이터베이스로 구성된 마이크로서비스 차트 생성
3. **모니터링 스택 배포**:
    - Prometheus + Grafana + Alertmanager 조합으로 모니터링 스택 배포
4. **CI/CD 파이프라인과 Helm 통합**:
    - Jenkins 또는 GitLab CI를 사용하여 Helm 차트 자동 배포 파이프라인 구축

---

이 학습 가이드를 통해 Helm의 기본 개념부터 고급 기능까지 체계적으로 학습할 수 있습니다. 실습과 함께 점진적으로 학습하면 Kubernetes 애플리케이션 관리 역량을 크게 향상시킬 수 있습니다. Helm은 Kubernetes 환경에서 애플리케이션 배포를 간소화하고 표준화하는 강력한 도구로, 클라우드 네이티브 애플리케이션 관리에 필수적인 기술입니다.