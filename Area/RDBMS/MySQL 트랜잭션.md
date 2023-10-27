---
tags: RDBMS, MySQL, transaction
---
# MySQL 트랜잭션

태그: 트랜잭션, Lock, MySQL, RDB
Date: September 22, 2023 9:55 PM
공개 여부: 공개
설명: MySQL 에서 중요한 트랜잭션에 대해 공부
카테고리: 데이터베이스

![Untitled](Untitled%2032.png)

<aside>
💡 데이터베이스에서 안정성을 지원하기 위한 너무 중요한 파트다.
직접 정리보단 좋은 레퍼런스를 많이 첨부했으니 반복해서 읽고 자기 것으로 만들어야 한다.

</aside>

# 트랜잭션

트랜잭션은 작업의 완전성을 보장해주는 것

논리적인 작업 여러 개중 하나라도 처리하지 못할 경우 원 상태로 복구하여 `Partial Update` 발생을 방지해준다.

# 트랜잭션 주의 사항

백엔드에서 요청을 받고 처리하는 일련의 비즈니스 로직이 있다고 가정할 때

항상 시작부터 종료까지 모든 과정을 하나의 트랜잭션으로 묶는다는 생각은 위험하다.

DB 커넥션의 수는 제한되어있고 트랜잭션이 오래 점유될 수록 다른 요청 처리는 늦어지기 때문이다.

**트랜잭션은 가능하면 가장 작은 단위로 처리해야한다.**

```java
사용자 로그인 여부 확인
---> 트랜잭션 시작
사용자의 입력 내용 DBMS 저장
첨부 파일 정보 DBMS 저장
<--- 트랜잭션 종료
...
```

# MySQL 엔진의 잠금

MySQL 에서 사용되는 잠금은 크게 스토리지 엔진 레벨과 MySQL 엔진 레벨로 나눈다.

엔진 레벨 잠금은 모든 스토리지 엔진에 영향을 미치지만, 스토리지 엔진 잠금은 엔진 간 성능에 영향을 미치지 않는다.

이제 잠금의 종류에 대해 알아보자.

## Shared Lock 과 Exclusive Lock

### Shared Lock(Read Lock)

공유 락이 걸린 데이터에 대해서 읽기(SELECT) 연산만 수행 가능하며 쓰기 연산은 불가능하다.

락이 걸린 데이터는 다른 트랜잭션에서도 똑같이 공유 락을 획득할 수 있으나 배타 락은 획득할 수 없다.

**조회된 데이터가 트랜잭션 내내 변경되지 않음을 보장한다.**

### Exclusive Lock

다른 트랜잭션은 배타락이 걸린 데이터에 대해 읽기, 쓰기 작업이 모두 불가능하다.

**배타 락을 획득한 트랜잭션은 해당 데이터에 대한 독점권을 갖는다.**

## Global Lock

하나의 연결 세션에서  Global Lock 을 획득하면 다른 세션에서 SELECT 를 제외한 대부분의 DML, DDL 대기

백업 용도로 주로 사용되며 우선 처리되는 트랜잭션이 있다면 Global Lock 이 대기상태로 기다린다.

<aside>
💡 MySQL 8.0 부터 조금 더 가벼운 Global Lock 지원을 위해 Backup Lock 이 도입되었다.

</aside>

## Table Lock

```sql
LOCK TABLE table_name [ READ | WRITE ];
```

명시적 또는 묵시적으로 수행되며, 테이블 단위로 획득가능하다.

InnoDB 의 경우 스토리지 엔진 차원에서 레코드 기반의 잠금을 지원하기 때문에 단순 데이터 변경 쿼리로 인해 묵시적 테이블 락이 설정되지는 않는다.

## Named Lock

`GET_LOCK` 함수를 이용해 임의의 문자열에 대해 잠금을 설정할 수 있다.

스키마 객체(테이블, 뷰 등)의 이름을 변경하는 경우 획득된다.

## Metadata Lock

데이터베이스 객체(테이블, 뷰 등 메타데이터) 의 이름이나 구조를 변경할 때 사용된다.

## Record Lock

레코드가 아닌 인덱스에 Lock 걸리는 Lock 을 의미한다.

락 관련된 부분은 책보다 정리가 잘 되어있는 레퍼런스를 찾아서 첨부한다.

**[Lock의 종류 (Shared Lock, Exclusive Lock, Record Lock, Gap Lock, Next-key Lock)](https://jaeseongdev.github.io/development/2021/06/16/Lock%EC%9D%98-%EC%A2%85%EB%A5%98-(Shared-Lock,-Exclusive-Lock,-Record-Lock,-Gap-Lock,-Next-key-Lock)/)**

디비 격리수준에 대해서는 테코블을 참고하는 게 가장 좋은 것 같다.

[[Tecoble -   트랜잭션 격리 수준  ]]

# References

[MySQL 엔진 잠금 (Lock) - nahyungmin](https://nahyungmin.tistory.com/81)

**[[MySQL] Metadata Lock - 참된오징어의 개발 블로그 - 티스토리](https://ohtaeg.tistory.com/16)**

**[Lock의 종류 (Shared Lock, Exclusive Lock, Record Lock, Gap Lock, Next-key Lock)](https://jaeseongdev.github.io/development/2021/06/16/Lock%EC%9D%98-%EC%A2%85%EB%A5%98-(Shared-Lock,-Exclusive-Lock,-Record-Lock,-Gap-Lock,-Next-key-Lock)/)**

[[Tecoble -   트랜잭션 격리 수준  ]]

**[MySQL 8.0의 공유 락(Shared Lock)과 배타 락(Exclusive Lock)](https://hudi.blog/mysql-8.0-shared-lock-and-exclusive-lock/)**