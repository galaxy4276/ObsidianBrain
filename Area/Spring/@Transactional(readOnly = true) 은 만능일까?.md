---
tags: spring, transaction
---
# readOnly = true 명시하면 얻는 이점

### 명시적 Read 연산
개발자가 보기에 해당 연산이 Read 작업만을 수행하기 위함이라는 의미를 전달할 수 있다.

## Flush Mode 변경
readOnly 를 명시하면 Jpa 트랜잭션 내부적으로 플러시 모드를 `MANUAL` 로 변경한다.

> [!Flush Mode - Manual]
> 개발자가 명시적으로 플러시 코드를 호출해야 플러시 기능이 동작한다.

```java
protected FlushMode prepareFlushMode(Session session, boolean readOnly) throws PersistenceException {
FlushMode flushMode = session.getHibernateFlushMode();  
	if (readOnly) {  
	// We should suppress flushing for a read-only transaction.  
	if (!flushMode.equals(FlushMode.MANUAL)) {  
		session.setHibernateFlushMode(Flusode.MANUAL);  
		return flushMode;  
	}  
}  
	else {  
	// We need AUTO or COMMIT for a non-read-only transaction.  
	if (flushMode.lessThan(FlushMode.COMMIT)) {  
		session.setHibernateFlushMode(FlushMode.AUTO);  
		return flushMode;  
	}  
}  
// No FlushMode change needed...  
	return null;  
}
```

## Non-Dirty Check
readOnly 를 명시하면 해당 엔티티 대상에 대해 더티 체킹을 수행하지 않습니다.
또한 영구 상태 스냅샷도 유지되지 않으므로 변경 내용도 반영되지 않게됩니다.

이러한 결과로 다음과 같은 이점이 존재합니다.
* **더티 체킹을 수행하지 않아 성능이 향상됨**
* **스냅샷이 생성되고 관리되지 않기 떄문에 메모리를 절약할 수 있음**
* 읽기/쓰기 복제본 디비 환경을 사용할 경우 읽기 전용 DB에 접근할 수 있음


# @Transactional(readOnly = true) 를 그러면 항상 사용해야만 하는가?

서비스 계층의 읽기 전용 메서드에 모두 해당 어노테이션을 사용한다면 두 가지 우려 사항이 존재합니다.

* 트랜잭션을 제한 없이 사용하면 DB 에 데드락이 발생하여 성능과 처리량이 하향될 여지가 있다.
* 하나의 트랜잭션은 하나의 DB 연결을 사용하기 때문에 DB 커넥션이 고갈 될 여지가 있다.

두 번째 문제에 대한 시나리오로 다음과 같은 상황이 존재할 수 있습니다.
서비스 계층에서 readOnly 를 명시하여 사용하는데, 해당 Service 메서드의 실행 시간이 오래걸려 DB 커넥션을 오래 물고 있게 되면 전체적인 애플리케이션 성능에 문제가 생기게 됩니다.

그러니 이러한 부분을 주의해서 사용해야만 할 것 같습니다.


