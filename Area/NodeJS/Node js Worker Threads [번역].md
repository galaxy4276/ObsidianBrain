---
tags: nodejs, multi-threading
---

# Worker Thread 탄생 이유

Node.js 는 수년 동안 CPU 집약적인 작업을 수행하는 애플리케이션에 적합하지 않았다, 자바스크립트가 단일스레드로 동작하기 때문이다.

이 문제를 해결하기 위해 v12 LTS 부터 `worker_thread` 모듈이 안정적인 기능으로 탑재되었다.

## 그럼 Worker Thread 가 탄생하기 이전에는?

- `child_process` 모듈을 사용해 CPU 집약적 작업 수행
- `cluster` 모듈을 사용해 여러 프로세스에서 CPU 집약적 작업 수행

# CPU 집약적인 작업에 워커 스레드 사용

`worker_threads` 는 자바스크립트 자체에 멀티스레딩 기능을 도입하지 않는다 대신,

`worker_threads` 구현은 애플리케이션이 여러 개의 격리된 자바스크립트 워커를 사용할 수 있도록 하고, **워커와 부모 워커 간 통신은 Node.js 에서 제공함으로써 동시성을 제공**한다.

**Node.js 에서 각 워커는 자체적인 V8 및 이벤트 루프 인스턴스를 가지게 되며, 자식 프로세스와 달리 워커는 메모리를 공유할 수 있다.**

아래는 워커스레드의 간단한 예제이다.

```jsx
const {Worker, isMainThread, parentPort, workerData} = require('worker_threads');
if (isMainThread) {
 const worker = new Worker(__filename, {workerData: {num: 5}});
 worker.once('message', (result) => {
 console.log('square of 5 is :', result);
 })
} else {
 parentPort.postMessage(workerData.num * workerData.num)
}
```

# Worker Threads 의 작동 방식

javascript 에는 멀티 스레딩 기능이 없다. 따라서 Node.js 워커 스레드는 다른 많은 고급 언어의 기존 멀티스레딩과는 다른 방식으로 작동한다.

워커의 책임은 부모 워커가 제공한 스크립트를 실행하는 것이며 그렇게 되면 워커 스크립트는 다른 워커와 분리되어 실행되며 워커와 부모 워커 간 메시지를 전달할 수 있게 된다.

워커 스크립트는 별도의 파일일 수도 있고, 평가할 수 있는 텍스트 형식의 스크립트일 수도 있다.

각 워커는 메시지 채널을 통해 부모 워커에 연결된다.

자식 워커는 `parent.postMessage` 함수를 이용하여 메시지 채널에 쓰기 작업을 할 수 있고, 부모 워커는 워커 인스턴스에서 `worker.postMessage` 함수를 호출하여 메시지 채널에 쓰기 작업이 가능하다.

![부모 워커와 자식 워커 간의 메시지 채널](Untitled%2086.png)

부모 워커와 자식 워커 간의 메시지 채널

## 어떻게 Node.js 의 workers 는 병렬로 실행될 수 있는가?

자바스크립트가 동시성을 제공하지 않는데, 두 개의 Node.js 워커가 어떻게 병렬로 실행할 수 있을까?

