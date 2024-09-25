#functional-programming 
# Defensive Copy

> 데이터를 변경할 수도 있는 코드와 불변성 코드 사이에 데이터를 주고받기 위한 원칙

신뢰할 수 없는 쓰기 코드(레거시 코드, 라이브러리) 의 코드 변형을 막기 위해 사용한다.
 
```javascript
var cart_copy = deepCopy(shopping_cart); <-- 넘기기 전에 복사
black_friday_promotion(cart_copy);
```
### 규칙 
1. 데이터가 안전한 코드로 나갈 때 복사
2. 데이터가 안전한 코드로 들어올 때 복사

`Defensive Copy` 는 `Deep Copy` 를 사용하며 비용은 `Copy On Write` 방식보다 비싸다.
그러니 `Copy On Write` 를 사용할 수 없는 곳에서만 사용한다.


### 1급 객체
1급이라는 의미는 **인자로 전달할 수 있다**는 의미가 된다.
