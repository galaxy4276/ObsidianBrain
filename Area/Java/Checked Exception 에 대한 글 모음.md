---
tags: exception, java
---
![Untitled](Untitled%20132.png)

코틀린에서 `Checked Exception` 기능을 제외시켰는 지 대해 공식 문서 중 Rod Waldhoff 의

`Checked Exception` 에 대한 지적에 대한 내용을 우선적으로 언급하겠습니다.

Java 는 C++ 의 try/catch 를 계승받아 예외를 처리하며 “`Checked Exception`” 은 자바에서 추가 된 개념입니다.

언 뜻 보면 `Checked Exception` 이 복구할 수 없는 예외 조건을 처리할 수 있다는 점에서 꽤나 괜찮은 아이디어이며 `UnChecked Exception` 의 가장 큰 위험은 아무도 예외를 포착하지 못하여 문제가 스택에서 사라질 수 있다는 것입니다.

<aside>
💡 복구 불가능 예외 예시: 파일 읽기/쓰기, 네트워크 작업과 같은 I/O 작업

</aside>

이러한 경우 `Checked Exception` 을 이용하여 예외를 처리하거나 처리되지 않은 예외를 알릴 수 있습니다.

`Checked Exception` 은 언 뜻 보면 잘 동작하는 듯 하지만 애플리케이션 아키텍처의 연결 수준에서는 거의 재앙과도 같다고 합니다.

> Checked exceptions are pretty much disastrous for the connecting parts of an application's architecture however. - Rod Waldhoff
> 

그 이유는 하위 수준에서 발생할 수 있는 특정 유형의 장애에 대해 알 필요가 없거나 일반적으로 알고 싶어하지 않으며, 발생할 수 있는 예외 조건에 적절히 대응하기에는 너무 범용적이기 때문입니다.

즉 생산성이 하락하고 코드 퀄리티도 떨어진다는 점이 핵심입니다.

자세한 내용은 아래 링크를 참고

[Java's checked exceptions were a mistake (and here's what I would like to do about it)](https://radio-weblogs.com/0122027/stories/2003/04/01/JavasCheckedExceptionsWereAMistake.html)

또한 Checked Exception 에 대해 다수 개발자 유저가 개인 의견을 정리한 유용한 글을 첨부합니다.

[Java의 Checked Exception은 실수다?](https://velog.io/@eastperson/Java의-Checked-Exception은-실수다-83omm70j)

[당신의 Checked Exception은 필요 없다](https://velog.io/@sangmin7648/당신의-Checked-Exception은-필요-없다)

****[Java에서 Checked Exception은 언제 써야 하는가?](https://blog.benelog.net/1901121.html)****