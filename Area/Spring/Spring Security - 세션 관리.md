---
tags: spring, spring-security, session
---
# 세션 관리 필터

Spring Security 5 는 사용자가 인증했는 지 여부를 감지하기 위해 `SessionManagementFilter에` 의존하고 [`SessionAnthenticationStrategy`](https://docs.spring.io/spring-security/site/docs/6.1.5/api/org/springframework/security/web/authentication/session/SessionAuthenticationStrategy.html) 를 호출해요.
이 구성의 문제점은 일반적인 설정에서 모든 요청에 대해 `HttpSession을` 읽어야 한다는 것을 의미하죠.

> [!Spring Security 6 는 다르다.]
> Spring Security 6 에서는 [SessionAuthenticationStrategy]() 를 호출하기 때문에 인증이 완료되는 시점을 감지할 필요가 없어요.
>  그러므로 모든 요청에 대해 `HttpSession` 을 읽을 필요가 없게됩니다.

# Spring Session Redis 는 어떻게 동작할까

`Spring Security` 의 `SecurityContextPersistenceFilter` 가 `SecurityContext` 를 `HttpSession` 에 저장하면 그 다음에 `Redis` 에도 동일하게 반영되요.
### SecurityContextHolder
지정된 SecurityContext를 현재 실행 스레드와 연관시킵니다.
이 클래스는 `SecurityContextHolderStrategy의` 인스턴스에 위임하는 일련의 정적 메서드를 제공합니다. 이 클래스의 목적은 주어진 JVM에 사용해야 하는 전략을 편리하게 지정하는 방법을 제공하는 것입니다.
이 클래스의 모든 것이 정적이므로 코드를 호출할 때 사용하기 쉽도록 하기 위해 이 설정은 JVM 전체에 적용됩니다.
어떤 전략을 사용해야 하는지 지정하려면 모드 설정을 제공해야 합니다. 
모드 설정은 정적 최종 필드로 정의된 세 가지 유효한 MODE_ 설정 중 하나이거나, 공용 무인수 생성자를 제공하는 `SecurityContextHolderStrategy의` 구체적인 구현에 대한 정규화된 클래스 이름입니다.
원하는 전략 모드 문자열을 지정하는 방법에는 두 가지가 있습니다. 
첫 번째는 SYSTEM_PROPERTY에 키가 지정된 시스템 속성을 통해 지정하는 것입니다. 
두 번째는 클래스를 사용하기 전에 `setStrategyName(String)`을 호출하는 것입니다. 두 가지 방법을 모두 사용하지 않으면 클래스는 기본적으로 이전 버전과 호환되고 JVM 비호환성이 적으며 서버에 적합한 `MODE_THREADLOCAL`을 사용합니다(반면 MODE_GLOBAL은 서버에 사용하기에 부적절합니다)
