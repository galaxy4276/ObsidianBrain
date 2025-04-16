#web-rtc #media-soup
## 1. WebRTC 기본 개념 이해

WebRTC(Web Real-Time Communication)는 웹 브라우저와 모바일 애플리케이션이 별도의 플러그인이나 소프트웨어 설치 없이 실시간으로 음성, 비디오, 데이터를 주고받을 수 있게 해주는 오픈 소스 기술입니다.

### 1.1 WebRTC의 핵심 구성 요소

WebRTC는 다음과 같은 주요 구성 요소로 이루어져 있습니다:
- **MediaStream(getUserMedia)**: 카메라, 마이크 등 사용자의 장치에서 오디오 및 비디오 스트림에 접근합니다.
- **RTCPeerConnection**: 두 사용자 간의 안전한 P2P 연결을 설정하고 유지합니다.
- **RTCDataChannel**: 비디오와 오디오 외의 임의의 데이터 교환을 가능하게 합니다.

### 1.2 WebRTC 통신 흐름
WebRTC 통신 과정은 크게 다음 단계로 이루어집니다:
1. **Signaling**: 두 피어가 서로를 찾고 연결하기 위해 필요한 정보를 교환하는 과정
2. **ICE(Interactive Connectivity Establishment)**: 네트워크 장벽을 통과하여 최적의 연결 경로를 찾는 과정
3. **미디어 전송**: 실제 오디오, 비디오 및 데이터 전송이 이루어지는 과정

### 1.3 WebRTC의 장점
- **플러그인 불필요**: 웹 브라우저에 내장되어 있어 별도 설치가 필요 없음
- **낮은 지연시간**: 실시간 통신에 최적화된 낮은 지연시간 제공
- **보안**: 기본적으로 모든 통신이 암호화됨 (DTLS, SRTP)
- **적응형 비트레이트**: 네트워크 상황에 따라 자동으로 품질 조정

## 2. WebRTC 아키텍처 종류와 비교
WebRTC 구현에는 크게 세 가지 아키텍처 방식이 있습니다: Mesh(P2P), SFU, MCU. 각 방식은 서로 다른 장단점과 적합한 사용 사례를 가지고 있습니다.

### 2.1 Mesh(P2P) 방식
Mesh 방식은 중앙 서버 없이 모든 참여자가 서로에게 직접 연결되는 방식입니다.

**장점:**
- 서버 비용 최소화 (시그널링 서버만 필요)
- 실시간성 극대화 (중간 서버를 거치지 않음)
- 단순한 구현 방식

**단점:**
- 참여자 수 증가에 따라 연결 수가 기하급수적으로 증가 (n*(n-1)/2)
- 각 클라이언트의 네트워크 대역폭과 처리 성능에 크게 의존
- 일반적으로 4-5명 이상부터 성능 저하 발생

### 2.2 SFU(Selective Forwarding Unit) 방식

SFU는 미디어 서버가 각 참여자로부터 스트림을 받아 다른 참여자들에게 전달하는 방식입니다.

**장점:**

- 클라이언트의 부담 감소 (각 참여자는 하나의 업로드 스트림만 유지)
- 확장성 향상 (다수의 참여자 지원 가능)
- 실시간성 유지 (미디어 처리 과정 없음)

**단점:**

- 서버 인프라 필요 (시그널링 서버보다 비용 증가)
- 서버 성능과 네트워크 대역폭에 의존
- 참여자 수가 많을 경우 서버 부하 증가

### 2.3 MCU(Multipoint Control Unit) 방식

MCU는 모든 참여자의 미디어 스트림을 서버에서 혼합하여 단일 스트림으로 각 참여자에게 전송하는 방식입니다.

**장점:**

- 클라이언트 부담 최소화 (항상 하나의 스트림만 수신)
- 낮은 네트워크 대역폭 요구 (수신 스트림 수가 일정)
- 낮은 성능의 장치에서도 다수 참여자 지원 가능

**단점:**

- 서버 처리 부담 극대화 (트랜스코딩, 믹싱 등 고성능 요구)
- 실시간성 저하 (미디어 처리 지연 발생)
- 높은 서버 비용

