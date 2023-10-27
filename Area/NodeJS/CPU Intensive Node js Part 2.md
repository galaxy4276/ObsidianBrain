---
tags: nodejs, multi-threading
---
![Untitled](Untitled%2021.png)

<aside>
💡 핵심: 비동기 처리를 위한 메시지 큐 도입

</aside>

# 외부 Queue 도입

이전 글에서 설명했던 CPU 집약적 엔드포인트가 존재하는 웹 서버의 문제점의 일반적인 해결 책은

대기열과 worker 프로세스 풀을 설정하는 것입니다.

특히 이를 위해 [Kue](https://github.com/Automattic/kue) 라이브러리를 이용하겠습니다.

<aside>
💡 Kue 는 redis 를 이용하는 우선순위 작업 큐 라이브러리입니다.

</aside>

<aside>
💡 Kue 는 더 이상 관리되지 않으며 대안으로 Bull 을 권장합니다.
학습 목적으로 이 글에서는 Kue 로 진행합니다.

</aside>

# 왜 Queue 를 사용하는 지?

- 클러스터된 Node.js 프로세스는 전역 범위를 공유하지 않으므로 이 경우 큐 데이터는 다른 프로세스에 있어야 한다.
- Redis 는 일반적으로 사용되며 기능이 풍부하고, 고도로 최적화된 인메모리 데이터 구조 저장소이기 때문
- Kue 는 Redis 의 원시 키/값 구조를 사용하며 강력한 우선순위 큐를 제공

또한 이러한 라이브러리는 대기열을 모니터링할 수 있기 때문에 좋은 유지보수 방안을 제공합니다.

```bash
node_modules/kue/bin/kue-dashboard -p 3050 -r redis://127.0.0.1:6379
```

![Untitled](Untitled%2022.png)

이전에 이벤트 루프를 차단하는 코드를 Kue 를 사용해 리팩토링한 예제를 봅시다.

```jsx
// worker.js
const kue = require('kue');
const { sleep } = require('sleep');
const queue = kue.createQueue();
console.log('WORKER CONNECTED');
queue.process('mytype', (job, done) => {
  sleep(5);
  console.log('WORKER JOB COMPLETE');
  switch (job.data.letter) {
    case 'a':
      done(null, 'apple');
      break;
    default:
      done(null, 'unknown');
  }
});
```

```jsx
// index.js
const express = require('express');
const kue = require('kue');
const app = express();
const queue = kue.createQueue();
app.get('/', (req, res) => res.send('Hello World!'));
app.get('/intense', (req, res) => {
  const job = queue.create('mytype', {
    title: 'mytitle',
    letter: 'a',
  })
    .removeOnComplete(true)
    .save((err) => {
      if (err) {
        res.send('error');
        return;
      }
      job.on('complete', (result) => {
        res.send(`Hello Intense ${result}`);
      });
      job.on('failed', () => {
        res.send('error');
      });
    });
});
app.listen(3000, () => console.log('Example app listening on port 3000!'));
```

만약에 요청이 `**120초(기본 값)**` 동안 수행되지 못하는 경우 Node.js 는 자동으로 실패 응답을 수행합니다.

worker.js 예제처럼 실행하면 CPU 집약적인 문제에 대한 더 나은 해결책을 찾을 수 있습니다.

**이 솔루션은 단일 워커를 사용하여 CPU 집약적 엔드포인트에 대한 동시 호출을 최대 24개(120/5s) 까지 처리할 수 있지만, 호출이 실패하기 전엔 연속적으로 호출할 때마다 시간이 점점 더 오래 걸립니다.**

Node.js 는 완료하는데 120초 이상 걸리는 응답을 자동으로 처리하게 됩니다.

- CPU 집약적이지 않는 엔드포인트는 중단 없이 작동합니다.
- 이 방법은 동시 요청 수에 관계없이 안정적입니다. (서버가 다운되지 않음)

그러나 CPU 집약적인 엔드포인트에는 여전히 확장 문제가 존재하며 약 6개의 동시 연결이 끝나면 사실상 실패합니다.

<aside>
💡 유저는 결과를 기다리는데 30초 이상 걸리는 것을 원하지 않을겁니다.

</aside>

# 스케일링

먼저 worker.js 예제에서 CPU 집약적 프로세스를 수행하지 않는 경우, 예를 들어 단순히 타사 API(이메일, SMS 등)를 호출하고 대기하는 경우 Kue의 프로세스 동시성 기능을 사용하여 단일 워커가 여러 개의 활성 작업을 동시에 처리할 수 있도록 할 수 있습니다.

그러나 우리의 예제에서는 CPU 집약적인 문제가 존재하며 Node.js 는 단일 스레드이므로 이 경우 프로세스 동시성 기능을 활용할 수 없습니다.

대신 많은 작업자 프로세스를 스핀 업하면 어떨까요?

<aside>
💡 스핀 업: 인스턴스 생성을 의미

</aside>

이에 대해 생각해볼 방안은 다음정도가 있습니다.

- CPU 가 있는 만큼만 워커를 활용하기. 이렇게하면 처음 몇개의 요청은 빨리 처리되지만 다른 모든 요청은 지연됩니다.
- 많은 워커를 요청하여 모든 요청에 부하를 분산시키기. 이렇게하면 부하량에 따라 모든 요청이 지연되는 효과가 있습니다.

워커를 CPU 수와 일치시키는 경우 Node.js 자식 프로세스 기능을 활용하여 이를 자동화 할 수 있습니다.

```jsx
// 예시
const { cpus } = require('os');
const { fork } = require('child_process');
const numWorkers = cpus().length;
for (let i = 0; i < numWorkers; i += 1) {
  fork('./worker');
}
```

또다른 방법으로 **네트워크를 통해 Redis 에 접근**할 수 있다는 사실을 활용하는 것입니다.

네트워크를 사용하도록 workers.js 를 리팩터링하면 솔루션을 효과적으로 무한대로 확장할 수 있습니다.

예를 들어, 수백 대의 컴퓨터에서  workers.js 를 실행한다고 가정하면 많은 요청을 빠르게 처리할 수 있게됩니다.

# 마치며

이 글에서 Node.js 에서 CPU를 많이 사용하는 작업에 대해(집약적) 어떻게 효율적으로 처리할 수 있는 지 큐를 이용한 방안을 예제로 학습해보았습니다.

Java Spring 처럼 멀티스레드를 활용하는 애플리케이션조차도 스레드 풀에 제한이 있기때문에 이러한 솔루션이 통용될 수 있을 것 같습니다!

# 원 글

**[CPU Intensive Node.js: Part 2](https://codeburst.io/cpu-intensive-node-js-part-2-f1610a17f40a)**

# References

**[[Project] 프로젝트 삽질기10 (feat bull 공식문서 정리)](https://overcome-the-limits.tistory.com/679?category=1006727)**