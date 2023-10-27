---
tags: jpa
---
![Untitled](Untitled%2048.png)

# 일대다 관계의 “양방향” 과 “단뱡향” 개념

## 양방향(Bidirectional)

양방향 일대다 관계에서는 두 엔티티가 서로에 대한 참조를 가집니다.

즉, 부모에서 자식으로 또는 자식에서 부모로 어느 방향으로든 관계를 탐색할 수 있습니다.

```java
@Entity
public class Author {
    // ...

    @OneToMany(mappedBy = "author")
    private List<Book> books;

    // ...
}

@Entity
public class Book {
    // ...

    @ManyToOne
    @JoinColumn(name = "author_id")
    private Author author;

    // ...
}
```

## 단방향(Unidirectional)

단방향 일대다 관계에서는 하나의 엔티티만 다른 엔티티에 대한 참조를 갖습니다. 

즉, 부모에서 자식으로 한 방향으로만 관계를 탐색할 수 있습니다.

```java
@Entity
public class Author {
    // ...

    @OneToMany
    @JoinColumn(name = "author_id")
    private List<Book> books;

    // ...
}

@Entity
public class Book {
    // ...

    // No reference to the Author entity

    // ...
}
```

# `mappedBy`, `fetch`, `cascade` 그리고 `orphanRemoval` 에 대한 설명

다음 코드 예시 바탕으로 설명합니다.

```java
import javax.persistence.*;
import java.util.List;

@Entity
public class Author {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String name;
    
    @OneToMany(mappedBy = "author")
    private List<Book> books;
    
    // getters and setters
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
    
    // getters and setters
}
```

## `mappedBy`

`@OneToMany`어노테이션에의 `mappedBy` 필드는 `Book 엔티티`의 `Author` 속성이 관계의 소유자임을 명시합니다.

즉, 관계에 대한 변경 사항은 `Book 엔티티`의 `Author` 속성을 통해 유지됩니다.

`mappedBy` **속성은 특성은 일대다 관계에서 관계의 반대쪽을 나타내는 하위 엔티티의 속성 이름을 지정하는 데 사용됩니다.**

주로 관계의 소유를 지정하는 데 사용되며, 이는 관계에 대한 변경 사항이 데이터베이스를 올바르게 유지되도록 하는 역할을 수행합니다.

## `fetch=`

 일대다 관계에서 데이터베이스에 연결된 엔티티를 가져오는 방법을 지정하는데 사용됩니다.

`FetchType.EAGER` 또는 `FetchType.LAZY` 값을 가질 수 있습니다.

`FetchType.EAGER` 는 연결된 엔티티가 단일 쿼리에서 부모 엔티티와 함께 데이터베이스에서 가져오게 됩니다.

즉, 데이터베이스에서 로드될 때 연결된 엔티티를 항상 사용할 수 있으며, 연결된 엔티티를 가져오기 위해 추가 쿼리를 수행할 필요가 없습니다.

```java
@Entity
public class Author {
    // ...

    @OneToMany(fetch = FetchType.EAGER)
    private List<Book> books;

    // ...
}
```

이 예제에서 데이터베이스에서 `Author 엔터티`를 로드하면 연결된 `Book 엔터티`도 가져와서 **즉시 사용**할 수 있습니다.

`FetchType.LAZY` 는 상위 엔티티가 로드될 때 연결된 엔티티가 데이터베이스에서 가져오지 않습니다. 

대신, 연결된 엔티티 컬렉션에 처음 액세스할 때 필요에 따라 데이터베이스에서 연결된 엔티티를 가져옵니다. 

```java
@Entity
public class Author {
    // ...

    @OneToMany(fetch = FetchType.LAZY)
    private List<Book> books;

    // ...
}
```

## `cascade={}`

캐스케이드 특성은 일대다 관계에서 상위 엔터티에 대한 변경 사항이 연결된 엔터티로 캐스케이드되는 방식을 지정하는 데 사용됩니다.

<aside>
💡 **Cascade(영속성 전이)** 란?
특정 엔티티에 대해 특정한 작업을 수행하면 관련된 엔티티에도 동일한 작업을 수행한다는 의미입니다.

</aside>

`CascadeType.PERSIST`, `CascadeType.MERGE`, `CascadeType.REMOVE` 등과 같은 `CascadeType 열거형`에서 하나 이상의 값을 가질 수 있습니다.

## *`orphanRemoval =`*

일대다 관계에서 연관된 엔티티가 상위 엔티티에서 더 이상 참조되지 않을 때 데이터베이스에서 제거해야 하는지 여부를 지정하는 데 사용됩니다.

# `CasCadeType.REMOVE` 와 `orphanRemoval` 의 차이점

`orphanRemoval = true`와 `cascade = CascadeType.REMOVE`는 둘 다 데이터베이스에서 엔티티 제거를 제어한다는 점에서 유사하지만 작동 방식이 다릅니다. 

`orphanRemoval`은 다른 엔티티에서 더 이상 참조하지 않는 엔티티를 제거하도록 특별히 설계된 반면, `cascade = CascadeType.REMOVE`는 부모 엔티티가 삭제될 때 다른 엔티티에서 참조 여부와 관계없이 관련된 모든 엔티티를 제거합니다.

# References

[[JPA] save메서드로 살펴보는 persist와 merge 개념](https://umanking.github.io/2019/04/12/jpa-persist-merge/)

[JPA 연관관계 영속성 전이(CASCADE) - CascadeType](https://zzang9ha.tistory.com/350)

[[JPA] Spring JPA CascadeType 종류](https://data-make.tistory.com/668)

[In Spring Data JPA OneToMany What are These Fields (mappedBy, fetch, cascade and orphanRemoval)](https://medium.com/@burakkocakeu/in-spring-data-jpa-onetomany-what-are-these-fields-mappedby-fetch-cascade-and-orphanremoval-2655f4027c4f)