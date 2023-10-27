# Spring Data JPA 성능 최적화

태그: JPA, 데이터베이스, 최적화
Date: September 14, 2023 12:43 AM
공개 여부: 공개
설명: JPA 를 사용함으로써 디비 쿼리를 최적화하는 방법
카테고리: Spring

![Untitled](Untitled%2028.png)

Spring Data JPA 로 성능을 최적화하려면 상호 작용 효율성을 개선하고, 불필요한 쿼리를 줄여야 한다.

또한 데이터 검색 및 조작을 최적화하기 위한 몇 가지 전략이 필요한데 이것에 관한 팁을 몇가지 정리하였다.

# 1. 적절한 인덱싱 사용하기

- 쿼리 실행 계획을 분석하여 `WHERE`, `JOIN`, `ORDER BY` 절에서 자주 사용되는 열을 식별하고 해당 열에 인덱스를 생성하여 데이터 검색 속도를 높인다.
    
    <aside>
    💡 과도한 인덱싱은 `INSERT`, `UPDATE` 성능에 영향을 줄 수 있으므로 주의하자.
    읽기와 쓰기 작업 간 균형을 유지해야 한다.
    
    </aside>
    

예제로 살펴보자.

책과 저자간 관계를 의마하는 두 개의 엔티티가 있다.

```java
@Entity
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private String isbn;
    
    @ManyToOne
    @JoinColumn(name = "author_id")
    private Author author;

    // Constructors, getters, setters
}

@Entity
public class Author {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;

    // Constructors, getters, setters
}
```

저자의 모든 책을 검색하는 쿼리를 자주실행한다 가정했을 때, **인덱스가 없으면 데이터베이스는 일치하는 행을 찾기위해 전체 Book 테이블을 스캔해야 하므로 테이블이 커질수록 속도는 점점 느려진다. (성능 이슈)**

이 문제를 해결하려면 `Author` 테이블과의 조인에 사용되는 `Book` 테이블의 `author_id` 열에 인덱스를 추가한다.

```java
@Entity
public class Book {
    // ...

    @ManyToOne
    @JoinColumn(name = "author_id")
    @org.hibernate.annotations.Index(name = "author_id_index") // 인덱스 추가
    private Author author;

    // ...
}
```

인덱스를 생성하면 데이터베이스가 인덱싱된 열을 기반으로 관련 행을 빠르게 찾을 수 있으므로 특정 저자의 책에 대해 쿼리 수행 속도가 훨씬 빨라진다.

이러한 관행은 애플리케이션 응답속도를 빠르게 제공할 수 있는 주요한 방법 중 하나이다.

# 2. Fetch 전략 이용하기

JPA 에서 Fetch 전략을 사용하면 `Lazy` 하게 가져올 지 즉시(`Eager`) 가져올 지 결정할 수 있다.

- 연관 관계에 대해 적절한 가져오기 전략(Lazy)을 사용하면 불필요한 엔티티 로딩을 방지할 수 있다.
- 필요할 때 단일 쿼리에서 관련 엔티티를 가져오려면 `JPQL` 쿼리에 명시적인 `JOIN FETCH` 절을 사용해라

예시로 살펴보자.

```java
@Entity
public class Author {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @OneToMany(mappedBy = "author", fetch = FetchType.LAZY) // Lazy 전략(프록시)
    private List<Book> books = new ArrayList<>();

    // getters and setters
}

@Entity
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    @ManyToOne(fetch = FetchType.EAGER) // 즉시 가져오기 전략
    @JoinColumn(name = "author_id")
    private Author author;

    // getters and setters
}
```

- `Author` 엔티티에서 책 컬렉션에 대해 지연(Lazy) 전략을 사용하여 저자를 불러오면 코드에서 실제로 액세스할 때까지 해당 도서 컬렉션이 로드되지 않는다.
- `Book` 엔티티에서 즉시(Eager) 전략을 사용하면 책 데이터를 불러왔을 때 연결된 저자도 함께 가져오게 된다.

## 주의 사항

