---
tags: spring, spring-security, session
---
# 세션 관리 필터

Spring Security 5 는 사용자가 인증했는 지 여부를 감지하기 위해 `SessionManagementFilter에` 의존하고 [`SessionAnthenticationStrategy`](https://docs.spring.io/spring-security/site/docs/6.1.5/api/org/springframework/security/web/authentication/session/SessionAuthenticationStrategy.html) 를 호출해요.
이 구성의 문제점은 일반적인 설정에서 모든 요청에 대해 `HttpSession을` 읽어야 한다는 것을 의미하죠.

> [!Spring Security 6 는 다르다.]
> Spring Security 6 에서는 [SessionAuthenticationStrategy]() 를 호출하기 때문에 인증이 완료되는 시점을 감지할 필요가 없어요.
>  그러므로 모든 요청에 대해 `HttpSession` 을 읽을 필요가 없게됩니다.

