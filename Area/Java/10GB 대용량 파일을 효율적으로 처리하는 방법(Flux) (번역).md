#java #asynchronous #concurrency #flux
# 대용량 파일(10GB) 효과적으로 처리하는 방법
대용량 데이터 처리는 2025년에도 여전히 큰 도전 과제다. 메모리 제한과 처리 시간 때문이다. 요즘 개인용 컴퓨터는 32GB 이상의 메모리를 갖추고 있어 큰 파일을 전부 메모리에 올려서 처리할 수 있지만, 클라우드 컴퓨팅 환경에서는 이런 방식이 일반적이지 않다.

클라우드 애플리케이션에서는 확장성 원칙에 따라 수평적 스케일링을 강조한다. 즉, 단일 인스턴스의 메모리나 CPU를 늘리기보다는 증가하는 자원 요구를 처리하기 위해 추가 애플리케이션 인스턴스를 생성하는 방식을 주로 사용한다.

## 시나리오
이 문제를 설명하기 위해 고객과 지원팀 멤버 간의 채팅 메시지 기록을 담고 있는 대용량 파일을 처리하는 프로그램을 만든다고 가정해보자. 이 프로그램의 목표는 데이터를 익명화하고 기계 학습 컴포넌트로 보내는 것이다.

기본 요구사항은 다음과 같다.
- 입력 파일은 각 줄이 고객이나 지원 엔지니어가 보낸 메시지를 나타내는 독립적인 JSON 객체인 텍스트 파일이다
- 특정 비즈니스 규칙에 따라 일부 채팅 메시지는 무시해야 한다
- 채팅 메시지는 외부 모듈을 사용하여 익명화해야 한다
- 익명화된 채팅 메시지는 기계 학습 컴포넌트로 전송해야 한다

`입력 파일 예시`
```
{ "order" : 0 , "datetime" : "2023-06-25 01:56:44" , "session_id" : 123 , "customer_id" : 307 , "sender" : "customer" , "message" : "Can I speak to a supervisor?" }
{ "order" : 1 , "datetime" : "2023-07-08 09:35:54" , "session_id" : 123 , "customer_id" : 1043 , "sender" : "support" , "message" : "How can I help you?"}
```

파일의 각 줄은 다음과 같은 Java DTO 클래스로 매핑될 수 있다
```java
public class ChatLog {
  private Integer order;
  private String datetime;
  private Integer session_id;
  private Integer customer_id;
  private String sender;
  private String message;
}
```

## 전통적인 접근 방식

첫 번째 접근 방식은 Java InputStream을 사용하여 파일을 처리하는 것이다
```java
public void consumeFile() throws IOException {
  try (var bufferedReader = new BufferedReader(new FileReader("chat_logs.txt"))) {
    String line;
    while ((line = bufferedReader.readLine()) != null) {
      var dto = toDto(line);

      if (!discardUnneeded(dto)) {
        var anonymizedData = anonymizeData(dto);
        sendToML(anonymizedData);
      }
    }
  }
}

// ObjectMapper를 사용하여 텍스트 라인을 객체로 변환
private ChatLog toDto(String line) {
  try {
    return MAPPER.readValue(line, ChatLog.class);
  } catch (JsonProcessingException e) {
    throw new RuntimeException(e);
  }
}

// order가 0인 경우 무시하는 더미 코드
private boolean discardUnneeded(ChatLog chatLog) {
  return chatLog.getOrder() == 0;
}

// 데이터 익명화에 10밀리초가 걸리는 블로킹 프로세싱 시뮬레이션
private ChatLog anonymizeData(ChatLog chatLog) {
  try {
    Thread.sleep(10);
  } catch (InterruptedException e) {
    throw new RuntimeException(e);
  }
  return chatLog;
}

// ML에 데이터 전송에 20밀리초가 걸리는 블로킹 프로세싱 시뮬레이션
private void sendToML(ChatLog chatLog) {
  try {
    Thread.sleep(10);
  } catch (InterruptedException e) {
    throw new RuntimeException(e);
  }
}
```

