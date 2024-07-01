#typescript 



# New Thing!

## [Custom Type] Get
```typescript
type Get<T, K, F> = K extends keyof T ? T[K] : F  
  
type Get2<K, T, R> = K extends keyof T ? T[K] : R  
  
type Example1 = Get<{ id: number; name: string }, 'id', boolean>  
  
type Example2 = Get2<'anony', { anony: string }, boolean>  
type Example3 = Get2<'anony', { anonymous: string }, boolean>  
  
const ex1: Example1 = 1  
  
const ex2: Example2 = '1'  
  
const ex3: Example3 = false
```


# References
### [구현부에서 useExternelStore 를 사용하는 이유](https://velog.io/@jay/Concurrent-React)

### [useDebugValue (React Official)](https://react.dev/reference/react/useDebugValue)