### 2.4 아키텍처 비교 요약

|특성|Mesh(P2P)|SFU|MCU|
|---|---|---|---|
|실시간성|매우 높음|높음|중간|
|서버 비용|매우 낮음|중간|높음|
|클라이언트 부담|높음|중간|낮음|
|확장성|매우 낮음|중간~높음|높음|
|적합한 사용 사례|소규모 회의(~4명)|중규모 회의, 1:N 스트리밍|대규모 회의, 방송|

## 3. SFU(Selective Forwarding Unit) 심층 분석

### 3.1 SFU 작동 원리

SFU 아키텍처는 다음과 같은 방식으로 작동합니다:

1. 각 참여자는 자신의 미디어 스트림을 SFU 서버에 한 번만 전송합니다.
2. SFU 서버는 받은 스트림을 다른 모든 참여자에게 전달합니다.
3. 각 참여자는 SFU 서버로부터 다른 모든 참여자의 스트림을 개별적으로 수신합니다.

이 방식을 통해 각 참여자는 하나의 업로드 연결만 유지하면서도 여러 다운로드 연결을 통해 다른 참여자들의 스트림을 수신할 수 있습니다.

### 3.2 SFU의 주요 특징

- **선택적 전달**: SFU는 필요에 따라 특정 참여자에게만 스트림을 전달할 수 있어 효율성이 높습니다.
- **레이어드 인코딩 지원**: SVC(Scalable Video Coding) 및 Simulcast 기술을 통해 네트워크 상황에 따라 다양한 품질의 스트림을 제공할 수 있습니다.
- **대역폭 최적화**: 참여자별로 네트워크 상황에 맞춰 최적의 비디오 품질을 선택할 수 있습니다.

### 3.3 SFU의 성능 특성

