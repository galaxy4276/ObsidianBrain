---
tags: java
---
![Untitled](Untitled%2029.png)

서버 개발을 할 때 DTO 를 작성할 때 마다 record 키워드를 권장했다.

무엇인가 코틀린의 data 객체 선언과 유사한 모습에 어떠한 기능을 수행하는 지 궁금하여 작성합니다.

# record 키워드는 왜 등장했을까?

객체 간 불변 데이터를 전달하는 것은 Java 애플리케이션에서 많은 일상 작업 중 하나입니다.

Java 14 이전에는 상용구 필드와 메서드가 있는 클래스를 생성해야 했기 때문에 사소한 실수나 의도가 왜곡되기 쉬웠습니다.

자바 14 부터 record 가 등장하면서 이러한 문제를 해결하기 쉬워졌다고 합니다.

일반적으로 DB 에서 가져온 값 또는 특정한 정보에 대한 전달 클래스를 작성할 때 다음과 같은 작업을 수행합니다.

- 각 데이터에 대한 `private` 와 `final` 선언
- 각 필드에 대한 `getter` 선언
- 각 필드에 해당하는 인자를 가진 `public` 생성자
- 모든 필드가 일치할 때 동일한 클래스의 객체에 대해 `true` 를 반환하는 메서드
- 모든 필드가 일치할 때 동일한 값을 반환하는 `hashCode()`
- 클래스 이름과 각 필드를 포함하는 값을 문자열로 반환하는 `toString()`

```java
public class Person {

    private final String name;
    private final String address;

    public Person(String name, String address) {
        this.name = name;
        this.address = address;
    }

    @Override
    public int hashCode() {
        return Objects.hash(name, address);
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        } else if (!(obj instanceof Person)) {
            return false;
        } else {
            Person other = (Person) obj;
            return Objects.equals(name, other.name)
              && Objects.equals(address, other.address);
        }
    }

    @Override
    public String toString() {
        return "Person [name=" + name + ", address=" + address + "]";
    }

    // standard getters
}
```

이러한 코드를 작성하면 2가지 문제에 직면하게 됩니다.

- 너무 많은 boilerplate 코드
- name 과 address 가 있는 클래스를 의미하기엔 의도를 모호하게 만듦

IDE 에서 많은 기능을 제공한다고 해도 클래스를 작성하자마자 자동으로 추가하지는 못합니다.

또한 추가적인 몇몇 코드로 인해 단순히 name, address 두 개의 문자열 필드가 존재하는 data class 라는 사실이 모호해집니다.

# Record

JDK 14 부터 반복적 데이터 클래스를 레코드로 대체할 수 있습니다.

레코드는 필드 유형과 이름만 필요한 불변 데이터 클래스입니다.

`equals, toString, private, final 필드, public 생성자`는 컴파일러에 의해 생성된다.

간단하게 다음과 같이 생성할 수 있다.

```java
public record Person (String name, String address) {}
```

## Getter

record 로 클래스를 생성하면 필드 이름으로 `getter` 메서드를 얻을 수 있습니다.

```java
@Test
public void givenValidNameAndAddress_whenGetNameAndAddress_thenExpectedValuesReturned() {
    String name = "John Doe";
    String address = "100 Linda Ln.";

    Person person = new Person(name, address);

    assertEquals(name, person.name());
    assertEquals(address, person.address());
}
```

## equals

이 메서드는 개체의 유형이 같고 모든 필드 값이 일치하면 `true` 를 반환합니다.

```java
@Test
public void givenSameNameAndAddress_whenEquals_thenPersonsEqual() {
    String name = "John Doe";
    String address = "100 Linda Ln.";

    Person person1 = new Person(name, address);
    Person person2 = new Person(name, address);

    assertTrue(person1.equals(person2));
}
```

## hashCode

해당 메서드는 두 개체의 필드 값이 모두 일치하는 경우 두 개체에 대해 동일한 값을 반환합니다.

# Constructors

공용 생성자가 생성되더라도 생성자 구현을 사용자 정의할 수 있습니다.

이 사용자 지정 선언은 유효성 검사에 사용하기 위한 것이므로 가능한 간단하게 유지해야 합니다.

예를 들어 다음 생성자 구현을 사용하여 개인 레코드에 제공된 이름과 주소가 null 이 아닌 지 확인가능합니다.

```java
public record Person(String name, String address) {
    public Person {
        Objects.requireNonNull(name);
        Objects.requireNonNull(address);
    }
}
```

이런식으로 사용할 수도 있다.

```java
public record Person(String name, String address) {
    public Person(String name) {
        this(name, "Unknown");
    }
}
```

# Static 변수와 메서드

일반  Java 클래스와 마찬가지로 레코드에 정적 변수와 메서드를 포함할 수 있습니다.

정적 변수는 클래스와 동일한 구문을 사용하여 선언합니다.

```java
public record Person(String name, String address) {
    public static String UNKNOWN_ADDRESS = "Unknown";
}
```

```java
public record Person(String name, String address) {
    public static Person unnamed(String address) {
        return new Person("Unnamed", address);
    }
}
```