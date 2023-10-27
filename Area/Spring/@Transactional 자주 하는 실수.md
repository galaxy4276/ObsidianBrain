![[springboot-banner-01.jpg]]
# 1. 동일한 클래스 내에서 호출

```java
public void registerAccount(Account acc) {
    createAccount(acc);

    notificationSrvc.sendVerificationEmail(acc);
}

@Transactional
public void createAccount(Account acc) {
    accRepo.save(acc);
    teamRepo.createPersonalTeam(acc);
}
```

위 사례에서는 `registerAccount()` 를 호출할 때 사용자의 저장, 팀 생성은 트랜잭션에서 수행되지 않는다.

트랜잭션은 OOP 에 의해 구동되며 따라 다른 빈에서 빈을 호출할 때 처리가 발생한다.

즉 메서드가 동일한 클래스에서 호출되므로 프록시가 적용되지 않는다.

( AOP 구조를 생각해보면 이해가 쉽다. )

`@Cacheable` 과 같은 어노테이션 또한 마찬가지이다.

이 문제는 3가지 방법으로 해결가능하다.

1. Self-injection ( 자체 주입 )
2. 다른 추상화 계층 생성
3. `createAccount` 호출을 래핑하여 `registerAccount` 메서드에서 `TransactionTemplate` 을 사용하기

## 1-1. Self Injection

명확하지는 않지만 @Transaction 에 매개변수가 포함된 경우 로직 중복을 피할 수 있다.

```java
@Service
@RequiredArgsConstructor
public class AccountService {
    private final AccountRepository accRepo;
    private final TeamRepository teamRepo;
    private final NotificationService notificationSrvc;
    @Lazy private final AccountService self;

    public void registerAccount(Account acc) {
        self.createAccount(acc);

        notificationSrvc.sendVerificationEmail(acc);
    }

    @Transactional
    public void createAccount(Account acc) {
        accRepo.save(acc);
        teamRepo.createPersonalTeam(acc);
    }
}
```

<aside>
💡 Lombok 을 사용하는 경우 @Lazy 를 추가해야한다.

</aside>

# 2. 모든 예외 처리

기본적으로 롤백은 런타임 예외와 오류에서만 발생한다.

그러나 코드에는 트랜잭션을 롤백해야하는 `Checked Excepiton`이 포함되어야 할 수 있다.

```java
@Transactional(rollbackFor = StripeException.class)
public void createBillingAccount(Account acc) throws StripeException {
    accSrvc.createAccount(acc);

    stripeHelper.createFreeTrial(acc);
}
```

# 3. 트랜잭션 격리 수준과 전파(isolation & propagation)

원문 참고

# 4. 트랜잭션은 데이터에 대해 Lock 을 수행하지 않는다

```java
@Transactional
public List<Message> getAndUpdateStatuses(Status oldStatus, Status newStatus, int batchSize) {
    List<Message> messages = messageRepo.findAllByStatus(oldStatus, PageRequest.of(0, batchSize));
    
    messages.forEach(msg -> msg.setStatus(newStatus));

    return messageRepo.saveAll(messages);
}
```

DB 에서 무언가를 `SELECT` 한 다음 업데이트하는 구조가 있다면 이 모든 작업이 트랜잭션에서 이루어지고 트랜잭션은 원자성이 존재하므로 위 코드는 단일 요청으로 실행될 것이라 생각할 수 있다.

**문제는 다른 애플리케이션 인스턴스가 첫 번째 인스턴스와 동시에 `findAllByStatus` 를 호출하는 것을 막을 방법이 없다는 것이다.**

결과적으로 메서드는 두 인스턴스 모두에서 동일한 데이터를 반환하고 데이터는 두 번 처리된다.

