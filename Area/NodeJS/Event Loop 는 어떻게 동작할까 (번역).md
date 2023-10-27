---
tags: nodejs, event-loop
---
![Untitled](Untitled%202.png)

# Reacter Pattern

`Reacter 패턴`에 대해서는 [[Reactor Proactor 패턴]] 에서 다루었지만,

`Node.js` 관점에서 다시 한 번 설명해보겠습니다.

`Node.js` 는 일반적으로 `Event-Driven` 모델이라고 하는 `Reactor 패턴`을 사용합니다.

그렇다면 Node.js 에서 Reactor 패턴은 어떻게 작동할까요?

I/O 요청에 대해서 다음과 같은 예시 코드가 있다고 가정해봅시다.

```jsx
fs.readFile('./file.txt', callback);
```

I/O 연산을 포함하는 함수를 호출하면 요청이 `Event Loop` 에 전달되고 이 요청은 `이벤트 디멀티플렉서`에 전달됩니다.

<aside>
💡 비동기 요청이 Event Loop 에 전달되는 과정까지는 흔하게 우리가 알고 있던 사실입니다.

</aside>

`이벤트 디멀티플렉서`에서는 `이벤트 루프`에 요청을 받은 후 I/O 요청에 따라 수행해야 할 `하드웨어 I/O 작업 유형`을 결정합니다.

그리고 해당 작업은 파일을 읽는 **적절한 장치에 위임**됩니다.

해당 코드는 `Node.js` 내 C/C++ 함수에 의해 요청된 파일을 읽고 콘텐츠를 `이벤트 디멀티플렉서`에 반환힙니다.

```jsx
uv__fs_read(req)
```

