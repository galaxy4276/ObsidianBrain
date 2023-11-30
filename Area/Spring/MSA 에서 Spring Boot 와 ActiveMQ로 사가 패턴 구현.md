---
tags: saga-pattern, spring
---
![[Pasted image 20231130102725.png]]
# Saga Pattern
사가 패턴은 마이크로서비스 아키텍처 내에서 분산 트랜잭션을 관리하는데 사용되는 디자인 패턴입니다.
여러 마이크로서비스에서 데이터 일관성을 유지하는 데 따르는 복잡성과 문제를 해결하는 동시에 기존 분산 트랜잭션의 함정을 피할 수 있습니다.

사가 패턴에서는 글로벌 트랜잭션이 일련의 작은 로컬 트랜잭션으로 나뉘며, 각 트랜잭션은 특정 마이크로서비스와 연관이 있습니다.
**한 단계에서 트랜잭션 실패가 발생할 경우 이전 단계를 취소하는 보상 작업이 트리거되어 데이터 일관성을 보장합니다.**




# References
[마이크로서비스에서 Spring Boot 및 ActiveMQ로 사가 패턴 구현하기](https://jackynote.medium.com/implementing-the-saga-pattern-with-spring-boot-and-activemq-in-microservice-43742d7ca300)