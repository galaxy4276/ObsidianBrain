![Untitled](Untitled%2034.png)

# 웹 소켓 핵심 포인트

- 웹 소켓은 본질적으로 양방향 통신입니다.
- 웹 소켓을 사용하여 개발된 연결은 참여자(클라이언트 또는 서버) 중 한 명이 연결을 닫을 때까지 지속됩니다.
- 웹 소켓은 HTTP 를 사용하여 연결을 시작합니다.

# 웹 소켓을 왜 사용할까?

웹소켓은 안정적이고 사용하기 쉬우며 실시간성이 요구되는 시스템에서 큰 역할을 합니다.

지속적으로 변화하는 데이터를 실시간으로 표시해야 하는 애플리케이션에서 작업하고 있다고 가정해 보겠습니다. 

가장 먼저 웹 소켓을 구현해야 합니다. 

다른 방법도 있지만 서버의 오버헤드가 증가하므로 결국 다른 신뢰할 수 있는 방법을 찾아야 합니다.

따라서 이러한 오버헤드를 줄이기 위해 웹소켓을 선택 사항으로 고려할 수 있습니다.

> **실시간을 요구하는 시스템에서 오버헤드를 줄이기 위한 선택사항임**
> 

![클라이언트와 서버 간의 핸드셰이크가 설정되면 연결이 끊어질 때까지 연결이 지속됩니다(웹소켓).](Untitled%2035.png)

클라이언트와 서버 간의 핸드셰이크가 설정되면 연결이 끊어질 때까지 연결이 지속됩니다(웹소켓).

# 웹 소켓 작동방식

웹소켓은 클라이언트와 서버 간의 연결을 통해 작동합니다. 

연결을 시작하기 위해 클라이언트는 업그레이드 헤더가 포함된 http GET 요청을 보내면 서버는 이것이 업그레이드 요청임을 알고 서버가 업그레이드 속성을 지원하는 경우 상태 101로 응답하고 지원하지 않는 경우 오류 코드를 반환합니다.

서버에서 101 이외의 코드가 반환되면 클라이언트는 연결을 종료해야 합니다.

<aside>
💡 **[101 Switching Protocols](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/101)**

</aside>

```bash
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
```

웹소켓은 클라이언트와 서버를 한 번만 연결하므로 통신할 때마다 서버와 핸드셰이크를 해야 하는 오버헤드가 없다는 점이 고려됩니다.

## 연결 설정(Connection Setup)

연결 설정은 클라이언트에서 핸드셰이크를 요청하는 것으로 시작됩니다.

![Untitled](Untitled%2036.png)

웹소켓 연결을 생성하고 싶다는 것을 서버에 알리기 위해 클라이언트가 보내야 하는 특정 헤더가 있습니다. 

요청은 **http GET 메서드를 사용**하여 이루어집니다.

```bash
GET /chat HTTP/1.1
Host: server.example.com
Upgrade: websocket       
Connection: Upgrade        
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==        
Origin: http://example.com        
Sec-WebSocket-Protocol: chat, superchat        
Sec-WebSocket-Version: 13
```

**Sec-WebSocket-Key**: 16바이트 값을 무작위로 선택하여 생성되는 Base64 인코딩 값입니다.

**Sec-Websocket-Protocol**: 클라이언트가 사용할 프로토콜을 지정하기 위해 전송합니다. (선택 사항)

**Sec-WebSocket-Version:** 클라이언트가 허용할 수 있는 하위 프로토콜(웹 소켓 프로토콜 위에 계층화된 애플리케이션 수준 프로토콜)을 나타내기 위해 전송됩니다(선택 사항).

다음 요청을 받으면 서버는 다음 작업을 수행합니다.

- 핸드셰이크가 수신되었음을 증명하기 위해 요청 헤더에서 Sec-WebSocket-key를 가져와서 전역 고유 식별자와 결합하고 이 연결 문자열의 SHA-1 해시를 생성해야 합니다.

그런 다음 base64를 사용하여 해당 문자열을 인코딩하고 서버 핸드셰이크로 반환합니다.

```bash
HTTP/1.1 101 Switching Protocols
        Upgrade: websocket
        Connection: Upgrade
        Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
        Sec-WebSocket-Protocol: chat
```

101 상태 코드로 응답하며, 101 이외의 코드는 오류를 의미하며 웹소켓 핸드셰이크가 완료되지 않았음을 의미합니다.

**Sec-WebSocket-Accept:** 서버가 연결 요청을 수락할지 여부를 나타냅니다. 이 필드가 있는 경우 이 필드에는 Sec-WebSocket-키와 전역 고유 식별자를 결합한 base64 인코딩 해시가 포함됩니다.

