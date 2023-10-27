---
tags:
  - design-pattern
---
# Reactor / Proactor 패턴

태그: Proactor, Reactor
Date: September 7, 2023 12:23 AM
공개 여부: 공개
설명: 비동기 논블로킹 구현의 핵심
카테고리: 디자인 패턴

# 학습 이전 사진 지식

****[Blocking/Non-Blocking I/O && I/O 이벤트 통지 모델](https://velog.io/@octo__/BlockingNon-Blocking-IO-IO-%EC%9D%B4%EB%B2%A4%ED%8A%B8-%ED%86%B5%EC%A7%80-%EB%AA%A8%EB%8D%B8#:~:text=I%2FO%20%EC%9D%B4%EB%B2%A4%ED%8A%B8%20%ED%86%B5%EC%A7%80%20%EB%B0%A9%EC%8B%9D%EC%97%90%EB%8A%94%20%EB%8F%99%EA%B8%B0%2F%EB%B9%84%EB%8F%99%EA%B8%B0(synchronus,async%20%EB%B0%A9%EC%8B%9D%EC%9C%BC%EB%A1%9C%20%EB%B6%84%EB%A5%98%EB%90%9C%EB%8B%A4.)****

**[Event Handling Patterns](http://www.dre.vanderbilt.edu/~schmidt/POSA/POSA2/event-patterns.html)**

## 이벤트 핸들링의 주요 동작

- 이벤트 핸들링을 위한 객체들을 초기화(Intiate)하고,
- 여러 통로에서 들어오는 이벤트들을 수신(recieve)하고,
- 이벤트들을 대응할 객체별로 분할하고(demultiplex),
- 개체에게 이벤트를 발송(dispatch)해서,
- 그 개체가 이벤트에 걸맞는 작업을 수행(process events)한다.

이 일련의 동작으로 동시다발적으로 들어오는 각각의 입력에 대해서 적절한 대응을 수행할 수 있다.

# Reactor 패턴

![Untitled](Untitled%2044.png)

![이벤트 핸들링 패턴의 전형적인 모습](Untitled%2045.png)

이벤트 핸들링 패턴의 전형적인 모습

`Reactor 패턴`은 `애플리케이션`이 능동적으로 지속적인 처리를 위한 루프를 도는 것이 아닌,

이벤트에 반응하는 `객체(Reactor)` 가 `사건(Event)`이 발생하면 애플리케이션 대신 `객체(Reactor)`가 반응하여 처리하는 것을 의미함.

- 객체는 이벤트 발생을 대기하고 발생 시 이벤트 핸들러에게 이벤트를 발송한다.

이런 구조면 `애플리케이션`에서 이벤트를 대기하고 분할하는 작업을 따로 수행하지 않아도 동작할 수 있기 때문에 `이벤트 멀티플렉싱`을 구현하는데 좋은 구조이다.

<aside>
💡 **멀티플렉싱(Multiplexing)?**
하나의 채널에서 2개 이상의 데이터를 전송하는 기술
최소한의 물리장비를 사용하며 최대한의 데이터를 전송하기 위해 고안 됨

</aside>

동작 구조는 다음과 같다.

- 이벤트에 반응하는 reactor를 만들고 reactor에 이벤트를 처리할 event handler들을 등록한다. (initiate)
- reactor는 이벤트가 발생하기를 기다린다. (receive)
- 이벤트가 발생하면 이벤트를 처리할 event handler단위로 분할한다.(demultiplex)
- 분할된 이벤트를 해당 event handler에게 발송한다. (dispatch)
- event handler에 알맞은 method를 사용하여 이벤트를 처리한다. (process event)

<aside>
💡 Reactor 패턴의 I/O 통지모델은 직접 I/O 이벤트를 대기하는 동기형 multiplex 모델이다.

</aside>

**근데 좀 더 쉽게 설명해보자.**

1. 새로운 연결이 들어온다.
2. 이 연결과 연결에 대해서 처리할 이벤트를 일괄 등록한다.
    - 이벤트는 "입력 데이터", "출력 데이터", "종료"등이 있을 수 있다.
3. 주기적으로 이벤트를 확인한다.
4. 이벤트가 발생하면 **dispatcher** 에 전달해서 처리한다.

한 번 짚고 넘어갈 것이 2번이 바로 `멀티플렉싱`이다.

<aside>
💡 즉 여러 개의 입력을 처리할 수 있도록 다중화 한다.

</aside>

그렇다면 3번이 바로 `디멀티플렉싱(demultiplexing)` 과정으로 이벤트가 발생한 “하나의” 입력을 찾아낸다.

마지막으로 dispatcher 로 데이터를 처리한다.

## 주의 사항

### 처리할 수 있는 이벤트 핸들러의 갯수 제한

동시에 수 많은 I/O 요청이 발생하는 경우, 너무 많은 이벤트 핸들러가 등록되는데 그럴 경우 눈에 띄게 성능이 저하한다.

이벤트 핸들러 **등록 갯수가 관리할 수 있는 범주를 넘어선다면 애플리케이션이 폭발한다.** 

### 다중 스레드 환경에서 효율이 적다

하나의 `객체(Reactor)` 는 하나의 스레드만 사용이 가능하다.

다중 스레드를 활용하려면 쓰레드 별로 `객체(Reactor)` 를 사용해야 하는데, 여기에 OS 의 스케줄링 능력을 활용할 수 없다.

특정 스레드에 부하가 걸리면 다른 스레드로 I/O 요청을 수행해야 하는데, 이 기능은 개발자가 직접 구현하는 수 밖에 없고, 직접 구현해도 OS 의 스케줄링 보다 뛰어나긴 어렵다.

# Proactor 패턴

![Untitled](Untitled%2046.png)

![Proactor Pattern](Untitled%2047.png)

Proactor Pattern

Reactor 패턴에서 이벤트 핸들러가 비대해지는 경우 발생하는 문제점을 해결하기 위해 나온 패턴이다.

해당 패턴은 이벤트를 수동적으로 기다리지 않는다.

비동기 연산이 가능한 작업거리를 demultiplexing 한 후, 작업까지 비동기 처리해버린다.

그리고 작업이 완료되면 비동기 연산이 Completion Dispatch 에게 이벤트를 넘기고 Dispatcher 는 적절한 Completion Handler(Queue) 에게 이벤트를 발행(Dispatch) 한다.

<aside>
💡 Reactor 에서 이벤트가 작업이 가능함을 알리는 용도였다면,
Proactor 에서 이벤트는 작업의 완료를 알리는 용도이다.

</aside>

Completion Handler  이벤트가 발행(Dispatch)되면 미리 정해진 콜백을 호출하여 프로세스를 처리한다.

- proactor는 비동기 작업을 지시하고 완료 이벤트를 받을 completion handler를 등록한다.(initiate)
- 비동기 프로세스가 가능한 작업을 대기한다. 혹은 작업이 발생하면 깨어나 처리한다(receive)
- 가능한 작업들이 생기면 비동기 프로세스가 작업을 분리하여 비동기적으로 처리한다. (demultiplex / work processing)
- 작업이 완료되면 비동기 프로세스는 completion dispatcher에게 완료 정보를 넘기고 dispatcher는 정보를 이벤트로 만들어서 적절한 completion handler에게 발송한다.(dispatch)
- completion handler는 받은 이벤트의 정보를 토대로 정해진 콜백을 호출하여 process event를 처리한다.(process event)

**용어 및 내용이 굉장히 복잡하니, 추 후 레퍼런스를 참고해서 작성을 더 진행해보자.**

# References

**[Reactor / Proactor 패턴](https://ozt88.tistory.com/25)**

**[Reactor Pattern 과 I/O Multiplexing (반응자 패턴, 입출력 다중화, select, epoll, 혼동 포인트, ProjectReactor)](https://sjh836.tistory.com/184)**

**[Event Handling Patterns](http://www.dre.vanderbilt.edu/~schmidt/POSA/POSA2/event-patterns.html)**

****[The Proactor Pattern[Medium]](https://medium.com/@beeleeong/the-proactor-pattern-bbfe7c33a43c)****

[**JOINIC REACTOR PATTERN**](https://www.joinc.co.kr/w/Site/SoftWare_engineering/pattern/reactor)