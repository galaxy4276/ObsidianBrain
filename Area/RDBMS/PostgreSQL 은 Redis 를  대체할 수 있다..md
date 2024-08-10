#postgreSQL #RDBMS #redis #caching 

[원문](https://medium.com/redis-with-raphael-de-lio/can-postgres-replace-redis-as-a-cache-f6cba13386dc)

# 서론

원문에서 PostgreSQL 은 Redis 뿐만 아닌 다른 데이터베이스 시스템을 대체하여 사용할 수 있으며,
이렇게 함으로써 기술적인 복잡도를 낮추고 더 빠르게 작업을 진행할 수 있다고 한다.

>  "모든 일에 Postgres를 사용하세요(복잡성을 줄이고 더 빠르게 이동하는 방법)" - Stephan Schmidt

# PostgreSQL 로 redis 를 대체해야 할 이유?

## 기술 스택의 통합
Postgres 는 널리 사용되며 이미 사용하고 있을 가능성이 높다.
이를 캐시로 활용하여 DB 를 관리하면 유지 및 보수가 필요한 포인트가 줄어들고 기술스택을 간소화할 수 있다.

## 친근한 인터페이스
캐시 시스템에 SQL 을 활용할 수 있어 직접 고급 검색 및 변환 작업을 더 쉽게 처리할 수 있다.

## 비용
경우에 따라 Redis와 같은 별도의 캐싱 솔루션을 배포하는 것보다 기존 Postgres 리소스를 캐싱에 사용하는 것이 더 비용 효율적일 수 있다.
특히 인프라 예산이 제한된 환경에서는 기본 스토리지와 캐싱 모두에 Postgres를 사용하면 리소스 활용도를 높일 수 있다.


# 어떻게 대체할 수 있는가?
원문 내 Stephan, Partin 의 말에 따르면, UNLOGGED 테이블을 사용하여 Postgres 를 캐싱 서비스로 전환할 수 있다고 말한다.
[You Don’t Need a Dedicated Cache Service — PostgreSQL as a Cache](https://martinheinz.dev/blog/105)

## UNLOGGED Tables 란?
Postgres 에서 특정 테이블이 WAL(Write Ahead Log) 를 생성하지 못하도록 하는 방법이다.
> WAL 은 DB에 대한 모든 변경 사항이 실제로 DB 파일에 기록되기 전에 따로 기록해둔다.
> 이는 충돌이나 정전 시 데이터 무결성을 유지하는데 도움이 된다.

즉 WAL 을 off 해두면 성능이 향상된다.
모든 데이터 수정에 대해 WAL 과 데이터 파일에 모두 기록하면 쓰기 작업의 수가 2배로 늘기때문이다.
또한 모든 커밋된 트랜잭션이 ㅁ루리적으로 디스크에 기록되도록 하기 위해 WAL은 디스크 플러시(fsync) 를 강제로 수행하도록 설계되어 있으며 플러시 작업이 자주 발생하면 데이터가 안전하게 기록되었음을 인식할 때까지 대기 시간이 발생하므로 성능에 영향이 미친다.

```sql
CREATE UNLOGGED TABLE cache (  
id serial PRIMARY KEY,  
key text UNIQUE NOT NULL,  
value jsonb,  
inserted_at timestamp);  
  
CREATE INDEX idx_cache_key ON cache (key);
```

## Stored Procedures 를 활용한 Exipration

```sql
CREATE OR REPLACE PROCEDURE expire_rows (retention_period INTERVAL) AS  
$$  
BEGIN  
DELETE FROM cache  
WHERE inserted_at < NOW() - retention_period;  
  
COMMIT;  
END;  
$$ LANGUAGE plpgsql;  
  
CALL expire_rows('60 minutes'); -- This will remove rows older than 1 hour
```

사실 대부분의 최신 애플리케이션은 더 이상 저장 프로시저에 의존하지 않으며 오늘날 많은 소프트웨어 개발자는 저장 프로시저를 반대한다.
일반적으로 그 이유는 비즈니스 로직이 데이터베이스로 유출되는 것을 피하고 싶기 때문이며, 
또한 저장 프로시저의 수가 증가함에 따라 이를 관리하고 이해하는 것이 번거로울 수 있으며, 일정에 따라 이러한 저장 프로시저를 호출해야 한다. 
이를 위해서는 pg_cron이라는 확장 프로그램을 사용해야 합니다. 확장 프로그램을 설치한 후에도 스케줄러를 만들어야 한다.

```sql
-- Create a schedule to run the procedure every hour  
SELECT cron.schedule('0 * * * *', $$CALL expire_rows('1 hour');$$);  
  
-- List all scheduled jobs  
SELECT * FROM cron.job;
```

왠지 복잡성이 증가하는 것 같다..

## Stored Procedure 를 활용한 Eviction

```sql
CREATE OR REPLACE PROCEDURE lru_eviction(eviction_count INTEGER) AS  
$$  
BEGIN  
DELETE FROM cache  
WHERE ctid IN (  
SELECT ctid  
FROM cache  
ORDER BY last_read_timestamp ASC  
LIMIT eviction_count  
);  
  
COMMIT;  
END;  
$$ LANGUAGE plpgsql;  
  
-- Call the procedure to evict a specified number of rows  
CALL lru_eviction(10); -- This will remove the 10 least recently accessed rows
```

## Logged, UnLogged 성능 비교
**Unlogged Table:  
Latency:** 2.059 ms  
 **TPS:** 485,706168

**Logged Table:  
Latency:** 5.949 ms  
 **TPS:** 168,087557

쓰기 작업에 대한 처리 성능이 올랐을 뿐, 읽기 작업은 Shared Buffer 에 의존하므로 성능 차이가 유의미하지 않다.

아래는 Redis 의 벤치마킹 결과이다.

**Reading:  
Latency (p50):** 0.095 ms  
• **Requests per second (RPS):** 892.857,12

**Writing:  
Latency (p50):** 0.103 ms  
• **Requests per second (RPS):** 892.857,12


# Postgres 로 Redis 를 대체해도 정말 괜찮을까?
postgres 의 UNLOGGED Table 을 사용한다고 해도 Redis 에 비해서는 성능이 부족하다.
캐싱 서비스를 사용하는 주된 이유는 데이터 검색 시간을 개선하기 위해서이며,
UNLOGGED TABLE 은 읽기 성능을 향상시키지 못하지만, Redis 는 매우 빠른 읽기 작업에서 탁월한 성능을 발휘합니다.

Postgres를 관리하는 것이 더 쉬워 보일 수 있지만, Postgres를 캐시로 전환하는 것은 전용 캐싱 서비스의 이점을 제공하지 않는다. 
반면에  Redis는 배우고, 배포하고, 사용하기가 쉽다.

결과적으로 더 빠른 성능과 단순성을 원한다면 Redis와 같은 실제 캐싱 서비스를 선택하는 것이 확실한 선택임