정답은 [V8 의 Isolates](https://v8docs.nodesource.com/node-0.8/d5/dda/classv8_1_1_isolate.html) 에 존재한다.

> **내부 문서 description 번역본**
격리란 V8 엔진의 격리된 인스턴스를 나타냅니다. V8 아이솔레이트는 완전히 분리된 상태를 갖습니다. 한 아이솔레이트의 오브젝트를 다른 아이솔레이트에서 사용할 수 없습니다. V8이 초기화될 때 기본 아이솔레이트가 암시적으로 생성되어 입력됩니다. 임베더는 추가 아이솔레이트를 생성하여 여러 스레드에서 병렬로 사용할 수 있습니다. 아이솔레이트는 한 번에 최대 하나의 스레드에서만 입력할 수 있습니다. 동기화하려면 잠금/잠금 해제 API를 사용해야 합니다.
> 

이 기능은 자체 **JS Heap 과 Microtask queue 에 있는 크롬 v8 런타임의 독립적인 인스턴스**를 말한다.

이를 통해 각 Node.js 워커는 다른 워커와 완전히 분리된 상태에서 자바스크립트 코드를 실행할 수 있다.

단점은 워커가 서로의 Heap 에 직접 액세스할 수 없다는 점이다.

Isolates 에 의해 각 워커는 다른 워커 및 부모 워커의 이벤트 루프와는 독립적인 자체 Libuv 이벤트 루프 복사본을 갖게 된다.

## JS/C++ 의 경계를 넘어

새 워커의 인스턴스화와 부모 JS 스크립트와 워커 JS 스크립트 간 통신 제공은 C++ 워커 구현에 의해 제공된다.

전반적인 구현부는 [worker.cc](https://github.com/nodejs/node/blob/921493e228/src/node_worker.cc) 에 구현되어있다.

워커 구현은 `worker_threads` 모듈을 사용하여 userland Javascript 에 노출된다.

<aside>
💡 **유저랜드(userland)란?**

운영체제(Operating System) 에서는 메모리 공간을 커널공간과 사용자(User) 공간으로 구분한다.
커널 공간은 커널과 커널 확장 기능 그리고 장치 드라이버를 실행하기 위한 예비 공간이며 그와 반대로 유저 공간은 사용자 모드 응용 프로그램들이 동작하는 메모리 영역이다.

유저랜드는 이 사용자 공간에서 실행되는 프로그램 및 라이브러리를 가리킨다.
출처 - [https://limjunho.github.io/2021/04/26/USERLAND.html](https://limjunho.github.io/2021/04/26/USERLAND.html)

</aside>

이 JS 구현은 두 개의 스크립트로 나뉘는데 이 두 스크립트의 이름을 다음과 같이 명칭한다.

### 1. Worker Initialisation script

[https://github.com/nodejs/node/blob/921493e228/lib/internal/worker.js](https://github.com/nodejs/node/blob/921493e228/lib/internal/worker.js)

워커 인스턴스를 인스턴스화하고 부모에서 자식 워커로 워커 메타데이터를 전달할 수 있도록 초기 부모-자식 워커 통신을 설정하는 역할을 수행한다.

### 2. Worker Execution script

[https://github.com/nodejs/node/blob/921493e228/lib/internal/main/worker_thread.js](https://github.com/nodejs/node/blob/921493e228/lib/internal/main/worker_thread.js)

사용자가 제공한 워커 데이터 및 상위 워커에서 제공한 기타 메타데이터를 사용하여 사용자의 워커 JS 스크립트를 실행한다.

위 두 역할에 대해서 다음 다이어그램을 참조하길 바란다.

![워커 구현 내부](Untitled%2087.png)

워커 구현 내부

위 두 단계를 기반으로 하여 워커의 설정 프로세스를 두 단계로 나눌 수 있다.

- 워커 프로세스의 초기화
- 워커 프로세스의 실행

# Worker Threads 최대한 활용하기

워커 스레드를 사용할 땐 다음 두 가지 주요 사항을 기억해야 합니다.

- 워커 스레드는 실제 프로세스보다 가볍지만, 워커를 생성하는 데 상당한 작업이 필요하며 자주 수행되면 비용이 많이 들 수 있다.
- 워커 스레드를 사용하여 I/O 작업을 병렬화하는 것은 비용 효율적이지 않는데, 그 이유는 이를 위해 워커 스레드를 처음부터 시작하는 것보다 Node.js Native I/O 메커니즘을 사용하는 것이 훨씬 빠르기 때문이다.

첫 번째 주의 사항을 극복하기 위해서 Thread Pooling 을 구현해야 한다.

## Worker Thread Pooling

스레드 풀링을 제대로 구현하면 새 스레드 생성에 따른 추가 오버헤드가 줄어들어 성능이 크게 향상될 수 있다.

또한 하드웨어에 따라 효과적으로 실행할 수 있는 병렬 스레드 수가 항상 제한되어 있으므로 많은 수의 스레드를 생성하는 것도 효율적이지 않다는 점도 알아두어야 한다.

다음 그래프는 12번의 salt round 가 존재하는 Bcrypt 해시를 반환하는 세 개의 Node.js 서버의 성능을 비교한 것이며 세 개의 다른 서버는 다음 항목과 같다.

- 멀티 스레딩이 없는 서버
- 멀티 스레딩이 존재하지만 스레드 풀링이 없는 서버
- 스레드 풀이 4개인 서버

![worker_threads를 사용하는 것이 얼마나 효율적인가?](Untitled%2088.png)

worker_threads를 사용하는 것이 얼마나 효율적인가?

스레드 풀의 직접 구현 예제는 다음 링크를 참고하자.

[threadpool](https://replit.com/@dpjayasekara/threadpool)

이제 해당 글을 통해 워커 스레드가 어떻게 동작하는 지 간략하게 나마 이해하셨길 바라며 워커 스레드를 사용하여 CPU 집약적인 애플리케이션을 실험하고 작성할 수 있길 바란다.