**지연(Lazy) 전략을 제대로 관리하지 않으면 각 관련 엔티티가 별도의 DB 쿼리를 발생시키는 N + 1 쿼리 문제를 발생시킨다.**

# 3. 일괄 처리(Batch Fetching)

일괄 처리는 엔티티 간 연결, 특히 1:N, N:M 관계를 처리할 때 DB 쿼리를 최적화하기 위해 사용되는 기술을 말한다.

**관련 엔티티를 로드할 때 수행되는 개별 DB 쿼리 횟수를 줄여 성능을 개선하고 N + 1 쿼리 문제를 최소화하는 것을 목표로 한다.**

- Batch Fetching 을 활용해 단일 쿼리에서 여러 엔티티를 가져오면 N + 1 쿼리 문제를 줄일 수 있다.
- `@BatchSize` 또는 배치 구성을 사용하여 배치 크기를 구성할 수 있다.

두 개의 엔티티가 존재하는 단순한 전자상거래 도메인을 고려하여 일괄 처리의 예시를 살펴보자

<aside>
💡 일괄 처리를 사용하여 주문 항목 가져오기를 최적화하는 데 중점을 두었다.

</aside>

```java
@Entity
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Other order attributes, getters, setters
}

@Entity
public class OrderItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY) // 즉시 가져오기를 피하기 위한 지연 전략
    @JoinColumn(name = "order_id")
    private Order order;

    // Other order item attributes, getters, setters
}
```

`OrderItem` 엔티티에서 `Order` 에 대해 LAZY 설정은 불필요한 로딩을 피하기 위한 좋은 습관이다.

이제 코드에 Batch 를 적용해보자.

`@BatchSize` 는 단일 쿼리에서 특정 수의 연결된 엔티티를 가져와야 함을 의미한다.

```java
@Entity
@BatchSize(size = 10) // Batch Fetching 을 위한 size 설정
public class Order {
    // ...
}
```

위 예제에서는 `Hibernate` 가 연관 데이터는 `OrderItem` 을 10개의 배치로써 가져온다는 의미이다.

이제 JPA 쿼리를 사용하여 `Order` 엔티티를 가져오면 `Hibernate` 가 자동으로 일괄 처리를 사용하여 연결된 `OrderItem` 엔티티를 **일괄적으로 가져오게 되므로 실행되는 쿼리가 줄어든다.**

배치 크기를 적절하게 설정하고 `Batch Fetching` 을 사용하면 연결된 `OrderItem` 컬렉션과 함께 `Order` 엔티티를 효율적으로 검색하여 실행되는 DB 쿼리의 횟수를 최소화할 수 있다.

이러한 최적화는 데이터 집합의 크기가 커질수록 더욱 두드러진다.

# 4. 캐싱(Caching)

캐싱은 데이터베이스 쿼리 횟수를 줄이고 응답 시간을 늘려 애플리케이션의 성능을 크게 향상시킬 수 있다.

- `Spring Cache`, `Ecache`, `Caffine` 같은 솔루션으로 캐싱을 활성화하여 자주 액세스하는 데이터를 메모리에 저장하여 데이터베이스 히트를 줄이자.
- `second-level caching` 을 사용하여 세션 전체에 걸쳐 데이터를 캐싱할 수 있다.

`Spring Boot JPA` 의 캐시 예제를 살펴보자

## Cache Eviction

캐시된 데이터는 시간이 지남에 따라 stale 해질 수 있다.

<aside>
💡 **stale cache**
시스템이 수정될 때 마다 데이터의 사본을 보관하는 캐시는 업데이트되어야 하며 그렇지 않으면
오래된 데이터가 된다.
캐시에 접근할 때는 기본적으로 오래된 데이터가 제공되지 않도록 일관성을 보장하는 메커니즘이 존재해야 한다.
캐시에 있는 데이터가 무효화되거나 업데이트될 때 까지는 “오래된(stale)” 데이터라고 하며
이것을 stale cache 라고 부른다.

</aside>

**이를 처리하기 위해 특정 조건이 충족될 때 캐시에서 항목을 제거하는 데 사용할 수 있는 `@CacheEvict` 어노테이션을 제공한다.**