연구 결과에 따르면 SFU 방식은 다음과 같은 성능 특성을 보입니다millo-l.github.io[1](https://millo-l.github.io/WebRTC-%EC%84%B1%EB%8A%A5%EB%B9%84%EA%B5%90-P2P-vs-SFU/):

- **클라이언트 CPU 사용률**: P2P 방식의 약 절반 수준 (8명 참여 시 P2P 80% vs SFU 30%)
- **서버 CPU 사용률**: 참여자 수에 따라 급증 (8명 참여 시 약 50%)
- **한계점**: 참여자가 6명 이상일 때 일부 영상의 실시간성이 저하되기 시작, 7명 이상에서는 영상이 일시적으로 멈추는 현상 발생

따라서 SFU는 다대다 회의보다는 소수의 발표자와 다수의 시청자가 참여하는 일대다 스트리밍 환경에 더 적합할 수 있습니다.

## 4. Mediasoup 소개 및 특징

### 4.1 Mediasoup이란?

Mediasoup은 Node.js 기반의 고성능 WebRTC SFU(Selective Forwarding Unit) 구현체로, 실시간 화상 회의 및 스트리밍을 위한 강력한 기능을 제공합니다.

### 4.2 Mediasoup의 주요 특징

Mediasoup은 다음과 같은 핵심 특징을 가지고 있습니다:

- **고성능 아키텍처**: C++로 구현된 미디어 처리 레이어와 Node.js 기반의 API 레이어로 구성되어 효율적인 성능을 제공합니다mediasoup.org[2](https://mediasoup.org/documentation/v3/mediasoup/design/).
- **다중 스트림 지원**: 단일 ICE + DTLS 전송을 통해 여러 오디오/비디오 스트림을 처리할 수 있습니다.
- **확장성**: 멀티코어 환경에서 워커 프로세스를 분산하여 높은 확장성을 제공합니다.
- **IPv6 지원**: 최신 네트워크 환경에 대응할 수 있습니다.
- **Simulcast 및 SVC 지원**: 네트워크 상황에 따라 적응적인 비디오 품질을 제공합니다.
- **혼잡 제어**: 네트워크 상황에 따른 자동 비트레이트 조정을 지원합니다.
- **대역폭 추정**: 송수신 대역폭을 추정하여 공간/시간 레이어 분배 알고리즘을 적용합니다.

### 4.3 Mediasoup의 기술적 이점

- **낮은 지연시간**: 실시간 통신에 최적화된 아키텍처로 지연시간을 최소화합니다.
- **높은 처리량**: C++ 기반의 미디어 워커를 통해 효율적인 처리량을 제공합니다.
- **유연한 API**: 확장 가능한 ECMAScript API를 통해 다양한 사용 사례에 맞춤 구현이 가능합니다.
- **모듈식 구조**: 독립적인 구성 요소로 설계되어 필요에 따라 확장 가능합니다.

## 5. Mediasoup 아키텍처 및 구성 요소

### 5.1 Mediasoup 아키텍처 개요

Mediasoup의 아키텍처는 크게 두 부분으로 나눌 수 있습니다:

1. **JavaScript API 레이어**: Node.js에서 실행되는 현대적인 ECMAScript API
2. **C/C++ 서브프로세스**: 미디어 레이어(ICE, DTLS, RTP 등)를 처리하는 고성능 컴포넌트

이 두 구성 요소는 프로세스 간 통신(IPC)을 통해 서로 연결됩니다.

![Mediasoup V3 Architecture Diagram](https://mediasoup.org/images/mediasoup-v3-architecture-01.svg)

### 5.2 Mediasoup의 주요 구성 요소

Mediasoup의 주요 구성 요소는 다음과 같습니다:

#### 5.2.1 Worker

- 미디어 처리를 담당하는 C++ 서브프로세스입니다.
- CPU 코어당 하나의 Worker를 생성하여 병렬 처리가 가능합니다.
- 여러 Router 인스턴스를 포함할 수 있습니다.

#### 5.2.2 Router

- WebRTC 통신의 중심 구성 요소입니다.
- 같은 Router 내의 Producer와 Consumer 간 미디어 패킷 라우팅을 담당합니다.
- 하나의 Router는 하나의 "방"(room)에 해당한다고 볼 수 있습니다.

#### 5.2.3 Transport

- 네트워크 연결을 추상화한 컴포넌트입니다.
- 클라이언트와 Router 간의 미디어 전송을 담당합니다.
- 주요 Transport 유형:
    - **WebRtcTransport**: WebRTC 엔드포인트와의 통신
    - **PlainTransport**: RTP/RTCP 엔드포인트와의 통신
    - **PipeTransport**: 다른 Router와의 통신

#### 5.2.4 Producer

- 미디어 스트림을 생성하는 엔티티입니다.
- Transport를 통해 Router로 미디어를 전송합니다.
- 오디오, 비디오 등 각각의 미디어 트랙마다 별도의 Producer가 생성됩니다.

#### 5.2.5 Consumer

- 미디어 스트림을 수신하는 엔티티입니다.
- Router로부터 Transport를 통해 미디어를 수신합니다.
- Producer의 미디어를 특정 참여자에게 전달하는 역할을 합니다.

#### 5.2.6 Device (클라이언트 측)

- 클라이언트 측에서 라우터와의 연결 및 미디어 전송을 관리하는 핵심 객체입니다.
- Router의 RTP 기능을 로드하고 송수신 Transport를 생성합니다.

### 5.3 Mediasoup의 데이터 흐름

1. 클라이언트는 미디어 서버의 Router와 WebRTC Transport를 설정합니다.
2. 미디어를 전송하려는 클라이언트는 Producer를 생성합니다.
3. Router는 생성된 Producer의 미디어를 수신하고, 해당 미디어를 받아야 하는 다른 클라이언트들을 위한 Consumer를 생성합니다.
4. 각 Consumer는 해당 클라이언트의 Transport를 통해 미디어를 전달합니다.

## 6. Mediasoup 설치 및 구현 방법

### 6.1 Mediasoup 설치 요구사항

Mediasoup을 설치하기 위해서는 다음 요구사항이 필요합니다mediasoup.org[3](https://mediasoup.org/documentation/v3/mediasoup/installation/):

**모든 플랫폼 공통:**

- Node.js 버전 >= v18.0.0
- Python 버전 >= 3.7 (with PIP)

**Linux, OSX 및 Unix 계열:**

- gcc 및 g++ >= 8 또는 clang (C++17 지원)
- cc 및 c++ 명령어가 gcc/g++ 또는 clang/clang++을 가리키도록 설정

**Windows:**

- C++17 지원이 가능한 Microsoft Visual Studio 환경(MSVC 컴파일러)
- ISRG Root X1 인증서 설치 필요

### 6.2 Mediasoup 서버 설치

서버 측 Mediasoup 설치는 다음과 같이 진행됩니다:

```bash
# Node.js 프로젝트 내에서 mediasoup 설치
npm install mediasoup@3
```

설치 과정에서 mediasoup-worker 바이너리가 자동으로 다운로드되거나 로컬에서 빌드됩니다. 특별한 환경 변수를 설정하여 설치 과정을 제어할 수 있습니다:

```bash
# 바이너리 다운로드 건너뛰고 로컬 빌드 강제
MEDIASOUP_SKIP_WORKER_PREBUILT_DOWNLOAD="true" npm install mediasoup@3

# 특정 경로의 mediasoup-worker 바이너리 사용
MEDIASOUP_WORKER_BIN="/home/xxx/src/foo/mediasoup-worker" npm install mediasoup@3
```

### 6.3 Mediasoup 클라이언트 설치

클라이언트 측 라이브러리 설치는 다음과 같이 진행됩니다:

```bash
# 클라이언트 애플리케이션에 mediasoup-client 설치
npm install mediasoup-client@3
```

### 6.4 기본 서버 구현

다음은 Mediasoup 서버의 기본 구현 예제입니다:

```javascript
const mediasoup = require('mediasoup');

// Worker 생성
const worker = await mediasoup.createWorker({
  logLevel: 'debug',
  logTags: ['info', 'ice', 'dtls', 'rtp', 'srtp', 'rtcp'],
  rtcMinPort: 10000,
  rtcMaxPort: 10100
});

// Router 생성
const router = await worker.createRouter({
  mediaCodecs: [
    {
      kind: 'audio',
      mimeType: 'audio/opus',
      clockRate: 48000,
      channels: 2
    },
    {
      kind: 'video',
      mimeType: 'video/VP8',
      clockRate: 90000
    }
  ]
});

// WebRTC Transport 생성
const webRtcTransport = await router.createWebRtcTransport({
  listenIps: [
    { ip: '0.0.0.0', announcedIp: '192.168.1.1' } // 실제 서버 IP로 변경
  ],
  enableUdp: true,
  enableTcp: true,
  preferUdp: true
});
```

### 6.5 기본 클라이언트 구현

다음은 Mediasoup 클라이언트의 기본 구현 예제입니다:

```javascript
import * as mediasoupClient from 'mediasoup-client';

// Device 객체 생성
const device = new mediasoupClient.Device();

// Router의 RTP 기능 로드
await device.load({ routerRtpCapabilities: routerRtpCapabilities });

// Send Transport 생성
const sendTransport = device.createSendTransport({
  id: transportInfo.id,
  iceParameters: transportInfo.iceParameters,
  iceCandidates: transportInfo.iceCandidates,
  dtlsParameters: transportInfo.dtlsParameters
});

// Transport 이벤트 핸들러 등록
sendTransport.on('connect', async ({ dtlsParameters }, callback, errback) => {
  try {
    // 서버에 연결 요청
    await signaling.transport.connect({
      transportId: sendTransport.id,
      dtlsParameters
    });
    
    callback();
  } catch (error) {
    errback(error);
  }
});

sendTransport.on('produce', async ({ kind, rtpParameters, appData }, callback, errback) => {
  try {
    // 서버에 Producer 생성 요청
    const { id } = await signaling.transport.produce({
      transportId: sendTransport.id,
      kind,
      rtpParameters,
      appData
    });
    
    callback({ id });
  } catch (error) {
    errback(error);
  }
});

// Producer 생성
const producer = await sendTransport.produce({
  track: mediaStream.getVideoTracks()[0],
  encodings: [
    { maxBitrate: 100000 },
    { maxBitrate: 300000 },
    { maxBitrate: 900000 }
  ],
  codecOptions: {
    videoGoogleStartBitrate: 1000
  }
});
```

### 6.6 연결 흐름 이해

Mediasoup을 사용한 전형적인 연결 흐름은 다음과 같습니다:

1. **서버 초기화**: Worker 및 Router 생성
2. **클라이언트 접속**: 클라이언트가 서버에 접속하여 RTP 기능 정보 교환
3. **Transport 설정**: 서버와 클라이언트 간 WebRTC Transport 설정
4. **미디어 송수신**: Producer 및 Consumer 생성을 통한 미디어 송수신
5. **리소스 관리**: 사용이 끝난 자원의 정리 및 해제

## 7. Mediasoup vs 다른 SFU 구현체 비교

### 7.1 주요 SFU 구현체 소개

WebRTC SFU 구현체는 다양한 옵션이 있으며, 각각 다른 특징과 장단점을 가지고 있습니다pinokio5600.tistory.com[4](https://pinokio5600.tistory.com/107):

1. **Mediasoup**: Node.js 기반의 고성능 저수준 SFU
2. **Janus**: C 기반의 SFU 및 MCU 기능을 모두 제공하는 멀티 플랫폼 미디어 서버
3. **Jitsi VideoBridge**: Java 기반의 실시간 비디오 회의에 최적화된 SFU
4. **Kurento**: C++ 기반의 SFU 및 MCU 기능을 모두 제공
5. **OpenVidu**: Kurento 기반의 Java 라이브러리로 개발자 친화적 API 제공
6. **Pion**: Go 기반의 경량화된 SFU
7. **Ant**: Java 기반의 클러스터링 및 확장 기능이 있는 SFU

### 7.2 기술적 특징 비교

|구현체|언어|특징|적합한 사용 사례|
|---|---|---|---|
|Mediasoup|Node.js & C++|고성능, 낮은 지연시간, 높은 처리량|대규모 비디오 회의, 커스텀 구현|
|Janus|C|다양한 플러그인, SFU/MCU 기능|범용 미디어 서버|
|Jitsi|Java|대규모 회의 최적화, 자동 포워딩|전용 회의 솔루션|
|Kurento|C++|강력한 미디어 처리 API|미디어 처리 기능이 필요한 경우|
|OpenVidu|Java|간편한 API, 빠른 개발|빠른 프로토타이핑, 소규모 프로젝트|
|Pion|Go|경량화, 최소 메모리 사용|리소스 제약 환경|
|Ant|Java|클러스터링, 확장성|엔터프라이즈급 대규모 배포|

### 7.3 성능 비교

다양한 SFU 구현체 간의 성능 비교 연구mediasoup.org[5](https://mediasoup.org/resources/CoSMo_ComparativeStudyOfWebrtcOpenSourceSfusForVideoConferencing.pdf)에 따르면 다음과 같은 결과가 나타났습니다:

- **지연시간**: 초기 연결 시 Mediasoup, Medooze, Jitsi는 20ms 미만의 낮은 지연시간을 보이는 반면, Janus는 61ms, Kurento는 500ms 이상의 지연시간을 보였습니다.
- **CPU 사용량**: Mediasoup은 다른 구현체에 비해 더 적은 CPU 리소스를 사용하는 경향이 있습니다. 특히 Kurento와 Janus에 비해 더 효율적입니다.
- **확장성**: Mediasoup은 높은 동시 연결 수를 처리하는 데 있어 좋은 성능을 보입니다.

### 7.4 Mediasoup의 차별화 포인트

Mediasoup의 주요 차별화 포인트는 다음과 같습니다:

- **모듈식 설계**: 독립적인 Node.js 모듈로 설계되어 기존 애플리케이션에 쉽게 통합할 수 있습니다.
- **C++/Node.js 하이브리드 아키텍처**: 고성능 C++ 코어와 사용하기 쉬운 Node.js API의 장점을 결합했습니다.
- **RTP 기능 중심 설계**: 다양한 미디어 코덱과 포맷을 유연하게 지원합니다.
- **최신 ECMAScript 지원**: 현대적인 JavaScript 개발 경험을 제공합니다.
- **활발한 개발 커뮤니티**: 지속적인 업데이트와 개선이 이루어지고 있습니다.

## 8. 성능 및 확장성 분석

### 8.1 Mediasoup의 성능 특성

Mediasoup은 다음과 같은 성능 특성을 보입니다:

- **처리량**: 고성능 C++ 미디어 워커를 통해 높은 처리량을 달성합니다.
- **지연시간**: 미디어 스트림을 단순 전달만 하기 때문에 낮은 지연시간을 유지합니다.
- **CPU 사용률**: 멀티코어 환경에서의 효율적인 자원 활용으로 CPU 사용률을 최적화합니다.

### 8.2 확장성 전략

Mediasoup을 사용한 대규모 시스템 구축을 위한 확장성 전략은 다음과 같습니다:

1. **워커 최적화**: CPU 코어당 하나의 Worker를 생성하여 병렬 처리 효율을 극대화합니다.
2. **분산 아키텍처**: 여러 서버에 Mediasoup 인스턴스를 분산하여 수평적 확장이 가능합니다.
3. **Router 간 연결**: PipeTransport를 통해 다른 Router 간의 미디어 전달이 가능하여 논리적 분리와 확장성을 지원합니다.
4. **리소스 관리**: 효율적인 자원 관리와 가비지 컬렉션을 통해 장기 실행 안정성을 확보합니다.

### 8.3 성능 최적화 팁

Mediasoup을 최적의 성능으로 운영하기 위한 팁은 다음과 같습니다:

- **적절한 Worker 수 설정**: 서버의 CPU 코어 수에 맞게 Worker를 설정합니다.
- **네트워크 최적화**: UDP 기반 통신을 선호하고, 필요한 경우에만 TCP 폴백을 사용합니다.
- **비디오 인코딩 최적화**: Simulcast와 SVC를 적절히 활용하여 네트워크 대역폭을 효율적으로 사용합니다.
- **메모리 관리**: 미사용 Producer 및 Consumer를 적시에 정리하여 메모리 누수를 방지합니다.
- **모니터링**: 시스템 성능을 지속적으로 모니터링하여 병목 현상을 식별하고 대응합니다.

## 9. 실제 구현 예제와 코드

### 9.1 기본 샘플 프로젝트 구조

Mediasoup을 활용한 기본적인 화상 회의 시스템의 프로젝트 구조는 다음과 같습니다:

```
mediasoup-sample/
├── server/
│   ├── index.js           # 서버 진입점
│   ├── config.js          # 설정 파일
│   ├── mediasoup/         # Mediasoup 관련 코드
│   │   ├── worker.js      # Worker 관리
│   │   ├── router.js      # Router 관리
│   │   └── transport.js   # Transport 관리
│   └── room/              # 방 관리 로직
│       ├── room.js        # 방 클래스
│       └── peer.js        # 피어 클래스
├── client/
│   ├── index.html         # 클라이언트 HTML
│   ├── index.js           # 클라이언트 진입점
│   └── mediasoup-client/  # 클라이언트 Mediasoup 관련 코드
│       ├── device.js      # Device 관리
│       ├── transport.js   # Transport 관리
│       └── media.js       # 미디어 처리
└── package.json           # 프로젝트 의존성
```

### 9.2 서버 측 핵심 구현

다음은 Mediasoup 서버의 핵심 구현 예제입니다:

```javascript
// server/mediasoup/worker.js
const mediasoup = require('mediasoup');
const os = require('os');

const numWorkers = Object.keys(os.cpus()).length;
const workers = [];
let nextWorkerIndex = 0;

module.exports = {
  async initializeWorkers() {
    for (let i = 0; i < numWorkers; i++) {
      const worker = await mediasoup.createWorker({
        logLevel: 'warn',
        rtcMinPort: 10000 + (i * 100),
        rtcMaxPort: 10099 + (i * 100)
      });
      
      worker.on('died', () => {
        console.error(`Worker died, exiting...`);
        process.exit(1);
      });
      
      workers.push(worker);
    }
    
    console.log(`Created ${workers.length} workers`);
  },
  
  getNextWorker() {
    const worker = workers[nextWorkerIndex];
    nextWorkerIndex = (nextWorkerIndex + 1) % workers.length;
    return worker;
  }
};

// server/room/room.js
class Room {
  constructor(roomId) {
    this.id = roomId;
    this.peers = new Map();
    this.router = null;
  }
  
  async initialize(worker, mediaCodecs) {
    this.router = await worker.createRouter({ mediaCodecs });
    return this.router;
  }
  
  addPeer(peer) {
    this.peers.set(peer.id, peer);
  }
  
  removePeer(peerId) {
    this.peers.delete(peerId);
  }
  
  getProducerListForPeer() {
    const producerList = [];
    
    this.peers.forEach(peer => {
      peer.producers.forEach(producer => {
        producerList.push({
          producer: producer,
          peerId: peer.id,
          producerId: producer.id
        });
      });
    });
    
    return producerList;
  }
}

module.exports = Room;
```

### 9.3 클라이언트 측 핵심 구현

다음은 Mediasoup 클라이언트의 핵심 구현 예제입니다:

```javascript
// client/mediasoup-client/device.js
import * as mediasoupClient from 'mediasoup-client';

class MediasoupDevice {
  constructor() {
    this.device = new mediasoupClient.Device();
    this.sendTransport = null;
    this.recvTransport = null;
  }
  
  async load(routerRtpCapabilities) {
    await this.device.load({ routerRtpCapabilities });
  }
  
  canProduce(kind) {
    return this.device.canProduce(kind);
  }
  
  async createSendTransport(transportOptions) {
    this.sendTransport = this.device.createSendTransport(transportOptions);
    
    this.sendTransport.on('connect', async ({ dtlsParameters }, callback, errback) => {
      try {
        await socket.request('connectTransport', {
          transportId: this.sendTransport.id,
          dtlsParameters
        });
        
        callback();
      } catch (error) {
        errback(error);
      }
    });
    
    this.sendTransport.on('produce', async ({ kind, rtpParameters, appData }, callback, errback) => {
      try {
        const { id } = await socket.request('produce', {
          transportId: this.sendTransport.id,
          kind,
          rtpParameters,
          appData
        });
        
        callback({ id });
      } catch (error) {
        errback(error);
      }
    });
    
    return this.sendTransport;
  }
  
  async createRecvTransport(transportOptions) {
    this.recvTransport = this.device.createRecvTransport(transportOptions);
    
    this.recvTransport.on('connect', async ({ dtlsParameters }, callback, errback) => {
      try {
        await socket.request('connectTransport', {
          transportId: this.recvTransport.id,
          dtlsParameters
        });
        
        callback();
      } catch (error) {
        errback(error);
      }
    });
    
    return this.recvTransport;
  }
}

export default MediasoupDevice;
```

### 9.4 완전한 예제 구현

더 완전한 예제 구현은 Dirvann/mediasoup-sfu-webrtc-video-rooms[6](https://github.com/Dirvann/mediasoup-sfu-webrtc-video-rooms)나 footniko/mediasoup-sample[7](https://github.com/footniko/mediasoup-sample)와 같은 GitHub 리포지토리에서 확인할 수 있습니다. 이러한 예제는 실제 사용 사례에 대한 참조 구현을 제공합니다.

## 10. 결론 및 권장 사항

### 10.1 WebRTC 아키텍처 선택 가이드

WebRTC 아키텍처 선택은 프로젝트의 요구 사항에 따라 달라집니다:

- **소규모 화상 회의(2-4명)**: Mesh(P2P) 방식이 간단하고 효율적입니다.
- **중규모 화상 회의(5-20명)**: SFU가 가장 적합한 선택입니다.
- **대규모 화상 회의(20명 이상)**: SFU 기반으로 분산 아키텍처를 고려하세요.
- **일대다 스트리밍**: SFU가 이상적인 선택입니다.
- **화면 공유 또는 발표**: SFU가 권장됩니다.
- **미디어 처리 필요(믹싱, 트랜스코딩)**: MCU를 고려하세요.

### 10.2 Mediasoup 적용을 위한 권장 사항

Mediasoup 적용을 위한 권장 사항은 다음과 같습니다:

1. **시스템 요구사항 확인**: 서버 환경이 Mediasoup의 요구사항을 충족하는지 확인하세요.
2. **네트워크 구성 최적화**: ICE/TURN 서버를 적절히 구성하여 NAT 통과 문제를 해결하세요.
3. **확장성 계획**: 초기부터 확장성을 고려한 아키텍처를 설계하세요.
4. **오류 처리**: 네트워크 불안정성과 연결 문제에 대한 강건한 오류 처리를 구현하세요.
5. **모니터링 및 로깅**: 성능 모니터링 및 문제 해결을 위한 로깅 시스템을 구축하세요.

### 10.3 향후 발전 방향

WebRTC와 SFU 기술의 향후 발전 방향은 다음과 같습니다:

1. **AV1 코덱 지원**: 더 효율적인 비디오 압축을 위한 AV1 코덱 지원 확대
2. **WebRTC-HTTP Ingestion Protocol(WHIP)**: 브로드캐스팅을 위한 표준화된 프로토콜
3. **WebTransport**: UDP 기반의 새로운 웹 전송 프로토콜 통합
4. **머신러닝 기반 최적화**: 네트워크 조건에 따른 지능적인 적응
5. **서버리스 SFU**: 클라우드 네이티브 환경에서의 자동 확장 가능한 SFU 구현

WebRTC와 Mediasoup와 같은 SFU 구현체는 실시간 통신의 미래를 형성하는 핵심 기술로, 화상 회의, 원격 교육, 원격 의료, 실시간 스트리밍 등 다양한 응용 분야에서 혁신을 주도할 것입니다.

---

## 참고 자료

- mediasoup 공식 문서[8](https://mediasoup.org/documentation/)
- WebRTC 구현 방식(Mesh/P2P, SFU, MCU)[9](https://millo-l.github.io/WebRTC-%EA%B5%AC%ED%98%84-%EB%B0%A9%EC%8B%9D-Mesh-SFU-MCU/)
- WebRTC 성능 비교(P2P vs SFU)[1](https://millo-l.github.io/WebRTC-%EC%84%B1%EB%8A%A5%EB%B9%84%EA%B5%90-P2P-vs-SFU/)
- MediaSoup을 사용해서 SFU방식으로 VideoChat 구현하기[10](https://stay-present.tistory.com/106)
- Comparative Study of WebRTC Open Source SFUs for Video Conferencing[5](https://mediasoup.org/resources/CoSMo_ComparativeStudyOfWebrtcOpenSourceSfusForVideoConferencing.pdf)
- GitHub - Dirvann/mediasoup-sfu-webrtc-video-rooms[6](https://github.com/Dirvann/mediasoup-sfu-webrtc-video-rooms)
- GitHub - footniko/mediasoup-sample[7](https://github.com/footniko/mediasoup-sample)

---

## Appendix: Supplementary Video Resources

![youtube](https://i.ytimg.com/vi_webp/DOe7GkQgwPo/maxresdefault.webp)![youtube](data:image/png;base64,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)

WebRTC: mediasoup (SFU) introduction - Part 1

Oct 11, 2021

![youtube](https://i.ytimg.com/vi_webp/FLxU6ftLJsE/maxresdefault.webp)![youtube](data:image/png;base64,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)

WebRTC: mediasoup (SFU) hands on - Part 2

Sep 14, 2021

![youtube](https://i.ytimg.com/vi/KSM1PKf4JOE/hqdefault.jpg)![youtube](data:image/png;base64,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)

Mediasoup Tutorial webrtc video call

Jun 13, 2021