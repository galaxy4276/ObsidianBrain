[원문](https://programming.earthonline.us/can-you-answer-this-senior-level-javascript-promise-interview-question-69f7b6ffc2e7)

![[Senior Level Javascript Interview(마이크로태스크와 매크로태스크)-20240831005026024.webp]]


자바스크립트의 이벤트 루프에는 우선순위 개념이 존재한다.

- Tasks with higher priority are called microtasks. Includes: `Promise`, `ObjectObserver`, `MutationObserver`, `process.nextTick`, `async/await` .
- Tasks with lower priority are called macrotasks. Includes: `setTimeout` , `setInterval` and `XHR` .


![[Senior Level Javascript Interview(마이크로태스크와 매크로태스크)-20240831005100800.webp]]

항상 `Microtasks` 가 우선 순위를 먼저 가져간다.
> 아마 Microtasks 전용 Queue 가 존재하고 EventLoop 의 한 Tick 내에서해당 Queue 가 비워질 때까지 매크로태스크는 지연될 것이다.

#nodejs #javascript #event-loop #asynchronous  


