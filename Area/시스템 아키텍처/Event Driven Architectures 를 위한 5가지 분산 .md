---
tags: event-driven, architecture
---
# Pub/Sub Pattern

Publisher/Subscriber Pattern 

해당 패턴은 이벤트 기반 설계 및 분산 시스템에서 사용되는 *`메시징 패턴`입니다.

<aside>
💡 **메시징 패턴?**
이 패턴은 비동기 폴링 모델을 사용하여 마이크로서비스 간에 비동기 통신을 제공합니다.
백엔드 시스템이 호출을 받으면 요청 식별자로 즉시 응답한 다음 요청을 비동기적으로 처리합니다. 느슨하게 결합된 아키텍처를 구축할 수 있으므로 동기 통신, 지연 시간 및 입출력 작업 (IO) 으로 인한 병목 현상을 피할 수 있습니다. [**- AWS 메시징 패턴 분리 -**](https://docs.aws.amazon.com/ko_kr/prescriptive-guidance/latest/modernization-integrating-microservices/decouple-messaging.html)

</aside>

해당 패턴은 게시자(Publisher) 와 구독자(Subscriber) 두 가지 구성 요소가 포함되며 특징은 다음과 같습니다.

### Publisher

메시지 또는 이벤트를 생성하고 발송하는 구성 요소입니다.

퍼블리셔는 특정 수신자에게 직접 메시지를 보내지 않습니다. 대신 구독자가 메시지를 수신할 지 여부를 알 수 없는 상태에서 메시지를 주제별로 분류합니다.

### Subscriber

메시지를 수신하고 처리하는 요소입니다.

하나 이상의 주제에 관심을 표명하고 어떤 퍼블리셔가 있는 지 알지 못한 채 관심 있는 메시지만 수신합니다.

### Message Broker 또는 Event Channel

![Event Broker](Untitled%2070.png)

Event Broker

퍼블리셔에게 이벤트를 배포하는 중개자입니다.

퍼블리셔와 구독자 간의 연결을 관리하고 이벤트를 적절하게 라우팅합니다.

Pub/Sub 패턴의 주요 특징은 **퍼블리셔와 구독자의 분리**입니다.

퍼블리셔와 구독자는 서로를 알 필요가 없으며 그저 이벤트 채널이나 메시지 브로커를 통해 메시지를 주고받기만 하면 됩니다.

이러한 분리를 통해 시스템 설계에서 확장성과 *`적응성`을 높일 수 있습니다.

<aside>
💡 **적응성?**
시스템의 변화에 대응하고 조정할 수 있는 능력을 의미합니다.

</aside>

대중적인 Pub/Sub 패턴의 구현으로는 Google 의 Cloud Pub/Sub, AWS SNS, RabbitMQ 및 Apache Kafka 등이 존재합니다.

# Event Streaming Pattern

이벤트 스트리밍 패턴은 분산 시스템과 이벤트 중심 아키텍처에서 자주 사용되는 디자인 패턴입니다. 

본질적으로 다양한 이벤트 생산자에서 소비자로 이벤트를 지속적으로 생성, 처리 및 전송하는 것을 포함합니다.

### Event Producers

이벤트의 소스입니다.

스트림의 일부가 되는 데이터를 생성합니다. 

웹 앱에서의 사용자 상호 작용부터 IoT 디바이스의 데이터에 이르기까지 모든 것이 여기에 해당합니다.

### Event Streams

이벤트 프로듀서가 생성한 이벤트의 시퀀스입니다. 

각 이벤트는 일반적으로 시스템의 상태 변화를 나타내는 독립된 데이터 조각입니다.

### Event Consumers

이벤트를 소비하는 서비스 또는 시스템입니다. 

스트림을 구독하고 수신한 이벤트에 따라 작업을 수행합니다.

### Event Storages

이벤트 스트림이 저장되는 곳으로, 이벤트가 생성되는 순서대로 저장되는 경우가 많습니다. 

저장된 스트림은 실시간 처리(소비자가 들어오는 이벤트에 즉시 반응) 또는 기록 분석에 사용할 수 있습니다.

이벤트 스트리밍을 구현하기 위해 Apache Kafka, Amazon Kinesis 또는 Google Cloud Pub/Sub 과 같은 플랫폼이 자주 사용됩니다.

해당 패턴을 사용함으로써 얻는 주요 이점은 다음과 같습니다.

**실시간 처리**: 이벤트가 도착하는 즉시 처리되므로 시스템이 실시간으로 이벤트에 응답할 수 있습니다.

**확장성**: 이 패턴은 대량의 이벤트를 처리할 수 있으므로 대규모의 복잡한 시스템에 적합합니다.

**느슨한 결합**: 이벤트 생산자와 소비자가 분리되어 있어 한 쪽이 변경되더라도 다른 쪽이 변경될 필요가 없습니다.

**복원력**: 이벤트가 저장되므로 소비자가 처음에 실패하더라도 다시 처리할 수 있습니다.

**감사 가능성**: 모든 변경 사항이 일련의 이벤트로 기록되므로 작업 이력을 감사할 수 있습니다.

그러나 이벤트 스트리밍이 모든 사용 사례, 특히 **항상 데이터 일관성이 중요하거나 트랜잭션 요구 사항이 엄격한 경우**에 적합하지 않을 수 있다는 점에 유의할 필요가 있습니다.

이러한 경우에는 기존 데이터베이스 아키텍처가 더 적합할 수 있습니다.

# Event Sourcing Pattern

![Untitled](Untitled%2071.png)

애플리케이션 데이터의 모든 상태 변경을 단순히 데이터베이스의 데이터를 덮어쓰는 것이 아니라 정렬된 시퀀스의 고유 이벤트로 저장하도록 지시하는 디자인 패턴입니다.

## 이벤트 소싱(Event Sourcing) 개념

이벤트 소싱은 데이터 저장 방법에 대한 것입니다.

평소에 우리는 어떠한 로직을 처리하고, 결과 값만을 저장해왔지만 **이벤트 소싱은 순차적으로 발생하는 이벤트를 모두 저장**합니다.

## 구성 요소

구성요소에 대해 소개하겠습니다.

### Events

이벤트 소싱 패턴의 기본 구성 요소입니다. 각 이벤트는 애플리케이션 데이터의 변경 사항을 나타냅니다. 

이러한 이벤트는 발생하는 순서대로 저장되어 시스템 상태에 대한 모든 변경 사항에 대한 포괄적인 로그를 생성합니다.

### Event Store

모든 이벤트를 기록하는 데이터 저장소입니다. 

각 이벤트는 이벤트 스토어에 추가되며 수정하거나 삭제할 수 없으므로 이벤트 로그의 불변성을 보장합니다.

### Replayability

모든 상태 변경 사항이 기록되므로 이벤트를 재생하여 특정 시점의 시스템 상태를 재현할 수 있습니다. 

이를 통해 문제를 디버깅하거나 감사를 수행하거나 변경 사항을 롤백하는 데 사용할 수 있습니다.

### Snapshotting

특정 시점의 상태를 빠르게 재현하기 위해 스냅샷을 사용할 수 있습니다. 

<aside>
💡 스냅샷은 특정 시점의 시스템 상태를 저장합니다.

</aside>

시스템을 다시 만들어야 하는 경우 스냅샷에서 시작한 다음 스냅샷을 만든 이후에 발생한 이벤트만 재생할 수 있습니다.

이벤트 소싱 패턴은 다음과 같은 이점을 제공합니다.

**감사 가능성 및 추적 가능성**: 이벤트 로그는 애플리케이션에서 수행된 모든 작업을 완벽하게 추적할 수 있는 감사 추적 역할을 합니다.

**시간적 쿼리**: 특정 시점에 애플리케이션의 상태를 쿼리할 수 있습니다.

**이벤트 재생**: 필요에 따라 시스템 상태를 재현할 수 있어 문제 디버깅에 매우 유용할 수 있습니다.

그러나 이벤트 소싱은 애플리케이션에 복잡성을 더할 수 있으며 모든 사용 사례에 적합하지 않을 수도 있습니다. 

추가 스토리지 필요, 데이터 처리량 증가, 이벤트 스키마 관리 및 유지 관리의 필요성은 모두 이 패턴을 사용할지 여부를 결정할 때 고려해야 할 중요한 요소입니다.

# ****Backpressure Pattern****

백프레셔 패턴은 다양한 시스템과 프로토콜에서 **부하 시 안정성을 보장하기 위해** 사용되는 설계 원칙입니다. 

백프레셔 패턴은 **시스템 과부하를 방지하기 위해 시스템 구성 요소 간의 데이터 흐름 속도를 제어**해야 하는 네트워킹, 스트리밍 데이터 처리 및 이와 유사한 시나리오에서 자주 활용됩니다.

<aside>
💡 백프레셔 패턴은 일반적으로 **빠른 구성 요소(생산자)에서 느린 구성 요소(소비자)로 데이터가 전달되는 시나리오에서 사용됩니다.** 백프레셔가 없으면 느린 구성 요소가 데이터에 압도되어 **리소스 경색, 성능 저하, 잠재적인 시스템 장애를 초래할 수 있습니다.**

</aside>

작동하는 방식은 소비자가 생산자에게 **현재 용량에 대해 신호를 보낼 수 있는 메커니즘을 제공**하는 것입니다. 

이 신호는 소비자가 생산자에게 부하에 대한 피드백을 보내는 명시적 신호일 수도 있고, 소비자의 확인이 없으면 과부하의 신호로 간주하는 암시적 신호일 수도 있습니다.

다음은 `배압(Backpressure)` 를 적용하는 두 가지 전략입니다.

### Buffering

들어오는 데이터를 처리할 수 있을 때까지 저장하는 버퍼를 유지합니다. 

버퍼가 가득 차면 생산자는 데이터 생성 속도를 늦추거나 일시 중지하라는 지시를 받습니다.

### Dropping

경우에 따라, 특히 실시간 데이터가 관련된 경우, 오래되었거나 덜 중요한 데이터가 삭제될 수 있습니다.

 소비자가 더 이상 버퍼링할 수 없는 경우, 시스템은 더 많은 데이터를 버퍼링하는 대신 들어오는 데이터 중 일부를 삭제합니다.

배압의 목표는 부하 급증을 원활하게 처리하고 치명적인 장애를 피할 수 있는 복원력 있는 시스템을 만드는 것입니다.

이를테면 비디오 스트리밍, 실시간 데이터 처리 또는 고부하 웹 서버와 같은 데이터 집약적인 실시간 시스템에서 널리 사용됩니다.

<aside>
💡 Akka, Java의 리액티브 스트림, Node.js 스트림과 같은 플랫폼은 백프레셔 메커니즘을 사용합니다.

</aside>

# Saga Pattern

사가 패턴은 마이크로서비스 아키텍처의 디자인 패턴으로, 여러 서비스에 걸친 분산 트랜잭션을 구현하는 메커니즘을 제공합니다.

가 패턴의 주요 목적은 분산 트랜잭션을 분리된 비동기식 내결함성 방식으로 관리해야 하는 시나리오에서 **서비스 간에 데이터 일관성을 보장**하는 것입니다.

### 작동 방식에 대한 간략 개요

1. **Local Transactions**
    
    각 사가는 로컬 트랜잭션의 시퀀스입니다. 
    
    각 로컬 트랜잭션은 데이터베이스를 업데이트한 다음 이벤트를 게시하여 사가의 다음 로컬 트랜잭션을 트리거합니다.
    
2. **Compensating Transactions**
    
    각 로컬 트랜잭션에는 로컬 트랜잭션에서 변경된 내용을 취소하는 상응하는 보상 트랜잭션이 있습니다.
    
3. **Coordinator**
    
    사가에는 의사 결정 과정을 중앙 집중화하는 코디네이터가 있습니다. 
    
    로컬 트랜잭션이 완료되지 않으면 코디네이터가 보정 트랜잭션을 실행하여 데이터 일관성을 유지합니다.
    

예를 들어 이커머스 애플리케이션을 위한 마이크로서비스 아키텍처가 있다고 가정해 보겠습니다.

고객이 주문을 하면 주문 서비스, 고객 서비스, 인벤토리 서비스의 세 가지 서비스가 포함됩니다. 

이러한 서비스는 주문을 완료하기 위해 다음과 같은 작업이 함께 동작해야 합니다.

![Untitled](Untitled%2072.png)

- 주문 서비스는 로컬 트랜잭션을 시작하여 주문을 생성함으로써 사가를 시작합니다.
- 고객 서비스는 고객의 신용 한도를 감소시킵니다.
- 인벤토리 서비스는 인벤토리를 감소시킵니다.

이러한 단계 중 하나라도 실패하면 사가는 보상 거래를 시작하여 이전 단계를 취소하고 데이터 일관성을 유지합니다. 

<aside>
💡 예를 들어, 재고 서비스에서 품목이 품절된 것을 발견하면 보상 거래를 시작하여 고객의 신용 한도를 늘리고 주문을 취소합니다.

</aside>

# References

****[이벤트 소싱 event-sourcing 패턴 정리](https://edykim.com/ko/post/eventsourcing-pattern-cleanup/)****

****[이벤트 소싱(Event Sourcing) 개념](https://mjspring.medium.com/%EC%9D%B4%EB%B2%A4%ED%8A%B8-%EC%86%8C%EC%8B%B1-event-sourcing-%EA%B0%9C%EB%85%90-50029f50f78c)****

****[5 Must-Know Distributed Systems Design Patterns for Event-Driven Architectures](https://levelup.gitconnected.com/stay-ahead-of-the-curve-5-must-know-distributed-systems-design-patterns-for-event-driven-7515121a28ae)****