```java
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Service;

@Service
public class ProductService {

    @Cacheable("products")
    public Product getProductById(Long productId) {
        // Simulate fetching data from the database
        return databaseService.fetchProductById(productId);
    }

    @CacheEvict(value = "products", key = "#productId")
    public void updateProduct(Long productId, Product updatedProduct) {
        // Simulate updating data in the database
        databaseService.updateProduct(productId, updatedProduct);
    }
}
```

예제에서 `updateProduct` 메서드가 호출되면 `products` 캐시에서 해당 항목이 제거된다.

## Cache Put

수동으로 데이터를 캐시에 넣으려면 `@CachePut` 어노테이션을 사용할 수 있다.

이 어노테이션은 캐시된 데이터를 업데이트하고 업데이트된 데이터를 반환하려는 경우 유용하다.

```java
import org.springframework.cache.annotation.CachePut;
import org.springframework.stereotype.Service;

@Service
public class ProductService {

    @CachePut(value = "products", key = "#productId")
    public Product updateProduct(Long productId, Product updatedProduct) {
        // Simulate updating data in the database
        databaseService.updateProduct(productId, updatedProduct);

        return updatedProduct;
    }
}
```

`updateProduct` 메서드는 DB 의 데이터를 업데이트하고 캐시를 새 데이터로 업데이트한다.

# 5. 쿼리 최적화(Query Optimization)

- 필요한 데이터만 가져오는 효율적인 `JPQL` 또는 `Criteria API` 쿼리를 작성하자.
    
    <aside>
    💡 SELECT * 는 가급적 피하자.
    [[SELECT  는 얼마나 느릴까]]
    
    </aside>
    
- 필요한 필드만 가져오려면 적절한 `projection` 을 사용하자.
    
    <aside>
    💡 DTO Prjoections
    
    </aside>
    

# 6. 페이지네이션 & 정렬 사용(Pagination & Sorting)

페이징 및 정렬은 쿼리에서 검색되는 결과의 양을 제한하고 특정 표준에 따라 정렬하기 위해 사용되는 전략이다.

Spring 에서는 `Pageable` 인터페이스를 사용하여 쉽게 기능을 구현할 수 있다.

페이징 및 정렬을 사용하면 특히 대규모 데이터 세트를 처리할 때 Spring Data JPA 애플리케이션의 성능을 크게 향상시킬 수 있다.

- 쿼리에서 반환되는 결과의 수 제한
- 특정 기준에 따라 정렬함으로써 반환해야하는 데이터의 양을 줄임

**→ 응답속도 개선**

# 7. 읽기 전용 작업 수행(Read-Only Operations)

읽기 전용 트랜잭션을 명시적으로 표시하여 불필요한 트랜잭션 관련 오버헤드를 우회하여 DB 성능을 개선한다.

```java
@Transactional(readonly = true)
```

```java
@Service
@Transactional(readOnly = true)
public class OrderService {
    @Autowired
    private OrderRepository orderRepository;

    public List<Order> getOrdersByStatus(OrderStatus status) {
        return orderRepository.findOrdersByStatus(status);
    }
}
```

읽기 전용 트랜잭션은 DB에서 데이터를 수정하지 않으므로(Write) 잠금 충돌을 방지하고 트랜잭션 병행성을 향상시킨다.

또한 읽기 전용 트랜잭션은 DB 로그에 기록을 할 필요가 없으므로 로그 부담을 줄인다.

# 8. 배치 작업 수행(Batch Operations)

`bulk inserts, updates, deletes` 는 일괄 처리를 사용하게 된다.

**Spring Data JPA** 는 `saveAll()` 및 `deleteAllInBatch()` 메서드를 통해 배치 처리를 지원한다.

```java
@Service
public class OrderService {
    @Autowired
    private OrderRepository orderRepository;

    public List<Order> saveOrders(List<Order> orders) {
        return orderRepository.saveAll(orders);
    }
}
```

# 9. N + 1 쿼리 문제 피하기

N+1 쿼리 문제는 관계형 데이터베이스에서 데이터를 검색하기 위해 `Spring Boot JPA`와 같은 **객체 관계형 매핑(ORM) 프레임워크**를 사용할 때 발생하는 일반적인 성능 문제이다.

