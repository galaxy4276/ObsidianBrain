#stompjs #message-queue #spring #websocket 
 
Stompjs는 WebSocket을 통해 STOMP(Simple Text Oriented Messaging Protocol) 프로토콜을 구현하는 JavaScript 라이브러리입니다. 이 라이브러리를 이용하면 클라이언트와 서버 간에 효율적인 실시간 양방향 통신을 구현할 수 있습니다. 메시지 큐와 연동하여 강력한 메시징 시스템을 구축할 수 있는 방법을 자세히 살펴보겠습니다.

## 1. STOMP 프로토콜 기본 개념
STOMP는 간단한 텍스트 기반 메시징 프로토콜로, HTTP와 유사한 설계 방식을 따릅니다. 주요 특징으로는:
- 텍스트 기반 프레임 구조 (바이너리 메시지도 지원)
- 클라이언트와 메시지 브로커 간의 상호 운용성
- 쉬운 구현 (텔넷으로도 연결 가능할 정도로 단순)

### STOMP 프레임 구조
STOMP 프레임은 다음과 같은 구조로 이루어져 있습니다:

```
COMMAND
header1:value1
header2:value2

Body^@
```

여기서:

- `COMMAND`는 명령어(CONNECT, SEND, SUBSCRIBE 등)
- 헤더는 `key:value` 형식의 메타데이터
- 공백 라인으로 헤더와 바디를 구분
- 바디는 선택적이며, 널 바이트(^@, 0x00)로 프레임 종료

## 2. Stompjs의 웹소켓 활용 방식

Stompjs는 WebSocket 위에서 STOMP 프로토콜을 구현합니다.

### 연결 설정 과정

```javascript
const client = new StompJs.Client({
  brokerURL: 'ws://localhost:8080/ws',
  connectHeaders: {
    login: 'user',
    passcode: 'password',
  },
  debug: function (str) {
    console.log(str);
  },
  reconnectDelay: 5000,
  heartbeatIncoming: 4000,
  heartbeatOutgoing: 4000,
});

client.onConnect = function (frame) {
  // 연결 성공 처리
  console.log('Connected: ' + frame);
  
  // 구독 설정
  client.subscribe('/topic/messages', function (message) {
    console.log('Received: ' + message.body);
  });
};

client.onStompError = function (frame) {
  // 에러 처리
  console.error('Broker reported error: ' + frame.headers['message']);
  console.error('Additional details: ' + frame.body);
};

// 연결 활성화
client.activate();
```

이 과정에서 일어나는 일:

1. WebSocket 연결 설정 (`ws://` 또는 `wss://` URL 사용)
2. CONNECT 프레임 전송 (인증 정보, 하트비트 설정 포함)
3. 서버로부터 CONNECTED 프레임 수신
4. 연결 콜백 함수 실행

### 메시지 송수신

```javascript
// 메시지 보내기
client.publish({
  destination: '/app/message',
  body: JSON.stringify({ content: 'Hello, world!' }),
  headers: { priority: 'high' }
});

// 메시지 받기 (구독)
const subscription = client.subscribe('/topic/messages', function(message) {
  // message.body로 메시지 내용 접근
  // message.headers로 헤더 접근
  console.log(`Received: ${message.body}`);
});

// 구독 취소
subscription.unsubscribe();
```

메시지 처리 과정:

1. 클라이언트가 SEND 프레임을 destination과 함께 전송
2. 서버가 메시지를 처리하고 관련 구독자에게 MESSAGE 프레임을 브로드캐스트
3. 클라이언트의 구독 콜백이 호출됨

## 3. 백엔드에서의 메시지 큐 활용

STOMP 서버(브로커)는 메시지를 대상(destination)에 따라 관리하는데, 이 과정에서 메시지 큐를 활용합니다.

### Spring Boot에서의 STOMP 구현

Spring Boot는 STOMP를 위한 간단한 내장형 브로커와 외부 브로커 연결을 모두 지원합니다.

#### 내장형 브로커 설정

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

  @Override
  public void configureMessageBroker(MessageBrokerRegistry config) {
    // 간단한 인메모리 브로커 설정
    config.enableSimpleBroker("/topic", "/queue");
    // 애플리케이션 목적지 접두사 설정
    config.setApplicationDestinationPrefixes("/app");
  }

  @Override
  public void registerStompEndpoints(StompEndpointRegistry registry) {
    // STOMP 웹소켓 엔드포인트 등록
    registry.addEndpoint("/ws")
            .setAllowedOrigins("*")
            .withSockJS(); // SockJS 폴백 지원
  }
}
```

이 설정은:

1. `/topic`과 `/queue` 접두사를 가진 메시지는 브로커가 처리
2. `/app` 접두사를 가진 메시지는 애플리케이션 메시지 핸들러로 라우팅됨

#### 컨트롤러에서 메시지 처리

```java
@Controller
public class MessageController {

