## Overview

React Query 는 서버상태의 특성을 파악하고 다음 문제를 해결합니다.
- 캐싱... (아마도 프로그래밍에서 가장 어려운 일)
- 동일한 데이터에 대한 여러 요청을 단일 요청으로 중복 제거하기
- 백그라운드에서 '오래된' 데이터 업데이트하기
- 데이터가 "오래된" 시기 파악하기
- 가능한 한 빠르게 데이터 업데이트 반영하기
- 페이지 매김 및 지연 로딩 데이터와 같은 성능 최적화
- 서버 상태의 메모리 및 가비지 컬렉션 관리
- 구조적 공유를 통한 쿼리 결과 메모화


성장하는 애플리케이션에 대해 다음 혜택을 제공합니다.

- 애플리케이션에서 복잡하고 오해의 소지가 있는 **여러** 줄의 코드를 제거하고 몇 줄의 React 쿼리 로직으로 대체할 수 있도록 도와줍니다.
- 새로운 서버 상태 데이터 소스를 연결할 걱정 없이 애플리케이션의 유지 관리성을 높이고 새로운 기능을 더 쉽게 구축할 수 있습니다.
- 애플리케이션의 속도와 반응성을 그 어느 때보다 빠르게 만들어 최종 사용자에게 직접적인 영향을 미치세요.
- 잠재적으로 대역폭을 절약하고 메모리 성능을 향상시키는 데 도움이 될 수 있습니다.

## Important Defaults
기본적으로 **useQuery**, **userInfiniteQuery** 를 통한 쿼리 인스턴스는 캐시된 데이터를 오래된 것으로 간주합니다.

오래된 쿼리는 다음 경우 백그라운드에서 자동으로 리프레시됩니다.
-  쿼리의 새 인스턴스가 마운트되는 경우
- 창이 다시 초점이 맞춰진 경우
- 네트워크가 다시 연결된 경우
- 쿼리가 선택적으로 다시 가져오기 간격으로 구성됩니다.
> 이 기능을 변경하려면 `refetchOnMount`, `refetchOnWindowFocus`, `refetchOnReconnect` 및 `refetchInterval과` 같은 옵션을 사용할 수 있습니다.

## Query Basics
쿼리는 **고유 키**에 연결 된 비동기 데이터 소스에 대한 선언적 종속성입니다.

쿼리는 다음 상태 중 하나만 존재할 수 있습니다.
- `isPending` or `status === 'pending'` - The query has no data yet
- `isError` or `status === 'error'` - The query encountered an error
- `isSuccess` or `status === 'success'` - The query was successful and data is available

위 3가지 상태 외에도 쿼리 상태에 따라 더 많은 정보를 확인할 수 있습니다.
- `error` - If the query is in an `isError` state, the error is available via the `error` property.
- `data` - If the query is in an `isSuccess` state, the data is available via the `data` property.
- `isFetching` - In any state, if the query is fetching at any time (including background refetching) `isFetching` will be `true`.

## Query Keys
**Tanstack Query 의 모든 쿼리는 키를 기반으로 캐싱을 관리하는 것이 핵심입니다.**
쿼리 키는 최상위 수준에서 배열이어야 하며 단일 문자열이 포함된 간단한 배열일 수 있고, 여러 문자열과 중첩된 객체가 포함된ㅇ 배열처럼 복잡할 수 있습니다.

### 변수와 존재하는 배열 키
쿼리 데이터를 고유하게 설명하기 위해 더 많은 정보가 필요한 경우 문자열과 직렬가능한 객체가 포함된 배열을 사용할 수 있습니다.
```typescript
// An individual todo
useQuery({ queryKey: ['todo', 5], ... })

// An individual todo in a "preview" format
useQuery({ queryKey: ['todo', 5, { preview: true }], ...})

// A list of todos that are "done"
useQuery({ queryKey: ['todos', { type: 'done' }], ... })

```

### 쿼리 키는 해시화됩니다
즉, 객체의 키 순서에 관계없이 다음 쿼리는 모두 동일한 것으로 간주됩니다.
```typescript
useQuery({ queryKey: ['todos', { status, page }], ... })
useQuery({ queryKey: ['todos', { page, status }], ...})
useQuery({ queryKey: ['todos', { page, status, other: undefined }], ... })
```

그러나 다음 쿼리 키는 동일하지 않습니다.  배열 항목 순서가 중요합니다!
```typescript
useQuery({ queryKey: ['todos', status, page], ... })
useQuery({ queryKey: ['todos', page, status], ...})
useQuery({ queryKey: ['todos', undefined, page, status], ...})
```
