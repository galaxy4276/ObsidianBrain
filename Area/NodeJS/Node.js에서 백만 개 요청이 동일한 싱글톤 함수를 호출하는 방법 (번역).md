#nodejs #concurrency 

Node.js는 이벤트 기반, 논블로킹 아키텍처 덕분에 모두 싱글톤의 동일한 메서드를 호출하더라도 수백만 개의 동시 요청을 효율적으로 처리할 수 있다.

## Node.js와 이벤트 루프
Node.js는 단일 스레드 이벤트 루프를 사용하지만, 한 번에 하나의 요청만 처리한다는 의미는 아니다. 대신 비동기 I/O 작업과 이벤트 콜백을 사용하여 메인 스레드를 차단하지 않고 여러 동시 요청을 처리한다.

요청이 들어올 때 다음과 같은 일이 발생한다.
- Node.js가 요청 처리를 시작한다
- 요청에 비동기 작업(데이터베이스 쿼리나 파일 읽기 등)이 포함된 경우, 해당 작업은 위임된다(시스템 커널이나 워커 스레드에)
- 대기하는 동안 Node.js는 다음 요청 처리로 넘어간다
- 비동기 작업이 완료되면 콜백이 큐에 추가되고 실행된다

이러한 아키텍처를 통해 Node.js는 최소한의 리소스로 대량의 동시 요청을 처리할 수 있다.
## 공유 싱글톤 함수 접근
다음과 같은 간단한 싱글톤 객체가 있다고 가정해보자.
```javascript
class Config {
  constructor() {
    this.settings = {
      dbHost: 'localhost',
      dbPort: 3306
    };
  }

  get(key) {
    return this.settings[key];
  }
}

const config = new Config();
module.exports = config;
```

이 config 객체는 애플리케이션 시작 시 한 번만 생성된다. 이 모듈을 가져오는 모든 요청은 동일한 인스턴스를 받는다. get() 메서드는 단순히 정적 인메모리 객체에서 읽기만 한다. 변경도 없고, I/O도 없고, 차단도 없다.
그렇다면 백만 개의 요청이 모두 config.get()을 호출하면 어떻게 될까? 충돌 없이 모두 성공한다.
왜냐하면..
- 변경되는 공유 상태가 없다
- 차단이나 대기가 관여하지 않는다
- 각 호출이 가볍고 독립적이다
## 실제 Node.js 동시성
간단한 Express 서버로 상황을 살펴보자.
```javascript
const express = require('express');
const app = express();
const config = require('./config');

app.get('/', (req, res) => {
  const dbHost = config.get('dbHost');
  res.send(`Database host is ${dbHost}`);
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
});
```

100만 개의 요청이 이 서버에 도달하면..
- 각 요청은 config.get('dbHost')를 호출한다
- 이는 JavaScript 객체의 속성 조회일 뿐이다
- Node.js는 이벤트 루프에서 이를 처리하고, 이전 요청이 완료될 때까지 기다리지 않고 요청을 효율적으로 큐에 넣고 응답한다
**이 메서드가 다음과 같기 때문에**
- 상태가 없다
- 읽기 전용이다
- 논블로킹이다

따라서 Node.js는 최소한의 지연으로 요청을 동시에 처리할 수 있다.
## 싱글톤이 병목 현상이 되는 경우
이러한 효율성은 싱글톤이 상태가 없고 논블로킹 상태를 유지하는 한 유효하다.
문제가 될 수 있는 경우는 다음과 같다.
### 블로킹 작업 예시

```javascript
class Logger {
  constructor() {
    this.logFile = fs.createWriteStream('./app.log');
  }

  log(message) {
    this.logFile.write(`${new Date().toISOString()} ${message}\n`);
  }
}
```

모든 요청이 로그 항목을 작성하는 경우
- 모든 요청은 동일한 Logger 인스턴스와 동일한 파일 스트림을 공유한다
- 디스크에 쓰기는 I/O 바인딩되어 있으며 잠재적으로 블로킹될 수 있다
- 높은 부하에서 로그 쓰기는 이벤트 루프를 느리게 하거나 차단할 수 있다
### 공유 가변 상태 예시
```javascript
class EmailSender {
  constructor() {
    this.recipients = [];
  }

  setRecipients(list) {
    this.recipients = list;
  }

  send(message) {
    this.recipients.forEach(email => {
      console.log(`Sending "${message}" to ${email}`);
    });
  }
}
```

여러 요청이 동시에 수신자 목록을 수정하면 서로 간섭하게 된다. 이는 전형적인 경쟁 상태다.
## 결론
백만 개의 요청이 싱글톤의 동일한 함수를 안전하게 호출할 수 있다.
단!
- 메서드가 읽기 전용이어야 한다
- 공유 가변 상태가 없어야 한다
- 블로킹 작업(파일 또는 네트워크 I/O와 같은)이 없어야 한다
- 함수가 일정한 시간과 메모리로 작동해야 한다

Node.js는 스레드를 생성하는 방식이 아니라 이벤트 루프를 통해 작업을 매우 효율적이고 논블로킹 방식으로 큐에 넣고 디스패치함으로써 높은 동시성을 처리할 수 있다.
### 핵심 요점
Node.js에서 싱글톤은 상태가 없고 논블로킹 작업을 수행하는 경우 안전하고 확장 가능하다. 하지만 가변 데이터나 블로킹 로직을 도입하면 조용히 성능 병목 현상이 되거나 더 나쁘게는 버그의 원인이 될 수 있다.
# References
https://dev-aditya.medium.com/how-can-a-million-requests-call-the-same-singleton-function-in-node-js-af3737ec2d0d
