# Node.js 에서 병렬 처리는 어떻게 동작하나?
![[병렬 작업 처리 With Nest.JS-20240511115709947.webp]]

> Event Loop 동작 메커니즘

Node.js 는 `Event Loop` 개념을 통해 병렬 처리를 가능하게 하는 단일 스레드, 이벤트 중심 플랫폼
`EL(Event Loop` 을 활용하여 OS 로 작업을 위임하여 `Non Blocking I/O` 작업을 수행할 수 있다!

`Non Blocking I/O` 작업이 발생하면 이를 스레드 풀로 넘기고 다음 요청을 작업한다.
그러나 연산량이 많은 작업이 발생한다면 `Event Loop` 가 응답하지 않을 수도 있다.


# References
### [Node.js Event Loop 공식문서](https://nodejs.org/en/learn/asynchronous-work/event-loop-timers-and-nexttick)


