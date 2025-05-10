#java #spring 
## DTO (Data Transfer Objects)
DTO는 애플리케이션의 레이어 간에 데이터를 전송하는 간단한 자바 객체다. DAO(Data Access Object)와 컨트롤러 또는 서비스 간에 데이터를 주고받을 때 주로 사용한다. 이들은 일반적으로 비즈니스 로직을 포함하지 않고 필드와 게터, 세터만 가지고 있다.
![[1_Xdfo5JAiW3S-xofdDXNkng-1.webp]]
### DTO를 사용하는 이유
- 관심사 분리 DTO는 데이터베이스나 엔티티의 내부 데이터 구조를 API나 UI 레이어에서 사용되는 표현과 분리한다
- 보안 엔티티에서 민감한 필드가 노출되는 것을 방지한다
- 성능 필요한 필드만 반환하여 페이로드 크기를 줄일 수 있다
- 유연성 API 버전 관리와 동일한 엔티티에 대한 다양한 표현을 쉽게 만들 수 있다

### DTO 예시
`Entity`
```java
@Entity
public class User {
    @Id
    private Long id;
    private String username;
    private String email;
    private String password; // API에서 노출되어선 안 됨
    private String address;
    // Getters and setters
}
```

`DTO`
```java
public class UserDTO {
    private String username;
    private String email;
    // Getters and setters
}
```

Entity에서 DTO로 매핑하기
```java
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
    
    public List<UserDTO> getAllUsers() {
        List<User> users = userRepository.findAll();
        return users.stream()
                .map(user -> {
                    UserDTO dto = new UserDTO();
                    dto.setUsername(user.getUsername());
                    dto.setEmail(user.getEmail());
                    return dto;
                })
                .collect(Collectors.toList());
    }
}
```

## Projections
Projections은 데이터베이스에서 특정 필드만 가져오는 방법이다. 주로 JPA 쿼리를 통해 직접 가져오며, 인터페이스 기반 또는 클래스 기반으로 구현할 수 있다.
### Projections을 사용하는 이유
- 성능 불필요한 필드를 가져오지 않아 메모리 사용량을 줄이고 쿼리 성능을 향상시킨다
- 편의성 필요한 형식으로 데이터를 직접 가져와 추가적인 매핑 로직을 거치지 않아도 된다
### Projections 예시
인터페이스 기반 Projection

```java
public interface UserProjection {
    String getUsername();
    String getEmail();
}
```

`Repository`

```java
public interface UserRepository extends JpaRepository<User, Long> {
    List<UserProjection> findAllBy();
}
```

`사용법`

```java
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
    
    public List<UserProjection> getAllUsers() {
        return userRepository.findAllBy();
    }
}
```

## Mappers
Mappers는 다른 객체 타입 간의 변환을 자동화한다. 주로 DTO와 엔티티 간의 변환에 사용되며, MapStruct나 ModelMapper 같은 인기 있는 라이브러리를 통해 구현한다.

### Mappers를 사용하는 이유
- 편리함 필드 매핑을 위한 상용구 코드를 줄여준다
- 일관성 애플리케이션 전체에 걸쳐 일관된 매핑 규칙이 적용되도록 보장한다

### Mapper 예시
`DTO`

```java
public class UserDTO {
    private String username;
    private String email;
}
```

`Entity`

```java
@Entity
public class User {
    @Id
    private Long id;
    private String username;
    private String email;
    private String password;
}
```

`Mapper 인터페이스`

```java
@Mapper(componentModel = "spring")
public interface UserMapper {
    UserDTO toDto(User user);
    User toEntity(UserDTO userDTO);
}
```

`Service`

```java
@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private UserMapper userMapper;
    
    public UserDTO getUserById(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("User not found"));
        return userMapper.toDto(user);
    }
}
```

## 트레이드오프와 사용 사례
### 각 방식을 사용하는 시기
- DTO 데이터 표현의 유연성이 필요하거나, 내부 구조를 추상화하고 싶거나, 민감한 데이터를 제외해야 할 때 사용한다
- Projections 성능이 중요한 읽기 위주의 작업에서 엔티티의 특정 필드만 필요할 때 사용한다
- Mappers 애플리케이션에 복잡한 매핑 요구 사항이 있고 상용구 코드를 줄이는 것이 우선순위일 때 사용한다

## Personal Opinion
개인적으로는 복잡한 비즈니스 요구사항이 있는 프로젝트에서는 세 가지 방식을 적절히 혼합해서 사용하는 것이 좋다고 생각한다. 간단한 조회 작업에는 Projections을 사용해 성능을 최적화하고, 복잡한 데이터 변환이 필요한 경우에는 Mapper 라이브러리를 활용하며, API 응답이나 요청에는 DTO를 사용하는 식이다.

💡 특히 MapStruct는 컴파일 타임에 매핑 코드를 생성하기 때문에 런타임 오버헤드가 없어 성능 면에서 ModelMapper보다 우수하다.

