---
tags: redis
---

![Untitled](Untitled%2083.png)

# Master Slave 구조의 Redis 환경을 구축해보자

해커톤을 진행하면서 세션, 일회용 인증코드 목적으로 Redis 를 도입하게 될 것 같은데 장애 처리에 안정적인 Redis 환경을 구축하고 싶다.

얼핏 들었던 Master Slave 로 장애에 대해 유연한 복구 기술에 대해 눈독이 들여졌는데 그전에 

정말 그런 구성이 필요한 지 분석해봐야겠다는 생각이 들었다.

redis 를 직접 벤치마킹해보고 다른 분들의 자료를 우선 참고하였다.

# 메모리 디비인 Redis, 어느정도 수준의 데이터를 처리하는가

처음에는 메모리에서 동작하는 시스템이다 보니 데이터가 어느정도 쌓이면 터질 것이라는 생각이 들어 이 부분을 예민하게 생각했다.

그러나 내가 생각하는 것 이상으로 많은 데이터를 저장해도 처리에 크게 문제가 없을 거라는 생각도 들긴 했다.

애초에 레디스가 기존 DB 시스템의 처리 속도에 실증이 나서 탄생한 시스템이다보니..그런생각이 든 것 같다.

자료 및 수치로 보자.

아래는 `redis-benchmark` 명령어를 통해 1000000 건의 데이터에 대한 입출력 테스트이다.

```bash
redis-benchmark -n 1000000 -c 300 -d 10000 -r 10000
```

<aside>
💡 요청수 1000000회, 동시 클라이언트 수 300, 데이터 크기 10KB, 키와 값의 범위 10000

</aside>

```java
Latency by percentile distribution:
0.000% <= 0.471 milliseconds (cumulative count 1)
50.000% <= 1.463 milliseconds (cumulative count 508165)
75.000% <= 1.607 milliseconds (cumulative count 755770)
87.500% <= 1.735 milliseconds (cumulative count 880128)
93.750% <= 1.855 milliseconds (cumulative count 938731)
96.875% <= 2.007 milliseconds (cumulative count 969402)
98.438% <= 2.247 milliseconds (cumulative count 984646)
99.219% <= 2.647 milliseconds (cumulative count 992232)
99.609% <= 3.383 milliseconds (cumulative count 996101)
99.805% <= 4.559 milliseconds (cumulative count 998051)
99.902% <= 8.191 milliseconds (cumulative count 999024)
99.951% <= 16.023 milliseconds (cumulative count 999512)
99.976% <= 16.655 milliseconds (cumulative count 999757)
99.988% <= 25.903 milliseconds (cumulative count 999879)
99.994% <= 36.319 milliseconds (cumulative count 999963)
99.997% <= 36.351 milliseconds (cumulative count 999981)
99.998% <= 36.383 milliseconds (cumulative count 999989)
99.999% <= 36.415 milliseconds (cumulative count 999995)
100.000% <= 36.447 milliseconds (cumulative count 999998)
100.000% <= 36.479 milliseconds (cumulative count 1000000)
100.000% <= 36.479 milliseconds (cumulative count 1000000)
```

redis 는 데이터가 얼마나 있던 `O(1)` 에 근접한 성능을 제공한다는 사실을 데이터로 알 수 있다.

<aside>
💡 redis 가 데이터를 저장할 때 **separate chaining hash table** 자료 구조를 사용하기 때문이라고 한다.

</aside>

이러한 처리성능을 보여준다면 그럼 굳이 Master-Slave 구조를 이용할 필요는 사실은 없다.

하지만 해커톤, 사이드 프로젝트 등 어떠한 것을 할 때 학습 목적으로 다양한 것들을 시도한다는 명목으로 진행하는 셈 치면 될 것 같다.

개인적으로 사이드 프로젝트는 **오버 엔지니어링** 해보는게 도움이 많이 된다고 생각한다.

차후에 대용량 트래픽을 처리할 때 도움이 될 것이다.

# Master-Slave 를 위한 Replication

**[Redis replication 공식 문서](https://redis.io/docs/management/replication/)**

Replication 은 메인(마스터) 레디스 서버의 데이터를 그대로 복제하는 것을 의미한다.

복제본은 연결이 끊어질 때마다 자동으로 메인에 연결되며 마스터에 무슨 일이 일어나든 상관없이 정확하게 마스터의 복사본으로 존재한다.

**Replication 은 세 가지 주요 메커니즘을 사용한다.**

1. 메인과 복제본 인스턴스가 연결되어 있으면 메인은 복제본에 스트림을 전송하여 `client writes, keys expired or evicted, 기타 작업으로 인해 메인 측에 발생하는 데이터셋`에 대한 영향을 복제하여 복제본을 업데이트함.
2. 네트워크 이슈 또는 복제본에서 타임아웃이 감지되어 연결이 끊어지면 복제본은 **다시 연결을 시도하고 부분 재동기화를 시도한다. ( 연결이 끊어진 동안 놓친 명령 스트림의 일부만 얻기 위해 )**
3. 부분 재동기화가 불가능한 상황에 복제본은 전체 재동기화를 요청한다.
**마스터가 모든 데이터 스냅샷을 만들어 복제본으로 전송한다음 데이터셋이 변경될 때 마다 명령 스트림을 계속 전송해야하는 더 복잡한 과정을 거친다.**

**Redis 는 데이터셋 동기화 작업을 비동기로 수행한다.**

<aside>
💡 수동으로 동기 복제도 가능하다.

</aside>

만약 메인(마스터) 에서 장애로 인해 데이터가 삭제되었을 경우 복제본도 동기화 작업으로 인해 삭제된다는 점을 주의하자.

 replication 관련 `redis.conf` 는 [Happy koo 님 블로그](https://www.happykoo.net/@happykoo/posts/43)를 참고하자. 

# Redis Sentinel

Master-Slave 구조의 레디스 환경에서 마스터가 다운되었다면 관리자가 이를 감지해서

복제본을 마스터로 승격하고 클라이언트가 새로운 마스터로 접속할 수 있도록 해주어야한다.

레디스에서 감시자 역할을 센티넬이라고 한다.

센티넬은 마스터와 복제본을 감시하고 있다가 마스터가 다운되면 감지해서 관리자 개입없이 자동으로 복제본을 마스터로 승격시킨다.

<aside>
💡 센티넬에 대해 자세한 설명은 **[Redis SENTINEL Introduction - RedisGate](http://redisgate.jp/redis/sentinel/sentinel.php)**

</aside>

# References

**[레디스 모니터링을 위한 대표적인 툴 2가지 알아보기](https://danawalab.github.io/common/2021/09/02/redis-monitoring-tools.html)**

**[DevOps 엔지니어의 Redis Test 분투기 - Part 1](https://helloworld.kurly.com/blog/redis-fight-part-1/)**

[**100만 단위 레디스 성능 테스트**](https://www.joinc.co.kr/w/man/12/REDIS/PerfTest)

**[레디스(Redis)는 언제 어떻게 사용하는 게 좋을까](https://brunch.co.kr/@skykamja24/575)**

**[Redis benchmark - Redis Official Docs](https://redis.io/docs/management/optimization/benchmarks/)**

**[Redis SLAVEOF Parameter](http://redisgate.kr/redis/configuration/param_slaveof.php)**

**[Redis replication 공식 문서](https://redis.io/docs/management/replication/)**

**[5분 안에 구축하는 Redis-Sentinel](https://co-de.tistory.com/15)**

**[Redis SENTINEL Introduction - RedisGate](http://redisgate.jp/redis/sentinel/sentinel.php)**