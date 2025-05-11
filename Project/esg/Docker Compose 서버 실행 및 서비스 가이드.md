## 1. 개요
이 프로젝트는 Spring Boot, Node.js 정적 자원 빌드, Flyway 마이그레이션, MariaDB를 Docker Compose로 통합 관리합니다.

---
## 2. 요구사항
- Docker 20.x 이상
- Docker Compose v2 이상
---
## 3. 환경별 Docker 설치 및 compose 실행

### Windows

1. [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) 설치
2. PowerShell 또는 CMD에서 프로젝트 루트로 이동
3. 실행:
```sh

docker compose up -d --build

```

4. 종료:
```sh

docker compose down

```

### Ubuntu
1. Docker, Docker Compose 설치

```sh

sudo apt update

sudo apt install docker.io docker-compose-plugin -y

sudo systemctl enable --now docker

```

2. 프로젝트 루트로 이동
3. 실행:
```sh

docker compose up -d --build

```
4. 종료:
```sh

docker compose down

```

---

## 4. 환경 변수 및 .env 파일
- 기본적으로 docker-compose.yml에 환경변수가 명시되어 있습니다.
- 필요시 프로젝트 루트에 `.env` 파일을 생성해 아래와 같이 작성할 수 있습니다.
```env

SPRING_DATASOURCE_URL=jdbc:mariadb://mariadb:3306/ESG_HOMEPAGE?autoReconnect=true&allowMultiQueries=true&useSSL=false

SPRING_DATASOURCE_USERNAME=root

SPRING_DATASOURCE_PASSWORD=dpvmdptm1!

```

---
## 5. 주요 서비스 설명
### mariadb
- 포트: 3307 (호스트) → 3306 (컨테이너)
- DB명: ESG_HOMEPAGE, 계정: root, 비번: dpvmdptm1!
- 데이터는 `mariadb_data` 볼륨에 저장
### flyway
- DB 마이그레이션 자동 수행
- 마이그레이션 실패 시 `repair` 명령 필요:
```sh

# docker-compose.yml에서 flyway 서비스의 command를 repair로 변경 후 실행

docker compose up esg-flyway

# 완료 후 migrate로 복구

```

### springboot-app
- Node.js로 정적 자원 빌드 후 Spring Boot JAR 실행
- 포트: 8088
- 환경변수로 DB 접속 정보 주입
---
## 6. 자주 발생하는 문제와 해결법
- **마이그레이션 실패(Validate failed, Foreign key 오류 등)**
- DB 볼륨 완전 삭제: `docker compose down -v`
- Flyway repair: 위 flyway 설명 참고
- **포트 충돌**
- 3307, 8088 포트가 이미 사용 중이면 docker-compose.yml에서 포트 변경
- **권한 오류**
- mariadb 볼륨 삭제 후 재시작
---
## 7. 기타 참고사항
- 정적 자원 빌드는 `src/main/resources/fs`에서 수행
- 로그는 `./logs` 폴더에 저장
- 컨테이너 상태 확인: `docker compose ps`
- 로그 확인: `docker compose logs [서비스명]`