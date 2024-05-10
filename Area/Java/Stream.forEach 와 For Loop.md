#java #java-stream
# Stream 은 순회(Looping) 이 아니다.
스트림의 루프를 대체하는 것이 목적이 아님
반복해야 할 목록만 있는 경우에는 Stream.forEach가 필요하지 않음.
즉 `Stream.forEach`는 반복이 필요한 목록이 있을 때 사용하는 것이 아님!

Stream.forEach 릀 아요하면 자체 명령형 루프를 강제하는 대신 스트림의 파이프라인 아래에서 동작함
스트림은 일반적인 명령형 파이프라인과는 다른 방식으로 존재할 수 있다.

> 루프에 스트림을 선택하는 유일한 예는 병렬 스트림으로,
> 람다를 순차적이지 않은 병렬 방식으로 호출하여 람다 내부 코드가 성능에 중요한 경우 루프를 더 빠르게 만든다.
# 성능에 관해서
병렬 스트림은 상당한 오버헤드가 발생하므로 오버헤드를 감수할 가치가 있다고 확신하지 않는 한 사용하지 않는 것이 좋다.
일반적인 루프가 성능이 우세하지만 성능만에 코드를 측정하는 지표가 아니다.
소프트웨어 엔지니어링의 모든 것은 **Trade-Off**
> 성능이 좋은 코드는 일반적으로 가독성이 좋지 않고, 가독성이 좋은 코드는 일반적으로 성능이 좋지 않습니다.

ms 단위의 성능이 **mission ciritic** 하고 전체 스택과 소프트웨어가 아예 최적화되어있지 않는 한 일반적으로 크게 의미는 없다.

# 엣지 케이스
중첩 루프 케이스를 예를 들어 `Stream.forEach` 를 선택했는데 `StackOverflow` 에 의한 무한 루프 예외가 발생한 사례가 있다.
이 문제의 원인을 찾기위해 고군분투했지만 지금까지 여전히 미스테리다.
> 원 글 작성자의 경험입니다.

```java
//...  
repository.findAll()  
	.stream()  
	.map(entity -> mapper.map(entity, Model.class)  
	.collect(Collectors.toList())  
	.forEach(model -> model.getEmployees().forEach(employee -> {  
	System.out.println(employee)  
	}))  
//...
```

무한 루프를 피하기 위해 중첩된 for 루프로 코드를 리팩터링하여 해결책을 찾았다.
```java
//...  
for (Model model: entities) {  
	for (employee : model.employees) {  
		System.out.println(employee)  
	}  
}  
//...
```

#  결론
결론적으로, 이 글은 Stream.forEach 메서드보다 Java for loop가 더 실용적인 선택인 이유에 대한 귀중한 통찰력을 제공한다.이 두 가지 접근 방식의 뉘앙스를 이해함으로써 코딩 효율성과 Java에 대한 숙련도를 높일 수 있다.
# References
https://medium.com/@kouomeukevin/why-you-should-use-java-for-loop-instead-of-stream-foreach-method-da8227990fad