#shell-script #os #docker 

간단하게 실행 중인 컨테이너를 종료, 제거하고 다시 빌드 및 컨테이너 재실행하는 스크립트를 작성 후,
GPT 에게 더 안정서있게 작성해달라고 부탁했다.

```bash
#!/bin/bash
PROJECT_DIR="/home/galaxy4276/project/frontend"
NAME="newbie_dev"

# Function to print error messages and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    error_exit "Docker daemon is not running. Please start Docker."
fi

# Get container IDs using the image
container_ids=$(docker ps -a --filter ancestor=$NAME --format "{{.ID}}")

# Stop and remove containers if any exist
if [ -n "$container_ids" ]; then
    echo "Stopping containers: $container_ids"
    docker stop $container_ids || error_exit "Failed to stop containers."
    echo "Removing containers: $container_ids"
    docker rm $container_ids || error_exit "Failed to remove containers."
fi

# Remove image
if docker images -q $NAME >/dev/null 2>&1; then
    echo "Removing image: $NAME"
    docker rmi $NAME || error_exit "Failed to remove image. It may be used by stopped containers."
fi

# Change to project directory
cd "$PROJECT_DIR" || error_exit "Failed to change directory to $PROJECT_DIR."

# Build the Docker image
echo "Building Docker image: $NAME"
docker build -t $NAME . || error_exit "Failed to build Docker image."

# Run the Docker container
echo "Running Docker container: $NAME"
docker run -d -p 3000:80 --name $NAME $NAME || error_exit "Failed to run Docker container."

echo "Script completed successfully."
```

다음 스크립트에서 모르는(배울 수 있는) 코드를 정리하며 `Shell Script` 에 더 익숙해져보고자한다.


# 함수 선언 및 사용

```bash
error_exit() {
    echo "$1" >&2
    exit 1
}
...
error_exit "Docker daemon is not running. Please start Docker."
```

함수 인자는 순서대로 전달된다.

```bash
#!/bin/bash

# 함수 선언
function 함수명()
{
    함수 내용
    # $1 : 인자1, $2 : 인자2 ...
}

# 함수 사용
함수명 인자1 인자2 ...
```
 
* \>&2 는 **모든 출력을 강제로 표준 에러로 출력한다는 의미**이다.
* **종료 코드가 1**은 에러가 발생하며 프로그램이 종료된 것을 의미하며 **종료 상태 코드 0** 은 성공적으로 실행된 것을 의미한다.

# /dev/null

```bash
if ! docker info >/dev/null 2>&1; then
    error_exit "Docker daemon is not running. Please start Docker."
fi
```

> - `>` : 결과를 파일로 저장 (덮어쓰기)
> - `>>` : 결과를 파일로 저장 (덮어쓰지 않고 기존 파일에 추가)
> - `<` : 입력(파일, 텍스트 등)을 명령어에 실행 (덮어쓰기)
> - `<<` : 입력을 명령어에 실행 (덮어쓰지 않고 기존 파일에 추가)

`/dev/null` 은 데이터가 버려지는 특별한 파일이다.
즉 `>/dev/null` 은 표준 출력을 `/dev/null` 로 리디렉션 처리한다.

`2>&1` 은 표준 에러(stderr) 를 표준 출력(stdout) 으로 리디렉션한다.



#### [출처 - bash 함수 사용법](https://github.com/lyw1217/TIL/blob/main/Bash/bash_%ED%95%A8%EC%88%98_%EC%82%AC%EC%9A%A9%EB%B2%95.md)
#### [간단하게 1>, >2, >&2, 2>&1, exec 살펴보기](https://knight76.tistory.com/entry/%EA%B0%84%EB%8B%A8%ED%95%98%EA%B2%8C-1-2-2-exec%EB%A5%BC-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0)

#### [# [Shell Script] 출력 내용의 맨 뒤에 붙는 '2>&1' 의 뜻](https://katfun.tistory.com/190)
