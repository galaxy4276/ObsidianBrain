---
tags: kotlin
---
# [Kt] Coroutines 개념 정리

태그: Coroutines, Kotlin
Date: September 9, 2023 3:07 PM
공개 여부: 공개
설명: 코루틴에 대한 내용 정말 간략하게 정리
카테고리: 프로그래밍

![Untitled](Untitled%20133.png)

# What is Coroutines?

Coroutines 은 동시성 프로그래밍을 지원하는 하나의 개념이라고 볼 수 있다.

오해하면 안되는 것이 Kotlin 만의 개념이 아닌 대부분의 현대 언어에서 지원하고 있다.

해당 개념을 활용하면, 비동기를 처리하는 코드를 쉽게 작성할 수 있게 된다.

실제로 비동기를 처리하기 위해 Callback Hell 을 형성한다던 지 Rx 같은 라이브러리를 사용하여 비동기 코드를 제어하고 관리하고 있지만 대부분의 상황에서 Coroutines 을 사용하면 더 간결하고 빠르다.

JS 에서 셀 수 없이 해당 개념을 사용해온 만큼 Kotlin 에서 사용법 또는 Coroutines 관점에서 동시성/병렬성에 대해 헷갈리지 않게 이야기하는 내용을 References 에 첨부하고 마친다.

# P**ersonal Opinion**

Coroutines 을 학습하고 나서 Kotlin 은 MultiThread Programming 도 지원하는데 어떠한 상황에서 Coroutines 을 사용할 지, Thread 를 사용할 지 고민하는 내용을 간접적으로 경험해보면 도움이 많이 될 것 같다. 

코루틴의 경우 결국 하나의 스레드를 잘 활용하기 위해 개발자가 직접 스레드 내 작업을 제어하는 것으로  하나의 작업에 대해서 너무 많은 비동기 코드를 형성하거나 너무 오래 걸리는 작업이 있는 경우 스레드를 따로 생성하여 수행하는 것이 더 효율적일 것이라고 생각한다.

# References

[Coroutines basics | Kotlin](https://kotlinlang.org/docs/coroutines-basics.html#your-first-coroutine)

[코틀린 코루틴(coroutine) 개념 익히기 · 쾌락코딩](https://wooooooak.github.io/kotlin/2019/08/25/코틀린-코루틴-개념-익히기/)