---
tags: nodejs, tcp
---
`Node.js` 의 `Stream` 기능을 활용해서 완전 밑바닥부터 웹 서버를 만들며 공부 된 내용을 정리하였습니다.

`Node.js` 내장된 모듈은 `http` 보단 `net` 모듈을 사용하였습니다.

<aside>
💡 소켓 수준에서 프로그래밍하기 더 적합하며, 기존에 만들기 위한 기능은 http 모듈에서 이미 제공 중입니다.

</aside>

전반적인 코드는 아래 깃헙 레포지토리를 확인해주세요.

**[[Github] galaxy-basic-web-server](https://github.com/galaxy4276/galaxy-basic-web-server)**

# node:net 에 대해

[공식문서](https://nodejs.org/api/net.html)

> 스트림 기반 TCP 또는 ICP 서버와 클라이언트를 생성하기 위한 비동기 네트워크 API 를 제공합니다. - node.js docs
> 

해당 모듈에서 제공하는 API로 생성된 소켓은 `이중 스트림(Duplex Stream)` 을 지원합니다.

<aside>
💡 **이중 스트림이란?**
읽기와 쓰기가 혼합된 스트림 형태입니다.
예시로 데이터를 송수신할 수 있는 두 개의 채널을 제공하는 소켓이 있습니다.

</aside>

### 왜 Node.js 에서 Stream 을 사용할까요?

![Node.js 에서 Stream 을 지원하는 기능](Untitled%2089.png)

Node.js 에서 Stream 을 지원하는 기능

`스트림(Stream)`은 실시간으로 한 번에 가져올 수 없는 데이터를 처리할 때 매우 효과적인 Node.js 의 핵심 기능입니다.

주로 외부 데이터를  `청크(chunk)`단위로 가져올 때 큰 힘을 발휘합니다.

<aside>
💡 청크(chunk) 는 데이터를 **작은 조각으로 분할하여 전송하는 단위**를 의미합니다.

</aside>

# 살펴보기

전반적인 가이드는 ****[Let's code a web server from scratch with NodeJS Streams!](https://www.codementor.io/@ziad-saab/let-s-code-a-web-server-from-scratch-with-nodejs-streams-h4uc9utji)** 을 따르고 있으며 핵심적인 로직부분 만을 정리해보겠습니다.

최종적으로 작성되어 동작하는 서버 코드를 일부 보여드리겠습니다.

```jsx
const server = createWebServer((req, res) => {
  console.debug('요청 콜백이 수행 됨');
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World');
});

server.listen(3000, () => {
  console.debug('서버가 실행되었습니다.');
});
```

익숙한 기존 http 서버의 모습이 보이지 않나요?

여기서 핵심은 `TCP` 수준에서 받아온 `HTTP 메시지`에서 `HTTP 헤더`를 파싱하고 객체 정보(`req`, `res`) 에 저장하여 개발자가 쉽게 가져오고 응답 메시지를 작성할 수 있게 추상화된 도구를 작성하는 겁니다.

`HTTP 요청`을 받고 처리할 수 있는 콜백함수를 반환해주는 핵심 메서드인 `createWebServer` 함수를 확인해봅시다.

```jsx
export const createWebServer = (requestHandler: (req: Request, res: Response) => void) => {
  const server = net.createServer();

  const handleConnection = (socket: net.Socket) => {
    socket.once('readable', () => {
      let reqBuffer: Buffer = initBuffer();
      let buf: Buffer;
      let reqHeader: string;
      let body = {} as Record<string, any>;
  
     // (1) HTTP 메시지 읽고 저장하는 로직
      while (true) ...
    
      // (2) 헤더를 파싱하고 요청, 응답에 대한 추상화 객체를 생성하는 로직
      const reqHeaders: string[] = reqBuffer.toString().split(createHeaderLineBreak());
      const request: Request = createRequest(reqHeaders, socket, body);
      const response: Response = createResponse(socket);

      requestHandler(request, response); // http 요청 처리 콜백 함수 실행
    });
  };

  server.on('connection', handleConnection);
  
  // (3) 개발자가 필요로하는 메서드 객체 반환
  return {
    listen: (port: number, listenCb?: () => void) => server.listen(port, listenCb),
    close: server.close,
  };
};
```

먼저 (1) 번 내용입니다.

```jsx
     // (1) HTTP 메시지 읽고 저장하는 로직
while (true) {
        buf = socket.read() as Buffer;
        if (buf == null) break;
        reqBuffer = Buffer.concat([reqBuffer, buf]);
        let marker = reqBuffer.indexOf(createHeaderLineBreak());
        if (marker !== -1) {
          const remaining: Buffer = reqBuffer.subarray(marker, 4);
          console.log({ remaining: remaining.toString() });
          reqHeader = reqBuffer.subarray(0, marker).toString();
          socket.unshift(remaining);
          break;
        }
      }
```

`socket.read()` 메서드는 내부 버퍼에서 데이터를 읽고 반환합니다.

여기서 데아터가 없으면 `null` 을 반환하게 되므로 전체 로직을 중지할 수 있습니다.

### Stream API 의 unshift 메서드

![Untitled](Untitled%2090.png)

`Readable Streams` 에서 일부 `데이터 청크` 를 내부 버퍼로 밀어넣어야 할 때,

`readable.unshift()` 메서드를 사합니다.

이 메서는 메모리가 완전히 사용되었을 때 `데이터 청크`를 내부 버퍼로 이동하여 일부 공간을 확보하는데 유용합니다.

이제 남은 코드는 이해하기 쉽습니다.

```tsx
...
// (2) 헤더를 파싱하고 요청, 응답에 대한 추상화 객체를 생성하는 로직
const reqHeaders: string[] = reqBuffer.toString().split(createHeaderLineBreak());
const request: Request = createRequest(reqHeaders, socket, body);
const response: Response = createResponse(socket);

requestHandler(request, response); // http 요청 처리 콜백 함수 실행
...
```

`HTTP Request` 문자열을 한 줄마다 쪼개서 `string[]` 으로 변환하고 해당 값을 이용해서 `request` 객체를 만들고 그 후, `response` 객체를 생성합니다.

그리고 최종적으로 인수로 전달받은 콜백함수에 `request`, `response` 값을 매개변수로 주입해서 함수를 실행함으로써 HTTP 요청을 처리할 수 있게됩니다.

# References

**[knowledgehut Node.Js - Net Module](https://www.knowledgehut.com/blog/web-development/nodejs-net-module)**

**[Victor Jonah - Creating Duplex streams in Node.js](https://blog.logrocket.com/creating-duplex-streams-nodejs/)**

****[What is Stream Module unshift() in Node.js?](https://www.educative.io/answers/what-is-stream-module-unshift-in-nodejs)****

****[How to check if a file exists in Node.js](https://flaviocopes.com/how-to-check-if-file-exists-node/)****

**[Node.js Stream 당신이 알아야할 모든 것 1편](https://jeonghwan-kim.github.io/node/2017/07/03/node-stream-you-need-to-know.html)**

****[Let's code a web server from scratch with NodeJS Streams!](https://www.codementor.io/@ziad-saab/let-s-code-a-web-server-from-scratch-with-nodejs-streams-h4uc9utji)****