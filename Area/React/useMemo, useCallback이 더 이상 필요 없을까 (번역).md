#react #optimization 
## React 메모이제이션의 현재와 미래
React 개발자로서 우리는 수년간 애플리케이션의 효율성을 유지하고 불필요한 리렌더링을 피하기 위해 useMemo와 useCallback을 사용해왔다.
언제 최적화하고 언제 React가 알아서 처리하도록 할지 지속적으로 고민해왔다. 그러나 React 19에서 이 모든 상황이 바뀌게 된다.

새로운 React 컴파일러는 혁신적인 기술이다. 컴파일러가 스스로 성능 최적화를 처리하고 우리가 메모이제이션을 직접 관리해야 하는 부담에서 벗어나게 해준다.

이 글에서는 React 19 이전의 메모이제이션 작동 방식, React 컴파일러의 역할, 그리고 앞으로 useMemo와 useCallback이 여전히 필요한지 알아보자.

## 수동 메모이제이션의 문제점
### React에서 메모이제이션이란
메모이제이션은 비용이 많이 드는 함수 호출의 결과를 저장하고 동일한 입력이 다시 발생할 때 캐시된 결과를 반환하는 최적화 기법이다. React에서는 컴포넌트와 함수의 불필요한 리렌더링을 방지한다.
### useMemo와 useCallback을a 사용했던 이유
React 19 이전에는 필요하지 않을 때도 React가 모든 렌더링마다 함수를 다시 생성하고 값을 재계산했다. 성능을 최적화하기 위해 직접 다음을 사용해야 했다.
- 비용이 많이 드는 계산을 메모이즈하기 위한 useMemo
- 불필요한 함수 재생성을 방지하기 위한 useCallback
### React 19 이전 예시

```javascript
import { useState, useMemo, useCallback } from "react";

function ExpensiveComponent({ num }) {
  const expensiveValue = useMemo(() => {
    console.log("Computing...!");
    return num * 2;
  }, [num]);

  const handleClick = useCallback(() => {
    console.log("Button clicked!");
  }, []);

  return (
    <div>
      <p>Computed Value: {expensiveValue}</p>
      <button onClick={handleClick}>Click Me</button>
    </div>
  );
}
```

### 수동 최적화의 문제점
- 함수와 값을 수동으로 감싸면 코드 복잡성이 증가한다.
- useMemo와 useCallback을 과도하게 사용하면 코드를 읽거나 유지 관리하기 어려워질 수 있다.

## React 19 솔루션: 자동 메모이제이션
React 19의 새로운 React 컴파일러는 과도한 메모이제이션의 필요성을 없애준다. useMemo와 useCallback 없이도 자동으로 함수와 값을 최적화하여 리렌더링을 줄여준다.

### React 컴파일러의 작동 방식
React 컴파일러는 컴포넌트를 분석하고 다음과 같이 자동으로 최적화한다.
- 불필요한 리렌더링을 감지하고 건너뛴다.
- 비용이 많이 드는 계산을 내부적으로 메모이즈한다.
- 안정적인 함수 참조를 보장하여 prop 변경이 리렌더링을 유발하지 않도록 한다.
### React 19에서 메모이제이션 없이 작성한 코드

```javascript
function ExpensiveComponent({ num }) {
  function computeValue() {
    console.log("Computing...!");
    return num * 2;
  }

  function handleClick() {
    console.log("Button clicked!");
  }

  return (
    <div>
      <p>Computed Value: {computeValue()}</p>
      <button onClick={handleClick}>Click Me</button>
    </div>
  );
}
```
### 결과
- 컴파일러가 자동으로 함수 호출을 최적화하고 handleClick이 불필요하게 재생성되지 않도록 한다.
- 추가 작업 없이 더 깔끔하고 가독성 높은 효율적인 코드를 작성할 수 있다.
## useMemo와 useCallback이 여전히 필요한 경우
React 19가 수동 메모이제이션의 필요성을 크게 줄여주지만, useMemo와 useCallback이 여전히 유용할 수 있는 몇 가지 상황이 있다.
### useMemo를 사용해야 하는 경우
- 메모이즈된 값에 의존하는 서드파티 라이브러리를 사용할 때
- React의 최적화가 감지하지 못하는 매우 비용이 많은 계산을 수행할 때
### useCallback을 사용해야 하는 경우
- 엄격한 참조 동등성에 의존하는 컴포넌트에 함수를 전달할 때(예: React.memo로 메모이즈된 자식 컴포넌트)

그러나 대부분의 경우에는 더 이상 필요하지 않다.

<aside> 💡 React 19의 컴파일러는 대부분의 일반적인 최적화 케이스를 자동으로 처리해주므로 개발자는 비즈니스 로직에 더 집중할 수 있다. </aside>

## 모범 사례 및 일반적인 실수
### 모범 사례
- 먼저 간단한 코드를 작성하고 React가 자동으로 최적화하도록 한다.
- useMemo와 useCallback은 정말 필요한 경우에만 사용한다.
- 최적화하기 전에 성능을 테스트하고 무언가가 느리다고 가정하지 않는다.
### 일반적인 실수
- 불필요하게 useMemo와 useCallback을 과도하게 사용하여 코드를 더 복잡하게 만든다.
- 자동 최적화에 의존하기 전에 React 19로 업데이트하는 것을 잊는다.

## 마무리
React 19의 React 컴파일러를 통한 자동 메모이제이션은 성능 최적화에 있어 게임 체인저다. 수동 메모이제이션 없이도 불필요한 리렌더링을 제거하여 개발을 단순화한다.

아직도 모든 것을 수동으로 최적화하고 있다면, 업그레이드하고 더 깔끔하고 빠른 React 코드를 즐겨보자!

# References
https://medium.com/front-end-world/react-19-memoization-no-more-usememo-usecallback-3a09a986f9c7