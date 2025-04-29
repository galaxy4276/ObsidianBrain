#redis #redis-pipeline #caching #optimization
## 1. Redis Pipeline 개념 및 기본 원리

Redis Pipeline은 여러 Redis 명령을 한 번에 서버로 전송하여 각 명령의 응답을 기다리지 않고 일괄 처리하는 최적화 기법입니다. 일반적인 Redis 통신에서는 클라이언트가 명령을 전송하고 서버의 응답을 받은 후 다음 명령을 보내는 요청-응답 사이클을 반복합니다. 그러나 이 방식은 네트워크 지연 시간으로 인해 성능이 제한될 수 있습니다.

### 1.1 Redis Pipeline의 작동 원리
Redis Pipeline은 다음과 같은 단계로 작동합니다
1. 클라이언트는 여러 명령을 연속적으로 서버에 전송합니다.
2. 서버는 이러한 명령을 순차적으로 처리하고 응답을 큐에 저장합니다.
3. 클라이언트는 모든 응답을 한 번에 수신합니다.

이 과정을 통해 네트워크 왕복(round-trip) 시간을 최소화하고 시스템 호출 오버헤드를 줄여 전체 처리량을 크게 향상시킵니다.

```
클라이언트                            서버
    |                                |
    | --- 명령1, 명령2, 명령3 --->   |
    |                                | (순차적으로 명령 처리)
    |                                |
    | <--- 응답1, 응답2, 응답3 ---   |
    |                                |
```

### 1.2 Redis Pipeline과 일반 명령 실행의 차이
일반적인 Redis 명령 실행 방식과 Pipeline을 사용한 방식의 가장 큰 차이점은 네트워크 통신 횟수입니다. 예를 들어, 10개의 명령을 실행하는 경우:
- **일반 방식**: 10번의 요청과 10번의 응답, 총 20번의 네트워크 통신
- **Pipeline 방식**: 1번의 요청과 1번의 응답, 총 2번의 네트워크 통신
이 차이는 명령 수가 많을수록, 네트워크 지연이 클수록 더 뚜렷하게 나타납니다.