  @MessageMapping("/send")
  @SendTo("/topic/messages")
  public OutputMessage processMessage(InputMessage message) {
    // 메시지 처리 로직
    return new OutputMessage(message.getContent());
  }
  
  // 특정 사용자에게 메시지 전송
  @Autowired
  private SimpMessagingTemplate messagingTemplate;
  
  @MessageMapping("/private")
  public void sendPrivateMessage(PrivateMessage message) {
    messagingTemplate.convertAndSendToUser(
      message.getRecipient(),
      "/queue/private",
      message
    );
  }
}
```

### 외부 메시지 브로커(RabbitMQ, ActiveMQ) 연동

대규모 애플리케이션의 경우 외부 메시지 브로커를 사용하는 것이 일반적입니다.

#### RabbitMQ와의 연동

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

  @Override
  public void configureMessageBroker(MessageBrokerRegistry registry) {
    // RabbitMQ 브로커 릴레이 설정
    registry.enableStompBrokerRelay("/topic", "/queue")
            .setRelayHost("localhost")
            .setRelayPort(61613)
            .setClientLogin("guest")
            .setClientPasscode("guest");
    
    registry.setApplicationDestinationPrefixes("/app");
  }
  
  @Override
  public void registerStompEndpoints(StompEndpointRegistry registry) {
    registry.addEndpoint("/ws").withSockJS();
  }
}
```

이 설정에서 Spring의 `StompBrokerRelayMessageHandler`는:

1. 시스템 레벨의 TCP 연결을 브로커와 유지
2. 각 WebSocket 클라이언트를 위한 별도의 TCP 연결을 생성
3. 메시지를 적절한 목적지로 릴레이

