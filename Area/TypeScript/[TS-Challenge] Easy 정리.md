
![Untitled](Untitled%2030.png)

# Pick 유틸리티 클래스 타입 작성해보기

[[]]

```tsx
type MyPick<K, T extends keyof K> = {
  [key in T]: K[key];
}
```

타입에서 `**[key in 대상객체]**` 를 이용해서 객체의 키 값을 매칭시킬 수 있다.

### References

**[Keyof Type Operator](https://www.typescriptlang.org/docs/handbook/2/keyof-types.html)**

# Readonly 유틸리티 클래스 타입 작성해보기

```tsx
type MyPick<K, T extends keyof K> = {
  [key in T]: K[key];
}
```

위 Pick 구현 문제와 같이 궁금한게 `**[P in 대상 객체]**` 의 문법을 무엇으로 명칭하는 지 궁금해서 찾아본 결과

`**Mapped Type**` 이라고 한다.

해당 기능은 제네릭 타입 `**T`** 에 대해 속성을 순회하는 것을 의미하며 `**T**`의 속성을 순회하며 각 속성의 타입을 변경하거나, 수정할 수 있다.

<aside>
💡 예를 들어, 모든 속성을 옵셔널하게 만들거나 불변하게 할 수 있다.

</aside>

### References

**[맵드 타입(Mapped Type)이란?](https://joshua1988.github.io/ts/usage/mapped-type.html)**

**[Mapped Types](https://www.typescriptlang.org/docs/handbook/2/mapped-types.html)**

# Tuple To Object

[[]]

```tsx
type TupleToObject<T extends readonly string[]> = {
  [P in T[number]]: P
}
```

**`[P in T[number]]`**는 **`T`** 배열의 모든 요소를 순회하면서 각 요소를 키로 가지는 속성을 생성합니다. **`P`**의 값은 각 요소 자체가 된다. 

### References

[선례](https://github.com/type-challenges/type-challenges/issues/2737)

**[Indexed Access Types](https://www.typescriptlang.org/docs/handbook/2/indexed-access-types.html)**

# First Array

```tsx
type First<T extends (string | number)[]> = T extends [] ? never : T[0];
```

`**T extends []**` 는 **T 가 비어있는 배열**임을 뜻한다.

아래 코드도 정답이 될 수 있다.

```tsx
type First<T extends any[]> = T['length'] extends 0 ? never : T[0]
```

# Length of Tuple

```tsx
type Length<T extends readonly any[]> = T['length'];
```

easy

# Exclude

```tsx
type Result<T, U extends keyof T> = T extends U ? never : T;
```

다음은 해당 코드에 대한 GPT 분석 답변이다.

주어진 TypeScript 코드는 **`Result`**라는 제네릭 타입을 정의합니다. 이 타입은 두 개의 제네릭 타입 매개변수 **`T`**와 **`U`**를 사용합니다.

1. **`T`**는 어떤 객체(타입)를 나타내며, **`U`**는 **`T`** 객체의 키(key) 중 하나를 나타냅니다.
2. **`Result`** 타입은 **`T`**가 **`U`**에 할당 가능한 키(key)를 가지고 있는지 여부를 확인하고, 만약 **`T`**가 **`U`**에 할당 가능한 키를 가지고 있다면 **`never`** 타입으로 설정됩니다.
3. 결과적으로 **`Result`** 타입은 **`T`** 객체가 **`U`** 키를 가지고 있지 않으면 **`T`** 타입 그대로 반환하고, **`T`** 객체가 **`U`** 키를 가지고 있다면 **`never`** 타입으로 반환됩니다.

`**never**` 는 절대로 발생하지 않는 값을 표현하는 용도로 사용되었음을 유의하자.

### References

[TS distributive-conditional-types](https://www.typescriptlang.org/docs/handbook/2/conditional-types.html#distributive-conditional-types)

# Awaited

```tsx
type MyAwaited<T extends Promise<any>> = T extends Promise<infer R> 
? R extends Promise<any> ? MyAwaited<R> 
: R : never;
```

`**infer**` 를 통해 동적으로 타입을 추론가능한 점 기억하기

`**Promise**` 자체가 중첩될 수 있기 때문에 재귀적으로 타입을 추론하는 방식의 좋은 예제인 것 같다.

### References

**[TypeScript - infer](https://velog.io/@from_numpy/TypeScript-infer)**

# Includes

```tsx
// 직접 구현한 타입
type Includes<T extends any[], A extends T[number]> = A extends T[number] 
? true : false;
```

```tsx
// 모범 답안
type Includes<T extends readonly any[], U> = {
  [P in  T[number]]: true;
}[U] extends true ? true : false;
```

### References

[Recommended Solution](https://github.com/type-challenges/type-challenges/issues/1568)

# Parameters

```tsx
type MyParameters<T extends (...args: any) => any> =
  T extends (...args: infer R) => any ? R : never;
```

`infer` 키워드를 이용해 매개변수를 추론하여 반환하는 방법이다.

조금 복잡하니 한 단씩 해석해보자.

`**T extends (...args: any) => any**`

해당 구문은 `제네릭 타입 매개변수 T` 가 함수타입임을 나타낸다.

단순히 `T`가 함수 타입이라는 것을 명시한 것이다.

`**(...args: infer R)**`

함수 시그니처를 나타내며, `…args` 는 함수의 매개변수 목록을 나타내고 `infer R` 은 해당 매개변수들의 유형을 추론하고 그 결과를 `R` 에 할당한다.

<aside>
💡 `R`은 함수 매개변수 유형의 tuple 이다.

</aside>

즉, `T` 가 함수일 경우를 확인해서 `R` 을 반환하고 그렇지 않으면 `never` 를 반환하게 되는 것이다.

### References

[Recommended Solution](https://github.com/type-challenges/type-challenges/issues/16812)