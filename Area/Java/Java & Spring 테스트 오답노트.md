---
tags:
  - test
  - java
  - spring
---

# 실패하는 테스트는 왜그런것일까

테스트 커버리지에만 너무 집착한다.
	테스트가 주는 이점을 활용할 생각보다는 커버리지에 집중하게 되어 의미가 무색해진다.

테스트가 주는 신호를 캐치하지 못한다. 즉.. 개선해야할 코드를 개선하지 못해서 테스트 구현이 어려워지는 것
	특정 코드에 너무 의존적인 부분을 테스트가 알려주기도 한다. (JPA, Spring 에 의존적인 코드라던 지..)

#### 강의 중 배우는 Tip
Java Switch 문은 JDK 12 부터 lambda 연산을 수행할 수 있다.

```java
long answer = switch (operator) {  
	case "+" -> num1 + num2;  
	case "-" -> num1 - num2;  
	case "*" -> num1 * num2;  
	case "/" -> num1 / num2;  
	default -> throw new InvalidOperationException();  
};
```

[Java 13 스위치](https://catch-me-java.tistory.com/31)
# TDD

테스트 주도 개발 즉 개발 이전에 테스트를 먼저 작성하는 것
1. RED - 깨지는 테스트를 먼저 작성한다.
2. GRREN - 깨지는 테스트를 성공시킨다.
3. BLUE - 리팩토링을 수행한다.

즉 GREEN 까지 도달했으므로 리팩토링을 수행한 이후에 잘못된 리팩토링인 지 바로 인지할 수 있다
개발자가 저지리는 대표적인 실수를 사전에 방지해준다는 이점이 존재한다.

TDD는 What/Who Cycle 을 주도할 수 있게 끔 도와준다.

> [!What/Who 사이클]
> 객체 사이의 협력 관계를 설계하기 위해서는 먼저 어떤 행위(What)를 수행할 것인지를 결정한 후에 누가(who) 그 행위를 수행할 것인지를 결정해야한다는 것이다.
> 여기서 어떤 행위가 바로 메시지다. - 객체지향의 사실과 오해 -

