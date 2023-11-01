---
tags: spring, transaction
banner: Archive/images/springboot-banner-01.jpg
---
Spring 트랜잭션에서 예외를 잡아서 정상적으로 처리하게 끔 유도한다하여도
커밋이 되지 않고 바로 롤백이 된다.

> [!이유]
> @Tx 에서 Exception 이 발생하면 롤백 마크를 수행하기 때문이다.
> 그래서 해당 트랜잭션을 재사용하는 것이 불가능하다.

의도하려던 대로 예외를 무시하고 트랜잭션을 처리하도록 우회하는 방법은 다음과 같다.
### 특정 로직을 Tx 에서 제외

```java 
@Transactional(propagation = Propagation.NOT_SUPPORTED)
public void tx01() { ... }
```

> [!NOT_SUPPORT]
> Non-Transactional 로 실행되며 이미 진행중인 트랜잭션이 있으면 보류시킨다.

### 트랜잭션 예외 자체를 예외 처리

```java
@Transactional
public void main() {
	try {
		tx01();
	} catch (TransactionSystemException ignore) {}
	tx02();
}

@Transactional
public void tx01() {
	try { ... } 
	catch (Exception igonre) {}
}
```

### noRollbackFor 사용
속성에 정의한 Exception 은 해당 트랜잭션 내부에서 발생했을 경우 진행한 부분까지 커밋이 발생하며 롤백을 진행하지 않는다.
```java
@Transactional(noRollbackFor = { ExceptionA.class, ExceptionB.class })
public void tx01() {...}
```

**다만 예외는 callee 에게 전파되니 꼭 예외 처리 로직을 작성해야만 한다.**
# References
[# 응? 이게 왜 롤백되는거지?](https://techblog.woowahan.com/2606/)
[Transaction marked as rollback](https://brunch.co.kr/@purpledev/8)
[Spring Transaction Propagation을 예제를 통해 알아보자](https://oingdaddy.tistory.com/28)