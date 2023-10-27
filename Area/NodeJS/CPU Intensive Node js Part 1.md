---
tags: nodejs, multi-threading
---
# CPU 집약적 작업

![Untitled](Untitled%2021.png)

다음과 같이 CPU 집약적인 코드가 존재한다고 가정해봅시다.

<aside>
💡 [전체 예제](https://github.com/larkintuckerllc/hello-kue/tree/master/worse)

</aside>

```jsx
const express = require('express');
const { sleep } = require('sleep');
const app = express();
app.get('/', (req, res) => res.send('Hello World!'));
app.get('/intense', (req, res) => {
  sleep(5); // 인공적인 CPU 집약적 작업
  res.send('Hello Intense!');
});
app.listen(3000, () => console.log('Example app listening on port 3000!'));
```

`/intense` 엔드포인트로 요청이 들어왔을 경우, **이벤트 루프**를 차단하게 됩니다.

<aside>
💡 Node.js 에서 이벤트 루프는 동시성을 제공하는 역할을 수행한다.

</aside>

요청이 두 개가 수행된다고 가정할 때 첫 요청이 5초정도 시간이 걸린다면 두 번째 요청은 응답까지 10초 가량의 시간을 요구하게 됩니다.

# Fork

```jsx
const express = require('express');
const { fork } = require('child_process');
const app = express();
app.get('/', (req, res) => res.send('Hello World!'));
app.get('/intense', (req, res) => {
  const worker = fork('./worker');
  worker.on('message', ({ fruit }) => {
    res.send(`Hello Intense ${fruit}!`);
    worker.kill();
  });
  worker.send({ letter: 'a' });
});
app.listen(3000, () => console.log('Example app listening on port 3000!'));
```

```jsx
const { sleep } = require('sleep');

process.on('message', ({ letter }) => {
  sleep(5); // 인공적인 CPU 집약적 작업
  let fruit = null;
  switch (letter) {
    case 'a':
      fruit = 'apple';
      break;
    default:
      fruit = 'unknown';
  }
  process.send({ fruit });
});
```

Node.js 에서 `fork` 함수로 자식 프로세스를 생성하여 이벤트 루프를 차단하지 않고 새로운 하위 프로세스를 이용해 CPU 집약적인 작업을 처리할 수 있습니다.

실행된 Node.js 자식 프로세스는 둘 사이에 설정된 IPC 통신 채널을 제외하고 부모 프로세스와 독립적이게 됩니다.

## 주의사항

각 프로세스는 자체 메모리와 자체 V8 인스턴스가 할당되어있는 관계로 추가 리소스 할당이 필요로 합니다.

즉 많은 수의 하위 Node.js 프로세스를 생성하는 것은 권장되지 않습니다.

**OS의 프로세스 모니터를 보면 상위 프로세스가 약 14MB 를 사용하며 하위 프로세스가 약 7MB 메모리를 사용하게 됩니다.**

<aside>
💡 여유 메모리가 1740MB 라 가정하였을 때, 해당 엔드포인트를 약 250회 호출하면 컴퓨터가 다운됩니다

</aside>

<aside>
💡 이에 비해 고루틴을 사용하는 Go 언어는 호출 당 몇 킬로바이트만 사용합니다.
(따라 25만 건의 동시 호출을 처리할 수 있습니다.)

</aside>

# 해결책

이러한 종류의 Node.js 문제(CPU 집약적 엔드포인트가 있는 웹 서버)에 대한 일반적인 해결책은 대기열과 작업자 프로세스 풀을 설정하는 것입니다. 

다음 글에서는 CPU Intensive Node.js: 2부에서는 이 해결책을 다루겠습니다.

# 내용 정리 및 번역 후기

Node.js 로 작성한 WAS 에서 CPU 를 많이 사용하는 작업을 수행할 때는 요청 전에 배치된 리버스 프록시 서버에서 처리할 수 있는 작업이 있다면 해당 서버에서 작업을 처리해야한다고 배운 적이 있었다.

그 외에 WAS 에서 처리해야할 요청에 대해서 어떻게 처리하는 지 방안을 배울 수 있었다.

하지만 무작정 fork 는 대규모 웹 트래픽을 처리하기엔 부적절한 방안으로 보이니 차선책을 알아두면 좋을 것 같으며, 메모리 사용률로 지표를 보여주는 예제가 도움이 된 것 같다.

[[CPU Intensive Node.js Part.2]] 

# 원 글

**[CPU Intensive Node.js: Part 1](https://codeburst.io/cpu-intensive-node-js-part-1-1218b102e5ec)**