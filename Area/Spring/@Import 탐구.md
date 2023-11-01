---
tags: spring
---
![[springboot-banner-01.jpg]]
# Import 는 어떤 역할을 수행하나?

Import 에 대해 간략하게 설명하자면, 한 객체 안에서 수십 개의 빈을 불러오는 과정을 그룹화(Groiping) 하여 관리할 수 있게 해준다.

[docs.spring.io](http://docs.spring.io) 에서 설명하는 스펙에 대한 소개는 다음과 같다.

> 임포트할 컴포넌트 클래스 (일반적으로 `@Configuration` 클래스) 를 하나 이상 나타냅니다.
`@Configuration` 클래스 뿐만 아닌 `ImportSelector`, `ImportBeanDefinitionRegistrar` 구현을 임포트할 수 있습니다.
`XML` 또는 `@Configuration` 이 아닌 다른 빈 정의 리소스를 가져와야 하는 경우 `@ImportResource` 어노테이션을 사용하세요.


코드의 예제를 표현하자면 아래 코드를

```java
@ContextConfiguration(classes = { BirdConfig.class, CatConfig.class, DogConfig.class })
class ConfigUnitTest {
...
}
```

다음과 같이 빈을 가져오는 설정을 묶어 관리할 수 있게 해준다.

```java
@Configuration
@Import({ DogConfig.class, CatConfig.class })
class MammalConfiguration {}

@ContextConfiguration(classes = { MammalConfiguration.class })
class ConfigUnitTest {
...
}
```

`Enable*` 로 관리하는 합성 애노테이션도 구현부를 확인해보면 내부적으로 `Import` 를 활용하고 있다.

아래는 `EnableJpaAuditing` 의 예시이다.

```java
@Documented
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Import(JpaAuditingRegistrar.class)
public @interface EnableJpaAuditing {
	...
}
```

이런식으로 `Import` 를 적절하게 활용하면 `Configuration` 의 중복을 방지하며 쉽게 확장할 수 있다.

그럼 이제 `Configuration` 뿐만 아닌 `ImportSelector` 와 같은 구현또한 Import 할 수 있다는데, 해당 객체는 무슨 역할을 수행할까?

# ImportSelector

사용자가 생성하는 임의 조건에 따라 가져올 `@Configuration` 클래스를 결정하는 인터페이스이다.

다음 Aware 인터페이스 중 하나를 구현할 수 있ㅇ며, 각각의 메서드는 `selectImports` 이전에 호출된다.

- [EnvironmentAware](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/EnvironmentAware.html)
- [BeanFactoryAware](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/beans/factory/BeanFactoryAware.html)
- [BeanClassLoaderAware](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/beans/factory/BeanClassLoaderAware.html)
- [ResourceLoaderAware](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/ResourceLoaderAware.html)

ImportSelector 를 활용하는 [예제 링크](https://www.logicbig.com/how-to/code-snippets/jcode-spring-framework-importselector.html)를 첨부한다.

# ImportResource

```java
@Configuration
@ImportResource({ "saving-account-config.xml", "loan-account-config.xml" })
class AccountConfiguration {}
```

XML 형식의 스프링 구성 파일을 현재의 구성 클래스로 가져오는 데 사용된다.

# References

**[Annotation Interface Import Spring docs](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/annotation/Import.html)**

[**Baeldung](https://www.baeldung.com/spring-import-annotation)** 

[Composing Java-based Configurations :: Spring Framework](https://docs.spring.io/spring-framework/reference/core/beans/java/composing-configuration-classes.html#beans-java-using-import)

**[Interface ImportSelector](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/annotation/ImportSelector.html)**