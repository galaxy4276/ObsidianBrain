---
tags: nodejs
---
![[nodejs.webp]]

Node.js 12.x 버전부터 비동기 스택 추적 기술이 도입되었다고 합니다.

비동기 스택 추적을 통해 개발자는 비동기 코드의 호출 스택을 볼 수 있으므로,

코드 이슈를 더 쉽게 추적하고 디버깅할 수 있게 되었습니다.

## 비동기 스택 추적은 어떻게 동작하는가?

비동기 스택 추적은 비동기 코드가 실행될 때가 아닌,

코드가 스케줄링 될 때 호출 스택을 캡처해둠으로써 개발자가 오류의 전체 컨텍스트를 확인할 수 있도록 합니다.

<aside>
💡 **코드 스케줄링?**
코드 실행이 예약되어 실행 컨텍스트 내에서 실행되기를 기다리게 만드는 과정
비동기 작업이 특정 시점에 실행되도록 예약되어야 하기 때문에 필요하다.

</aside>

만약 오류 발생 시점에서 호출 스택을 캡처한다면 원인을 추적하기 어려울 것입니다.

코드로 예시를 확인해보겠습니다.

```jsx
const funcThree = async () => {
  await Promise.resolve();
  throw new Error("Oops"); // 에러를 발생시킨다.
};
 
const funcTwo = async () => {
  await Promise.resolve();
  await funcThree();
};
 
const funcOne = async () => {
  await new Promise((resolve) => setTimeout(resolve, 10));
  await funcTwo();
};
 
const init = async () => {
  await new Promise((resolve) => setTimeout(resolve, 10));
  await funcOne();
};
 
init().then(
  () => console.log("success"),
  (error) => console.error(error.stack)
);
```

다음과 같은 코드를 실행하여 `funcThree` 에서 에러가 발생하였을 때 출력은 다음과 같습니다.

```jsx
Error: Oops
    at funcThree (/Users/kennethjimmy/Desktop/asyncStackTraces.js:3:9)
    at async funcTwo (/Users/kennethjimmy/Desktop/asyncStackTraces.js:8:3)
    at async funcOne (/Users/kennethjimmy/Desktop/asyncStackTraces.js:13:3)
    at async init (/Users/kennethjimmy/Desktop/asyncStackTraces.js:18:3)
```

비동기 코드에서 오류가 발생했을 때 이전에 호출 스택을 캡처해두었기 때문에 위와 같이 스택을 추적하기 쉽습니다.

만약 Node.js 12 보다 낮은 버전을 사용할 경우 다음과 같이 출력될 것입니다.

```jsx
Error: Oops
    at funcThree (/Users/kennethjimmy/Desktop/asyncStackTraces.js:3:9)
    at <anonymous>
```

## 마치며

해당 글은 Node.js 12부터 비동기 호출에서도 에러 스택을 쉽게 디버깅할 수 있게 코드가 스케줄링 될 때 미리 호출 스택을 캡처해둔다는 내용이 핵심이었습니다.

기존에 비동기 코드에서 에러가 발생했을 때 어떻게 스택을 추적할 수 있는 지에 대한 의문이 어느정도 해결되었으면 좋겠습니다. 

## References

****[An Introduction to Async Stack Traces in Node.js](https://blog.appsignal.com/2023/05/17/an-introduction-to-async-stack-traces-in-nodejs.html)****