[해당 API 문서](https://docs.libuv.org/en/v1.x/fs.html)

요청된 작업이 완료되면 `이벤트 디멀티플렉서`는 새 이벤트를 생성하여 이벤트 대기열에 추가합니다.

<aside>
💡 다른 유사한 이벤트와 함께 대기열에 추가할 수 있습니다.

</aside>

자바스크립트 호출 스택이 비어 있으면 `이벤트 큐`의 이벤트가 처리되고 `콜백 함수`가 실행됩니다.

![Untitled](Untitled%203.png)

`이벤트 디멀티플렉서`나 `이벤트 큐` 모두 단일 구성 요소는 아닙니다.

위 사진 자료는 추상적인 예시이며, 예를 들어, `이벤트 디멀티플렉서` 및 하드웨어 I/O의 구현은 운영 체제에 따라 다를 수 있습니다. 또한 `이벤트 큐`는 단일 큐가 아니라 **여러 큐**로 구성되어 있습니다.

그럼 이러한 구현은 어디서 제공되며 동작할까요?

바로 `Node.js` 구성 중 `Libuv` 라이브러리에서 제공되는 기능인데, `Libuv` 에 대해서는 잘 작성되어 있는 게시글이 많기 때문에 따로 설명하지 않겠습니다.

<aside>
💡 저는 개인적으로 추 후, C++ 환경에서 Libuv 라이브러리만 이용해서 다양한 실습을 통해 라이브러리를 분석해보고자 합니다.

</aside>

이제 이번 글의 핵심 내용인 `이벤트 큐`에 대해서 다루어 보겠습니다.

# Event Queues

![Untitled](Untitled%204.png)

`이벤트 루프`는 처리할 이벤트가 더 이상 없을 때까지 단일 스레드에서 이벤트를 지속적으로 처리하는 메커니즘입니다.

처리할 이벤트가 더 이상 없거나 오류가 발생할 때까지 무기한으로 실행되기 때문에 **`“semi-infinite loop”`** 이라고 부릅니다.

앞서 언급했듯이 `이벤트 루프`는 **여러 개의 큐로 구성되어있으며** 각 큐는 우선순위 레벨이 존재합니다.

호출 스택이 비어있으면 `이벤트 루프`는 큐를 살펴보고 이벤트가 실행될 때까지 기다립니다.

타이머 관련 이벤트를 예시로 봅시다.

![Untitled](Untitled%205.png)

`setTimeout` 혹은 `setInterval` 함수가 실행되면 이벤트 디멀티플렉서는 이벤트를 타이머 대기열 큐에 대기시킵니다.

한 시간 후에 실행되도록 예약된 `setTimeout` 함수가 있다고 가정해 봅시다. 

이는 한 시간 후에 `이벤트 디멀티플렉서`가 이벤트를 이 큐에 대기열에 넣는다는 의미입니다.

큐에 이벤트가 존재하면 `이벤트 루프`는 큐가 비워질 때까지 해당 콜백을 실행합니다.

큐가 비워지면 `이벤트 루프`는 다른 를 확인하기 위해 이동합니다.

<aside>
💡 타이머 함수는 내부적으로 [min-heap 알고리즘](https://coderkoo.tistory.com/10)에 의해 관리됩니다.

</aside>

![Untitled](Untitled%206.png)

두 번째 위치에는 파일 시스템 작업, 네트워킹 등과 같은 대부분의 비동기 작업을 담당하는 I/O 대기열이 있습니다.

다음으로, `setImmediate` 호출을 담당하는 즉시 대기열이 있습니다. 이를 통해 I/O 작업 이후에 실행해야 하는 작업을 예약할 수 있습니다.

![Untitled](Untitled%207.png)

그리고 마지막에는 `마감된 이벤트(close events)`가 특정 대기열이 있습니다.

<aside>
💡 close events 는 데이터베이스 및 TCP 연결과 같이 닫기 이벤트가 있는 모든 연결을 처리하는 역할을 담당합니다.

</aside>

![Untitled](Untitled%208.png)

이제 `이벤트 루프`가 각 `주기(cycle)` 마다 모든 대기열을 감시하며 **실행해야 할 이벤트가 있는 지** 확인합니다.

일반적으로 모든 큐를 검토하고 실행 할 이벤트가 있는 지 확인하는 데 몇 밀리초밖에 걸리지 않습니다.

그러나 `이벤트 루프`를 사용 중이라면 시간이 더 오래 걸릴 수는 있습니다.

<aside>
💡 대기열에 대기중인 이벤트를 **Macrotask** 라고도 부릅니다.

</aside>

실제로 이벤트 루프에서 두 가지 유형의 작업이 존재하는 데, 마로 `Macrotask` 와 `Microtask` 라고 합니다.

해당 내용에 대해서는 나중에 설명하겠습니다.

이제 처리 할 이벤트가 더 이상 없는 상황일 때 `이벤트 루프`가 `Node.js` 프로세스를 중지를 결정하는 방법에 대해 서술하겠습니다.

이벤트 루프는 프로세스가 시작될 때 **0 으로 시작하는 참조 카운터를 유지합니다.**

그리고 비동기 연산이 있을 때마 카운터는 1씩 증가됩니다.

<aside>
💡 예를 들어, setTImeout 또는 readFile 연산이 존재할 경우 이러한 각 함수는 카운터를 1씩 증가시킵니다.

</aside>

![Untitled](Untitled%209.png)

이벤트가 대기열로 푸시되고 `이벤트 루프`가 특정 `매크로태스크(Macrotask)`의 콜백을 실행하고나면 카운터도 1씩 감소합니다.

![Untitled](Untitled%2010.png)

`마감 이벤트(close events)` 를 처리하고 `이벤트 루프`는 카운터를 확인합니다.

카운터가 만약 0이라면 진행 중인 작업이 없음을 의미하며 프로세스를 종료합니다.

그러나 0이 아니라면 아직 진행 중인 작업이 존재한다는 의미이므로 모든 작업이 완료될 때까지(카운터가 0이 될 때까지) `이벤트 루프`는 `주기(Cycle)`를 반복합니다.

이제 실습으로 확인해봅시다.

```jsx
const fs = require('fs');

setTimeout(() => {
  console.log('hello');
}, 50);

fs.readFile(__filename, () => {
  console.log('world');
});
```

동작 과정에 대해 순차적으로 파악해봅시다.

1. 노드 프로세스가 시작되고, `V8` 은 JS 코드를 파싱하고 `setTImeout` 함수를 실행합니다.
그러면 C/C++ 함수가 Libuv 내부에서 실행되고 카운터(refs++)가 증가합니다.
2. V8이 `readFile` 함수를 발견하면 동일한 작업을 수행합니다.
    
    <aside>
    💡 Libuv 에서 파일 읽기 작업을 시작하고 카운터를 증가(refs++)시킵니다.
    
    </aside>
    
3. 이제 `V8`이 수행할 작업이 남지 않았으며 `이벤트 루프`가 작업을 시작합니다.
`이벤트 루프`는 카운터가 0이 될 때까지 각 대기열을 하나씩 검토합니다.
4. 타이머 함수가 완료되면 이벤트가 타이머 큐에 등록됩니다.
`이벤트 루프`가 타이머 큐를 다시 검토했을 때 이벤트를 감지하고 해당 콜백을 실행하여 콘솔에 “hello” 메시지를 출력합니다.
그런 다음 카운터가 감소되고 `이벤트 루프`는 카운터가 0이 될 때까지 각 큐를 지속적으로 확인합니다.
5. 파일의 크기에 따라 특정 시점에 파일 읽기 작업이 완료되고, 이벤트가 `I/O 큐`에 등록됩니다.
이 사항을 `이벤트 루프`가 다시 주기를 돌며 감지하고 해당 콜백을 실행하여 콘솔에 “world” 메시지를 출력합니다.
그런 다음 카운터가 감소되고 `이벤트 루프`는 다시 큐를 지속적으로 확인합니다. ( 지속적 작업 수행 )
6. 마지막으로 `마감 큐(close event queue)` 를 확인하고 `이벤트 루프`는 카운터를 확인하며 **0이면 Node 프로세스를 종료합니다.**

현재 `매크로 작업(Macrotask)` 에 대해 논의한 동안 다른 중대사안에 대해 이야기 해보겠습니다.

## I/O Polling

`이벤트 루프`에 대해 배우려는 사람들에게 종종 혼란을 줍니다.

 많은 문서에서 이벤트루프의 일부로 언급하고 있지만, `이벤트루프의 기능`을 설명하는 문서는 거의 없습니다. 

[**공식 문서**](https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick)에서도 이벤트 루프가 무엇을 하는지 이해하기 어렵습니다.

다음과 같은 코드 예시를 봅시다.

```jsx
const fs = require('fs')
const now = Date.now();

setTimeout(() => {
  console.log('hello');
}, 50);

fs.readFile(__filename, () => {
  console.log('world');
});

setImmediate(() => {
  console.log('immediate');
});

while(Date.now() - now < 2000) {} // 2 second block
```

`setTimeout`, `readFile`, `setImmediate` 3가지 연산이 존재하며

마지막에 2초 동안 스레드를 차단하는 while 루프가 존재합니다.

코드가 실행되는 동안 세 개의 이벤트는 모두 각각의 큐에 등록되어야 합니다.

즉, V8이 while 루프 실행을 완료하고 나면 `이벤트 루프`는 동일한 주기 3개의 이벤트를 모두 확인하고 다음 순서로 콜백을 실행해야 합니다.

```jsx
hello
world
immediate
```

그러나 실제로 결과는 다음과 같습니다.

```jsx
hello
immediate
world
```

이것은 `I/O Polling` 이라는 프로세스가 존재하기 때문입니다.

다른 유형의 이벤트와 달리 I/O 이벤트는 특정 시점에만 큐에 추가됩니다.

따라서 while 루프가 완료되고 나면 모든 이벤트가 준비되었음에도 불구하고 `setImmediate()` 에 대한 콜백이 `readFile()` 에 대한 콜백보다 먼저 실행되는 이유입니다.

문제는 `이벤트 루프`의 `I/O 대기열 확인 단계`가 이미 이벤트 대기열에 있는 콜백만 실행한다는 점입니다.

**콜백이 완료되면 이벤트 큐에 자동으로 추가되지 않습니다.**

대신 나중에 I/O Polling 작업 중에 이벤트 큐에 추가됩니다.

다음 절차는 while 루프가 완료된 후 발생하는 과정입니다.

1. `이벤트 루프`는 타이머 콜백을 실행하고 타이머가 완료되어 실행할 준비가 되었다는 것을 확인하여 타이머를 실행합니다.
콘솔에 "hello"가 표시됩니다.
2. 그 후 `이벤트 루프`는 `I/O 콜백 단계(I/O callback stage)` 로 넘어갑니다.
이 시점에서 파일 읽기 프로세스는 완료되었지만 해당 콜백은 아직 실행되도록 표시되지 않았습니다.
현재 `주기(Cycle)`의 후반부에 표시될 것입니다.
그런 다음 `이벤트루프`의 이벤트는 다른 여러 단계를 거쳐 결국 `I/O 폴링 단계(I/O poll phase)`에 도달합니다.
이 시점에서 `readFile()` 콜백 이벤트가 수집되어 `I/O 대기열(I/O queue)`에 추가되지만 아직 실행되지는 않습니다.
실행할 준비가 되었지만 `이벤트 루프`가 다음 `주기(cycle)`에서 실행합니다.
3. 다음 단계로 넘어가면 `이벤트 루프`가 `setImmediate()` 콜백을 실행합니다.
콘솔에 "immediate" 메시지가 출력됩니다.
4. 그러면 `이벤트 루프`가 다시 `주기(Cycle)`를 반복합니다. 
실행할 타이머가 없으므로 `I/O 콜백 단계(I/O callback stage)`로 이동하여 마침내 `readFile()` 콜백을 찾아서 실행합니다.
결과적으로 콘솔에 “world” 메시지를 출력하게 됩니다.

그런데 만약 2초 동안 스레드를 차단하는 while 루프 코드를 제거하고 나면 다음과 같은 결과가 발생합니다.

```jsx
immediate
world
hello
```

`setImmediate()`는 `setTimeout` 또는 파일 시스템 프로세스 중 어느 것도 완료되지 않은 경우 `이벤트 루프`의 첫 번째 `주기(Cycle)`에서 작동하기 때문입니다.

해당 내용에 대해서 아래 더 자세하게 다루도록 하겠습니다.

![이벤트루프의 다이어그램](Untitled%2011.png)

이벤트루프의 다이어그램

## setTimeout 과 setImmediate

이 예에서는 지연 시간이 0초인 `setTimeout`, `setImmediate` 함수가 있습니다. 

까다로운 질문이지만 올바르게 대답하면 면접에서 좋은 인상을 남길 수 있습니다.

```jsx
setTimeout(() => {
  console.log('setTimeout');
}, 0);

setImmediate(() => {
  console.log('setImmediate');
});
```

요점은 어떤 함수의 콜백이 먼저 수행될 지 알 수 없다는 것입니다.

![실행 결과](Untitled%2012.png)

실행 결과

그 이유는 프로세스가 실행 되는데 걸리는 시간이 오래 걸릴 수도 있기 때문입니다( 대략 몇 밀리초 정도)

이로 인해 `이벤트 루프`가 `타이머 큐`가 비어있을 때 해당 큐를 지나칠 수도 있고 또는 `이벤트 루프`가 너무 빨리 작동해서 `이벤트 디멀티플렉서`가 `타이머 큐`에 제때 이벤트를 등록하지 못했을 수도 있습니다.

따라서 위 예제를 실행할 때마다 매번 다른 결과가 출력되는 겁니다,

## fs 콜백 내부의 setTimeout & setImmediate

이전 예제와 달리 해당 코드의 결과는 예측 가능합니다.

```jsx
const fs  = require('fs');

fs.readFile(__filename, () => {
  setTimeout(() => {
    console.log('setTimeout');
  }, 0);
  
  setImmediate(() => {
    console.log('setImmediate');
  });
});
```

readFIle 콜백이 실행될 때 `이벤트 루프`는 `I/O 단계(I/O poll phase)` 에 있는 것을 알 수 있으며 그 다음 큐인 `즉시 큐(Immediate queue)`를 검토하게 됨으로써 항상 `setImmediate` 의 콜백이 우선 실행됩니다. 

이제 계속해서 동작과정에 대해 더 자세히 살펴보겠습니다.

## 마이크로태스크(process.nextTick & Promise)

먼저 자바스크립트 실행단계를 나타내는 표시를 추가하여 다이어그램을 개선하였습니다.

![Untitled](Untitled%2013.png)

다이어그램에서 시간 초과에 대한 콜백 실행은 두 번째 자바스크립트 단계에서 발생합니다.

지금까지는 `매크로태스크`에 초점을 맞추었기 때문에 `Promises`와 `process.nextTick`에 대한 정보는 포함되지 않았습니다. 이 두 가지를 `마이크로태스크(Microtask)`라고 합니다.
각 자바스크립트 실행 단계에서 추가적인 처리가 이루어집니다.

![Microtasks](Untitled%2014.png)

Microtasks

이 두 가지 유형의 `마이크로태스크`에는 전용 대기열이 있습니다.

 그 외에도 `MutationObserver`, `queueMicrotask`와 같은 다른 `마이크로태스크 스케줄러`도 있지만, 여기서는 다음 틱과 프로미스에 초점을 맞춰 설명하겠습니다.

`V8`은 모든 자바스크립트 코드를 실행한 후 `매크로태스크`와 마찬가지로 `마이크로태스크` 대기열을 확인합니다.

`마이크로태스크`대기열에 등록된 이벤트가 있으면 해당 이벤트가 처리되고 해당 콜백이 실행됩니다.

![매크로태스크와 마이크로태스크](Untitled%2015.png)

매크로태스크와 마이크로태스크

다이어그램 내 밝은 회색은 예약된 작업 중 가장 우선순위가 높은 `process.nextTick 대기열`을 의미합니다.

그 다음 짙은 회색은 우선순위가 그 다음인 `Promise 대기열`을 나타냅니다.

코드로 살펴봅시다.

```jsx
console.log(1);

process.nextTick(() => {
  console.log('nextTick');
});

Promise.resolve()
  .then(() => {
    console.log('Promise');
  });

console.log(2);
```

출력 순서 측면에서 `process.nextTick()` 의 콜백은 항상 `Promise` 의 콜백보다 먼저 실행됩니다.

실행 과정은,

`V8`에서 첫 번째 로그 문을 출력한 다음 이벤트를 큐에 등록하는 nextTick 함수를 실행합니다.

콜백이 별도의 큐에 저장되는 프로미스에서도 비슷한 프로세스가 발생합니다.

그리고 `V8`이 마지막 함수 호출을 수행하여 2를 출력한 후, 대기열에 저장된 이벤트를 실행하기 위해 이동합니다.

`process.nextTick`에서 현재 작업을 완료된 직 `이벤트 루프`가 다음 단계로 진행되기 전에 콜백 함수를 실행할 수 있도록 하는 함수입니다.

`process.nextTick()` 이 호출되면 제공된 콜백이 `이벤트 루프` 내에서 예약된 작업 중 가장 높은 우선순위를 갖는 `nextTick 대기열`에 추가됩니다.

결과적으로 콜백은 프로미스 및 기타 `마이크로태스크` 등 다른 유형의 작업보다 먼저 실행됩니다.

**마이크로태스크 대기열에 이벤트가 하나 이상 남아 있는 한 이벤트 루프는 타이머 대기열보다 이벤트의 우선순위를 높게 부여합니다.**

`process.nextTick()`을 재귀적으로 실행하면 `이벤트 루프`가 `타이머 대기열`에 도달하지 않으며 `타이머 대기열`의 해당 콜백이 실행되지 않습니다.

```jsx
function recursiveNextTick() {
  process.nextTick(recursiveNextTick);
}

recursiveNextTick();

setTimeout(() => {
  console.log('This will never be executed.');
}, 0);
```

이러한 현상을 관찰했을 때, `nextTick` 함수를 잘못사용하게 되면 `이벤트 루프`가 차단되어 예약된 시간 내에 타이머 콜백이 적절하게 수행되지 않을 수 있습니다.

```jsx
setTimeout(() => {
  console.log('setTimeout');
}, 0);

let count = 0;

function recursiveNextTick() {
  count += 1;

  if (count === 20000000)
    return; // finish recursion

  process.nextTick(recursiveNextTick);
}

recursiveNextTick();
```

![Untitled](Untitled%2016.png)

실제로 타이머 함수에 설정된 시간 값은 0 이지만 2초 뒤에 실행됩니다.

이제 다음과 같은 코드의 출력을 예상해보겠습니다.

```jsx
process.nextTick(() => {
  console.log('nextTick 1');

  process.nextTick(() => {
    console.log('nextTick 2');

    process.nextTick(() => console.log('nextTick 3'));
    process.nextTick(() => console.log('nextTick 4'));
  });

  process.nextTick(() => {
    console.log('nextTick 5');

    process.nextTick(() => console.log('nextTick 6'));
    process.nextTick(() => console.log('nextTick 7'));
  });
  
});
```

이 코드가 실행되면 중첩된 `process.nextTick` 의 콜백을 예약합니다.

1. 초기 `process.nextTick` 콜백이 먼저 실행되어 ‘nextTick 1’ 을 기록합니다.
2. 그리고 해당 콜백 내 ‘nextTick 2’ 와 ‘nextTick 5’ 를 로깅하는 콜백 두 개가 더 예약되어 있습니다.
3. ‘nextTick 2’ 로 기록된 콜백이 먼저 수행되어 콘솔에 ‘nextTick 2’ 를 기록합니다.
    1. 그리고 해당 콜백 내부에는 ‘nextTick 3’ 와 ‘nextTick 4’ 를 로깅하는 콜백 두 개가 더 예약되어 있습니다.
4. ‘nextTick 5’ 로 기록된 콜백은 ‘nextTick 2’ 이후에 실행되어 ‘nextTick 5’ 를 콘솔에 기록합니다.
    1. 해당 콜백 내부에 ‘nextTick 6’, ‘nextTick 7’ 을 로깅하는 콜 백 두개가 더 예약되어 있습니다.
5. 마지막으로 나머지 `process.nextTick` 콜백이 예약된 순서대로 실행되어 ‘nextTick 3’, ‘nextTick 4’, ‘nextTick 6’, ‘nextTick 7’ 을 콘솔에 기록하게 됩니다.

다음은 실행 전반에 걸쳐 대기열이 어떻게 구조화되는지에 대한 개요입니다.

```jsx
Proess started: [ nT1 ]
nT1 executed: [ nT2, nT5 ]
nT2 executed: [ nT5, nT3, nT4 ]
nT5 executed: [ nT3, nT4, nT6, nT7 ]
// ...
```

다이어그램을 다시 확인했을 때, 기본 논리를 이해하는 데 큰 도움이 된다는 점에 주목할 필요가 있습니다.

![Untitled](Untitled%2017.png)

## Microtasks & Macrotasks 연습

![Untitled](Untitled%2018.png)

  다음 연습에서는 개념을 완전히 이해하기 위해 전체 다이어그램을 가지고 작업해야 합니다.

```jsx
process.nextTick(() => {
  console.log('nextTick');
});

Promise.resolve()
  .then(() => {
    console.log('Promise');
  });

setTimeout(() => {
  console.log('setTimeout');
}, 0);

setImmediate(() => {
  console.log('setImmediate');
});
```

1. `process.nextTick` 함수가 현재 실행 프로세스가 완료된 직후에 콜백이 실행되도록 예약됩니다.
2. `Promise.resolve()` 는 해결된 프로미스를 생성하고, 첨부된 .then 메서드는 실행될 콜백을 예약합니다.
3. `setTimeout` 은 지연이 0 밀리초로 설정되어 있어도 매크로 태스크 대기열에 추가되며 보류 중인 `마이크로태스크(nextTicks, Promises)` 가 모두 실행되고 나서 실행됩니다.
4. `setImmediate` 함수는 타임아웃과 마찬가지로 매크로 태스크로 실행 될 콜백을 예약합니다.

결과적으로 위 순번 순서대로 함수가 실행되게 됩니다.

좀더 어려운 예제를 살펴봅시다.

```jsx
const fs  = require('fs');

fs.readFile(__filename, () => {
  process.nextTick(() => {
    console.log('nextTick in fs');
  });

  setTimeout(() => {
    console.log('setTimeout');
    
    process.nextTick(() => {
      console.log('nextTick in setTimeout');
    });
  }, 0);
  
  setImmediate(() => {
    console.log('setImmediate');

    process.nextTick(() => {
      console.log('nextTick in setImmediate');

      Promise.resolve()
        .then(() => {
          console.log('Promise in setImmediate');
        });
    });
  });  
});
```

어려워 보이지만 사실 이벤트 루프의 주기 순서를 기억한다면 쉽게 실행 순서를 예측할 수 있습니다.

핵심은 `I/O Poll 단계`에서 다음 큐가 `즉시 큐`이기 때문에 nextTick in fs 출력 후 `setImmediate` 내부 콜백이 순서대로 실행된 뒤 마지막으로 `setTimeout` 의 콜백이 수행됩니다.

[Node.js 의 소스코드](https://github.com/nodejs/node/tree/main)를 분석해보면 `마이크로태스크`는 c++ 이 아닌 자바스크립트 수준에 존재하므로 쉽게 이해할 수 있습니다.

# Libuv

운영체제에서의 명령은 `블로킹` 혹은 `논블로킹` 될 수 있습니다.

`블로킹` 명령은 다른 명령을 동시에 실행하기 위해서는 스레드가 필요로 합니다.

그러나 `논블로킹` 연산을 사용하면 추가 스레드 없이 다중 연산을 동시에 수행 가능합니다.

파일 및 DNS 작업은 `블로킹` 형태이므로 완료될 때까지 스레드를 차단합니다. 

반면 네트워크 작업은 `논블로킹` 방식으로 하나의 요청에서 여러 요청을 동시에 전송할 수 있습니다.

운영 체제마다 `논블로킹` I/O에 대한 알림 메커니즘을 제공합니다. 

Linux에서는 `epoll`, `Windows`에서는 IOCP 등으로 불립니다. 

이러한 알림 메커니즘을 통해 핸들러를 추가하고 작업이 완료될 때까지 기다리면 특정 작업이 완료될 때 알림을 받을 수 있습니다.

`Libuv`는 이러한 메커니즘을 사용하여 `네트워크 I/O`를 비동기적으로 작업할 수 있도록 합니다. 하지만 `블로킹` I/O 작업은 다릅니다.

생각해보면 `Node.js` 는 `semi-infinite-loop` 로 실행되는 `이벤트 루프`가 존재하는 단일 스레드에서 동작합니다.

즉, I/O 작업을 블로킹할 때 `Libuv` 는 동일한 스레드 내에서 이를 처리할 수 없습니다.

이러한 이유로 `Libuv` 는 스레드 풀을 활용합니다.

![Untitled](Untitled%2019.png)

기본 스레드 풀 크기가 4인 경우, `Libuv`는 해당 스레드 중 하나에서 `파일 읽기 작업`을 실행하여 처리합니다.

 작업이 완료되면 스레드가 해제되고 `Libuv`는 해당 응답을 전달합니다. 

따라서 스레드 풀을 사용하여 비동기 방식으로 `블로킹 I/O 작업`을 효율적으로 처리할 수 있습니다.

10개의 파일 읽기 작업을 수행하려고 하면 그 중 4개만 프로세스를 시작하고 나머지 6개 작업은 스레드를 실행할 수 있을 때까지 기다립니다.

많은 `블로킹 I/O 작업`을 수행하려는데 기본 스레드 풀 크기인 4개가 부족하다고 판단되면 스레드 풀 크기를 쉽게 늘릴 수 있습니다.

![Untitled](Untitled%2020.png)

```jsx
UV_THREADPOOL_SIZE=64 node script.js
```

따라서 이 경우 `Libuv`는 64개의 스레드가 있는 스레드 풀을 생성합니다.

스레드 풀에 스레드 수가 너무 많으면 성능 문제가 발생할 수 있다는 점에 유의하세요. 

많은 스레드를 유지하려면 상당한 리소스가 필요하기 때문입니다.

# References

**[김범준님 - NodeJS Event Loop파헤치기](https://medium.com/zigbang/nodejs-event-loop%ED%8C%8C%ED%97%A4%EC%B9%98%EA%B8%B0-16e9290f2b30)**

**[korECM님 - Node.js 이벤트 루프(Event Loop) 샅샅이 분석하기](https://www.korecmblog.com/node-js-event-loop/)**

[libuv 공식 문서](http://docs.libuv.org/en/v1.x/design.html)

[V8 공식 문서](https://v8.dev/docs) 

[멍개님 Node.js 비동기 매커니즘 이해와 설계](https://m.blog.naver.com/pjt3591oo/221978583678)

[Evans Moon 님 **로우 레벨로 살펴보는 Node.js 이벤트 루프**](https://evan-moon.github.io/2019/08/01/nodejs-event-loop-workflow/)