**Sec-WebSocket-Protocol:** 선택적 필드로, 서버가 통신을 위해 선택한 프로토콜을 나타냅니다.

이러한 필드는 스크립팅된 페이지에 대해 WebSocket 클라이언트에서 확인하며, Sec-WebSocket-Accept 값이 예상 값과 일치하지 않거나 헤더 필드가 누락되거나 HTTP 상태 코드가 101이 아닌 경우 연결이 설정되지 않고 WebSocket 프레임이 전송되지 않습니다.

## 웹 소켓의 기본 URL 형식

```bash
ws-URI = "ws:" "//" host [ ":" port ] path [ "?" query ]
wss-URI = "wss:" "//" host [ ":" port ] path [ "?" query ]
```

wss 는 보안 프로토콜이므로 보안 통신을 위해 서버와 클라이언트 간에 TLS 핸드셰이크가 수행됩니다.

# 웹 소켓 구조

![웹소켓 프레임](Untitled%2037.png)

웹소켓 프레임

웹소켓의 **프레임**은 **클라이언트와 서버 간에 교환되는 데이터의 기본 단위**입니다.

웹소켓 프로토콜에서 데이터는 일련의 프레임을 사용하여 전송됩니다. 

클라이언트는 프레임을 서버로 보내기 전에 마스킹해야 하며, 마스킹되지 않은 프레임이 서버에 수신되면 서버는 연결을 닫아야 합니다.

**FIN (1비트) -** 메시지의 마지막 조각인지 여부를 나타냅니다. 값 1은 True를 나타냅니다. 첫 번째 조각이 최종 조각일 수도 있습니다.

**RSV1, RSV2, RSV3(각 1비트)** - 0 값이어야 합니다. 0이 아닌 값인 경우 0이 아닌 값의 의미를 정의하는 확장자를 정의해야 합니다.

**Opcode(4비트)** - 페이로드 데이터를 정의하며, 다음 값 중 하나를 가져야 합니다.

```bash
*  %x0 denotes a continuation frame
*  %x1 denotes a text frame
*  %x2 denotes a binary frame
*  %x3-7 are reserved for further non-control frames
*  %x8 denotes a connection close
*  %x9 denotes a ping
*  %xA denotes a pong
*  %xB-F are reserved for further control frames
```

**Mask (1비트)** - 마킹 사용 여부를 정의하며, 1로 설정하면 마스킹 키도 정의해야 합니다. "페이로드 데이터"의 마스킹을 해제하는 데 사용되며, 모든 클라이언트는 마크 값을 1로 보내고 마스킹 키도 함께 보내야 합니다.

**Masking-Key(0 또는 4바이트)** - 클라이언트에서 전송되는 모든 프레임은 이 키를 사용하여 마스킹됩니다. 마스킹 키는 32비트 값입니다.

**Payload length(7비트, 16비트, 64비트):** 0-125이면 페이로드 길이입니다. 

126이면 16비트 부호 없는 정수로 해석되는 다음 2바이트가 페이로드 길이입니다. 

127이면 64비트 부호 없는 정수로 해석된 다음 8바이트(가장 큰 비트는 0이어야 함)가 페이로드 길이입니다.

**Payload Data** - "페이로드 데이터"는 "애플리케이션 데이터"와 연결된 "확장 데이터"로 정의됩니다.

# Fragments

WebSocket에서 메시지를 보낼 때, 특히 메시지가 크거나 복잡한 경우 메시지가 여러 프레임으로 분할되는 것이 일반적입니다. 

이때 `조각(Fragment)`이 필요합니다.

`조각(Fragment)`을 사용하면 **메시지를 더 작은 조각으로 분할할 수 있으며, 각 조각은 별도의 프레임으로 전송됩니다.**

메시지가 조각으로 분할되면 각 조각은 **시퀀스의 마지막 프레임을 제외한 모든 프레임에 대해 FIN 비트가 0으로 설정된 상태로 전송**됩니다. FIN 비트는 현재 프레임이 메시지의 마지막 프레임인지 아니면 더 많은 프레임이 뒤따를 것인지를 나타냅니다.

**FIN 비트가 0으로 설정되어 있으면 더 많은 프레임이 오고 있으며 수신자는 메시지를 처리하기 전에 추가 프레임을 계속 기다려야 함을 의미합니다.**

메시지의 마지막 조각이 전송되면 FIN 비트가 1로 설정된 상태로 전송됩니다. 이는 수신자에게 이것이 메시지의 마지막 프레임임을 알리는 신호입니다.

# References

[Understanding Websockets In depth](https://vishalrana9915.medium.com/understanding-websockets-in-depth-6eb07ab298b3)