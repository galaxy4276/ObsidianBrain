#typescript 

`using`은  `const`, `let` 대신 사용되며 사용 후 정리되는 일회용 객체를 정의하며,
`[Symbol.dispose]` 를 사용하는 객체에 대해 사용되어야 한다.

# Symbol.dispose?
객체를 일회용 객체로 마킹하는데 사용되는 타입스크립트의 특수 함수이다.
```typescript
// Object marked as disposable using Symbol.dispose  
const disposableObject = {  
	[Symbol.dispose]: () => {  
		console.log("Dispose of me!");  
	},  
};  
  
// Using the object as a resource  
using resource = disposableObject
```

# 활용 예시
데이터베이스 커넥션과 같은 사용 후 제거되어야하는 객체의 경우 다음과 같이 활용할 수 있다.

```typescript
https://www.totaltypescript.com/typescript-5-2-new-keyword-using#database-connections  
const getConnection = async () => {  
  const connection = await getDb();  
  
  return {  
    connection,  
    [Symbol.asyncDispose]: async () => {  
      await connection.close();  
    },  
  };  
};  
  
{  
  await using db = await getConnection();  
  
  // Do stuff with db.connection  
  
} // Automatically closed!

```


# References
#### [# Understand the “using” keyword in TypeScript](https://levelup.gitconnected.com/using-the-using-keyword-in-typescript-2850c7b0b872)