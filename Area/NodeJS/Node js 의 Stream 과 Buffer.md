---
tags: nodejs, stream, buffer
---
# Node.js 의 Stream 과 Buffer

태그: Buffer, Node.js, Stream
Date: October 5, 2023 6:00 PM
공개 여부: 공개
설명: Node.js 데이터 처리와 통신에서 가장 중요한 요소들
카테고리: Node.js

![Untitled](Untitled%2085.png)

비디오, 대용량 파일 같은 스트리밍 데이터를 처리하고 조작하려면 Node 의 `Stream` 이 필요합니다.

Node.js 의 `Stream` 모듈은 모든 스트림을 관리합니다.

# Streams 의 유형

Node 에서는 4 가지 유형의 스트림이 존재합니다.

- `Readable Streams` → 읽을 수 있는 데이터 스트림
    
    <aside>
    💡 예시) 대용량 파일을 청크로 읽는 경우
    
    </aside>
    
- `Writeable Streams` → 쓰기용 데이터 스트림
    
    <aside>
    💡 예시) 파일에 대량의 데이터 쓰기 작업
    
    </aside>
    
- `Duplex Streams` → 읽기/쓰기가 동시에 가능한 스트림
    
    <aside>
    💡 클라이언트와 서버 간 소켓 연결
    
    </aside>
    
- `Transform Streams`  → 읽기 및 쓰기가 가능하지만 읽고 쓰는 동안 데이터를 수정 및 변환하는 스트림
    
    <aside>
    💡 요청 전 클라이언트와 서버가 데이터를 압축하는 경우
    
    </aside>
    

# Streams 에서 Buffers

Stream 은 Buffer 라는 개념으로 동작합니다.

**Buffer 는 스트림이 데이터를 소비할 때까지 일부 데이터를 보관하기 위해 사용하는 임시 메모리입니다.**

스트림에서 Buffer 크기는 스트림 인스턴스의 `highWatermark` 속성에 의해 결정되며, 이 속성은 버퍼의 크기를 바이트 단위로 나타내는 숫자입니다.

Node 의 버퍼 메모리는 기본적으로 String 과 Buffer 에서 동작합니다.

버퍼 메모리가 자바스크립트 객체에서 작동하도록 만들 수 있으며 이렇게 하려면 스트림 객체의 `objectMode` 속성을 true 로 설정해야합니다.

일부 데이터를 스트림으로 푸시하려고 하면 데이터가 스트림 버퍼로 푸시됩니다.

푸시된 데이터는 데이터가 소비될 때까지 버퍼로 남아있습니다.

만약 버퍼가 가득 찬 상태에서 스트림으로 데이터를 푸시하려고 하면 스트림이 해당 데이터를 허용하지 않고 푸시 작업에 대해 `false` 값 으로 반환합니다.

# Streams 과 EventEmitters

Node.js 스트림은 `EventEmitter` 클래스를 확장합니다.

데이터와 같은 이벤트를 수신하고 스트림으로 끝낼 수 있습니다.

단순히 이벤트를 수신하려면 `stream.on()` 함수를 사용해야합니다.

이벤트 이미터에 대해 살펴보려면 아래 문서를 참조하세요

