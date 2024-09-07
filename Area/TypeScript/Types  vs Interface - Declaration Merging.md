#typescript

`Types` 와 `Interface`  의 차이를 보며 인터페이스의 존재하는 `Declaration Merging` 기능과 해당 기능의 위험성에 따른
`type` 을 사용해야하는 이유에 대한 정리 문서이다.

# Merging

`type` 은 `&` 연산자를 사용해 타입을 병합할 수 있지만, `interface` 는 그럴 수 없다.
```typescript
// ✅ Works  
type Person = {  
	name: string  
	age: number  
} & { job: string }  
  
// ❌ Does not work  
interface Person {  
	name: string  
	age: number  
} & { job: string }
```


# Perfomance
`type` 과 `interface` 의 타입 체킹 비용의 차이는 거의 0 에 가깝다.

# Interface 는 위험하다.

> Interfaces in TypeScript have a unique feature called [**Declaration Merging**](https://www.typescriptlang.org/docs/handbook/declaration-merging.html)

인터페이스는 `Declaration Merging` 이라는 기능이 존재한다.

동일한 이름을 가진 인터페이스를 타입 컴파일러가 하나로 병합해주는 기능을 의미한다.
이는 다음과 같은 문제 발생 여지가 존재한다.

1. **우선 순위**
	* 이후에 선언된 것은 항상 이전에 선언된 것보다 우선되며 여러 부분에서 병합이 발생할 때 예기치 않은 문제가 발생할 수 있다.

2. **클래스와 안전하지 않은 병합**
	* TypeScript 컴파일러가 속성 초기화를 확인하지 않기 때문에 예기치 않은 런타임 오류가 발생할 수 있다.

`interface` 가 가지는 이러한 문제사항과 달리 **`type` 은 생성 이 후에 변경할 수 없으므로 이러한 문제로부터 자유롭다.**


# Conclusion
확장 가능한 개선이나 OOP를 사용한 구현 등 특정 인터페이스 동작이 필요한 경우가 아니라면 타입을 사용하는 것이 가장 좋다.
 타입은 유연하고 간단하며 선언 병합과 관련된 함정을 피할 수 있으며  또한 타입은 인터페이스와 비교해 성능면에서 동일하므로 코드베이스에서 인터페이스 대신 타입을 선택해야 하는 또 다른 이유를 제공한다.


# References
#### [Typescript 공식 문서 - Declaration Merging](https://www.typescriptlang.org/docs/handbook/declaration-merging.html)
#### [# Stop Using TypeScript Interfaces](https://levelup.gitconnected.com/stop-using-typescript-interfaces-973401f99920)