이러한 패턴들을 프로젝트 초기부터 일관되게 적용하면 코드 유지보수성이 크게 향상되고 애플리케이션이 점차 커지더라도 관리가 용이해진다.

## Mapper에 대한 추가 설명

![[1_qTv8Swhy0zLSoWPMIxrivA-1.webp]]

Mapper는 객체 간 변환을 자동화해주는 도구인데, 그중에서 MapStruct는 가장 인기 있는 매핑 라이브러리 중 하나다.
### MapStruct의 특징
MapStruct는 자바의 어노테이션 프로세서를 사용해서 컴파일 시점에 매핑 코드를 생성해준다. 다른 매핑 라이브러리들(ModelMapper, Dozer 등)이 런타임에 리플렉션을 사용하는 것과 달리, MapStruct는 실제 자바 코드를 생성하기 때문에 성능이 월등히 좋다.

```java
@Mapper
public interface PersonMapper {
    PersonMapper INSTANCE = Mappers.getMapper(PersonMapper.class);
    
    @Mapping(source = "birthDate", target = "dateOfBirth")
    @Mapping(source = "address.city", target = "city")
    PersonDto personToPersonDto(Person person);
}
```

위와 같이 인터페이스만 정의하면 MapStruct가 자동으로 구현체를 만들어준다. 컴파일된 클래스를 보면 실제로는 아래처럼 명시적인 매핑 코드가 생성된다.

```java
public class PersonMapperImpl implements PersonMapper {
    @Override
    public PersonDto personToPersonDto(Person person) {
        if (person == null) {
            return null;
        }
        
        PersonDto personDto = new PersonDto();
        
        if (person.getBirthDate() != null) {
            personDto.setDateOfBirth(person.getBirthDate());
        }
        
        if (person.getAddress() != null) {
            personDto.setCity(person.getAddress().getCity());
        }
        
        return personDto;
    }
}
```

### 복잡한 매핑도 처리 가능
MapStruct는 단순한 필드 복사뿐만 아니라 다음과 같은 복잡한 변환도 쉽게 처리할 수 있다.
1. **중첩된 객체 매핑**
    
    ```java
    @Mapping(source = "user.address.street", target = "streetName")
    ```
    
2. **타입 변환**
    
    ```java
    // String -> Date 자동 변환
    @Mapping(source = "stringDate", target = "date", dateFormat = "yyyy-MM-dd")
    ```
    
3. **커스텀 매핑 메서드**
    
    ```java
    default AddressDto map(Address address) {
        if (address == null) return null;
        // 커스텀 변환 로직
        return new AddressDto(...);
    }
    ```
    
4. **다중 소스에서 매핑**
    
    ```java
    @Mapping(source = "person.name", target = "name")
    @Mapping(source = "address.city", target = "city")
    PersonAddressDto personAndAddressToDto(Person person, Address address);
    ```
    
### MapStruct vs 다른 매핑 라이브러리
MapStruct는 다른 매핑 라이브러리에 비해 몇 가지 장점이 있다.
1. **성능**: 컴파일 타임에 코드를 생성하므로 리플렉션을 사용하는 ModelMapper나 Dozer보다 약 5-10배 빠르다.
2. **컴파일 시점 오류 검출**: 매핑 구성에 문제가 있으면 컴파일 타임에 오류가 발생하므로 런타임 오류를 방지할 수 있다.
3. **IDE 지원**: 생성된 구현체를 디버깅할 수 있고, 코드 자동 완성 등 IDE 기능을 모두 활용할 수 있다.
4. **스프링 통합**: `@Mapper(componentModel = "spring")` 설정을 통해 스프링 빈으로 자동 등록된다.

### MapStruct 사용 시 꿀팁
1. **디폴트 메서드**: 특별한 매핑 로직이 필요한 경우 인터페이스에 default 메서드로 구현할 수 있다.
2. **매핑 무시**: 특정 필드를 무시하려면 `@Mapping(target = "필드명", ignore = true)`를 사용하면 된다.
3. **매핑 전/후 처리**: `@BeforeMapping`과 `@AfterMapping` 어노테이션을 사용하여 변환 전후에 추가 로직을 실행할 수 있다.
4. **상속**: 매퍼 간에 공통 매핑 메서드를 재사용하기 위해 상속을 활용할 수 있다.

💡 MapStruct는 특히 대규모 프로젝트에서 코드의 양을 줄이고 타입 안전성을 높이는 데 큰 도움이 된다. 처음 설정하는 데는 약간의 학습 곡선이 있지만, 익숙해지면 매핑 코드 작성 시간을 대폭 절약할 수 있다.

만약 프로젝트에서 DTO 패턴을 많이 사용한다면 MapStruct는 거의 필수적인 도구라고 볼 수 있다. 특히 복잡한 도메인 모델과 다양한 DTO 간의 변환이 필요한 경우에 그 가치가 더욱 빛난다.

# References
https://medium.com/@avicsebooks/dto-vs-projections-vs-mappers-d88086d95536
