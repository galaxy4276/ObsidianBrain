---
tags: design-pattern
---

![[스크린샷 2023-10-26 오전 8.46.47.png]]
# 행동 패턴(Behavioral Pattern)

템플릿 메서드 디자인 패턴은 행동 패턴에 속한다.

여기서 행동 패턴이란 객체나 클래스 사이의 알고리즘이나 책임 분배에 관련된 패턴을 의미하며,

한 객체가 수행할 수 없는 작업을 여러 개의 객체로 임의의 방법을 이용해 분배하며 **객체 사이의 *결합도를 최소한으로 낮추는 것**에 중점을 둔다. 

<aside>
💡 *결합도
객체 간 상호 의존 정도 또는 관계의 끈끈함 정도를 의미한다.
예를 들면, 결합도가 강한 클래스는 다른 클래스와 의존성이 강하기 때문에 구조를 변경할 시 연관 된 클래스도 함께 변경해야 한다.

</aside>

# 템플릿 메서드 패턴(Template Method Pattern)

해당 디자인 패턴은 부모 클래스에서 알고리즘의 골격을 정의하지만, 해당 알고리즘의 구조를 변경하지 않고, 자식 클래스에서 알고리즘의 특정 단계를 오버라이드(재정의) 할 수 있도록 의도한다.

조금 더 쉽게 말해서..

**전체적으로 동일하면서 부분적으로는 다른 구문으로 구성 된 메서드 코드 중복을 최소화** 한다.

<aside>
💡 해당 디자인 패턴은 상속을 기반으로 한다.

</aside>

간단한 코드를 예시로 살펴보자.

<aside>
💡 글쓰기, 로그인, 로그아웃 기능이 존재하는 소셜 네트워크 서비스 역할을 수행하는 객체

</aside>

```java
public abstract class Network {
	String userName;
	String password;

	Network() {}

	/**
		* 부모 클래스에서 글 작성에 대한 템플릿을 제공한다.
	**/
	public boolean post(String message) {
        // Authenticate before posting. Every network uses a different
        // authentication method.
        if (logIn(this.userName, this.password)) {
            // Send the post data.
            boolean result =  sendData(message.getBytes());
            logOut();
            return result;
        }
        return false;
    }

		// 또한 자식마다(Twitter, Facebook, ...) 처리할 수 있는 방법에 대해 템플릿을 제공한다.
    abstract boolean logIn(String userName, String password);
    abstract boolean sendData(byte[] data);
    abstract void logOut();
}
```

이렇게 부모 클래스에서 알고리즘에 대해 부분적인 구현부를 자식 클래스에서 구현할 수 있게 끔 제공해두면 여러 자식 클래스에서 공통적인 로직 처리에 대해 코드를 덜 작성할 수 있게 된다.

```java
public class Facebook extends Network {
	...
	public logIn(String username, String password) { ... } // Facebook 만의 로그인 로직
	...
}

public class Twitter extends Network {
	...
	public logIn(String username, String password) { ... } // Twitter 만의 로그인 로직
	...
}
```

간단한 예제로 알아보듯이 템플릿 메서드 패턴은 규모가 큰 알고리즘의 일부분을 재정의 하도록 하여 다른 부분에서 발생하는 변경에 덜 영향을 받도록 하고, 중복 코드를 부모 클래스로 가져올 수 있는 장점이 있다.

그러나 다음과 같은 단점도 존재한다.

- 일부 클라이언트는 알고리즘의 제공된 골격에 의해 제한 될 수 있다.
- 자식 클래스를 통해 디폴트 단계 구현을 억제하여 리스코프 치환 원칙을 위반할 수 있다.

<aside>
💡 LSP(리스코프 치환 법칙)
부모 클래스의 행동 규약을 자식 클래스가 위반하면 안된다.

</aside>

- 템플릿 메서드들은 단계가 더 많을수록 유지가 더 어려워지는 경향이 존재한다.

장단점을 유의하여 자신의 코드의 구조에서 효율적인 지 판단하고 잘 사용해보도록 하자

# References

[템플릿 메서드 패턴](https://refactoring.guru/ko/design-patterns/template-method)

[[Design Pattern] 템플릿 메서드 패턴이란 - Heee's Development Blog](https://gmlwjd9405.github.io/2018/07/13/template-method-pattern.html)