---
tags: typescript, code-trick
---
```typescript
function writeTransactionsToFile(transactions) {  
	let writeStatus;  
  
	try {  
		fs.writeFileSync('transactions.txt', transactions);  
		writeStatus = 'success';  
	} catch (error) {  
		writeStatus = 'error';  
	}  
	// do something with writeStatus...  
}
```

다음과 같은 형식의 try .. catch 구문의 사례는 참 많을거에요.
일반적으로 try .. catch 내외에 오류 없는 접근을 위해 범위 외부에 변경가능한 변수를 선언할 확률이 높아요.
하지만 항상 그럴 필요는 없으며 함수형 tryCatch 를 사용하면 그러지 않아도 됩니다.

순수한 tryCatch() 함수는 변경 가능한 변수를 피하고 코드베이스의 **유지보수성과 예측 가능성**을 높입니다.

# tryCatch()
```typescript
type TryCatchProps<T> = {  
	tryFn: () => T;  
	catchFn: (error: any) => T;  
};  
function tryCatch<T>({ tryFn, catchFn }: TryCatchProps<T>): T {  
	try {  
		return tryFn();  
	} catch (error) {  
		return catchFn(error);  
	}  
}
```


# 가독성, 모듈화, SRP
예외를 처리할 때 두 가지 법칙이 있습니다.
1. try .. catch 는 가능한 한 오류의 원인에 가까워야 합니다.
2. 함수당 하나의 try ... catch 만 사용해야 합니다.

이를 통해 코드를 더 쉽게 읽고 유지보수할 수 있습니다.



### 원문
https://javascript.plainenglish.io/functional-javascript-try-catch-gives-you-cleaner-and-modular-code-6b42194399c0
