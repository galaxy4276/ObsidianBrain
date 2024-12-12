#react

# Race Condition 해결 방법

`Race Condition` 의 해결 예시이다.
```typescript
 useEffect(() => {
    let ignore = false;
    const request = async (requestId) => {
      setIsLoading(true);
      await sleep(Math.random() * 3000);
      if (!ignore) {
        setResponse(requestId);
        setIsLoading(false);
      }
    }
    request(counter);
    
    return () => {
      ignore = true;
    }
  }, [counter]);
```

이벤트가 다수가 발생하여 콜백이 수행될 때, 해당 콜백의 실행상태를 `cleanup` 함수에서 제어함으로써 `Race Condition` 을 회피할 수 있다.

아래는 현상을 상세히 정의하였다.

### **문제: Race Condition**
- `useEffect` 내부에서 비동기 작업이 실행되고, 의존성(`counter`)이 변경되어 새 작업이 트리거되면 이전 작업도 여전히 실행될 수 있다.
- 이로 인해 오래 걸린 이전 작업이 나중에 완료되면서 상태를 덮어쓰는 문제가 발생할 수 있다.

---

### **해결 방법: Cleanup 함수로 상태 제어**

1. **`ignore` 플래그 사용**
    
    - 비동기 작업 실행 시, `ignore` 플래그를 활용해 이전 작업을 무효화한다.
    - `cleanup` 함수에서 `ignore = true`를 설정하여 이전 작업의 상태 변경을 방지한다.
2. **로직 설명**
    
    - `request` 함수는 `counter`의 값을 기반으로 비동기 작업을 실행한다.
    - `cleanup` 함수(`return () => { ignore = true; }`)는 `useEffect`가 다시 호출될 때 실행되며, 이전 작업을 무효화한다.
    - 무효화된 작업은 `ignore` 조건에 의해 상태를 변경하지 않는다.

---

### **장점**

- 여러 이벤트로 인해 콜백이 동시에 실행되더라도, 최신 상태만 반영되어 **Race Condition**을 방지할 수 있다.
- 코드가 간단하고 React의 `useEffect` 패턴과 자연스럽게 통합된다.

# 데이터 흐름 망치기
```typescript
function Parent() {
  const [data, setData] = useState(null);

  return <Child onFetched={setData} />;
}

// 🔴 Effect 내에서 부모에게 데이터를 전달하는 건 좋지 않습니다
function Child({ onFetched }) {
  const data = useFetchData();

  useEffect(() => {
    if (data) {
      // 🇮🇹 스파게티 코드를 만드는 건가요?
      onFetched(data);
    }
  }, [onFetched, data]);

  return <>{JSON.stringify(data)}</>;
}
```

`React` 의 데이터는 폭포수처럼 흘러야한다.
데이터가 부모에서 자식 방향으로 흐르도록해야 에러 추적, 유지보수, 디버깅 측면에서 유리하다.
> 즉, Soruce of Truth 를 쉽게 이해할 수 있어야한다.

자식 컴포넌트에서 데이터를 가져오는 로직을 유지할 수 밖에 없다면 `useState`, `useEffect` 대신 상위에서 정의된 핸들러를 사용하여 데이터와 상호작용하는 것이 바람직하다.
```tsx
// 제안 #2 - onSuccess/onError 핸들러를 자식 컴포넌트에 전달합니다
function Parent() {
    function handleSuccess = (data) => {
        // 성공을 처리하는 로직
    }
    function handleError = (error) => {
        // 실패를 처리하는 로직
        toast(error.messasge)
    }
    // ✅ 올바른 방향으로 자식에게 데이터를 전달합니다
    return <Child onSuccess={handleSuccess} onError={handleError} />;
}

function Child({ onSuccess, onError }) {
  // ✅ 다른 이펙트는 관여하지 않고 데이터를 가져왔을 때 핸들러를 호출하는 훅을 사용하는 것이 좋습니다.
  const mutate = useMutateData({ onSuccess, onError });

  return ...;
}
```

# 원문
https://velog.io/@typo/leave-useeffect-alone