- GPT 부연 설명
    
    네, 맞습니다. 해당 내용은 데이터베이스 트랜잭션 및 병렬 요청에 관한 것으로, 두 개 이상의 사용자가 동시에 특정 데이터를 선택하고 업데이트하려고 할 때 발생할 수 있는 문제를 설명하고 있습니다.
    
    이해를 돕기 위해 더 자세히 설명하겠습니다.
    
    1. 두 개 이상의 사용자가 동시에 **`findAllByStatus`** 메서드를 호출합니다. 이 메서드는 데이터베이스에서 특정 상태(status)를 가진 데이터를 선택하는 쿼리를 실행합니다.
    2. 각 사용자의 요청은 별도의 트랜잭션 내에서 처리됩니다. 트랜잭션은 일반적으로 원자성(atomicity)을 가지며, 이는 모든 연산이 성공 또는 실패로 처리되어야 함을 의미합니다.
    3. 하지만 병렬로 실행되는 두 트랜잭션이 동일한 데이터를 읽는다면, 동일한 결과를 얻을 것입니다. 예를 들어, 두 번째 사용자가 데이터베이스에서 상태가 "활성"인 모든 항목을 읽기 시작할 때, 첫 번째 사용자가 이미 데이터를 선택했고 아직 업데이트를 수행하지 않았다면, 두 사용자는 동일한 데이터를 읽게 됩니다.
    4. 이것은 데이터 일관성 문제를 일으킬 수 있습니다. 즉, 동시에 실행되는 여러 트랜잭션 간에 데이터 일관성이 깨질 수 있으며, 업데이트 작업이 중복으로 수행될 수 있습니다.
    
    이러한 문제를 해결하기 위해서는 동시성 제어 방법을 사용해야 합니다. 예를 들어, 데이터를 읽고 업데이트하기 전에 해당 데이터를 잠금(lock)으로 보호하거나, 트랜잭션 간 충돌을 감지하고 처리하는 메커니즘을 구현해야 합니다. 이렇게 하면 동시에 여러 사용자가 동일한 데이터를 수정하려고 할 때 충돌을 방지하고 데이터 일관성을 유지할 수 있습니다.
    

## 4-1. UPDATE 를 위한 SELECT(비관적 락)

```sql
UPDATE message
SET status = :newStatus
WHERE id in (
   SELECT m.id FROM message m WHERE m.status = :oldStatus LIMIT :limit
   FOR UPDATE SKIP LOCKED)
RETURNING *
```

위 사례에서 `SELECT` 가 수행되면 `UPDATE` 가 끝낼 때 까지 해당 `row(행)` 가 차단된다.

쿼리는 변경된 모든 행을 반환할 것이다.

# 5. 두 개의 서로 다른 데이터 출처

```java
@Transactional
public void saveAccount(Account acc) {
    dataSource1Repo.save(acc);
    dataSource2Repo.save(acc);
}
```

위 사례의 경우 트랜잭션으로 처리 되는 `save` 는 `TransactionManager` 에서 기본값으로 지정된 단 하나의 대상만 처리된다.

스프링은 이 상황에 대해 2가지 방안을 제공한다.

## ChainedTransactionManager

```
1st TX Platform: begin
  2nd TX Platform: begin
    3rd Tx Platform: begin
    3rd Tx Platform: commit
  2nd TX Platform: commit <-- fail
  2nd TX Platform: rollback  
1st TX Platform: rollback
```

`ChainedTransactionManager` 는 여러 데이터 소스를 선언하는 방법으로 예외가 발생할 경우 롤백이 역순으로 발생한다.

**위 사례에서 2nd TX 에서 예외가 발생할 경우 2개의 대상에 대해서만 롤백이 수행된다.**

## JtaTransactionManager

이 관리자를 사용하면 2단계 커밋을 기반으로 완전히 지원되는 분산 트랜잭션을 사용할 수 있다.

# 원문

**[Spring @Transactional mistakes everyone did](https://medium.com/javarevisited/spring-transactional-mistakes-everyone-did-31418e5a6d6b)**