redis.io[1](https://redis.io/docs/latest/develop/use/pipelining/)에 따르면, Redis Pipeline은 단순히 네트워크 지연 시간을 줄이는 것 외에도 초당 수행할 수 있는 작업 수를 크게 향상시킵니다. 이는 여러 명령이 일반적으로 단일 read() 시스템 호출로 읽히고, 여러 응답이 단일 write() 시스템 호출로 전달되기 때문입니다.

## 2. Redis Pipeline의 이점과 한계
### 2.1 이점
1. **지연 시간 감소**: 네트워크 왕복 시간을 최소화하여 전체 지연 시간을 크게 줄입니다.
2. **처리량 향상**: Last9[2](https://last9.io/blog/how-to-make-the-most-of-redis-pipeline/)의 벤치마크에 따르면, 기본 파이프라이닝(10개 명령)으로 초당 5만 명령에서 초당 50만 명령으로 10배 향상되며, 최적화된 파이프라인 배치(100개 명령)는 초당 100만+ 명령(20배+)까지 성능을 끌어올릴 수 있습니다.
3. **시스템 호출 오버헤드 감소**: 여러 명령과 응답이 각각 단일 시스템 호출로 처리되므로 커널 스케줄러의 컨텍스트 전환을 최소화합니다.
4. **높은 처리 효율성**: 특히 대량의 유사한 명령을 실행할 때(예: 대규모 데이터셋 채우기, 여러 키 업데이트) 효율성이 크게 향상됩니다.
### 2.2 한계 및 고려사항
1. **메모리 사용량 증가**: 서버는 파이프라인 명령의 모든 응답을 큐에 저장해야 하므로 대규모 배치의 경우 서버 측 메모리 사용량이 증가할 수 있습니다. redis.io[1](https://redis.io/docs/latest/develop/use/pipelining/)는 이를 관리하기 위해 합리적인 크기(예: 10,000개 명령)의 배치로 나누어 전송하는 것을 권장합니다.
2. **의존적 명령에 대한 제한**: 이전 명령의 결과에 의존하는 명령(예: "읽기, 계산, 쓰기" 시퀀스)의 경우 파이프라이닝이 적합하지 않을 수 있습니다. 이런 경우엔 Lua 스크립팅이 더 효과적일 수 있습니다.
3. **구현 복잡성**: 간단한 동기식 상호작용에 비해 파이프라인을 구현하고 오류 처리를 강화하는 것은 더 복잡할 수 있습니다.
4. **시스템 제약 사항**: 빠른 네트워크(예: 루프백 인터페이스)에서도 커널 스케줄러와 시스템 호출 오버헤드가 여전히 지연을 유발할 수 있으므로, 이러한 시스템 제약을 고려해야 합니다.

GeeksforGeeks[3](https://www.geeksforgeeks.org/complete-guide-to-redis-pipelining/)에 따르면, 일부 명령은 이전 명령의 결과에 의존하기 때문에 파이프라이닝에 적합하지 않을 수 있습니다. 또한 너무 많은 명령이 큐에 대기하고 신속하게 처리되지 않으면 클라이언트 측에서 상당한 메모리 사용을 초래할 수 있습니다.

## 3. 다양한 언어에서의 Redis Pipeline 구현
### 3.1 Java에서의 Redis Pipeline
Java에서는 Jedis 라이브러리를 사용하여 Redis Pipeline을 구현할 수 있습니다. Jedis에서 Pipeline 객체를 생성하고, 명령을 추가한 후 실행하는 방식입니다.
#### 기본 예제:
```java
// Jedis 클라이언트 생성
Jedis jedis = new Jedis("localhost", 6379);

// Pipeline 생성
Pipeline pipeline = jedis.pipelined();

// 명령 추가
pipeline.set("user:1:name", "홍길동");
pipeline.set("user:1:email", "hong@example.com");
pipeline.incr("user:1:visits");
pipeline.expire("user:1:visits", 3600);

// 파이프라인 실행
List<Object> results = pipeline.syncAndReturnAll();

// 결과 처리
for (Object result : results) {
    System.out.println(result);
}

// 연결 종료
jedis.close();
```

#### Spring Data Redis에서의 사용 예
```java
@Autowired
private RedisTemplate<String, Object> redisTemplate;

public void executePipelinedCommands() {
    List<Object> results = redisTemplate.executePipelined(new RedisCallback<Object>() {
        @Override
        public Object doInRedis(RedisConnection connection) throws DataAccessException {
            StringRedisConnection stringRedisConn = (StringRedisConnection) connection;
            
            // 파이프라인 명령 실행
            stringRedisConn.set("product:1", "스마트폰");
            stringRedisConn.set("product:2", "노트북");
            stringRedisConn.incr("products:count");
            stringRedisConn.expire("products:count", 86400);
            
            // null 반환은 결과가 List<Object>로 수집됨을 의미
            return null;
        }
    });
    
    // 결과 처리
    for (Object result : results) {
        System.out.println(result);
    }
}
```

Spring Data Redis는 `executePipelined` 메서드를 제공하여 파이프라인 사용을 간소화합니다. 위 예제에서는 제품 정보를 설정하고, 제품 수를 증가시키며, 만료 시간을 설정하는 작업을 한 번의 파이프라인으로 수행합니다.

redis.io[4](https://redis.io/docs/latest/develop/clients/jedis/transpipe/)에 따르면, Jedis의 Pipeline 명령은 표준 명령 메서드와 유사하게 작동하지만, `Response<Type>` 객체를 반환합니다. 이 객체는 파이프라인 실행이 완료된 후에만 유효한 결과를 포함합니다.

### 3.2 Python에서의 Redis Pipeline
Python에서는 `redis-py` 라이브러리를 사용하여 Redis Pipeline을 구현할 수 있습니다. 컨텍스트 관리자(context manager)를 사용하거나 파이프라인 객체를 직접 생성하여 사용할 수 있습니다.

#### 기본 예제:
```python
import redis

# Redis 클라이언트 생성
r = redis.Redis(host='localhost', port=6379, db=0)

# 파이프라인 생성 및 실행
pipe = r.pipeline()
pipe.set('user:1:name', '김철수')
pipe.set('user:1:email', 'kim@example.com')
pipe.incr('user:1:visits')
pipe.expire('user:1:visits', 3600)
results = pipe.execute()

print(results)  # ['OK', 'OK', 1, True] 와 같은 결과 출력
```

#### 컨텍스트 관리자 사용 예:
```python
import redis

r = redis.Redis(host='localhost', port=6379, db=0)

# with 구문을 사용한 파이프라인
with r.pipeline() as pipe:
    # 트랜잭션 시작
    pipe.multi()
    pipe.set('cart:1:item:1', '노트북')
    pipe.set('cart:1:item:2', '마우스')
    pipe.incr('cart:1:count')
    pipe.expire('cart:1:count', 1800)
    # 파이프라인 실행
    results = pipe.execute()
    
print(results)  # ['OK', 'OK', 1, True] 와 같은 결과 출력
```

#### 성능 비교 예제:
redis-py 문서[5](https://redis-py.readthedocs.io/en/stable/examples/pipeline_examples.html)에 제공된 다음 예제는 Redis pipeline의 성능 향상을 보여줍니다:
```python
from datetime import datetime

incr_value = 100000
r = redis.Redis(decode_responses=True)

# 파이프라인 없이
r.set("incr_key", "0")
start = datetime.now()
for _ in range(incr_value):
    r.incr("incr_key")
res_without_pipeline = r.get("incr_key")
time_without_pipeline = (datetime.now() - start).total_seconds()
print(f"파이프라인 없이: {time_without_pipeline}초, 결과: {res_without_pipeline}")

# 파이프라인 사용
r.set("incr_key", "0")
start = datetime.now()
pipe = r.pipeline()
for _ in range(incr_value):
    pipe.incr("incr_key")
pipe.get("incr_key")
res_with_pipeline = pipe.execute()[-1]
time_with_pipeline = (datetime.now() - start).total_seconds()
print(f"파이프라인 사용: {time_with_pipeline}초, 결과: {res_with_pipeline}")
```

이 예제는 파이프라인을 사용하지 않을 때 약 21.76초가 소요되는 반면, 파이프라인을 사용할 때는 약 2.36초만 소요되어 약 9배의 성능 향상을 보여줍니다.

### 3.3 Node.js에서의 Redis Pipeline
Node.js에서는 `node-redis` 또는 `ioredis` 라이브러리를 사용하여 Redis Pipeline을 구현할 수 있습니다. 여기서는 두 가지 인기 있는 라이브러리의 사용 예를 살펴보겠습니다.

#### node-redis 사용 예:
```javascript
const { createClient } = require('redis');

async function example() {
    const client = createClient();
    await client.connect();
    
    // Promise.all을 사용한 자동 파이프라이닝
    const results1 = await Promise.all([
        client.set('seat:0', '#0'),
        client.set('seat:1', '#1'),
        client.set('seat:2', '#2')
    ]);
    console.log(results1); // ['OK', 'OK', 'OK']
    
    // multi()와 execAsPipeline()을 사용한 명시적 파이프라인
    const results2 = await client.multi()
        .set('seat:3', '#3')
        .set('seat:4', '#4')
        .set('seat:5', '#5')
        .execAsPipeline();
    console.log(results2); // ['OK', 'OK', 'OK']
    
    await client.quit();
}

example().catch(console.error);
```

redis.io[6](https://redis.io/docs/latest/develop/clients/nodejs/transpipe/)에 따르면, Node.js에서는 두 가지 방법으로 파이프라인을 구현할 수 있습니다:
1. `Promise.all()`을 사용하여 이벤트 루프의 동일한 "틱" 내에서 실행되는 명령을 자동으로 파이프라인화
2. `multi()` 메서드를 사용하여 파이프라인 객체를 생성하고 `execAsPipeline()`을 호출하여 실행

#### ioredis 사용 예:
```javascript
const Redis = require('ioredis');
const redis = new Redis();

async function example() {
    // 파이프라인 생성
    const pipeline = redis.pipeline();
    
    // 명령 추가
    pipeline.set('product:1:name', '스마트워치');
    pipeline.set('product:1:price', 299.99);
    pipeline.incr('products:count');
    pipeline.expire('products:count', 86400);
    
    // 파이프라인 실행
    const results = await pipeline.exec();
    console.log(results);
    // [[null, 'OK'], [null, 'OK'], [null, 1], [null, 1]] 형태로 결과 반환
    
    // 연결 종료
    redis.quit();
}

example().catch(console.error);
```

KoalaTea.io[7](https://koalatea.io/nodejs-redis-pipeline/)에 따르면, ioredis에서 파이프라인을 구현할 때 먼저 `redis.pipeline()`으로 파이프라인 인스턴스를 생성한 다음, 명령을 추가하고, `exec()`를 호출하여 모든 명령을 한 번에 실행합니다. 응답은 `[에러, 결과]` 쌍의 배열로 반환됩니다.

#### 성능 개선 사례
Medium[8](https://medium.com/@239yash/how-to-implement-redis-pipelining-in-node-js-using-ioredis-ba3eab32f1a7)의 한 사례에 따르면, ioredis의 파이프라인을 사용하여 50,000개의 SET 명령을 실행한 결과:
- 순차 실행: 약 2.6초 소요
- 파이프라인 사용: 약 243밀리초 소요 (약 10배 성능 향상)
```javascript
const express = require('express');
const Redis = require('ioredis');
const app = express();
const redis = new Redis();

// 순차 실행 엔드포인트
app.get('/run-sequential', async (req, res) => {
    console.time('Sequential');
    
    for(let i = 0; i < 50000; i++) {
        await redis.set('foo', 'test-test');
    }
    
    console.timeEnd('Sequential');
    res.send('Sequential process completed');
});

// 파이프라인 실행 엔드포인트
app.get('/run-pipeline', async (req, res) => {
    console.time('Pipeline');
    
    const pipeline = redis.pipeline();
    
    for(let i = 0; i < 50000; i++) {
        pipeline.set('foo', 'test-test');
    }
    
    await pipeline.exec();
    
    console.timeEnd('Pipeline');
    res.send('Pipeline process completed');
});

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});
```

### 3.4 Go에서의 Redis Pipeline
Go에서는 `go-redis` 라이브러리를 사용하여 Redis Pipeline을 구현할 수 있습니다. Go의 동시성 모델과 결합하여 효율적인 Redis 작업을 수행할 수 있습니다.
#### 기본 예제
```go
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    
    // Redis 클라이언트 생성
    rdb := redis.NewClient(&redis.Options{
        Addr: "localhost:6379",
        DB:   0,
    })
    
    // 파이프라인 생성
    pipe := rdb.Pipeline()
    
    // 명령 추가
    incr := pipe.Incr(ctx, "pipeline_counter")
    pipe.Expire(ctx, "pipeline_counter", time.Hour)
    
    // 파이프라인 실행
    _, err := pipe.Exec(ctx)
    if err != nil {
        panic(err)
    }
    
    // 명령 결과 확인
    fmt.Println(incr.Val()) // 증가된 값 출력
}
```

#### Pipelined 헬퍼 함수 사용 예
```go
package main

import (
    "context"
    "fmt"
    "time"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    
    // Redis 클라이언트 생성
    rdb := redis.NewClient(&redis.Options{
        Addr: "localhost:6379",
        DB:   0,
    })
    
    // Pipelined 헬퍼 함수 사용
    var incr *redis.IntCmd
    
    _, err := rdb.Pipelined(ctx, func(pipe redis.Pipeliner) error {
        incr = pipe.Incr(ctx, "pipelined_counter")
        pipe.Expire(ctx, "pipelined_counter", time.Hour)
        return nil
    })
    
    if err != nil {
        panic(err)
    }
    
    // 결과 확인
    fmt.Println(incr.Val())
}
```

#### 여러 명령 반복 처리 예
```go
package main

import (
    "context"
    "fmt"

    "github.com/redis/go-redis/v9"
)

func main() {
    ctx := context.Background()
    
    // Redis 클라이언트 생성
    rdb := redis.NewClient(&redis.Options{
        Addr: "localhost:6379",
        DB:   0,
    })
    
    // 여러 키 설정
    for i := 0; i < 100; i++ {
        rdb.Set(ctx, fmt.Sprintf("key%d", i), fmt.Sprintf("value%d", i), 0)
    }
    
    // 파이프라인으로 여러 키 가져오기
    cmds, err := rdb.Pipelined(ctx, func(pipe redis.Pipeliner) error {
        for i := 0; i < 100; i++ {
            pipe.Get(ctx, fmt.Sprintf("key%d", i))
        }
        return nil
    })
    
    if err != nil {
        panic(err)
    }
    
    // 결과 처리
    for _, cmd := range cmds {
        fmt.Println(cmd.(*redis.StringCmd).Val())
    }
}
```

Uptrace[9](https://redis.uptrace.dev/guide/go-redis-pipelines.html)에 따르면, Go에서의 Redis Pipeline은 명령을 큐에 넣고 `Exec` 메서드로 한 번에 실행하는 방식으로 작동합니다. 또한 `Pipelined` 헬퍼 함수를 사용하면 함수가 종료될 때 자동으로 `Exec`가 호출되므로 더 간결한 코드를 작성할 수 있습니다.

## 4. Redis Pipeline vs. Transactions
Redis는 명령을 일괄 처리하는 두 가지 주요 메커니즘인 Pipeline과 Transaction을 제공합니다. 이 두 가지 접근 방식은 비슷해 보이지만 중요한 차이점이 있습니다.
### 4.1 주요 차이점
#### 목적:
- **Pipeline**: 주로 네트워크 최적화를 위한 것으로, 여러 명령을 버퍼링하여 한 번에 서버로 전송합니다.
- **Transaction**: 명령의 원자성(atomicity)을 보장하기 위한 것으로, 다른 클라이언트의 명령이 중간에 끼어들지 않도록 합니다.
#### 구현:
- **Pipeline**: 클라이언트에서 단순히 명령을 큐에 넣고 한 번에 전송하는 방식입니다.
- **Transaction**: MULTI 명령으로 시작하고 EXEC 명령으로 종료되며, 그 사이의 모든 명령이 하나의 원자적 단위로 실행됩니다.

#### 오류 처리:
- **Pipeline**: 개별 명령에 오류가 있어도 다른 명령은 정상적으로 실행됩니다.
- **Transaction**: 명령 큐에 오류가 있으면 트랜잭션 전체가 실패합니다(Redis 2.6.5부터).

#### 연결 문제:

- **Pipeline**: 연결이 끊어지면 처리 방식이 클라이언트 구현에 따라 다릅니다. 예를 들어 Node.js의 경우, Promise.all()로 파이프라인을 구현하면 연결이 복구된 후 중단된 지점부터 실행을 계속하지만, multi()로 구현한 파이프라인은 실행되지 않은 나머지 명령을 모두 폐기합니다.
- **Transaction**: 연결이 끊어지면 트랜잭션은 중단되고 모든 명령이 실행되지 않습니다.

### 4.2 코드 비교 예시
**Pipeline (JavaScript)**
```javascript
const redis = require('redis');
const client = redis.createClient();

// Pipeline 사용
const commands = [
    ['set', 'key1', 'value1'],
    ['set', 'key2', 'value2'],
    ['incr', 'counter']
];

client.multi(commands).exec((err, replies) => {
    console.log(replies); // ['OK', 'OK', 1]
});
```

**Transaction (JavaScript):**
```javascript
const redis = require('redis');
const client = redis.createClient();

// Transaction 사용
client.multi()
    .set('key1', 'value1')
    .set('key2', 'value2')
    .incr('counter')
    .exec((err, replies) => {
        console.log(replies); // ['OK', 'OK', 1]
    });
```

위 코드는 비슷해 보이지만, 트랜잭션은 원자성을 보장하기 위해 MULTI/EXEC 명령을 사용하여 명령을 감싸는 반면, 파이프라인은 단순히 명령을 그룹화하여 네트워크 최적화를 수행합니다.

### 4.3 WATCH 명령과 낙관적 잠금
Redis 트랜잭션에서는 WATCH 명령을 사용하여 낙관적 잠금(optimistic locking)을 구현할 수 있습니다. 이는 트랜잭션이 시작되기 전에 특정 키를 감시하고, 트랜잭션이 실행되기 전에 해당 키가 변경되면 트랜잭션을 중단하는 메커니즘입니다.
```javascript
// 낙관적 잠금 예제 (Node.js)
async function incrementValueSafely(key) {
    const client = redis.createClient();
    
    try {
        while (true) {
            // 키 감시 시작
            await client.watch(key);
            
            // 현재 값 가져오기
            const currentValue = await client.get(key);
            const newValue = parseInt(currentValue || '0') + 1;
            
            // 트랜잭션 시작
            const result = await client.multi()
                .set(key, newValue)
                .exec();
            
            // 성공적으로 실행되면 루프 종료
            if (result) {
                return newValue;
            }
            // 실패하면 재시도
            console.log('트랜잭션 충돌, 재시도 중...');
        }
    } finally {
        await client.quit();
    }
}
```

이러한 접근 방식은 여러 클라이언트가 동시에 같은 키를 수정하려는 경우 특히 유용합니다. 파이프라인은 이러한 종류의 동시성 제어를 제공하지 않습니다.

Stack Overflow[10](https://stackoverflow.com/questions/29327544/pipelining-vs-transaction-in-redis)에 따르면, "파이프라이닝은 주로 네트워크 최적화이다. 본질적으로 클라이언트가 일련의 명령을 버퍼링하여 한 번에 서버로 전송하는 것을 의미한다. 트랜잭션은 서버 측 기능으로, 실행 중에 다른 명령이 개입하지 않도록 보장한다."

## 5. Redis Pipeline vs. Lua 스크립팅
Redis에서 명령을 최적화하고 복잡한 작업을 수행하는 또 다른 방법은 Lua 스크립팅을 사용하는 것입니다. 파이프라인과 Lua 스크립팅은 모두 성능 최적화에 사용될 수 있지만 다른 목적과 사용 사례가 있습니다.

### 5.1 주요 차이점
#### 실행 위치:
- **Pipeline**: 클라이언트에서 여러 명령을 모아 서버로 한 번에 전송합니다. 각 명령은 서버에서 개별적으로 처리됩니다.
- **Lua 스크립팅**: 전체 스크립트가 서버에서 실행되며, 모든 명령 처리 및 중간 결과 조작이 서버 내에서 이루어집니다.
#### 중간 결과 처리:
- **Pipeline**: 이전 명령의 결과에 기반하여 다음 명령을 동적으로 결정할 수 없습니다.
- **Lua 스크립팅**: 중간 결과를 읽고 조작한 후 다음 작업을 결정할 수 있습니다.

#### 원자성:
- **Pipeline**: 기본적으로 원자성을 보장하지 않습니다(트랜잭션과 함께 사용하지 않는 한).
- **Lua 스크립팅**: 스크립트 전체가 원자적으로 실행됩니다. 모든 명령이 실행되거나 아무것도 실행되지 않습니다.

#### 네트워크 효율성:
- **Pipeline**: 한 번의 네트워크 왕복으로 여러 명령을 전송하여 네트워크 지연을 줄입니다.
- **Lua 스크립팅**: 스크립트 자체만 전송하므로 많은 명령을 포함하는 복잡한 로직의 경우 더 효율적일 수 있습니다.

### 5.2 코드 비교 예시
**Pipeline (Python):**
```python
import redis

r = redis.Redis()

# 파이프라인 사용
pipe = r.pipeline()
pipe.hget('cart:123', 'total')
pipe.hget('cart:123', 'items')
pipe.hincrby('cart:123', 'visits', 1)
results = pipe.execute()

total = results[0]
items = results[1]
# 여기서 total과 items를 기반으로 무언가를 하고 싶다면
# 파이프라인 외부에서 별도로 처리해야 함
```

**Lua 스크립팅 (Python):**
```python
import redis

r = redis.Redis()

# Lua 스크립트 사용
lua_script = """
local total = redis.call('HGET', KEYS[1], 'total')
local items = redis.call('HGET', KEYS[1], 'items')
redis.call('HINCRBY', KEYS[1], 'visits', 1)

-- 중간 결과를 기반으로 로직 수행
if tonumber(total) > 100 and tonumber(items) > 5 then
    redis.call('SADD', KEYS[2], KEYS[1])
    return {total, items, 'added to premium'}
else
    return {total, items, 'regular customer'}
end
"""

# 스크립트 실행
result = r.eval(lua_script, 2, 'cart:123', 'premium_customers')
print(result)  # [total값, items값, 상태 메시지]
```

이 예제에서 Lua 스크립트는 중간 결과를 바탕으로 조건부 로직을 실행할 수 있지만, 파이프라인은 그럴 수 없습니다.

### 5.3 성능 비교
Medium[11](https://medium.com/@krittaboon.t/an-optimal-solution-to-use-redis-in-python-a4e5cee3b980)에 따르면, 같은 일을 하는 간단한 예제에서 Lua 스크립트가 파이프라인보다 더 나은 성능을 보였습니다. 이는 Lua 스크립트가 단일 네트워크 왕복만 필요로 하고 서버에서 직접 실행되기 때문입니다.

Last9[2](https://last9.io/blog/how-to-make-the-most-of-redis-pipeline/)는 "Lua 스크립트 접근 방식은 로직이 Redis 서버에서 직접 실행되기 때문에 단일 왕복만 필요합니다."라고 설명합니다.
### 5.4 언제 어떤 것을 사용해야 할까?
- **파이프라인 사용 시기**:
    - 서로 독립적인 여러 간단한 명령을 실행할 때
    - 중간 결과에 의존하지 않는 작업에서
    - 클라이언트에서 로직을 관리하고 싶을 때

- **Lua 스크립팅 사용 시기**:
    - 명령 간에 조건부 로직이 필요할 때
    - 중간 결과에 따라 다른 명령을 실행해야 할 때
    - 완전한 원자성이 필요한 복잡한 작업을 수행할 때
    - 서버 측에서 계산을 수행하여 네트워크 오버헤드를 줄이고 싶을 때

## 6. 실무 애플리케이션 사례
Redis Pipeline은 다양한 실제 애플리케이션에서 성능을 크게 향상시킬 수 있습니다. 여기서는 여러 산업 분야에서의 Redis Pipeline 사용 사례를 살펴보겠습니다.

### 6.1 전자상거래 시스템
#### 재고 관리 시스템
전자상거래 플랫폼에서 재고 관리는 중요한 과제입니다. 특히 플래시 세일이나 대규모 프로모션 동안 동시에 많은 재고 업데이트가 필요합니다.
```python
import redis
import time

r = redis.Redis(decode_responses=True)

def update_inventory_after_purchase(order_items):
    # 주문 시간 기록
    current_time = time.time()
    
    # 파이프라인 생성
    pipe = r.pipeline()
    
    for item in order_items:
        product_id = item['product_id']
        quantity = item['quantity']
        
        # 재고 감소
        pipe.decrby(f"inventory:{product_id}:stock", quantity)
        
        # 현재 재고 확인
        pipe.get(f"inventory:{product_id}:stock")
        
        # 재고 변경 이력 기록
        pipe.rpush(f"inventory:{product_id}:history", f"{current_time}:-{quantity}")
        
        # 재고 부족 알림이 필요한지 확인
        pipe.hget(f"product:{product_id}", "reorder_level")
    
    # 모든 명령 한 번에 실행
    results = pipe.execute()
    
    # 결과 처리 (매 3개 명령마다의 결과)
    for i in range(0, len(results), 4):
        product_id = order_items[i//4]['product_id']
        current_stock = int(results[i+1]) if results[i+1] else 0
        reorder_level = int(results[i+3]) if results[i+3] else 0
        
        if current_stock <= reorder_level:
            # 재고 부족 알림 트리거
            notify_low_stock(product_id, current_stock)
    
    return True
```

이 예제에서는 주문 처리 중 여러 제품의 재고를 업데이트하고, 현재 재고를 확인하고, 이력을 기록하며, 필요한 경우 재고 부족 알림을 트리거합니다. 파이프라인을 사용하면 이러한 모든 작업을 단일 네트워크 왕복으로 처리할 수 있습니다.

#### 장바구니 시스템
사용자가 제품을 장바구니에 추가하거나 제거할 때, 장바구니 정보를 신속하게 업데이트하고 관련 제품 정보를 가져와야 합니다.
```javascript
// Node.js 예제
const Redis = require('ioredis');
const redis = new Redis();

async function updateCart(userId, productId, action, quantity = 1) {
    const cartKey = `cart:${userId}`;
    const timestamp = Date.now();
    const pipeline = redis.pipeline();
    
    if (action === 'add') {
        // 장바구니에 제품 추가/업데이트
        pipeline.hincrby(cartKey, productId, quantity);
        pipeline.hset(`cart:${userId}:timestamps`, productId, timestamp);
    } else if (action === 'remove') {
        // 장바구니에서 제품 제거
        pipeline.hdel(cartKey, productId);
        pipeline.hdel(`cart:${userId}:timestamps`, productId);
    }
    
    // 장바구니 항목 수 가져오기
    pipeline.hlen(cartKey);
    
    // 장바구니 합계 업데이트
    pipeline.hget(`product:${productId}`, 'price');
    
    // 명령 실행
    const results = await pipeline.exec();
    
    // 가격 정보 받기 (마지막 명령의 결과)
    const price = parseFloat(results[3][1] || 0);
    
    // 합계 업데이트
    if (action === 'add') {
        await redis.hincrby(
            `cart:${userId}:total`, 
            'amount', 
            Math.round(price * quantity * 100)
        );
    } else if (action === 'remove') {
        await redis.hincrby(
            `cart:${userId}:total`, 
            'amount', 
            -Math.round(price * quantity * 100)
        );
    }
    
    return {
        items: parseInt(results[2][1]),
        updated: timestamp
    };
}

// 사용 예
updateCart('user123', 'prod456', 'add', 2)
    .then(result => console.log(result))
    .catch(err => console.error(err));
```

이 구현에서는 장바구니 업데이트, 타임스탬프 기록, 항목 수 계산 및 가격 정보 검색을 하나의 파이프라인으로 처리합니다.

### 6.2 실시간 리더보드
게임, 경쟁 플랫폼 또는 분석 대시보드에서 실시간 순위표는 Redis의 정렬된 세트와 파이프라인을 결합하여 효율적으로 구현할 수 있습니다.
```python
import redis
import time

r = redis.Redis(decode_responses=True)

def update_leaderboard_and_get_rank(game_id, user_id, score):
    pipe = r.pipeline()
    
    # 리더보드 키
    leaderboard_key = f"leaderboard:{game_id}"
    
    # 점수 업데이트
    pipe.zadd(leaderboard_key, {user_id: score})
    
    # 사용자 순위 확인
    pipe.zrevrank(leaderboard_key, user_id)
    
    # 탑 10 플레이어 가져오기
    pipe.zrevrange(leaderboard_key, 0, 9, withscores=True)
    
    # 접근 타임스탬프 업데이트
    pipe.hset(f"user:{user_id}:stats", "last_leaderboard_access", time.time())
    
    # 실행
    results = pipe.execute()
    
    # 사용자 순위 (0부터 시작하므로 1 추가)
    user_rank = results[1] + 1 if results[1] is not None else "순위 없음"
    
    # 상위 10명의 플레이어
    top_players = []
    for player_id, player_score in results[2]:
        # 각 플레이어 정보 가져오기 (별도 호출)
        player_name = r.hget(f"user:{player_id}", "name") or player_id
        top_players.append({
            "id": player_id,
            "name": player_name,
            "score": player_score,
            "is_current_user": player_id == user_id
        })
    
    return {
        "user_rank": user_rank,
        "total_players": r.zcard(leaderboard_key),
        "top_players": top_players
    }

# 사용 예
leaderboard_info = update_leaderboard_and_get_rank("game123", "user456", 1250)
print(f"당신의 순위: {leaderboard_info['user_rank']}/{leaderboard_info['total_players']}")
for idx, player in enumerate(leaderboard_info['top_players']):
    print(f"{idx+1}. {player['name']}: {player['score']} 점")
```

이 예제는 게임 리더보드를 업데이트하고, 사용자의 현재 순위를 확인하며, 상위 10명의 플레이어 목록을 가져옵니다. 파이프라인을 사용하면 이 모든 작업을 단일 네트워크 왕복으로 수행할 수 있어 실시간 리더보드의 응답 시간을 크게 향상시킵니다.

### 6.3 API 속도 제한
API 속도 제한은 서비스 남용을 방지하고 리소스를 공정하게 분배하는 데 중요합니다. Redis Pipeline을 사용하면 속도 제한 검사와 업데이트를 효율적으로 수행할 수 있습니다.
```javascript
// Node.js 예제
const Redis = require('ioredis');
const redis = new Redis();

async function checkRateLimit(userId, endpoint, limit = 100, timeWindowSeconds = 3600) {
    const currentTime = Math.floor(Date.now() / 1000);
    const windowStart = currentTime - timeWindowSeconds;
    
    // 키 설정
    const rateLimitKey = `ratelimit:${endpoint}:${userId}`;
    
    // 파이프라인 생성
    const pipeline = redis.pipeline();
    
    // 만료된 요청 제거
    pipeline.zremrangebyscore(rateLimitKey, 0, windowStart);
    
    // 현재 요청 수 확인
    pipeline.zcard(rateLimitKey);
    
    // 새 요청 추가
    pipeline.zadd(rateLimitKey, currentTime, `${currentTime}-${Math.random()}`);
    
    // 키 만료 설정 (윈도우 시간의 2배로 설정하여 자동 정리 보장)
    pipeline.expire(rateLimitKey, timeWindowSeconds * 2);
    
    // 파이프라인 실행
    const results = await pipeline.exec();
    
    // 현재 요청 수 가져오기
    const requestCount = parseInt(results[1][1]);
    
    // 응답 구성
    const response = {
        success: requestCount < limit,
        current: requestCount + 1,  // 방금 추가한 요청 포함
        limit: limit,
        remaining: Math.max(0, limit - (requestCount + 1)),
        reset: currentTime + timeWindowSeconds
    };
    
    return response;
}

// API 미들웨어 예제
async function rateLimitMiddleware(req, res, next) {
    const userId = req.user?.id || req.ip;
    const endpoint = req.originalUrl;
    
    try {
        const rateLimitInfo = await checkRateLimit(userId, endpoint);
        
        // 응답 헤더에 속도 제한 정보 추가
        res.setHeader('X-RateLimit-Limit', rateLimitInfo.limit);
        res.setHeader('X-RateLimit-Remaining', rateLimitInfo.remaining);
        res.setHeader('X-RateLimit-Reset', rateLimitInfo.reset);
        
        if (!rateLimitInfo.success) {
            return res.status(429).json({
                error: '너무 많은 요청을 보냈습니다. 나중에 다시 시도하세요.',
                rateLimitInfo
            });
        }
        
        next();
    } catch (error) {
        console.error('속도 제한 검사 중 오류 발생:', error);
        // 오류 발생 시 요청 허용 (안전 조치)
        next();
    }
}
```

이 구현에서는 Redis 정렬 세트(sorted set)를 사용하여 시간 기반 슬라이딩 윈도우로 API 요청을 추적합니다. 파이프라인을 사용하면 만료된 요청 제거, 현재 요청 수 확인, 새 요청 추가, 키 만료 설정을 단일 네트워크 왕복으로 수행할 수 있습니다.

### 6.4 대용량 데이터 처리 파이프라인

Redis Pipeline은 대용량 데이터 처리 시스템에서도 중요한 역할을 합니다. 예를 들어, 이벤트 스트림에서 데이터를 소비하고 변환한 후 관계형 데이터베이스에 저장하는 사례를 살펴보겠습니다.

Medium[12](https://medium.com/@ansujain/building-a-high-throughput-data-pipeline-with-go-redis-and-postgresql-cd67c342f95d)에 소개된 구현을 기반으로 한 Go 코드 예시:

```go
package main

import (
    "context"
    "database/sql"
    "fmt"
    "log"
    "time"

    "github.com/go-redis/redis/v8"
    _ "github.com/lib/pq"
)

type DataProcessor struct {
    redisClient *redis.Client
    db          *sql.DB
    streamKey   string
    batchSize   int
    workerCount int
    rawDataChan chan string
    processedDataChan chan string
    workerPool  chan struct{}
}

func NewDataProcessor(redisAddr, pgConnStr, streamKey string, batchSize, workerCount int) (*DataProcessor, error) {
    // Redis 클라이언트 설정
    redisClient := redis.NewClient(&redis.Options{
        Addr: redisAddr,
    })
    
    // PostgreSQL 연결 설정
    db, err := sql.Open("postgres", pgConnStr)
    if err != nil {
        return nil, err
    }
    
    // 연결 테스트
    if err := db.Ping(); err != nil {
        return nil, err
    }
    
    return &DataProcessor{
        redisClient: redisClient,
        db:          db,
        streamKey:   streamKey,
        batchSize:   batchSize,
        workerCount: workerCount,
        rawDataChan: make(chan string, 1000000),           // 백만 개의 메시지 버퍼
        processedDataChan: make(chan string, 1000000),
        workerPool:  make(chan struct{}, workerCount),     // 작업자 풀
    }, nil
}

func (p *DataProcessor) Start(ctx context.Context) {
    // 작업자 풀 초기화
    for i := 0; i < p.workerCount; i++ {
        p.workerPool <- struct{}{}
    }
    
    // Redis 스트림 소비자 시작
    go p.consumeRedisStream(ctx)
    
    // 변환 작업자 시작
    go p.transformData(ctx)
    
    // 배치 삽입 데몬 시작
    go p.batchInsertDaemon(ctx)
    
    log.Println("데이터 처리기 시작됨")
}

func (p *DataProcessor) consumeRedisStream(ctx context.Context) {
    for {
        // Redis 파이프라인 생성
        pipe := p.redisClient.Pipeline()
        
        // XREAD 명령 실행을 준비
        cmd := pipe.XRead(ctx, &redis.XReadArgs{
            Streams: []string{p.streamKey, "0"},
            Count:   int64(p.batchSize),
            Block:   0,
        })
        
        // 파이프라인 실행
        _, err := pipe.Exec(ctx)
        if err != nil {
            log.Printf("Redis에서 읽는 중 오류: %v", err)
            continue
        }
        
        messages, err := cmd.Result()
        if err != nil {
            log.Printf("결과 가져오는 중 오류: %v", err)
            continue
        }
        
        // 메시지 처리
        for _, msg := range messages[0].Messages {
            data, ok := msg.Values["data"].(string)
            if ok {
                p.rawDataChan <- data
            }
        }
    }
}

func (p *DataProcessor) transformData(ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            return
        case data := <-p.rawDataChan:
            // 작업자 슬롯 획득
            <-p.workerPool
            
            // 고루틴으로 데이터 변환
            go func(data string) {
                defer func() { p.workerPool <- struct{}{} }() // 작업자 슬롯 반환
                
                // 데이터 변환 로직
                transformedData := transformData(data)
                
                // 변환된 데이터를 처리된 데이터 채널로 전송
                p.processedDataChan <- transformedData
            }(data)
        }
    }
}

func (p *DataProcessor) batchInsertDaemon(ctx context.Context) {
    batch := make([]string, 0, p.batchSize)
    timeout := time.Second  // 1초 타임아웃
    timer := time.NewTimer(timeout)
    
    for {
        select {
        case <-ctx.Done():
            return
        case data := <-p.processedDataChan:
            batch = append(batch, data)
            
            // 배치 크기 도달 시 삽입
            if len(batch) >= p.batchSize {
                p.insertBatch(batch)
                batch = make([]string, 0, p.batchSize)
                timer.Reset(timeout)
            }
        case <-timer.C:
            // 타임아웃 시 현재 배치 삽입 (부분 배치)
            if len(batch) > 0 {
                p.insertBatch(batch)
                batch = make([]string, 0, p.batchSize)
            }
            timer.Reset(timeout)
        }
    }
}

func (p *DataProcessor) insertBatch(batch []string) {
    // PostgreSQL 트랜잭션 시작
    tx, err := p.db.Begin()
    if err != nil {
        log.Printf("트랜잭션 시작 오류: %v", err)
        return
    }
    
    // COPY 명령어로 대량 삽입 준비
    stmt, err := tx.Prepare(`COPY data_table(payload) FROM STDIN`)
    if err != nil {
        log.Printf("COPY 준비 오류: %v", err)
        tx.Rollback()
        return
    }
    
    // 배치 데이터 삽입
    for _, data := range batch {
        _, err := stmt.Exec(data)
        if err != nil {
            log.Printf("데이터 삽입 오류: %v", err)
            tx.Rollback()
            return
        }
    }
    
    // 트랜잭션 커밋
    if err := tx.Commit(); err != nil {
        log.Printf("트랜잭션 커밋 오류: %v", err)
        return
    }
    
    log.Printf("%d개 레코드가 성공적으로 삽입됨", len(batch))
}

func transformData(data string) string {
    // 실제 변환 로직 구현
    // 예: JSON 파싱, 필드 추출, 포맷 변경 등
    return fmt.Sprintf("transformed:%s", data)
}

func main() {
    // 설정
    redisAddr := "localhost:6379"
    pgConnStr := "postgres://user:password@localhost:5432/mydb?sslmode=disable"
    streamKey := "data_stream"
    batchSize := 1000
    workerCount := 100
    
    ctx, cancel := context.WithCancel(context.Background())
    defer cancel()
    
    // 데이터 처리기 생성
    processor, err := NewDataProcessor(redisAddr, pgConnStr, streamKey, batchSize, workerCount)
    if err != nil {
        log.Fatalf("데이터 처리기 생성 실패: %v", err)
    }
    
    // 처리 시작
    processor.Start(ctx)
    
    // 메인 스레드가 종료되지 않도록 대기
    select {}
}
```

이 구현에서는 Redis 파이프라인을 사용하여 Redis 스트림에서 데이터를 효율적으로 소비하고, 고루틴 워커 풀을 사용하여 데이터를 병렬로 변환한 다음, 트랜잭션으로 데이터베이스에 일괄 삽입합니다.

이 아키텍처는 초당 700,000개의 패킷을 처리할 수 있도록 설계되었으며, 다음과 같은 핵심 기능을 갖추고 있습니다:

- 높은 처리량: 초당 700,000개 패킷 처리 가능
- 동시성: Go의 고루틴과 채널을 사용한 효율적인 처리
- 일괄 삽입: 배치 크기가 1,000개에 도달하거나 1초 타임아웃이 발생하면 데이터베이스에 삽입
- 확장성: 버퍼 크기와 워커 풀 조정을 통한 스케일링

### 6.5 마이크로서비스 아키텍처

마이크로서비스 아키텍처에서 Redis Pipeline은 서비스 간 통신과 데이터 동기화를 최적화하는 데 사용될 수 있습니다. 특히 서비스 간에 데이터를 대량으로 주고받거나 공유 상태를 관리할 때 유용합니다.

다음은 마이크로서비스 환경에서 Redis Pipeline을 사용하여 서비스 간 동기화를 구현하는 예제입니다:

```csharp
// C# 예제
using StackExchange.Redis;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

public class ServiceSynchronizer
{
    private readonly ConnectionMultiplexer _redis;
    private readonly IDatabase _db;
    private readonly string _serviceName;
    
    public ServiceSynchronizer(string redisConnectionString, string serviceName)
    {
        _redis = ConnectionMultiplexer.Connect(redisConnectionString);
        _db = _redis.GetDatabase();
        _serviceName = serviceName;
    }
    
    public async Task SynchronizeStateAsync(string stateId, Dictionary<string, string> stateData, TimeSpan expiry)
    {
        // 상태 키
        string stateKey = $"service:{_serviceName}:state:{stateId}";
        string syncKey = $"sync:state:{stateId}";
        
        // 트랜잭션 및 파이프라인 생성
        IBatch batch = _db.CreateBatch();
        
        // 상태 데이터 저장
        foreach (var kvp in stateData)
        {
            batch.HashSetAsync(stateKey, kvp.Key, kvp.Value);
        }
        
        // 만료 시간 설정
        batch.KeyExpireAsync(stateKey, expiry);
        
        // 동기화 알림 게시
        batch.PublishAsync(syncKey, _serviceName);
        
        // 동기화 타임스탬프 업데이트
        batch.HashSetAsync(
            "service:sync:timestamps", 
            $"{_serviceName}:{stateId}", 
            DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
        );
        
        // 모든 명령 한 번에 실행
        await batch.ExecuteAsync();
        
        Console.WriteLine($"상태 '{stateId}'가 다른 서비스와 동기화되었습니다.");
    }
    
    public async Task<Dictionary<string, string>> GetServiceStateAsync(string serviceName, string stateId)
    {
        string stateKey = $"service:{serviceName}:state:{stateId}";
        
        // 파이프라인 생성
        IBatch batch = _db.CreateBatch();
        
        // 상태 데이터 가져오기
        Task<HashEntry[]> getStateTask = batch.HashGetAllAsync(stateKey);
        
        // 마지막 동기화 타임스탬프 가져오기
        Task<RedisValue> getTimestampTask = batch.HashGetAsync(
            "service:sync:timestamps", 
            $"{serviceName}:{stateId}"
        );
        
        // 배치 실행
        await batch.ExecuteAsync();
        
        // 결과 가져오기
        HashEntry[] stateEntries = await getStateTask;
        long timestamp = (long)await getTimestampTask;
        
        // 딕셔너리로 변환
        var result = new Dictionary<string, string>();
        foreach (var entry in stateEntries)
        {
            result[entry.Name] = entry.Value;
        }
        
        // 타임스탬프 추가
        result["_sync_timestamp"] = timestamp.ToString();
        
        return result;
    }
    
    // 서비스 동기화 이벤트 구독
    public void SubscribeToStateChanges(string stateId, Action<string> callback)
    {
        string syncKey = $"sync:state:{stateId}";
        ISubscriber subscriber = _redis.GetSubscriber();
        
        subscriber.Subscribe(syncKey, (channel, value) => {
            string sourceService = value;
            Console.WriteLine($"상태 '{stateId}'가 서비스 '{sourceService}'에 의해 업데이트되었습니다.");
            callback(sourceService);
        });
    }
}

// 사용 예
public class ProductCatalogService
{
    private readonly ServiceSynchronizer _synchronizer;
    
    public ProductCatalogService(string redisConnectionString)
    {
        _synchronizer = new ServiceSynchronizer(redisConnectionString, "product-catalog");
        
        // 재고 상태 변경 구독
        _synchronizer.SubscribeToStateChanges("inventory", sourceService => {
            Console.WriteLine($"재고 상태가 '{sourceService}'에 의해 변경되었습니다. 캐시 업데이트 중...");
            UpdateInventoryCache();
        });
    }
    
    public async Task UpdateProductAsync(string productId, Dictionary<string, string> productData)
    {
        // 제품 데이터 업데이트 로직...
        
        // 다른 서비스와 제품 상태 동기화
        await _synchronizer.SynchronizeStateAsync(
            $"product:{productId}", 
            productData, 
            TimeSpan.FromHours(24)
        );
    }
    
    private void UpdateInventoryCache()
    {
        // 재고 캐시 업데이트 로직...
    }
}
```

이 예제에서는 `ServiceSynchronizer` 클래스가 Redis Pipeline을 사용하여 마이크로서비스 간 상태 데이터의 효율적인 동기화를 처리합니다. 상태 업데이트, 만료 설정, 이벤트 발행 및 타임스탬프 업데이트와 같은 여러 작업을 단일 네트워크 왕복으로 수행합니다.

### 6.6 금융 시스템

금융 시스템에서는 레이트 리밋, 거래 처리, 사기 탐지 등을 위해 Redis Pipeline을 활용할 수 있습니다. 다음은 금융 거래 처리 예제입니다:

```java
// Java 예제
import redis.clients.jedis.Jedis;
import redis.clients.jedis.Pipeline;
import redis.clients.jedis.Response;
import java.util.UUID;
import java.time.Instant;

public class TransactionProcessor {
    private final Jedis jedis;
    private final String accountPrefix = "account:";
    private final String transactionPrefix = "transaction:";
    private final String pendingTransactionsKey = "pending_transactions";
    
    public TransactionProcessor(String redisHost, int redisPort) {
        this.jedis = new Jedis(redisHost, redisPort);
    }
    
    public TransactionResult processTransaction(String fromAccount, String toAccount, double amount) {
        String transactionId = UUID.randomUUID().toString();
        long timestamp = Instant.now().getEpochSecond();
        
        Pipeline pipe = jedis.pipelined();
        
        // 송금 계좌 잔액 확인
        Response<String> fromBalanceResponse = pipe.hget(accountPrefix + fromAccount, "balance");
        
        // 일일 한도 확인
        Response<String> dailyLimitResponse = pipe.hget(accountPrefix + fromAccount, "daily_limit");
        Response<String> dailySpentResponse = pipe.hget(accountPrefix + fromAccount, "daily_spent");
        
        // 계좌 상태 확인
        Response<String> fromStatusResponse = pipe.hget(accountPrefix + fromAccount, "status");
        Response<String> toStatusResponse = pipe.hget(accountPrefix + toAccount, "status");
        
        // 파이프라인 실행 (1단계: 잔액 및 상태 확인)
        pipe.sync();
        
        // 유효성 검사
        TransactionResult result = validateTransaction(fromAccount, toAccount, amount,
                fromBalanceResponse.get(), dailyLimitResponse.get(), dailySpentResponse.get(),
                fromStatusResponse.get(), toStatusResponse.get());
        
        if (!result.isSuccess()) {
            return result;
        }
        
        // 모든 검사 통과, 거래 처리
        pipe = jedis.pipelined();
        pipe.multi(); // 트랜잭션 시작
        
        // 송금 계좌에서 금액 차감
        double fromBalance = Double.parseDouble(fromBalanceResponse.get());
        pipe.hset(accountPrefix + fromAccount, "balance", String.valueOf(fromBalance - amount));
        
        // 일일 사용액 업데이트
        double dailySpent = dailySpentResponse.get() != null ? 
                Double.parseDouble(dailySpentResponse.get()) : 0;
        pipe.hset(accountPrefix + fromAccount, "daily_spent", String.valueOf(dailySpent + amount));
        
        // 수취 계좌에 금액 추가
        double toBalance = Double.parseDouble(pipe.hget(accountPrefix + toAccount, "balance").get());
        pipe.hset(accountPrefix + toAccount, "balance", String.valueOf(toBalance + amount));
        
        // 거래 기록 생성
        String transactionKey = transactionPrefix + transactionId;
        pipe.hset(transactionKey, "from_account", fromAccount);
        pipe.hset(transactionKey, "to_account", toAccount);
        pipe.hset(transactionKey, "amount", String.valueOf(amount));
        pipe.hset(transactionKey, "timestamp", String.valueOf(timestamp));
        pipe.hset(transactionKey, "status", "completed");
        
        // 최근 거래 목록에 추가
        pipe.lpush("recent_transactions:" + fromAccount, transactionId);
        pipe.lpush("recent_transactions:" + toAccount, transactionId);
        pipe.ltrim("recent_transactions:" + fromAccount, 0, 99); // 최근 100개만 유지
        pipe.ltrim("recent_transactions:" + toAccount, 0, 99);
        
        // 보류 중인 거래 목록에서 제거 (있는 경우)
        pipe.lrem(pendingTransactionsKey, 0, transactionId);
        
        // 트랜잭션 종료
        pipe.exec();
        pipe.sync();
        
        return new TransactionResult(true, "거래가 성공적으로 처리되었습니다.", transactionId);
    }
    
    private TransactionResult validateTransaction(String fromAccount, String toAccount, double amount,
                                               String fromBalanceStr, String dailyLimitStr, 
                                               String dailySpentStr, String fromStatus, String toStatus) {
        // 계좌 상태 확인
        if (!"active".equals(fromStatus)) {
            return new TransactionResult(false, "송금 계좌가 활성 상태가 아닙니다.", null);
        }
        
        if (!"active".equals(toStatus)) {
            return new TransactionResult(false, "수취 계좌가 활성 상태가 아닙니다.", null);
        }
        
        // 잔액 확인
        double fromBalance = fromBalanceStr != null ? Double.parseDouble(fromBalanceStr) : 0;
        if (fromBalance < amount) {
            return new TransactionResult(false, "잔액이 부족합니다.", null);
        }
        
        // 일일 한도 확인
        if (dailyLimitStr != null) {
            double dailyLimit = Double.parseDouble(dailyLimitStr);
            double dailySpent = dailySpentStr != null ? Double.parseDouble(dailySpentStr) : 0;
            
            if (dailySpent + amount > dailyLimit) {
                return new TransactionResult(false, "일일 거래 한도를 초과했습니다.", null);
            }
        }
        
        return new TransactionResult(true, "유효성 검사 통과", null);
    }
    
    public void close() {
        if (jedis != null) {
            jedis.close();
        }
    }
    
    public static class TransactionResult {
        private final boolean success;
        private final String message;
        private final String transactionId;
        
        public TransactionResult(boolean success, String message, String transactionId) {
            this.success = success;
            this.message = message;
            this.transactionId = transactionId;
        }
        
        public boolean isSuccess() {
            return success;
        }
        
        public String getMessage() {
            return message;
        }
        
        public String getTransactionId() {
            return transactionId;
        }
    }
}
```

이 예제에서는 금융 거래 처리 과정에서 두 단계의 파이프라인을 사용합니다:

1. 첫 번째 파이프라인은 계좌 잔액, 일일 한도, 계좌 상태 등의 여러 정보를 한 번에 조회합니다.
2. 두 번째 파이프라인은 트랜잭션으로 감싸져 있으며, 송금 계좌의 잔액 차감, 수취 계좌의 잔액 증가, 거래 기록 생성, 최근 거래 목록 업데이트 등의 여러 작업을 원자적으로 수행합니다.

이러한 접근 방식은 금융 거래의 원자성과 데이터 일관성을 유지하면서도 네트워크 효율성을 최적화합니다.

## 7. 성능 최적화 및 벤치마크

Redis Pipeline을 사용하면 상당한 성능 향상을 얻을 수 있습니다. 다양한 벤치마크와 실제 사례를 통해 성능 이득을 살펴보겠습니다.

### 7.1 기본 벤치마크 결과

Dev.to[13](https://dev.to/erikaheidi/pipeline-all-the-things-redis-performance-boost-at-application-level-3blb)에서 제공한 `redis-benchmark` 도구를 사용한 벤치마크 결과는 파이프라이닝의 효과를 명확하게 보여줍니다:

**일반 벤치마크 (각 명령이 개별적으로 실행):**

```
redis-benchmark -t get,set -q
SET: 95,785.44 requests per second
GET: 97,370.98 requests per second
```

**파이프라인 벤치마크 (16개 명령을 파이프라인으로 전송):**

```
redis-benchmark -t get,set -q -P 16
SET: 877,193.00 requests per second
GET: 1,351,351.38 requests per second
```

이 결과는 파이프라인을 사용할 때 GET 명령의 경우 초당 약 97,000개에서 1,351,000개로, 거의 **14배의 성능 향상**을 보여줍니다.

### 7.2 코드에서의 벤치마크 비교

다양한 언어에서 파이프라인의 성능 이점을 보여주는 벤치마크 코드를 살펴보겠습니다.

#### Ruby 예제:

```ruby
require 'redis'

def bench(descr)
  start = Time.now
  yield
  puts "#{descr} #{Time.now-start} seconds"
end

def without_pipelining
  r = Redis.new
  10000.times {
    r.ping
  }
end

def with_pipelining
  r = Redis.new
  r.pipelined {
    10000.times {
      r.ping
    }
  }
end

bench("파이프라인 없이") {
  without_pipelining
}
bench("파이프라인 사용") {
  with_pipelining
}
```

**출력:**

```
파이프라인 없이 1.185238 seconds
파이프라인 사용 0.250783 seconds
```

이는 파이프라인을 사용할 때 **약 4.7배 빠른 성능**을 보여줍니다.

#### Python 예제 (Redis-py):

앞서 살펴본 Redis-py 예제에서 100,000번의 incr 명령에 대해 다음과 같은 결과를 보였습니다:

- 파이프라인 없이: 21.76초
- 파이프라인 사용: 2.36초

이는 파이프라인 사용 시 **약 9.2배 빠른 성능**을 보여줍니다.

### 7.3 실제 사례 성능 개선

Medium[14](https://medium.com/safe-engineering/how-redis-pipelining-helped-us-improve-performance-by-15x-c6486737c960)에서는 SAFE CRQM 플랫폼에서 Redis Pipeline을 사용하여 성능을 크게 향상시킨 사례를 보고했습니다:

- 메시지당 약 1,500개의 개별 Redis 명령을 실행하는 워커가 있었습니다.
- 파이프라인을 사용하여 이러한 명령을 처음에는 3개 배치(쓰기, 읽기, 쓰기)로 리팩토링했습니다.
- 추가 최적화를 통해 배치 수를 2개로 줄이고 총 Redis 명령 수를 30% 줄였습니다.
- 결과적으로 초기 상태보다 **15배 빠른 성능**을 달성했습니다.

### 7.4 파이프라인 크기와 성능의 관계

Redis 파이프라인의 크기(한 번에 전송되는 명령 수)와 성능의 관계는 비선형적입니다. Redis 공식 문서[1](https://redis.io/docs/latest/develop/use/pipelining/)에서는 다음과 같은 벤치마크 결과를 제공합니다:

|Pipeline 크기|초당 요청 수|
|---|---|
|1 (파이프라인 없음)|약 50,000|
|2|약 100,000|
|5|약 150,000|
|10|약 200,000|
|50|약 250,000|
|100|약 300,000|

이 데이터는 파이프라인 크기가 증가함에 따라 처리량이 증가하지만, 점점 증가 폭이 줄어드는 것을 보여줍니다. 일반적으로 파이프라인 크기가 10~100 사이일 때 가장 좋은 성능과 메모리 사용 간의 균형을 제공합니다.

### 7.5 네트워크 지연과 파이프라인 효율성

네트워크 지연이 클수록 파이프라이닝의 이점이 더 커집니다. Last9[2](https://last9.io/blog/how-to-make-the-most-of-redis-pipeline/)에 따르면:

- 낮은 지연 환경(예: 로컬 인스턴스): 파이프라이닝으로 10-30배 성능 향상
- 높은 지연 환경(예: 원격 인스턴스): 파이프라이닝으로 50-100배 성능 향상

이는 파이프라이닝이 네트워크 왕복의 영향을 줄이기 때문에 네트워크 지연이 클수록 더 큰 이점을 제공한다는 것을 보여줍니다.

### 7.6 성능 최적화를 위한 Redis 서버 설정

Redis Pipeline을 사용할 때 다음과 같은 Redis 서버 설정을 조정하면 더 나은 성능을 얻을 수 있습니다:

```conf
# 클라이언트 버퍼 크기 증가
client-output-buffer-limit normal 0 0 0

# TCP 백로그 증가
tcp-backlog 1024

# 클라이언트 쿼리 버퍼 한도 조정
client-query-buffer-limit 1gb

# 최대 프로토콜 크기 조정
proto-max-bulk-len 1gb
```

이러한 설정은 대규모 파이프라인 요청과 응답을 처리할 때 특히 유용합니다.

## 8. Redis Pipeline 모범 사례

Redis Pipeline을 효율적으로 사용하기 위한 모범 사례와 권장 사항을 살펴보겠습니다.

### 8.1 최적의 배치 크기 선택

배치 크기는 성능과 메모리 사용량에 직접적인 영향을 미칩니다. redis.io[1](https://redis.io/docs/latest/develop/use/pipelining/)의 권장사항:

- **권장 범위**: 실무에서는 일반적으로 10~100개의 명령을 한 배치로 묶는 것이 적절합니다.
- **대규모 배치의 경우**: 만약 아주 많은 명령을 실행해야 한다면, 약 10,000개의 합리적인 크기로 명령을 나누고, 응답을 읽은 후 다음 10,000개 명령을 전송하는 방식을 사용하세요.

Last9[2](https://last9.io/blog/how-to-make-the-most-of-redis-pipeline/)는 다음과 같이 권장합니다:

- 간단한 명령(예: GET, SET)의 경우: 100~1,000개의 명령을 한 배치로 묶습니다.
- 복잡한 명령이나 대용량 데이터의 경우: 배치 크기를 줄이는 것이 좋습니다.

### 8.2 타임아웃 기반 배치 처리

실시간 응용 프로그램에서는 배치 크기와 함께 시간 기반 배치 전략을 사용하는 것이 좋습니다. 예를 들어:

```javascript
// Node.js 예제
class TimedBatcher {
    constructor(redisClient, maxBatchSize = 100, maxDelayMs = 50) {
        this.redis = redisClient;
        this.maxBatchSize = maxBatchSize;
        this.maxDelayMs = maxDelayMs;
        this.pipeline = this.redis.pipeline();
        this.commandCount = 0;
        this.timer = null;
    }
    
    add(command, ...args) {
        this.pipeline[command](...args);
        this.commandCount++;
        
        // 타이머가 없으면 시작
        if (!this.timer) {
            this.timer = setTimeout(() => this.flush(), this.maxDelayMs);
        }
        
        // 배치 크기 도달 시 즉시 플러시
        if (this.commandCount >= this.maxBatchSize) {
            this.flush();
        }
        
        return this;
    }
    
    async flush() {
        if (this.timer) {
            clearTimeout(this.timer);
            this.timer = null;
        }
        
        if (this.commandCount === 0) {
            return [];
        }
        
        const pipeline = this.pipeline;
        const count = this.commandCount;
        
        // 새로운 파이프라인 준비
        this.pipeline = this.redis.pipeline();
        this.commandCount = 0;
        
        // 명령 실행
        try {
            const results = await pipeline.exec();
            console.log(`${count}개 명령 처리 완료`);
            return results;
        } catch (error) {
            console.error('파이프라인 실행 오류:', error);
            throw error;
        }
    }
}

// 사용 예
const batcher = new TimedBatcher(redisClient, 100, 50);

// 명령 추가
batcher.add('set', 'key1', 'value1')
       .add('incr', 'counter')
       .add('expire', 'key1', 3600);

// 배치 크기에 도달하거나 50ms 후에 자동으로 실행됨
// 또는 수동으로 플러시할 수도 있음
await batcher.flush();
```

이 접근 방식은 최대 지연 시간을 보장하면서도 가능한 한 많은 명령을 배치로 처리할 수 있게 합니다.

### 8.3 오류 처리 및 재시도 전략

파이프라인 실행 시 오류 처리는 중요합니다. 다음과 같은 오류 처리 전략을 고려하세요:

```python
# Python 예제
import redis
import time
import logging

class RedisPipelineWithRetry:
    def __init__(self, redis_client, max_retries=3, retry_delay=0.1):
        self.redis = redis_client
        self.max_retries = max_retries
        self.retry_delay = retry_delay
        self.pipeline = self.redis.pipeline()
        self.command_log = []
    
    def add_command(self, command, *args, **kwargs):
        method = getattr(self.pipeline, command)
        method(*args, **kwargs)
        self.command_log.append((command, args, kwargs))
        return self
    
    def execute_with_retry(self):
        retries = 0
        last_error = None
        
        while retries <= self.max_retries:
            try:
                results = self.pipeline.execute()
                return results
            except (redis.ConnectionError, redis.TimeoutError) as e:
                retries += 1
                last_error = e
                
                if retries <= self.max_retries:
                    logging.warning(f"파이프라인 실행 실패, {retries}/{self.max_retries} 재시도 중: {str(e)}")
                    time.sleep(self.retry_delay * retries)  # 점진적 백오프
                    
                    # 파이프라인 재생성 및 명령 복원
                    self.pipeline = self.redis.pipeline()
                    for cmd, args, kwargs in self.command_log:
                        method = getattr(self.pipeline, cmd)
                        method(*args, **kwargs)
                else:
                    logging.error(f"최대 재시도 횟수 초과: {str(e)}")
                    raise last_error
            except Exception as e:
                # 다른 유형의 오류는 즉시 다시 발생
                logging.error(f"파이프라인 실행 중 오류 발생: {str(e)}")
                raise
    
    def reset(self):
        self.pipeline = self.redis.pipeline()
        self.command_log = []
        return self

# 사용 예
client = redis.Redis()
pipe = RedisPipelineWithRetry(client)

try:
    results = (pipe
               .add_command('set', 'key1', 'value1')
               .add_command('incr', 'counter')
               .add_command('expire', 'key1', 3600)
               .execute_with_retry())
    print(results)
except Exception as e:
    print(f"실패: {str(e)}")
finally:
    pipe.reset()
```

이 구현은 연결 오류나 타임아웃 시 재시도 로직을 포함하며, 재시도 시 이전에 추가된 모든 명령을 복원합니다.

### 8.4 메모리 사용량 관리

대규모 파이프라인은 서버 메모리 사용량을 증가시킬 수 있습니다. 메모리 문제를 방지하기 위한 몇 가지 전략:

1. **합리적인 배치 크기 유지**: 앞서 언급한 대로 10,000개 이상의 명령을 묶을 때는 여러 배치로 나눠서 실행하세요.
    
2. **메모리 모니터링**: Redis INFO 명령을 사용하여 메모리 사용량을 모니터링하세요.
    
    ```
    redis-cli INFO memory
    ```
    
3. **필터링된 응답**: 일부 클라이언트 라이브러리에서는 불필요한 응답을 필터링하여 메모리 사용량을 줄일 수 있습니다.
    
4. **연결 풀링 관리**: 대규모 파이프라인을 실행하는 연결은 다른 연결과 분리하여 관리하고, 필요하면 전용 Redis 인스턴스를 사용하세요.
    

### 8.5 파이프라인과 관련 기술 조합하기

더 나은 성능을 위해 파이프라인을 다른 Redis 최적화 기술과 결합할 수 있습니다:

1. **파이프라인 + 트랜잭션**: 원자적 실행이 필요한 관련 명령에 대해 파이프라인 내에서 MULTI/EXEC를 사용하세요.
    
    ```python
    pipe = r.pipeline(transaction=True)
    pipe.multi()
    pipe.set('key1', 'value1')
    pipe.incr('counter')
    pipe.exec()
    ```
    
2. **파이프라인 + Lua 스크립트**: 복잡한 작업의 경우 Lua 스크립트를 사용하고, 여러 스크립트 실행을 파이프라인으로 묶을 수 있습니다.
    
    ```python
    pipe = r.pipeline()
    
    script1 = r.register_script("return redis.call('SET', KEYS[1], ARGV[1])")
    script2 = r.register_script("return redis.call('INCR', KEYS[1])")
    
    script1(keys=['key1'], args=['value1'], client=pipe)
    script2(keys=['counter'], args=[], client=pipe)
    
    results = pipe.execute()
    ```
    
3. **파이프라인 + 연결 풀링**: 파이프라인과 연결 풀링을 함께 사용하여 최대 성능을 얻을 수 있습니다.
    
    ```java
    // Java 예제 (Jedis)
    JedisPool pool = new JedisPool(new JedisPoolConfig(), "localhost");
    
    try (Jedis jedis = pool.getResource()) {
        Pipeline pipeline = jedis.pipelined();
        pipeline.set("key1", "value1");
        pipeline.incr("counter");
        pipeline.syncAndReturnAll();
    }
    ```
    

## 9. 결론

Redis Pipeline은 네트워크 왕복 횟수를 줄이고 시스템 호출 오버헤드를 최소화하여 Redis 작업의 성능을 크게 향상시키는 강력한 최적화 기법입니다. 다양한 벤치마크와 실제 사례에서 볼 수 있듯이, 적절히 사용된 파이프라인은 10배에서 100배까지의 성능 향상을 제공할 수 있습니다.

본 문서에서 살펴본 주요 내용을 요약하면:

1. **기본 개념**: Redis Pipeline은 여러 명령을 서버에 한 번에 전송하고 모든 응답을 일괄적으로 받는 기술입니다.
    
2. **성능 이점**: 파이프라인은 네트워크 왕복 시간을 줄이고, 초당 처리 가능한 작업 수를 증가시키며, 시스템 호출 오버헤드를 최소화합니다.
    
3. **다양한 언어 지원**: Java, Python, Node.js, Go 등 대부분의 주요 프로그래밍 언어에서 Redis Pipeline을 쉽게 구현할 수 있습니다.
    
4. **실제 애플리케이션**: 전자상거래, 실시간 리더보드, API 속도 제한, 대용량 데이터 처리, 마이크로서비스 동기화, 금융 거래 처리 등 다양한 실제 애플리케이션에서 Redis Pipeline을 활용할 수 있습니다.
    
5. **모범 사례**: 적절한 배치 크기 선택, 시간 기반 배치 처리, 효과적인 오류 처리, 메모리 사용량 관리 등의 모범 사례를 따르면 파이프라인의 효과를 극대화할 수 있습니다.
    
6. **한계**: 이전 명령의 결과에 의존하는 작업의 경우 파이프라인이 적합하지 않을 수 있으며, 이런 경우 Lua 스크립팅을 고려할 수 있습니다.
    

Redis Pipeline은 특히 대량의 독립적인 명령을 처리해야 하는 고성능 애플리케이션에서 필수적인 최적화 도구입니다. 배치 처리, 벌크 데이터 로딩, 높은 처리량이 필요한 API와 같은 시나리오에서 Redis Pipeline을 사용하면 응답 시간을 크게 줄이고 시스템 처리량을 대폭 향상시킬 수 있습니다.

지속적인 모니터링과 성능 테스트를 통해 특정 애플리케이션에 가장 적합한 파이프라인 구성을 찾아내고, 필요에 따라 다른 Redis 최적화 기술(Lua 스크립팅, 트랜잭션, 연결 풀링 등)과 결합하여 최상의 결과를 얻을 수 있습니다.

## 10. 참고 자료

1. Redis 공식 문서: Redis Pipeline[1](https://redis.io/docs/latest/develop/use/pipelining/) redis.io[1](https://redis.io/docs/latest/develop/use/pipelining/)
    
2. GeeksforGeeks: Complete Guide to Redis Pipelining[3](https://www.geeksforgeeks.org/complete-guide-to-redis-pipelining/) GeeksforGeeks[3](https://www.geeksforgeeks.org/complete-guide-to-redis-pipelining/)
    
3. Last9: How to Make the Most of Redis Pipeline[2](https://last9.io/blog/how-to-make-the-most-of-redis-pipeline/) last9.io[2](https://last9.io/blog/how-to-make-the-most-of-redis-pipeline/)
    
4. Redis-py 문서: Pipeline Examples[5](https://redis-py.readthedocs.io/en/stable/examples/pipeline_examples.html) redis-py.readthedocs.io[5](https://redis-py.readthedocs.io/en/stable/examples/pipeline_examples.html)
    
5. Medium: How Redis pipelining helped us improve performance by 15x[14](https://medium.com/safe-engineering/how-redis-pipelining-helped-us-improve-performance-by-15x-c6486737c960) Medium[14](https://medium.com/safe-engineering/how-redis-pipelining-helped-us-improve-performance-by-15x-c6486737c960)
    
6. Rafael Eyng's Blog: Redis: Pipelining, Transactions and Lua Scripts[15](https://rafaeleyng.github.io/redis-pipelining-transactions-and-lua-scripts) rafaeleyng.github.io[15](https://rafaeleyng.github.io/redis-pipelining-transactions-and-lua-scripts)
    
7. Stack Overflow: Pipelining vs transaction in redis[10](https://stackoverflow.com/questions/29327544/pipelining-vs-transaction-in-redis) Stack Overflow[10](https://stackoverflow.com/questions/29327544/pipelining-vs-transaction-in-redis)
    
8. Uptrace: Golang Redis Pipelines, WATCH, and Transactions[9](https://redis.uptrace.dev/guide/go-redis-pipelines.html) Uptrace[9](https://redis.uptrace.dev/guide/go-redis-pipelines.html)
    
9. Dev.to: Pipeline all the things: Redis performance boost at application level[13](https://dev.to/erikaheidi/pipeline-all-the-things-redis-performance-boost-at-application-level-3blb) dev.to[13](https://dev.to/erikaheidi/pipeline-all-the-things-redis-performance-boost-at-application-level-3blb)
    
10. Medium: An optimal solution to use Redis in Python[11](https://medium.com/@krittaboon.t/an-optimal-solution-to-use-redis-in-python-a4e5cee3b980) Medium[11](https://medium.com/@krittaboon.t/an-optimal-solution-to-use-redis-in-python-a4e5cee3b980)
    

---

## Appendix: Supplementary Video Resources

![youtube](https://i.ytimg.com/vi_webp/xKceKGMWPOw/maxresdefault.webp)![youtube](data:image/png;base64,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)

Redis 입문·실전 - 3.4. 캐싱으로 조회 성능 개선을 하기 전 OOO ...