이 문제는 엔티티 모음을 가져올 때 발생하며, **각 엔티티의 관련 데이터에 액세스하기 위해 `ORM`은 각 엔티티에 대해 추가 쿼리를 생성하는데, 이로 인해 데이터베이스 쿼리 수가 크게 증가하여 성능이 저하되고 데이터베이스 서버의 부하가 증가하게 된다.**

예제를 통해 자세히 확인해보자.

Author 와 Book. 여기서 Author 는 여러 권의 Book 을 가질 수 있고 이들 간 관계는 1:N 이다.

```java
@Entity
public class Author {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    // Other fields, getters, setters...
}

@Entity
public class Book {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    
    @ManyToOne
    @JoinColumn(name = "author_id")
    private Author author;
    // Other fields, getters, setters...
}
```

### 문제 발생

`Book` 과 함께 `Author` 목록을 검색한다고 가정했을 때, `Author` 를 가져온 다음 `Book` 에 액세스하려는 경우,

JPA 는 각 `Author` 의 `Book` 에 대해 별도의 쿼리를 생성한다.

이렇게하면 `Author` 를 가져오기 위한 쿼리는 하나, 각 `Author` 의 `Book`을 가져오는 쿼리는 N개(여기서 N은 `Author` 의 수) 가 생성된다.

따라서 우리는 이것을 N + 1 쿼리 문제라고 한다.

여기서부터는 `Author` 를 저자, `Book` 을 책이라고 하겠다.

저자가 두 명이고, 각 저자가 3권 씩 책을 가지고 있다고 가정할 때,
저자를 불러오고 각 저자의 책에 대해 접근했을 때, 1 + 2 쿼리가 발생한다.

- 저자들을 가져오는 쿼리
- 저자 1의 책을 가져오는 쿼리
- 저자 2의 책을 가져오는 쿼리

이렇게 3개의 쿼리가 생성되는데, 한 개만 있으면 충분해야하는게 맞습니다.

### 해결 방법

N + 1 쿼리 문제를 피하기 위해서는 Eager 또는 Lazy 로딩 개념을 사용할 수 있다.

<aside>
💡 기본적으로 JPA는 관계에 Lazy 로딩을 사용한다.

</aside>

다른 대안으로는 조인이 포함된 명시적인 쿼리(`JPQL` 또는 `Criteria API`) 를 사용하는 것이다.

### Eager Loading 을 사용하는 방법

```java
@Entity
public class Author {
    // ...
    
    @OneToMany(mappedBy = "author", fetch = FetchType.EAGER)
    private List<Book> books;
    // ...
}
```

### Join Fetch 쿼리를 사용하는 방법

```java
@Repository
public interface AuthorRepository extends JpaRepository<Author, Long> {
    @Query("SELECT DISTINCT a FROM Author a JOIN FETCH a.books")
    List<Author> findAllWithBooks();
}
```

이 쿼리에서는 `JOIN FETCH` 는 단일 쿼리에서 저자가 책과 함께 검색되도록 한다.

N+1 쿼리 문제를 해결하면 데이터베이스 쿼리 수를 최소화하고 데이터베이스 서버의 부하를 줄임으로써 Spring Boot JPA 애플리케이션의 성능을 크게 향상시킬 수 있다.

# 원 글

**[Optimizing Performance with Spring Data JPA](https://medium.com/@avi.singh.iit01/optimizing-performance-with-spring-data-jpa-85583362cf3a)**

# References

**[JPA로 인덱스 사용하기](https://velog.io/@ljinsk3/JPA%EB%A1%9C-%EC%9D%B8%EB%8D%B1%EC%8A%A4-%EC%82%AC%EC%9A%A9%ED%95%98%EA%B8%B0)**

[**What is Stale Cache [Quora]**](https://www.quora.com/What-is-stale-cache)

**[N+1 문제](https://incheol-jung.gitbook.io/docs/q-and-a/spring/n+1)**

[[SELECT  는 얼마나 느릴까]]