이 코드는 간단하고 모든 데이터를 메모리에 로드하지 않는다. 하지만 실행 시간이 매우 길어 10시간 넘게 처리한 후에도 프로세스를 중단해야 했다.

## 병렬 스트림 사용하기
병렬 스트림을 활용하여 파일을 처리할 수 있다.
```java
public void consumeFile() throws IOException {
  try (var bufferedReader = new BufferedReader(new FileReader("chat_logs.txt"))) {
    bufferedReader
      .lines()
      .parallel()
      .map(this::toDto)
      .filter(this::discardUnneeded)
      .map(this::anonymizeData)
      .forEach(this::sendToML);
  }
}
```
BufferedReader 클래스의 lines 메서드를 사용하여 파일 줄의 스트림을 얻을 수 있다. 이 스트림을 병렬 스트림으로 변환하면 데이터를 병렬로 처리할 수 있다. 이 접근 방식은 간단하며 실행 성능을 크게 향상시켜 처리 시간을 약 6시간으로 단축시킨다.

## Flux Reactor 사용하기
성능을 더 높이려면 파일 줄을 처리하는 스레드 수를 늘려야 한다. 병렬 스트림은 컴퓨터에서 사용 가능한 코어 수로 제한되기 때문이다. CPU 집약적 처리의 경우 코어 수만큼 스레드를 생성하는 것이 좋다. 그러나 많은 블로킹 작업이 포함된 프로세스의 경우 훨씬 더 많은 스레드를 사용하는 것이 좋다.

더 많은 스레드를 도입하는 쉬운 방법은 다음과 같이 Flux를 사용하는 것이다.
```java
public void consumeFile() throws IOException {
  try (var bufferedReader = new BufferedReader(new FileReader("chat_logs.txt"))) {
    Flux.fromStream(bufferedReader.lines())
      .parallel(100)
      .runOn(Schedulers.boundedElastic())
      .map(this::toDto)
      .filter(this::discardUnneeded)
      .map(this::anonymizeData)
      .doOnNext(this::sendToML)
      .sequential()
      .blockLast();
  }
}
```

이 코드는 약간 더 복잡하지만 스레드 제어를 수동으로 관리하는 것보다 훨씬 간단하다. 다음과 같은 작업을 수행한다.
- 스트림에서 Flux를 생성한다
- 데이터를 병렬로 처리할 100개의 레일을 정의한다
- 코어 수보다 더 많은 스레드를 생성하는 스레딩 전략을 구성한다
- 모든 데이터가 처리될 때까지 기다린다

성능 향상은 상당히 크다. 모든 데이터 처리에 이제 단 38분만 소요된다!

💡 Flux를 사용한 병렬 처리로 성능을 향상시키는 것이 얼마나 간단한지 보여준다.
## Personal Opinion
대용량 파일 처리는 단순히 메모리에 로드하는 방식으로는 효율적이지 않다. 특히 클라우드 환경에서 작업할 때는 더욱 그렇다. 지금까지 살펴본 것처럼 Java에서 제공하는 다양한 비동기 처리 방식을 활용하면 성능을 크게 개선할 수 있다.

개인적으로는 Flux와 같은 리액티브 프로그래밍 도구를 사용하는 것이 매우 효과적이라고 생각한다. 코드의 복잡성이 크게 증가하지 않으면서도 처리 시간을 대폭 줄일 수 있기 때문이다. 대용량 데이터를 다루는 프로젝트에서 이러한 접근 방식을 처음부터 고려한다면 나중에 성능 이슈로 고생하는 상황을 피할 수 있을 것이다.

