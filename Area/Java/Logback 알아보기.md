---
tags: java, logback
---

![Untitled](Untitled%2069.png)

복잡한 요구조건을 지닌 애플리케이션을 자바 스프링으로 개발을 진행하면서

로깅의 중요성에 대해서 뼈저리게 느끼게 되었네요.

차 후 프로젝트에는 로깅 라이브러리를 제대로 도입하자는 목표를 가지고 Log4j 와  Logback 에 대해 알게되었고, 기능이나 성능 면에서 Logback 이 더 괜찮은 것 같아 공식문서를 보면서 관련 내용을 정리하였습니다.

# Logback

`log4j` 의 후속 버전으로 `log4j` 에서 중단된 버전(1.x) 을 이어받아 개발되었습니다.

`logback-core`, `logback-classic`, `logback-access` 세 가지 모듈로 나뉘어있으며

`logback-core` 모듈은 다른 두 모듈을 기반으로 합니다.

`logback-classic` 은 기본적으로 SLF4J API 를 구현하므로 `logback` 과 `log4j` 또는  `java.util.logging` 과 같은 다른 다른 로깅 프레임워크로 쉽게 전환할 수 있습니다.

`logback-access` 모듈은 `Tomcat`, `Jetty` 와 같은 `Servlet Container` 와 통합되어 HTTP 접근 로그 기능을 제공합니다.

`logback-core` 위에 자체 모듈을 쉽게 구축할 수도 있다고 합니다.

# Log4j 에서 Logback 으로 전환해야하는 이유

log4j 말고 logback 을 사용해야하는 이유에 대한 내용이 공식문서에 작성되어 있었는데 흥미로워서 읽고 정리해보았습니다.

## 빠른 구현체

log4j 1.4 기반으로 내부를 재작성하여 특정 경로에서 약 10배 더 빠른 성능을 발휘하도록 하였습니다.

더 빠를 뿐만 아닌 메모리 사용량도 더 적습니다!

## configuration 파일 자동 로딩

Logback-classic 은 수정 시 config 파일을 자동으로 리로딩합니다.

스캔 프로세스는 빠르고 경합은 존재하지 않으며 초당 수백만 건 호출로 동적 확장이 가능합니다.

또한 스캔을 위한 별도의 스레드를 생성할 필요가 없기 때문에 애플리케이션 서버에서 더 잘 작동합니다.

## 신속한 I/O 작업 실패 복구

Logback 의 FileAppender 와 그 서브클래스는 I/O 장애로부터 정상적인 복구를 수행합니다.

그러므로 파일 서버에서 장애가 발생해도 애플리케이션을 재시작할 필요가 없습니다.

## 로그 파일 자동 압축 수행

[RollingFileAppender](https://logback.qos.ch/manual/appenders.html#RollingFileAppender) 가 보관된 로그 파일을 자동으로 압축하는 기능을 수행합니다.

압축은 항상 비동기로 동작하므로 대용량 로그 파일의 경우에도 압축이 진행되는 동안 애플리케이션은 차단되지 않습니다.

이외에 더 많은 내용은 [문서 참고](https://logback.qos.ch/reasonsToSwitch.html) 바랍니다.

# 간단한 사용 방법

```java
package chapters.introduction;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HelloWorld1 {

  public static void main(String[] args) {

    Logger logger = LoggerFactory.getLogger("chapters.introduction.HelloWorld1");
    logger.debug("Hello world.");

  }
}
```

`logback` 사용은 `org.slf4j`내에서 정의된 `Logger` 및 `LoggerFactory` 를 import 하는 것으로 시작됩니다.

대부분 로깅의 경우 `slf4j` 를 사용하여 `logback` 의 존재를 알 수 없게합니다.

위 예제의 경우 실행하면 다음이 출력됩니다.

```java
20:49:07.962 [main] DEBUG chapters.introduction.HelloWorld1 - Hello world.
```

# 조금 짚고 넘어가는 아키텍쳐

본 글에서는 로그백에 대한 상세한 내용을 모두 다루기보단 해당 라이브러리에 대해 간략하게 알아가고 사용하고자하기 때문에 아키텍처 부분만 간략히 정리 후 마치겠습니다.

---

`logback` 은 `Logger`, `Appender`, `Layout` 이 세 가지 주요 클래스를 기반으로 동작합니다.

해당 구성 요소들은 함께 동작하며 개발자가 메시지 유형 및 수준(level) 에 따라 메시지를 기록하고 런타임에 보내는 메시지를 제어할 수 있도록 해줍니다.

`Logger` 는 `logback-classic` 모듈의 일부이고, `Appender` 와 `Layout` 인터페이스는 `logback-core`의 일부입니다. 

### LoggerContext

해당 객체는 로거를 생성하고 트리 구조와 같은 자료구조에 로거를 배열하는 역할을 수행합니다.

이 기능을 수행함으로써 `System.out.println` 과 달리 특정 로그를 비활성화하고 다른 로그의 출력에 대해서는 방해받지 않고 출력할 수 있게 됩니다.

<aside>
💡 한 Logger 의 이름 뒤 온점으로 표시된 부분이 하위 Logger 이름의 접두사입니다.
부모와 자식 관계로 이해하면 쉽습니다.

</aside>

### Appender

logback 에서 출력 대상을 Appender 라고 합니다.

현재 `Appender` 는 `console`, `files`, `remote socket server`, `MySQL`, `PostgreSQL` 와 같은 RDB 시스템이 존재합니다.

### Layout

`Layout` 은 들어오는 이벤트를 `String` 으로 변환하는 어댑터 계층입니다.

`Layout` 인터페이스의 `format` 메서드는 이벤트를 나타내는 객체를 받아 `String` 으로 반환합니다.

다음 코드는 `Layout` 인터페이스 구조입니다.

```java
public interface Layout<E> extends ContextAware, LifeCycle {

  String doLayout(E event);
  String getFileHeader();
  String getPresentationHeader();
  String getFileFooter();
  String getPresentationFooter();
  String getContentType();
}
```

# 마치며

logback 에 존재에 대해 간략하게 정리하였고,

해당 라이브러리를 사용해야하는 이유와 대략적인 원리를 파악하였으니 앞으로 Spring 과 결합하여 적용해보고 배우게 된 점을 또 글로 남길 것 같습니다.

# Refrences

[로그백 아키텍처](https://logback.qos.ch/manual/architecture.html)