# Spring Boot 에서 Cache-Aside

태그: CACHE, Cache-Aside, Spring, redis
Date: October 4, 2023 9:16 AM
공개 여부: 공개
설명: Spring Boot 에서 Cache-Aside 전략을 사용하는 방법
카테고리: Spring

![Untitled](Untitled%20119.png)

Cache-Aside, Lazy Loading 은 애플리케이션 자체가 캐시 관리를 담당하는 캐싱 전략입니다.

이 접근 방식은 요청된 데이터만 캐시되므로 자주 사용하지 않는 데이터로 인해 캐시가 복잡해지는 것을 방지할 수 있습니다.

# Cache-Aside 진행 방식

1. 애플리케이션은 캐시에서 필요한 데이터를 확인하고 반환합니다.
캐시에 데이터가 존재하지 않는 경우 다음 단계로 진행합니다.
2. 애플리케이션은 기본 데이터저장소(MySQL, MongoDB, ..) 에서 데이터를 조회합니다.
3. 조회된 데이터를 적절한 키와 함께 캐시에 추가합니다.
4. 마지막으로 조회된 데이터를 반환합니다.

# Cache-Aside 구현

서비스 계층에서 메서드에 `@Cacheable` 어노테이션을 적용하여 캐싱을 활성화합니다.

```java
@Service
public class DataService {

    @Autowired
    private DataRepository dataRepository;

    @Cacheable(value = "dataCache", key = "#id")
    public DataEntity getDataById(Long id) {
        return dataRepository.findById(id).orElse(null);
    }
}
```

서비스 계층에서 Cache-Aside 로직을 구현하는 메서드를 작성합니다.

아래 메서드는 캐시 미스가 발생할 때 호출됩니다.

```java
@Service
public class DataService {

    @Autowired
    private DataRepository dataRepository;

    @Autowired
    private RedisTemplate<String, DataEntity> redisTemplate;

    public DataEntity getDataByIdWithCacheAside(Long id) {
        DataEntity data = redisTemplate.opsForValue().get(String.valueOf(id));
        
        if (data == null) {
            data = dataRepository.findById(id).orElse(null);
            if (data != null) {
                redisTemplate.opsForValue().set(String.valueOf(id), data);
            }
        }
        
        return data;
    }
}
```

컨트롤러는 서비스 레이어에서 `getDataByIdWithCacheAside` 메서드를 호출합니다.

```java
@RestController
@RequestMapping("/api")
public class DataController {

    @Autowired
    private DataService dataService;

    @GetMapping("/data/{id}")
    public ResponseEntity<DataEntity> getDataById(@PathVariable Long id) {
        DataEntity data = dataService.getDataByIdWithCacheAside(id);
        
        if (data != null) {
            return ResponseEntity.ok(data);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}
```

# 이점

### 향상된 성능

캐시에 추가된 데이터는 데이터소스에서 가져올 때보다 훨씬 빠릅니다.

### 기본 데이터 소스의 부하 감소

메인 DB 의 부하를 줄여 전반적인 성능과 응답성을 개선합니다.

### 효율적인 캐시 활용

요청된 데이터만 캐시되므로 자주 액세스하지 않는 데이터로 캐시가 채워지는 것을 방지합니다.

### 간단하고 유연함

Cache-Aside는 구현이 간단하고 애플리케이션 내에서 캐시 관리를 유연하게 처리할 수 있습니다.

# 단점

### 캐시 일관성 문제

애플리케이션이 캐시 갱신을 담당하고 있어 기본 저장소 간 불일치 위험이 존재합니다.

기본 저장소의 데이터가 업데이트될 때 **캐시또한 즉시 업데이트되지 않는다면** 사용자에게 오래되거나 부정확한 데이터를 반환할 수 있습니다.

### 캐시 미스의 경우 패널티

캐시 미스가 발생하면 기본 저장소에서 데이터를 조회하고 다시 캐시를 채워야하는 추가적인 오버헤드가 발생합니다.

캐시 미스로 인한 지연은 시간에 민감한 작업의 경우 성능에 영향을 미칠 수 있습니다.

### 복잡도 증가

애플리케이션 코드베이스에 추가적인 복잡성을 도입하여 더 어려운 코드가 될 수 있습니다.

# 단점 보완

Cache-Aside 의 단점을 보완하기 위해 다음 전략을 사용할 수 있습니다.

### Write-Through Caching

두 소스를 동시에 업데이트하여 캐시 및 기본 저장소의 일관성을 보장

### Read-Through Caching

캐시 미스 발생 시 자동으로 캐시를 보충함으로써 캐시 미스에 따른 불이익을 줄임

### Write-Behind Caching

캐시에 작성한 후 기본 저장소를 비동기로 업데이트함

### Cache Invaildation(캐시 무효화)

기본 저장소 변경 시 항목을 제거하거나 업데이트하여 캐시 정확도를 적극적으로 관리

### TTL 또는 LRU(Least Recently Used) Cache

TTL 또는 LRU 캐시 퇴출 정책을 구현하여 캐시 일관성과 효율적인 공간 활용 유지에 도움을 줌

# 원문

**[Implementing Cache-Aside in a Spring Boot Application](https://medium.com/@bubu.tripathy/implementing-cache-aside-in-a-spring-boot-application-94e26c2dd89e)**

# References

**[[Spring] 캐시(Cache) 추상화와 사용법(@Cacheable, @CachePut, @CacheEvict)](https://mangkyu.tistory.com/179)**