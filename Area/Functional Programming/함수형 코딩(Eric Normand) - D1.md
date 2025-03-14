#functional-programming

> 함수형 사고 (Functional Thinking) 이 무엇인 

`함수형 프로그래밍` 개념은 `Side Effect 를 없애라!` 라는 슬로건때문에 단순하게 생각될 수도 있지만,
`부수 효과 구성(Organizing Side Effect)` 에 관한 내용을 다루며 부수 효과를 잘 관리하여 코드의 아무 곳에나 있지 않도록 하는데 더 의의가 있다.

# 함수형의 기본 분류

### Action
실행 시점이나 횟수 또는 둘 다 모두 의존하는 것 
> Example
> 1. 긴급한 메일을 오늘 보내는 것과 다음 주에 보내는 것은 다르다.
> 2. 같은 메일을 10번 보내는 것과 한 번 보내는 것은 다르다.
> 3. 메일을 보내는 것과 보내지 않는 것은 다르다.

### Calculation
입력값으로 출력값을 만드는 것을 의미한다.
같은 입력 값으로 항상 같은 출력 값이 나온다.
언제, 어디서 계산해도 결과는 같으며 부수 효과를 발생시키지 않는다.
테스트에 용이하다.

### Data
이벤트에 대해 기록한 사실이며 알아보기 쉬운 속성으로 되어있고 실행하지않아도 그 자체로 의미가 있다.

### What is "Action"?
* 프로그램 내부에 호출 시점이나 횟수에 의존하는 코드가 존재한다면 해당 프로그램(함수)은 액션이다.
	* 언제 실행되는지 - **순서**
	* 얼마나 실행되는지 - **반복**
> 액션의 예)
>	* 이메일 보내기
>	* 계좌에서 인출하기
>	* 전역변수값 바꾸기
>	* ajax 요청 보내기


# 함수형 접근법
#### 암묵적 입/출력 배제하기
입력과 출력은 명시적이거나 암묵적일 수 있다.
```javascript
var total = 0;
function add_to_total(amount) {
	console.log("Old total: " + total); // 암묵적 입력(전역변수 입력)
	total += amount; // 암묵적 출력(전역변수 변경)
	return total;
}
```

# Copy-On-Write 원칙
> 1. 복사본 만들기
> 2. 복사본 변경하기
> 3. 복사본 리턴하기

# References
https://yozm.wishket.com/magazine/detail/1485/
 