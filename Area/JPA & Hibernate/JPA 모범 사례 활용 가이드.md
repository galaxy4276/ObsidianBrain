---
tags: jpa, hibernate
---
JPA 를 더 잘사용하기 위해 해당 글을 작성하였습니다.

기존에 알고있었던 JPA 와 Hibernate 의 특징에 대해 간략하게 정리해볼게요.

JPA, Hibernate 는 Java ORM 을 의미하며 ORM은 개발자가 Java 객체를 관계형 데이터베이스 테이블에 매핑할 수 있는 기술입니다. 
즉, **개발자는 SQL 코드를 작성하지 않고도 Java 객체를 사용하여 데이터베이스와 상호 작용할 수 있습니다**.

# JPA 특징
JPA는 다음과 같이 데이터 지속성을 쉽게 관리할 수 있는 다양한 기능을 제공합니다.
### 엔티티 매핑
JPA를 사용하면 개발자가 **어노테이션을 사용하여 Java 객체를 관계형 데이터베이스 테이블에 매핑할** 수 있습니다. 
이를 통해 두 시스템 유형 간의 매핑을 생성하고 유지 관리하는 프로세스가 간소화됩니다.

### 객체 지향 쿼리(JPQL)
JPA는 데이터베이스에서 데이터를 쿼리하는 데 사용할 수 있는 객체 지향 쿼리 언어인 JPQL(Java 지속성 쿼리 언어)을 제공합니다.

### 트랜잭션 관리
JPA는 개발자가 데이터베이스에서 트랜잭션을 관리할 수 있는 트랜잭션 관리 API를 제공합니다.

# Hibernate 특징
최대 절전 모드는 JPA 사양의 인기 있는 오픈 소스 구현체입니다.
### 캐싱
Hibernate 는  **데이터베이스 데이터를 메모리에 캐시할** 수 있습니다.

### 지연 로딩
모든 DB에서 데이터를 지연 로드할 수 있으므로 필요할 때만 데이터를 로드합니다.

### 트랜잭션 관리
데이터의 무결성을 보장하는 데 도움이 되는 기본 제공 트랜잭션 관리 지원을 제공합니다.

# JPA 와 함께 DB 성능을 최적화하는 법

## 적절한 인덱스 사용
인덱스는 **데이터베이스 테이블에서 데이터 검색 작업의 속도를 향상시키는** 데이터 구조입니다.
인덱스는 책의 색인처럼 작동하여 데이터베이스가 쿼리의 WHERE 절을 만족하거나 JOIN 연산에 관련된 행을 빠르게 찾을 수 있게 해줍니다. 
인덱스가 없으면 데이터베이스가 전체 테이블을 스캔해야 하므로 대규모 데이터 셋의 경우 속도가 느려질 수 있습니다.
```java
import org.springframework.data.jpa.domain.support.AuditingEntityListener;  
import javax.persistence.*;  
  
@Entity  
@Table(name = "products")  
@EntityListeners(AuditingEntityListener.class)  
public class Product {  
@Id  
@GeneratedValue(strategy = GenerationType.IDENTITY)  
private Long id;  
  
@Column(unique = true)  
private String sku;  
  
@Column  
private String name;  
  
// Add index to sku field  
@Index(name = "idx_sku")  
@Column(unique = true)  
private String sku;  
  
// ...  
}
```
### 고려사항
- 인덱스에는 장단점이 있습니다. **읽기** 작업의 속도는 빨라지지만 데이터베이스가 인덱스 데이터 구조를 유지해야 하므로 **쓰기** (삽입, 업데이트, 삭제) 작업의 속도가 느려질 **수** 있습니다. 
- 따라서 인덱싱할 열을 신중하게 선택해야 하며, **WHERE 절이나 JOIN 연산에서 자주 사용되는** 열을 중심으로 선택해야 합니다.
- 단일 열 인덱스 외에도 여러 열의 조합을 기반으로 자주 쿼리하는 경우 여러 열에 복합 인덱스를 만들 수 있습니다.

## 캐싱(Redis) 사용

```java
@Service  
public class ProductService {  
@Autowired  
private ProductRepository productRepository;  
  
@Cacheable("products")  
public List<Product> getAllProducts() {  
	return productRepository.findAll();  
}  
  
@Cacheable(value = "products", key = "#id")  
public Product getProductById(Long id) {  
	return productRepository.findById(id).orElse(null);  
}  
  
@CacheEvict(value = "products", allEntries = true)  
public void clearProductCache()   
}
```

## Bulk Update 사용
다수 행에 대해 개별 업데이트를 수행하는 방식은 여러 SELECT, UPDATE 문을 생성하므로 데이터베이스 라운드 트립이 발생하고 오버헤드가 증가합니다.

대조적으로 대량 업데이트 접근 방식은 `@Modifying` 주석이 포함된 단일 JPQL(Java 지속성 쿼리 언어) 쿼리를 사용합니다. 
이 쿼리는 기준을 충족하는 엔티티의 `사용 가능한` 속성을 개별적으로 메모리에 로드하지 않고 직접 업데이트합니다. 이 쿼리는 **단일 SQL UPDATE 문을 수행하므로 더 효율적이며 데이터베이스 라운드 트립과 오버헤드를 크게 줄여줍니다**.

다른 접근 방식으로 JDBC의 일괄 처리 방식을 이용할 수 있습니다.
