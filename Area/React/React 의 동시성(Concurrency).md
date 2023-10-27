---
tags: react
---
![Untitled](Untitled%2067.png)

React 에서 v18 부터 동시성 기능을 지원합니다.

이번 글에서는 React 에서 동시성 기능을 어떻게 지원하고 동작하는 지에 대해 서술합니다.

## React 의 동시성이란?

기본 전제는 다음 뷰를 렌더링하는 동안 현재 뷰의 반응성을 유지하도록 렌더링 프로세스를 재작업하는 것입니다.

동시성 모드(Concurrency Mode) 는 애플리케이션 성능 개선을 위해 React 팀에서 제안된 기능입니다.

<aside>
💡 동시성 모드는 렌더링 연산은 중단할 수 있는 단위로 나누는 개념입니다.

</aside>

내부적으로 컴포넌트의 렌더링을 `requestIdCallback()` 으로 래핑하여 렌더링 연산 중에 애플리케이션의 응답성을 유지하는 방식으로 구현됩니다.

기본적으로 Blocking 모드가 다음과 같이 구현된다 가정해봅시다.

```jsx
function renderBlocking(Component) {
    for (let Child of Component) {
        renderBlocking(Child);
    }
}
```

그렇다면, 동시성 모드는 다음과 같이 구현되어 있을 것 입니다.

```jsx
function renderConcurrent(Component) {
    // 상태가 만료되었다면 렌더링을 중단합니다.
    if (isCancelled) return;

    for (let Child of Component) {
        // 브라우저가 busy 상태가 아닐 때까지 기다립니다. (처리할 Input 이 없을 때까지)
        requestIdleCallback(() => renderConcurrent(Child));
    }
}
```

## Mode 는 없고 기능만 존재한다.

동시성 모드는 실제로 이전 버전과 호환 문제 때문에 실현되지 않았습니다.

대신 React 팀은 동시성 렌더링을 선택적으로 활성화하는 새로운 API 세트인 Concurrent 기능으로 방향을 전환했습니다.

지금까지 React 는 동시 렌더링을 선택할 수 있는 두 가지 새로운 훅을 도입했습니다.

### useTransition

useTransition 은 두 가지 항목을 반환합니다.

1. 동시 렌더링이 진행 중일 때 true 인 bool 값 `isPending`
2. 새로운 동시 렌더링을 발생시키는 `startTransition` 함수
    
    해당 기능을 사용하기 위해서는 `setState` 를 `startTransition` 에 래핑하세요.
    
    ```jsx
    function MyCounter() {
        const [isPending, startTransition] = useTransition();
        const [count, setCount] = useState(0);
        const increment = useCallback(() => {
            startTransition(() => {
                // 아래 상태 갱신이 동시에 진행됩니다.
                setCount(count => count + 1);
            });
        }, []);
     
        return (
            <>
                <button onClick={increment}>Count {count}</button>
                <span>{isPending ? "Pending" : "Not Pending"}</span>
                // Component which benefits from concurrency
                <ManySlowComponents count={count} />
            </>
        )
    }
    ```
    
    예제는 [여기](https://codesandbox.io/s/transition-counter-demo-ejir9b?from-embed)서 확인하세요.
    
    개념적으로 접근하자면, 상태 갱신은 `startTransition` 에 래핑되어있는 지 감지하여 blocking 또는 동 렌더링을 예약할 지 여부를 결정합니다.
    
    ```jsx
    function startTransition(stateUpdates) {
      isInsideTransition = true;
      stateUpdates();
      isInsideTransition = false;
    }
    
    function setState() {
      if (isInsideTransition) {
        // 동시성 렌더링 예약
      } else {
        // Blocking 렌더링 예약
      }
    }
    ```
    
    <aside>
    💡 `useTransition` 의 주의사항은 [**제어 입력**](https://react.dev/reference/react/useTransition#updating-an-input-in-a-transition-doesnt-work)에는 사용할 수 없다는 것입니다.
    이러한 경우에는 `useDeferredValue` 를 사용하는 것이 좋습니다.
    
    </aside>
    

### useDeferredValue

해당 훅은 `startTransition` 에서 처럼 상태 갱신을 래핑할 수는 없지만 동시 갱신을 수행하려는 경우 편리한 기능입니다.

상황적인 예시로, 부모로부터 새 값을 전달받는 자식 컴포넌트가 존재합니다.

개념적으로 해당 훅은 디바운스이므로 다음과 같이 구현할 수 있습니다.

```jsx
function useDeferredValue<T>(value: T) {
    const [isPending, startTransition] = useTransition();
    const [state, setState] = useState(value);
    useEffect(() => {
        // Dispatch concurrent render
        // when input changes
        startTransition(() => {
            setState(value);
        });
    }, [value])

    return state;
}
```

이제 다음과 같은 방식으로 사용할 수 있습니다.

```jsx
function Child({ value }) {
    const deferredValue = useDeferredValue(value);
    // ...
}
```

## References

**[Understanding React Concurrency](https://www.bbss.dev/posts/react-concurrency/)**