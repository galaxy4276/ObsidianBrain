#java #java-stream 
## 자바 스트림의 숨겨진 보물들
자바 스트림은 보물 상자와 같다 - 대부분의 개발자들은 표면만 긁을 뿐이다. 하지만 코드를 더 깔끔하고, 빠르고, 우아하게 만들어주는 숨겨진 보석들이 있다면 어떨까? 준비하라 - 깊이 파고들어보자!
## 1. Null? 문제없다! Stream.ofNullable()이 구원이다
NullPointerException을 미리 차단하자! Java 9의 Stream.ofNullable()은 새로운 친구다. null 값을 조용히 제거해주어 악명 높은 충돌로부터 당신을 구해준다.

```java
List<String> names = Arrays.asList("Alice", null, "Bob", "Charlie", null);  
List<String> filteredNames = names.stream()  
    .flatMap(Stream::ofNullable)  // 👋 null 값들은 안녕!  
    .collect(Collectors.toList());  
System.out.println(filteredNames); // [Alice, Bob, Charlie]
```

더 이상 투박한 `filter(Objects::nonNull)`은 필요 없다! 이것이 자바가 "내가 너의 뒤를 봐주고 있어"라고 말하는 방식이다.

## 2. 무한 스트림? 가능하다! Stream.iterate()
마치 마법처럼 시퀀스를 즉석에서 생성할 수 있다! 끝없는 짝수 리스트가 필요한가? Stream.iterate()가 해결해준다.
```java
Stream.iterate(2, n -> n + 2)  
    .limit(5)  
    .forEach(System.out::println); // 2, 4, 6, 8, 10
```
시뮬레이션, 게임 또는 동적 데이터 생성에 완벽하다. 가능성은 무한하다.
## 3. Collectors.collectingAndThen(): 스트림의 만능 도구
전문가처럼 결과를 후처리하자! 평균 급여를 계산하고 한 번에 반올림하는 방법이다.
```java
long averageSalary = employees.stream()  
    .collect(Collectors.collectingAndThen(  
        Collectors.averagingDouble(Employee::getSalary),  
        Math::round  // 💡 짜잔! 즉각적인 변환  
    ));
```
우아하게 연산을 연결할 수 있는데 왜 추가 코드를 작성할 필요가 있을까?

## 4. takeWhile() & dropWhile(): 요리사처럼 스트림 자르기
데이터 스트림을 정밀하게 자르자! Java 9의 동적 듀오는 조건에 따라 컬렉션을 분할한다.
```java
List<Integer> numbers = List.of(1, 2, 3, 4, 5, 6, 7, 8);  
List<Integer> taken = numbers.stream()  
    .takeWhile(n -> n < 5)  // [1, 2, 3, 4]를 가져옴  
    .collect(Collectors.toList());  

List<Integer> dropped = numbers.stream()  
    .dropWhile(n -> n < 5)  // [5, 6, 7, 8]만 남김  
    .collect(Collectors.toList());
```
페이지네이션, 배치 처리 또는 데이터 청크 파싱에 이상적이다!
## 5. Collectors.teeing(): 일석이조
두 개의 컬렉터를 동시에 실행하고 결과를 병합하자! Java 12의 teeing()은 병렬 처리의 게임 체인저다.
```java
Map<String, Optional<Integer>> minMax = numbers.stream()  
    .collect(Collectors.teeing(  
        Collectors.maxBy(Integer::compare),  // 최댓값 찾기  
        Collectors.minBy(Integer::compare),  // 최솟값 찾기  
        (max, min) -> Map.of("Max", max, "Min", min)  
    ));  
// 출력: {Max=Optional[9], Min=Optional[1]}
```
데이터를 두 번 처리할 필요가 있을까?
## 보너스 팁!
- Stream.concat()으로 스트림을 매끄럽게 병합하기
- partitioningBy()를 사용하여 컬렉션을 그룹으로 분할하기 (짝수 vs 홀수? 쉽다!)
- IntStream.range()와 rangeClosed()를 통해 루프 없이 범위 생성하기
## 왜 이것이 중요한가
이 기능들은 단지 "알면 좋은" 것이 아니라 비밀 무기들이다.
- 상용구 코드를 50% 줄일 수 있다
- 버그를 방지한다 (NullPointerException을 바라보는 중)
- 코드를 즉시 더 읽기 쉽게 만든다
## 개인적인 의견
이런 스트림 API의 숨겨진 기능들은 자바 개발자라면 반드시 알고 있어야 할 필수 도구들이다. 특히 null 처리나 복잡한 연산을 단순화할 수 있는 기능들은 실무에서 매우 유용하게 쓰인다. 이러한 기능들을 잘 활용하면 코드의 품질과 가독성이 크게 향상될 수 있으니 꼭 익혀두자.
# References
https://medium.com/javarevisited/secret-java-stream-hacks-youve-never-heard-of-but-will-instantly-love-8b6155c8d878