# Flux와 리액티브 프로그래밍 이해하기
Flux가 왜 이렇게 성능이 비약적으로 상승하는지 좀 더 자세히 알아보자.
## Flux란 무엇인가
Flux는 Project Reactor 라이브러리의 핵심 클래스로, 0에서 N개의 요소를 비동기-논블로킹 방식으로 처리하는 리액티브 스트림이다. 리액티브 프로그래밍의 핵심 구현체로 대용량 데이터를 효율적으로 처리할 수 있는 다양한 연산자를 제공한다.
## 성능 향상의 핵심 요소
Flux가 병렬 스트림보다 성능을 크게 향상시키는 핵심 요소는 다음과 같다:
- **유연한 병렬 처리**: 예제에서 `.parallel(100)`으로 100개의 처리 레일을 구성했는데, 이는 CPU 코어 수에 제한되는 Java 병렬 스트림과 달리 더 많은 병렬 처리를 수행할 수 있다.
- **I/O 최적화 스레드 풀**: `Schedulers.boundedElastic()`은 블로킹 I/O 작업에 최적화된 스레드 풀이다. CPU 연산과 달리 I/O 작업은 대부분 시간을 대기하는데 사용하므로, 코어 수보다 훨씬 많은 스레드를 활용하는 것이 효율적이다.
- **백프레셔(Backpressure) 지원**: 데이터 생산 속도가 처리 속도보다 빠를 때 발생하는 문제를 관리하는 메커니즘이다. 이를 통해 메모리 사용량을 효율적으로 유지하면서 처리량을 최대화할 수 있다.

## 백프레셔(Backpressure)의 이해
백프레셔는 생산자(데이터 소스)가 소비자(데이터 처리자)보다 빠르게 데이터를 생산할 때 발생하는 문제를 관리하는 흐름 제어 방식이다. 대용량 파일 처리에서 특히 중요한 개념이다.

Flux에서 백프레셔는 다음과 같이 작동한다.
- **구독자 기반 요청 처리**: 구독자가 처리할 준비가 된 항목 수를 게시자에게 알려 데이터 흐름을 제어한다.
- **버퍼링과 흐름 제어 전략**: 필요시 다양한 전략(버퍼링, 드롭, 샘플링 등)을 적용하여 효율적으로 데이터를 관리한다.
이를 통해 메모리 부족 없이 대용량 데이터를 효율적으로 처리할 수 있게 된다.

## CPU 연산과 I/O 연산에 대한 최적 스레드 전략
앞서 살펴본 예제 코드에서는 모든 작업에 `Schedulers.boundedElastic()`을 사용했다. 하지만 작업 유형에 따라 다른 스케줄러를 적용하는 것이 더 효율적일 수 있다:
- **CPU 바운드 작업**: JSON 파싱, 필터링 같은 CPU 집약적 작업은 `Schedulers.parallel()`을 사용해 코어 수에 맞게 스레드를 할당하는 것이 효율적이다.
- **I/O 바운드 작업**: 네트워크 요청, 파일 입출력 같은 작업은 `Schedulers.boundedElastic()`을 사용해 더 많은 스레드를 활용하는 것이 좋다.

이런 작업별 최적화된 스케줄러 구성은 다음과 같이 구현할 수 있다.
```java
Flux.fromStream(bufferedReader.lines())
  // CPU 작업은 병렬 스케줄러로 처리
  .publishOn(Schedulers.parallel())
  .map(this::toDto)
  .filter(this::discardUnneeded)
  // I/O 작업은 boundedElastic 스케줄러로 처리
  .publishOn(Schedulers.boundedElastic())
  .flatMap(data -> Mono.fromCallable(() -> anonymizeData(data))
                       .subscribeOn(Schedulers.boundedElastic()), 100)
  .flatMap(data -> Mono.fromRunnable(() -> sendToML(data))
                       .subscribeOn(Schedulers.boundedElastic()), 100)
  .blockLast();
```

이런 방식으로 작업 특성에 맞게 스레드 전략을 구성하면 자원 활용도를 극대화하고 처리 성능을 더욱 향상시킬 수 있다.

# References
https://medium.com/java-tips-and-tricks/how-to-effectively-process-a-10gb-file-2d990e991825