![메시지 흐름: 브로커 릴레이](https://docs.spring.io/spring-framework/reference/_images/message-flow-broker-relay.png)

## 4. 메시지 흐름 분석

STOMP 애플리케이션에서 메시지가 어떻게 흐르는지 살펴보겠습니다:

1. **클라이언트 연결**: 클라이언트가 WebSocket 연결을 맺고 STOMP 세션을 설정
    
2. **구독 과정**:
    
    ```
    SUBSCRIBE
    id:sub-1
    destination:/topic/messages
    
    ^@
    ```
    
3. **메시지 발행 과정**:
    
    ```
    SEND
    destination:/app/message
    content-type:application/json
    
    {"content":"Hello, world!"}^@
    ```
    
4. **서버에서 메시지 처리**:
    
    - `/app/message`로 들어온 메시지는 `@MessageMapping("/message")` 메소드로 라우팅
    - 컨트롤러에서 비즈니스 로직 처리 후 결과를 `/topic/messages`로 반환
5. **브로커의 메시지 배포**:
    
    - 브로커는 `/topic/messages`를 구독하는 모든 클라이언트에게 메시지 배포
    - 각 클라이언트는 메시지 콜백 함수를 통해 메시지 수신

## 5. 다양한 메시지 큐 시스템에서의 STOMP 활용

### RabbitMQ에서의 STOMP 처리

RabbitMQ는 STOMP 플러그인을 통해 프로토콜을 지원합니다.

```bash
# STOMP 플러그인 활성화
rabbitmq-plugins enable rabbitmq_stomp
rabbitmq-plugins enable rabbitmq_web_stomp
```

RabbitMQ에서 STOMP의 destination은 다음과 같이 매핑됩니다:

- `/exchange/<name>`: 임의의 라우팅 키와 바인딩 패턴 사용
- `/queue/<name>`: STOMP 게이트웨이에서 관리하는 큐
- `/amq/queue/<name>`: STOMP 게이트웨이 외부에서 생성된 큐
- `/topic/<name>`: 일시적이거나 지속적인 토픽
- `/temp-queue/`: 임시 큐(reply-to 헤더에서만 사용)

### ActiveMQ에서의 STOMP 활용

ActiveMQ는 기본적으로 STOMP 프로토콜을 지원하며, 다음과 같은 방식으로 destination을 매핑합니다:

- `/queue/...`: 큐 (point-to-point)
- `/topic/...`: 토픽 (pub-sub)
- `/temp-queue/...`: 임시 큐
- `/temp-topic/...`: 임시 토픽

ActiveMQ에서는 다음과 같이 지속성을 설정할 수 있습니다:

```
SEND
destination:/queue/test
persistent:true

Hello, persistent message!^@
```

## 6. 실제 구현 예시: Spring Boot + Stompjs

### 서버 측 코드 (Spring Boot)

```java
// 웹소켓 설정
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

  @Override
  public void configureMessageBroker(MessageBrokerRegistry config) {
    // RabbitMQ 브로커 릴레이 사용
    config.enableStompBrokerRelay("/topic", "/queue")
          .setRelayHost("localhost")
          .setRelayPort(61613)
          .setClientLogin("guest")
          .setClientPasscode("guest");
    
    config.setApplicationDestinationPrefixes("/app");
  }

  @Override
  public void registerStompEndpoints(StompEndpointRegistry registry) {
    registry.addEndpoint("/ws").withSockJS();
  }
}

// 메시지 컨트롤러
@Controller
public class ChatController {

  @MessageMapping("/chat.send")
  @SendTo("/topic/public")
  public ChatMessage send(ChatMessage chatMessage) {
    return new ChatMessage(
      chatMessage.getSender(),
      chatMessage.getContent(),
      LocalDateTime.now()
    );
  }
  
  @Autowired
  private SimpMessagingTemplate messagingTemplate;
  
  @MessageMapping("/chat.private")
  public void sendPrivate(PrivateMessage message) {
    messagingTemplate.convertAndSendToUser(
      message.getRecipient(),
      "/queue/private",
      message
    );
  }
}
```

### 클라이언트 측 코드 (JavaScript, Stompjs)

```javascript
// STOMP 클라이언트 설정
const client = new StompJs.Client({
  brokerURL: 'ws://localhost:8080/ws',
  debug: function (str) {
    console.log(str);
  },
  reconnectDelay: 5000
});

// 연결 성공 핸들러
client.onConnect = function (frame) {
  console.log('Connected: ' + frame);
  
  // 공개 주제 구독
  client.subscribe('/topic/public', function (message) {
    const chatMessage = JSON.parse(message.body);
    displayMessage(chatMessage);
  });
  
  // 개인 메시지 구독
  client.subscribe('/user/queue/private', function (message) {
    const privateMessage = JSON.parse(message.body);
    displayPrivateMessage(privateMessage);
  });
};

// 연결 오류 핸들러
client.onStompError = function (frame) {
  console.error('Broker reported error: ' + frame.headers['message']);
};

// 활성화
client.activate();

// 메시지 전송 함수
function sendMessage() {
  const message = {
    sender: username,
    content: document.getElementById('message').value
  };
  
  client.publish({
    destination: '/app/chat.send',
    body: JSON.stringify(message)
  });
}

// 개인 메시지 전송 함수
function sendPrivateMessage() {
  const recipient = document.getElementById('recipient').value;
  const message = {
    sender: username,
    recipient: recipient,
    content: document.getElementById('privateMessage').value
  };
  
  client.publish({
    destination: '/app/chat.private',
    body: JSON.stringify(message)
  });
}
```

## 7. STOMP 메시지 흐름 상세 분석

다음은 Spring Boot 기반 애플리케이션에서 STOMP 메시지가 어떻게 처리되는지 보여주는 흐름도입니다:

1. **클라이언트 요청**:
    
    - 클라이언트가 WebSocket을 통해 STOMP SEND 프레임 전송
    - 목적지: `/app/chat.send`
2. **메시지 수신 및 디코딩**:
    
    - Spring의 WebSocket 핸들러가 메시지 수신
    - STOMP 프레임으로 디코딩
    - Spring Message 형태로 변환
3. **메시지 라우팅**:
    
    - clientInboundChannel을 통해 메시지 전달
    - 목적지 접두사(`/app`)에 따라 핸들러 결정
    - 해당 @MessageMapping 메소드로 라우팅
4. **컨트롤러 처리**:
    
    - `ChatController.send()` 메소드 호출
    - 비즈니스 로직 처리
    - 결과 메시지 생성
5. **응답 메시지 라우팅**:
    
    - @SendTo 지정 목적지로 메시지 변환
    - 브로커 채널(brokerChannel)로 메시지 전송
6. **메시지 배포**:
    
    - 브로커가 `/topic/public` 구독자 식별
    - clientOutboundChannel을 통해 각 구독자에게 MESSAGE 프레임 전송
7. **클라이언트 수신**:
    
    - WebSocket을 통해 MESSAGE 프레임 수신
    - 구독 콜백 함수 호출
    - 메시지 처리 및 UI 업데이트

## 8. 외부 브로커와 내장 브로커의 차이점

### 내장 브로커 (Simple Broker)

- 메모리 기반 간단한 메시지 배포 시스템
- 별도 설치 필요 없음
- 단일 서버에서만 작동 (클러스터링 불가)
- 지속성, 고급 라우팅, 복잡한 큐 기능 제한적

```java
config.enableSimpleBroker("/topic", "/queue");
```

### 외부 브로커 (Broker Relay)

- RabbitMQ, ActiveMQ 등 외부 메시지 브로커와 연동
- 고가용성 및 클러스터링 지원
- 메시지 지속성 보장
- 복잡한 라우팅 규칙 및 고급 기능 지원
- 확장성 우수

```java
registry.enableStompBrokerRelay("/topic", "/queue")
        .setRelayHost("localhost")
        .setRelayPort(61613);
```

## 9. 메시지 큐 활용의 이점

### 비동기 처리

클라이언트와 서버 간의 통신이 비동기적으로 이루어져, 시스템 각 부분이 독립적으로 작동합니다.

```javascript
// 메시지 발행 (비동기)
client.publish({destination: '/app/process', body: JSON.stringify(data)});

// 다른 작업 수행 (블로킹 없음)
doOtherWork();
```

### 로드 밸런싱

여러 워커가 메시지 큐에서 작업을 가져가 처리할 수 있어 부하 분산이 가능합니다.

```java
// 여러 인스턴스에서 동일한 큐 구독
@JmsListener(destination = "processingQueue")
public void processMessage(Message message) {
    // 메시지 처리
}
```

### 내구성 및 신뢰성

메시지가 디스크에 저장되어 시스템 장애 시에도 손실되지 않습니다.

```
SEND
destination:/queue/important
persistent:true

Critical data that must not be lost!^@
```

### 서비스 간 결합도 감소

서비스들이 메시지 큐를 통해 소통하므로 직접적인 의존성이 줄어듭니다.

## 결론

Stompjs는 클라이언트에서 STOMP 프로토콜을 구현하여 WebSocket을 통해 메시지 브로커와 통신하는 라이브러리입니다. 백엔드에서는 Spring Boot와 같은 프레임워크가 STOMP 프로토콜을 처리하고, 내장 브로커 또는 RabbitMQ/ActiveMQ 같은 외부 메시지 큐 시스템과 연동하여 메시지를 관리합니다.

이러한 구조는 실시간 통신이 필요한 애플리케이션에서 확장성과 안정성을 제공하며, 비동기 처리를 통해 시스템 성능을 향상시킵니다. 특히 채팅, 알림, 실시간 대시보드 등의 애플리케이션에서 강력한 기능을 발휘합니다.

## 참고 자료

- STOMP 프로토콜 명세[1](https://stomp.github.io/)
- Spring Framework 문서[2](https://docs.spring.io/spring-framework/reference/web/websocket/stomp.html)
- Stompjs GitHub 저장소[3](https://github.com/stomp-js/stompjs)
- RabbitMQ STOMP 플러그인[4](https://www.rabbitmq.com/docs/stomp)
- ActiveMQ STOMP 지원[5](https://activemq.apache.org/components/classic/documentation/stomp)

---

## Appendix: Supplementary Video Resources

![youtube](https://i.ytimg.com/vi_webp/TywlS9iAZCM/maxresdefault.webp)![youtube|180](data:image/png;base64,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)

Spring boot & WebSockets: Build a Real-Time Chat App From ...

Jun 12, 2023

![youtube](https://i.ytimg.com/vi_webp/7-l-c0OdWYQ/maxresdefault.webp)![youtube](data:image/png;base64,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)

WebSocket, STOMP in Spring Boot 4 (stomp demo)

1 week ago

![youtube](https://i.ytimg.com/vi_webp/9UUi5s_hkBU/maxresdefault.webp)![youtube](data:image/png;base64,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)

[10분 테코톡] 트레의 스프링에서 STOMP로 채팅 구현하기