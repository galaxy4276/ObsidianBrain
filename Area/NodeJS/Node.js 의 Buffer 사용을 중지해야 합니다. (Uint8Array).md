---
tags:
  - nodejs
  - buffer
---
- Buffer 타입은 Node.js 초기부터 바이너리 데이터 처리의 초석이었음
- 하지만 요즘은 Unit8Array가 기본 JavaScript 타입이고, 크로스플랫폼에서도 작동
- Buffer는 Uint8Array의 인스턴스이지만, 다른 자바스크립트 환경에서는 사용할 수 없는 다양한 메서드를 도입했음
    - 따라서 Buffer의 메서드를 활용하는 코드는 폴리필링이 필요하므로 많은 중요한 패키지가 브라우저와 호환되지 않게 만듦
    - 또한 Buffer#slice() 와 Uint8Array#slice() 는 동작이 달라서 예측할 수 없는 결과가 발생 가능

## 계획

- 모든 패키지들을 Buffer에서 Unit8Array로 이동하기로 함
- Buffer는 아마 절대 제거되지 않을 것이며, 더 이상 사용되지 않게 되지도 않겠지만, 적어도 커뮤니티는 버퍼에서 서서히 멀어질 수 있을 것
- 내 희망은 Node.js 팀이 적어도 Buffer 사용을 권장하지 않도록 시작하는 것

## How

- 먼저 Uint8Array와 Buffer의 [미묘한 비호환성](https://nodejs.org/api/buffer.html#buffers-and-typedarrays)에 대해 숙지할 것
- 이전이 쉽도록 [`uint8array-extras`](https://github.com/sindresorhus/uint8array-extras) 패키지를 만들었음
- 당신의 코드가 Buffer를 받고 Buffer 관련 메서드를 사용하지 않는 경우 문서와 유형을 Uint8Array로 업데이트하기만 하면 됨
    - 입력 유형을 Buffer에서 Uint8Array로 변경하는 것은 버퍼가 Uint8Array의 인스턴스이므로 non-breaking 변경임
- 반환 유형을 버퍼에서 Uint8Array로 변경하는 경우는 컨슈머가 버퍼 전용 메서드를 사용할 수 있기 때문에 breaking 변경임
- Uint8Array를 Buffer로 반드시 변환해야 하는 경우 Buffer.from(uint8Array)(데이터를 복사) 또는 Buffer.from(uint8Array.buffer, uint8Array.byteOffset, uint8Array.byteLength)(복사 안 함)를 사용할 수 있음. 하지만 일반적으로 더 좋은 방법이 있음
- 전환하는 단계는
    - 'node:buffer' import 에서 `import {Buffer}`를 모두 제거
    - 글로벌하게 Buffer의 모든 이용부분을 제거
    - Buffer 특정 메서드 사용을 중지

## 질문들

- 왜 애초에 Buffer가 있었지? : Buffer는 Unit8Array가 만들어지기 한참 전에 만들어짐
- Uint8Array를 사용하여 Base64로 from/to 변환하려면? : 당장은 `uint8array-extras` 를 사용. 결국에는 자바스크립트에서 기본적으로 지원될 가능성이 높음

# References
[Goodbye, Node.js Buffer](https://sindresorhus.com/blog/goodbye-nodejs-buffer)
[GeekNew 요약본](https://news.hada.io/topic?id=11519)