[](https://medium.com/developers-arena/nodejs-event-emitters-for-beginners-and-for-experts-591e3368fdd2)

# Node.js 에서 Streams 읽기

스트리밍 데이터를 읽는 데 사용되는 스트림을 읽기 스트림이라고합니다.

읽기 스트림은 서버에서 파일을 읽거나 온라인 동영상을 스트리밍할 수 있습니다.

대용량 텍스트 파일에서 읽기 스트림을 생성하여 실제로 동작하는 예제를 살펴보겠습니다.

```jsx
import { createReadStream, ReadStream } from 'fs';

var readStream: ReadStream = createReadStream('./data.txt');

readStream.on('data', chunk => {
  console.log('---------------------------------');
  console.log(chunk);
  console.log('---------------------------------');
});

readStream.on('open', () => {
  console.log('Stream opened...');
});

readStream.on('end', () => {
  console.log('Stream Closed...');
});
```

실행하면 다음 코드가 출력됩니다.

```java
Stream opened...
---------------------------------
<Buffer 4c 6f 72 65 6d 20 69 70 73 75 6d 20 64 6f 6c 6f 72 20 73 69 74 20 61 6d 65 74 2c 20 63 6f 6e 73 65 63 74 65 74 75 72 20 61 64 69 70 69 73 63 69 6e 67 ... >
---------------------------------
---------------------------------
<Buffer 74 20 6e 75 6e 63 20 76 69 74 61 65 20 66 65 72 6d 65 6e 74 75 6d 2e 20 49 6e 20 75 74 20 61 72 63 75 20 74 65 6d 70 6f 72 2c 20 66 61 75 63 69 62 75 ... >
---------------------------------
---------------------------------
<Buffer 20 76 69 74 61 65 2c 20 65 67 65 73 74 61 73 20 69 64 20 73 65 6d 2e 20 44 6f 6e 65 63 20 75 74 20 75 6c 74 72 69 63 69 65 73 20 6c 6f 72 65 6d 2c 20 ... >
---------------------------------
Stream Closed...
```

스트림의 버퍼 메모리에 있는 콘텐츠의 바이트 데이터인 버퍼 데이터를 가져옵니다.

## readable stream 일시 중지 및 재시작

`pause()`와 `resume()`함수를 이용하여 스트림을 일시 중지 및 재시작 할 수 있습니다.

`pause()` 함수를 호출하면 스트림의 `resume()` 함수를 호출할 때까지 데이터 이벤트가 트리거되지 않습니다.

# Flowing, Non-Flowing Streams

### Flowing Stream

스트림에서 데이터 이벤트를 사용하여 직접들을 수 있는(listening) 데이터를 지속적으로 전달하는 스트림입니다.

### Non-Flowing Stream

데이터를 자동으로 푸시하지 않는 스트림입니다.

대신 데이터를 버퍼에 저장하며, 데이터를 읽으려면 스트림의 `read()` 메서드를 명시적으로 호출해야합니다.

다음 코드는 스트림의 데이터 이벤트만 수신하고 스트림에서 새로운 데이터가 발생할 때마다 리스너가 자동으로 트리거되는 `Flowing Stream`의 예시입니다.

```jsx
import { createReadStream, ReadStream } from 'fs';

var readStream: ReadStream = createReadStream('./data.txt');

setTimeout(() => {
  const data = readStream.read(10);
  console.log(data);
}, 10);
```

```java
<Buffer 4c 6f 72 65 6d 20 69 70 73 75>
```

위 코드는 어떻게 동작했을까요?

`fs` 모듈의 `createReadStream` 메서드를 사용하여 읽기 스트림을 생성했기 때문입니다.

스트림이 생성되는 즉시 파일 데이터가 스트림 변수로 스트리밍되기 시작합니다. 

또한 스트림이 `setTimeout` 메서드를 사용하여 버퍼에 데이터를 채울 수 있도록 약간의 시간을 허용했습니다.

# Read Stream  에 의한 버퍼 관리

위 예시 코드에서 `console.log(data)` 뒤에 다시 `read()` 함수를 호출하여 새로운 데이터를 출력하면

이전 로그와 다른 데이터가 출력됩니다.

```jsx
import { createReadStream, ReadStream } from 'fs';

var readStream: ReadStream = createReadStream('./data.txt');

setTimeout(() => {
  const data = readStream.read(10);
  console.log(data);

  const data2 = readStream.read(10);
  console.log(data2);
}, 10);
```

```jsx
<Buffer 4c 6f 72 65 6d 20 69 70 73 75>
<Buffer 6d 20 64 6f 6c 6f 72 20 73 69> // diff
```

이유는 소비자(Consumer) 가 데이터를 읽은 후 버퍼가 데이터를 제거하기 때문에 기록되는 값이 다른겁니다.

따라서 `read()` 메서드를 처음 호출하면 버퍼 데이터의 첫 10바이트를 가져오고, `read()` 메서드를 두번 째 호출했을 때 버퍼의 첫 10바이트에 해당하는 실제 데이터의 **11번째 바이트부터 20번째** 바이트까지를 가져옵니다.

추가적으로 스트림, 파이핑 그리고 스트리밍 과정에서 에러 핸들링을 살펴보려면 아래 글을 참고하세요.

[](https://javascript.plainenglish.io/streams-piping-and-their-error-handling-in-nodejs-c3fd818530b6)

# References

**[Streams and Buffers in Node.js - Kunal Tandon](https://javascript.plainenglish.io/streams-and-buffers-in-nodejs-30ff53edd50f)**

**[Node Event Emitters — For Beginners and Experts](https://medium.com/developers-arena/nodejs-event-emitters-for-beginners-and-for-experts-591e3368fdd2)**