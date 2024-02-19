---
tags: nodejs
---
## setTimeout, setInterval, console 은 JavaScript 가 아니다.

setTimeout, setInterval, console 은 JS로 구현된 것이 아닌 각 런타임 환경에서 컨벤션에 따라 구현하는 함수이다.

[working group](https://console.spec.whatwg.org/) 는 모든 런타임이 따를 수 있는 공통 표준 API를 정의하는 문서의 일부이다.

## Node.js 와 JavaScript, V8, Libuv 간의 C++ Bridge

Node.js 는 엄밀히 말해, Libuv 를 추가하고 작업 일정 비동기화 함수를 만들어 Chrome 의 V8 엔진 동작을 확장하는 도구이다.
``
아래 영상은 JS 런타임에 custom print 및 setTimeout 함수를 도입하는 방법에 대해 설명한다. 
![[0_FxQUb83W_0esCW3d.gif.gif]]


동작방식을 간단하게 설명하면 다음과 같다.

1. 자바스크립트는 Chrome 의 V8 엔진이 해석하고 실행하는 문자열일 뿐이다.
2. C++ 코드는 JavaScript, V8, Libuv 를 각각 연결해주는 다리 역할을 수행한다.
여기에서 V8 API를 사용하여 전역 JavaScript 컨텍스트에 새 함수를 추가할 수 있다.
3. V8에 새 함수(print) 를 추가하는 코드를 작성한 후, 마술처럼 JavaScript 에서 globalThis 를 이용해 함수를 호출할 수 있다.

## custom console.log 함수를 구현하기

Node.js 에서 console.log 함수는 C++ printf 함수를 추상화한 것에 불과하다.

아래 코드에서 예시를 참고 바람

```cpp
static void Print(const v8::FunctionCallbackInfo<v8::Value> &args)
{

    bool first = true;
    for (int i = 0; i < args.Length(); i++)
    {
        v8::HandleScope handle_scope(args.GetIsolate());
        if (first)
        {
            first = false;
        }
        else
        {
            printf(" ");
        }
        v8::String::Utf8Value str(args.GetIsolate(), args[i]);
        // here is the log function
        printf("%s", *str);
    }
    printf("\n");
    fflush(stdout);
}
```

해당 함수는 JavaScript 전역환경에 바인딩된 C++ 함수이며 JavaScript 함수에서 호출 할 수 있다.

```cpp
// In Node.js
print('Hello World')
```

따라서 JS에서 이 함수를 호출하면 마치 JS 자체의 일부인 것처럼 마술같이 동작한다.

setTimeout, setInterval 또한 동일한 접근방식을 따른다.

이 두 함수는 C++ 함수이며 Node.js 에서는 Libuv 가 타이머 처리를 담당한다.

타이머는 환경에 의존하며 환경에 의존하는 자바스크립트에서 호출하는 모든 함수는 일반적으로 외부 함수이다.

<aside>
💡 즉, Node.js 에서 setTimeout, setInterval 은 운영체제 API를 내부적으로 호출하는 Libuv 타이머에 대한 추상화이다.

</aside>

아래 예시는 setTimeout 및 setInterval 함수를 만드는 데 사용된 C++ 코드 스니펫이다.

```cpp
static void Timeout(const v8::FunctionCallbackInfo<v8::Value> &args)
{
    auto isolate = args.GetIsolate();
    auto context = isolate->GetCurrentContext();
    int64_t sleep = args[0]->IntegerValue(context).ToChecked();
    int64_t interval = args[1]->IntegerValue(context).ToChecked();

    v8::Local<v8::Value> callback = args[2];
    if(!callback->IsFunction()) 
    {
        printf("callback not declared!");
        return;
    }

    timer *timerWrap = new timer();
    timerWrap->callback.Reset(isolate, callback.As<v8::Function>());
    timerWrap->uvTimer.data = (void *)timerWrap;
    timerWrap->isolate = isolate;

    uv_timer_init(loop, &timerWrap->uvTimer);
    uv_timer_start(
            &timerWrap->uvTimer, 
            onTimerCallback, 
            sleep, 
            interval
    );

}
```

### 정리

자바스크립트에 존재하는 모든 기능은 ECMAScript 사양에 의해 정의된다.

이를 제외한 모든 것은 자바스크립트가 실행되는 환경에 따라 달라진다.

즉 Node.js 가 console.log 대신 print 를 호출했었다면 ECMAScript 사양을 위반하지 않았을 것이다.

## Promise 는 비동기 작업이 아니라 콜백을 위한 래퍼일 뿐

![Untitled](Untitled%2026.png)

Promise 는 [JS 스펙](https://tc39.es/ecma262/#sec-promise-objects)에 존재한다 즉, JS 런타임 환경에 의존하지 않는다.

하지만 흔히 Promise 가 비동기 연산이라고 생각하는 것은 오해이다.

Promise 는 비동기 연산을 처리하는 방법이며, 완료된 후 해당 연산의 결과를 처리하는 메커니즘을 제공한다.

이를 통해 비동기 코드가 동기식 코드처럼 보이므로 읽기 쉽고 관리가 용이해진다.

또한 Promise 는 비동기 코드에서 작동하도록 설계되었다.

Promise 를 생성할 때는 우리는 기본적으로 다음과 같이 말한다.

> 이 작업을 완료하는 데 시간이 다소 걸릴 수 있지만 완료되면 그 결과로 다음과 같은 작업을 수행하겠다.
> 

콜백은 내부적으로 콜백 작업을 더 쉽게 하기 위한 추상화일 뿐이다.

```cpp
const setTimeout = (ms, cb) => timeout(ms, 0, cb);
const setInterval = (ms, cb) => timeout(0, ms, cb);
const setTimeoutAsync = (ms) =>
    new Promise(resolve => setTimeout(ms, resolve));

; (async function asyncFn() {
    print(new Date().toISOString(), 'waiting a sec....');
    await setTimeoutAsync(1000);
    print(new Date().toISOString(), 'waiting a sec....');
    await setTimeoutAsync(1000);
    print(new Date().toISOString(), 'finished....');
})();
```

위 코드  스니펫에서는 콜백 함수를 프로미스 객체로 감싸는 객체를 만들었다.

타임아웃 함수는 C++로 빌드되었고, 프로미스 객체는 자바스크립트이다.

타임아웃이 완료되면 실행되는 C++ 코드는 다음과 같다.

```cpp
static void onTimerCallback(uv_timer_t *handle)
{
    timer *timerWrap = (timer *)handle->data;
    v8::Isolate *isolate = timerWrap->isolate;
    v8::Local<v8::Context> context = isolate->GetCurrentContext();
    v8::Local<v8::Function> callback = v8::Local<v8::Function>::New(
        isolate,
        timerWrap->callback
    );
    v8::Local<v8::Value> result;

    // the result that goes back on the callback
    // something like:
    // callback(undefined, 'hello world')
    v8::Handle<v8::Value> resultr [] = {
        v8::Undefined(isolate),
        v8_str("hello world")
    };

    // invokes the callback function provided from JavaScript
    if(callback->Call(
        context,
        v8::Undefined(isolate),
        2,
        resultr).ToLocal(&result)
    ) 
    {}
}
```

따라서 C++ 함수는 주어진 콜백 함수를 호출한 다음 자바스크립트 측에서 resolve 함수를 호출하여 async/await 키워드를 사용해 결과가 완료되면 처리할 수 있다.

이제 for loop 를 Promise 객체안에 넣는 것만으로 비동기화되지 않는 이유를 알 수 있다.

<aside>
💡 Promise 자체가 비동기 연산을 진행하는 것이 아닌 비동기 콜백을 쉽게 처리하기 위한 래퍼로 이해하면 될 것 같다.

</aside>

참고로 Node.js 에서 비동기 연산을 생성하는 것은 Libuv 이다.

## JavaScript 는 단일 스레드 또는 멀티 스레드 언어가 아니다.

자바스크립트는 단순히 문법일 뿐이다.

더 자세히는 V8 엔진이 문자열을 C++ 객체 인스턴스로 변환하는 데 사용하는 문법이다.

스레딩은 운영체제 개념이므로 코드를 실행하는 환경에 따라 달라진다.

따라서 브라우저에서 스레딩을 사용하려면 웹 워커 API 를 사용하고, Node.js 에서는 워커 스레드 모듈을 사용해야 한다.

두가지 접근 방식과 두 가지 API. 언어 자체와는 전혀 관련이 없다.

## Node.js 는 멀티스레드 플랫폼이다.

Node.js 는 다음 [**문서**](https://nodejs.org/en/docs/guides/dont-block-the-event-loop#what-code-runs-on-the-worker-pool)에서 기술하는 것 처럼 멀티 스레드를 지원한다.

Libuv Worker Pool 이라 명칭된 스레드 풀에는 파일 시스템 API, 암호화 및 DNS와 같은 무거운 작업을 처리하는 데 사용되는 여러 개의 스레드가 존재한다.

문제는 이러한 스레드가 런타임 내부적으로만 사용되었고, 최근에서야 Worker Thread 모듈이 공용 Node.js API에 추가되었다는 점이다.

이제 개발자들은 자체 애플리케이션에서 이러한 스레드를 사용하여 Node.js 의 멀티스레딩 기능을 활용할 수 있다.

전반적으로 Node.js 는 거의 모든 것을 처리할 수 있는 강력한 기술이다.

그리고 스레드 풀과 워커 스레드 모듈을 사용하면 훨씬 더 많은 기능을 활용할 수 있다.

# Event Loop 은 단일 스레드이며 이것은 Event Loop 를 더 특별하게 만들어주는 이유이다.

2009년 당시 웹 개발에서는 Java, C# 과 같은 언어가 웹 애플리케이션을 구축하는 데 많이 이용되었지만, 많은 사용자의 동시 요청을 처리하는데 있어 큰 단점이 있었다.

이러한 언어들이 개별 요청을 동시에 처리하기 위해서 블로킹 I/O 모델과 무거운 스레드를 사용했기 때문에 다수의 동시 요청을 처리할 때 종종 성능 병목 현상과 메모리 이슈가 발생했다.

쉽게 말해, 많은 동시 사용자 요청을 처리하기 위해 많은 양의 메모리를 예약하여 서버가 대부분의 경우 사용 가능한 메모리의 80%를 사용하게 만들었다.

메모리 사용량 80% 의 서버에서 사용량이 급증하게 되면 순식간에 100%에 도달하기 때문에 빠르게 확장을 해야했고 두 개의 작업이 동시에 동일한 메모리 주소를 변경하지 않도록 스레딩을 세심하게 관리해야 했다.

<aside>
💡 다음과 같은 문제를 데드락(Deadlock) 이라고 한다.

</aside>

이러한 환경 속에서 문제를 해결하고 우리가 알고 있던 웹 개발에 혁신을 가져올 새로운 기술이 등장했다.

그 기술이 바로 Node.js 이다.

![Untitled](Untitled%2027.png)

Node.js 가 제시한 동시성 모델은 각 클라이언트를 위해 메모리를 예약할 필요가 없기 때문에 업계의 판도를 바꾸긴 충분했다.

## Node.js 동시성 모델의 특징

### Non-Blocking I/O

기존 언어와 달리 논 블로킹 I/O 모델과 경량 이벤트 루프를 사용하여 요청을 처리한다.

이는 여러 개의 동시 연결을 처리할 때 성능 병목 현상을 일으킬 수 있는 차단 I/O 모델과 대조적이다.

### 경량 프로세스 (Lightweight Processes)

Node.js 는 경량 프로세스(이벤트 루프)를 사용하여 요청을 처리하는데, 이는 C#, Java에서 활용하는 무거운 스레드 작업보다 더 효율적이기 때문에 더 적은 오버헤드로 더 많은 요청을 처리할 수 있다.

### 비동기 프로그래밍 (Asynchronous Programming)

Node.js 는 비동기 프로그래밍을 장려하여 개발자가 메인 스레드를 차단하지 않고 여러 작업을 병렬로 처리할 수 있는 보다 효율적이고 반응이 빠른 코드를 작성할 수 있도록 하였다.

### 실시간 웹 애플리케이션 (real-time web application)

Node.js 는 서버와 클라이언트 간 높은 수준의 동시성과 저지연 통신이 필요한 실시간 웹 애플리케이션을 구축하기 위해 특별히 설계되었다.

## [Node.](http://Node.sj)js 의 동시성 처리 vs 자바의 멀티스레드 처리

[Which is a better method: NodeJS asynchronous or Java multithreading?](https://www.quora.com/Which-is-a-better-method-NodeJS-asynchronous-or-Java-multithreading)

Node.js 의 이벤트 루프는 싱글스레드 프로세스지만 논블러킹 방식을 지원하기 위해 Node.js I/O API는 별도의 스레드/프로세스에서 실행된다.

 따라서 개발자는 스레드 간 메모리 공유에 대해 걱정할 필요는 없지만, 코드베이스에서 비동기/이벤트 호출을 처리해야 하는 자체적인 과제를 안게 된다.

## References

[5 Shocking Things About Node.js That You Thought You Knew But Didn’t!](https://medium.com/@erickwendel/5-shocking-things-about-node-js-that-you-thought-you-knew-but-didnt-f40dee003bed)