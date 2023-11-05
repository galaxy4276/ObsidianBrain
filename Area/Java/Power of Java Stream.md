---
tags: java, java-stream
---
![[Pasted image 20231106012153.png]]

[Power Of Java Stream](https://medium.com/@AlexanderObregon/the-power-of-java-stream-api-d7c0ab7e4c5a)

> [!NOTE]
> 몇몇 키워드와 부분적인 내용만 정리

# Java Stream 소개
개발자가 데이터를 처리할 때 기능적 접근 방식을 수용하도록 장려하는 패러다임의 전환입니다. 
계속 진행하기 전에 이러한 API가 왜 필요했는지, 그리고 이 API가 Java 개발자의 컬렉션 작업 방식을 어떻게 근본적으로 변화시켰는지 이해하는 것이 중요합니다.

## 역사적 맥락
역사적으로 Java는 주로 명령형 프로그래밍 언어였습니다. 즉, 코더는 컴퓨터가 원하는 결과를 얻기 위해 수행해야 하는 각 단계를 명시적으로 설명합니다. 이 접근 방식은 직접적이지만, 특히 컬렉션에 대한 작업을 수행할 때 장황한 코드가 생성되는 경우가 많습니다.

Java 8 이전에는 컬렉션으로 작업하려면 일반적으로 for-루프, 이터레이터 또는 for-each 구문을 사용해야 했습니다. 이러한 방식은 장황할 뿐만 아니라 표현력도 부족하여 코드의 의도가 반복의 메커니즘에 묻히는 경우가 많았습니다.

## 함수형 프로그래밍의 부상

함수형 프로그래밍 언어와 패러다임의 인기가 높아짐에 따라 Java가 진화해야 할 필요성이 분명해졌습니다. 함수형 프로그래밍은 계산을 수학 함수의 평가로 표현하는 것을 강조하며 상태 또는 변경 가능한 데이터의 변경을 피합니다. 이 접근 방식은 보다 간결하고 예측 가능하며 유지 관리가 용이한 코드로 이어질 수 있습니다.

이러한 필요성에서 탄생한 Java의 Stream API는 전통적으로 필수적인 Java에 함수형 프로그래밍 패러다임을 결합하여 개발자가 보다 표현력 있고 간결한 방식으로 데이터를 처리할 수 있게 해줍니다.

## 스트림이란?
본질적으로 Java의 스트림은 병렬 또는 순차적으로 처리할 수 있는 요소의 시퀀스(일반적으로 컬렉션)를 나타냅니다. 
컬렉션과 달리 스트림은 데이터 구조가 아니라는 점에 유의하는 것이 중요합니다. 
**스트림은 데이터를 저장하지 않습니다.**
대신 데이터를 전달하여 데이터 소스에 대한 여러 연산을 정의할 수 있으며, 이러한 연산을 온디맨드 방식으로 최적화된 방식으로 계산할 수 있습니다.
스트림은 내부 반복은 반복 프로세스를 추상화하여 라이브러리가 제어하도록 함으로써 보다 최적화된 반복으로 이어질 수 있습니다.


# 유용한 스트림 예제들
## 필터링 및 매핑
```java
List<String> names = Arrays.asList("Alice", " Bob", "Charlie", " David");  
List<String> namesStartingWithA = names.stream()  
	.filter(n -> n.startsWith("A"))  
	.collect(Collectors.toList());

List<Integer> nameLengths = names.stream()  
	.map(String::length)  
	.collect(Collectors.toList());
```

## 집계
```java
String concatenatedNames = names.stream()  
	.reduce("", (name1, name2) -> name1 + " " + name2);
```


## 중복 제거
```java
List<Interer> numbers = Arrays.asList(1, 2, 2, 2, 3, 3, 3, 3, 4, 4);  
List<Integer> uniqueNumbers = numbers.stream()  
	.distinct()  
	.collect(Collectors.toList());
```

## 제한
```java
List<String> firstTwoNames = names.stream()  
	.limit(2)  
	.collect(Collectors.toList());
```

# 스트림의 지연 평가
지연 평가는 Java Stream API의 가장 강력하지만 직관적이지 않은 기능 중 하나입니다. 
이 기능의 중요성을 이해하려면 먼저 스트림 API에서 중간 작업과 터미널 작업의 차이점을 파악해야 합니다.

자바 스트림은 크게 두 가지 유형으로 분류됩니다.
#### 중간 연산(Intermediate Operations)
다른 스트림을 반환하고 스트림 파이프라인에 새 연산을 설정합니다.
예를 들면 `filter`, `map`, `sorted` 가 존재합니다.
#### 터미널 연산(Terminal Operations)
결과 또는 사이드 이펙트를 생성하여 스트림 파이프라인을 처리하게 만드는 연산입니다.
`collect`, `forEach`, `reduce` 등이 있습니다.

## 지연 평가의 힘
지연 평가는 꼭 필요할 때까지 실제 계산을 연기하는 것을 말합니다. 
스트림의 맥락에서 이는 중간 연산이 호출될 때 데이터를 처리하지 않는다는 것을 의미합니다.
대신 스트림 파이프라인에 새 작업을 설정하고 기다립니다. **실제 계산은 터미널 연산이 호출될 때만 발생합니다.**
> [!NOTE]
> 터미널 연산 직전에 평가가 지연된다는 점 중요

지연 평가의 이점은 다음과 같습니다.
#### 성능 최적화
데이터가 필요할 때까지 처리되지 않으므로 특히 연쇄 연산이 관련된 경우 불필요한 계산을 피할 수 있습니다.

### Short-Circuiting
findFirst 또는 anyMatch와 같은 일부 연산은 결과를 생성하기 위해 전체 데이터 집합을 처리할 필요가 없습니다. 지연 평가를 사용하면 결과가 발견되는 즉시 처리가 중지됩니다.

예를 들어 짝수를 필터링한 다음 5보다 큰 첫 번째 숫자를 찾는 스트림 파이프라인을 생각해 보겠습니다
```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);  
Optional<Integer> result = numbers.stream()  
	.filter(n -> n % 2 == 0)  
	.filter(n -> n > 5)  
	.findFirst();
```

**여기서 목록에 수백만 개의 숫자가 있더라도 스트림은 5보다 큰 첫 번째 짝수를 찾자마자 처리를 중지합니다. 
이는 중간 연산의 Lazy 특성과 findFirst의 단락 동작 때문입니다.**

# 무한 스트림(Infinite Streams)
지연 평가를 사용하면 무한 스트림으로 작업할 수도 있습니다. 
계산이 지연되기 때문에 스트림에서 수행하는 작업을 제한하기만 하면 무한 소스로 스트림을 정의하고도 문제가 발생하지 않습니다.

예를 들어 `Stream.iterate` 메서드를 사용하면 짝수 스트림을 무한히 생성할 수 있습니다
```java
Stream<Integer> infiniteEvens = Stream.iterate(0, n -> n + 2);
```

그러나 이 스트림에서 처음 10개의 짝수를 수집하려는 경우 전체 무한 소스를 처리하지 않고도 수집할 수 있습니다.

```java
List<Integer> firstTenEvens = infiniteEvens.limit(10).collect(Collectors.toList());
```

# 스트림을 사용한 병렬 처리
데이터에 대한 연산을 쉽게 병렬화할 수 있는 기능은 Java Stream API의 뛰어난 기능 중 하나입니다. 
멀티코어 프로세서의 가용성이 증가함에 따라 병렬 처리는 최신 하드웨어의 성능을 최대한 활용하는 데 매우 중요해졌습니다. 
다행히도 Stream API는 이러한 잠재력을 활용할 수 있는 직관적인 메커니즘을 제공합니다.

**병렬 스트림은 데이터를 여러 개의 청크로 분할하고 각 청크는 별도의 스레드에서 처리됩니다.** 
이러한 동시 처리는 특히 대용량 데이터 세트를 처리할 때 CPU를 사용하는 작업의 성능을 크게 향상시킬 수 있습니다.

> [!How to Create Pararell Streams?]
> 병렬 스트림을 만드는 것은 매우 간단합니다. 
`parallel()` 메서드를 사용하여 일반 스트림을 병렬 스트림으로 변환하거나 `parallelStream(`)을 사용하여 컬렉션에서 직접 생성할 수 있습니다:

```java
List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);  
  
// parallel() 사용  
Stream<Integer> parallelStream1 = numbers.stream().parallel();  
  
// parallelStream() 사용  
Stream<Integer> parallelStream2 = numbers.parallelStream();
```

## 병렬 스트림 주의사항
병렬 처리가 속도를 크게 향상시킬 수는 있지만, 만병통치약은 아닙니다.
몇 가지 고려 사항을 염두에 두어야 합니다:

### 오버헤드 발생
병렬 처리는 작업의 분해, 스레드 관리, 결과 조합으로 인해 오버헤드가 발생합니다. 
작은 데이터 집합이나 작업의 경우, 이러한 오버헤드가 이점을 능가하여 병렬 버전이 순차 버전보다 느려질 수 있습니다.

## 상태를 저장하는 연산의 경우
상태 저장 람다 표현식(호출 간에 상태를 유지하는 표현식)은 병렬 스트림에서 사용할 때 예측할 수 없는 결과를 초래할 수 있습니다. 
연산을 상태 비저장형으로 만들고 부작용이 없도록 하는 것이 가장 좋습니다.

## 순서 처리
병렬 처리는 특히 맵이나 필터와 같은 작업 중에 원본 데이터의 순서를 유지하지 못할 수 있습니다. 순서가 필수적인 경우, 순서를 유지하기 위해 추가 단계가 필요하므로 병렬 처리의 효율성이 떨어질 수 있습니다.

## 공유 데이터 구조 사용
변경 가능한 공유 데이터 구조를 사용하면 데이터가 손상되거나 동시성 문제가 발생할 수 있습니다. 동시 데이터 구조를 사용하거나 변경 가능한 데이터 공유를 아예 피하는 것이 좋습니다.


큰 목록에서 각 숫자의 제곱을 계산하려는 시나리오를 생각해 보세요
```java
List<Integer> numbers = /* ... a large list ... */;  
  
List<Integer> squares = numbers.parallelStream()  
	.map(n -> n * n)  
	.collect(Collectors.toList());
```

`parallelStream()`을 사용하기만 하면 작업이 자동으로 분할되어 동시에 처리되므로 특히 큰 목록의 경우 속도가 크게 향상될 수 있습니다.

# References
1. [Java Stream API Docs](https://docs.oracle.com/javase/8/docs/api/java/util/stream/Stream.html)
2. [Fork/Join](https://docs.oracle.com/javase/tutorial/essential/concurrency/forkjoin.html)
3. [Oracle Stream Tutorial](https://docs.oracle.com/javase/tutorial/collections/streams/index.html)