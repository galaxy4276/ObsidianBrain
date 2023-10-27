---
tags: nodejs, libuv
---
## 서론

브라질의 Node.js 시니어 개발자분께서 [Node.js 런타임을 분석하고 수정하는 학습 영상](https://www.youtube.com/watch?v=ynNDmp7hBdo)을 유투브에 업로드해주셨다.

평소에 Node.js 에 관해 공부하면서 “싱글 스레드 런타임이라는 오해”, “Node.js 의 6 Phase 및 비동기 처리” 등등 처음 공부하면서 많이 애먹었던 개념등에 대해서 공부하고 있었는데 실제로 v8, Libuv 코드를 들여다보면서 언어 레벨을 수정하면서 동작 코드를 작성하는 것은 꽤나 흥미롭다고 생각했다.

Libuv 를 개념적으로 학습하는 것만이 아닌, 실제 코드를 건드려볼 기회가 생겼다는 점에서 꽤나 유익할 것이라 생각하여 영상과 GitPod 과 함께 즐겁게 학습했다. 😁😁

## 영상 시청 전에..

Node.js 는 사실상 프록시 역할을 수행한다. ( JavaScript 와 V8 간 브리지 역할 )

Deno 또한 V8 에 JavaScript 코드를 전송하여 Node.js 로 문자열을 평가한다.

<aside>
💡 Deno 는 Rust, Node.js 는 C++ 를 사용한다.

</aside>

Node.js, Deno, Bun.js 같은 자바스크립트 런타임은 V8 같은 엔진의 더 많은 기능적 확장 그 이상을 의미한다. 

영상 내에서 이러한 맥락으로 Node.js 와 같은 JS 런타임에 대해 소개하였고 이제 Node.js 를 중점적으로 더 서술하겠다.

## What is Node.js?

Node.js 는 주요 구성 요소로 Chrome V8, Libuv, C++ Layer 구성된 자바스크립트 런타임이다.

따로 작성한 글이 존재하지만 다시 언급하자면

V8 에는 console.log 나 setTimeout, setInterval 이 없다.

**V8 은 오로지 ECMAScript 사양만을 지원한다.** 

이러한 내용이 위에서 언급했듯, Node.js 를 확장(Extension) 부르는 이유이다.

 **V8 엔진에 없는 기능을 무엇이든 C++ 로 구현할 수 있다.**

<aside>
💡 Node.js 내장 모듈인 http, crypto, fs 와 같은 기능이 확장된 범위이다.

</aside>

![Node.js 동작 순서](Untitled%20118.png)

Node.js 동작 순서

## analysis uv_timer example

다음은 타이머 실행 코드이다.

```cpp
int main()
{
    loop = uv_default_loop();
    for (size_t i = 0; i < 10; i++)
    {
        timer *timerWrap = new timer(); // 타이머 생성
        timerWrap->callback = (functionTemplate *)callbackFn;
        timerWrap->text = "hello\n";

        timerWrap->req.data = (void *)timerWrap;

        // could actually be a TCP download or something
        uv_timer_init(loop, &timerWrap->req);
        int delay = 500 + i;
        int interval = 0;
        uv_timer_start(&timerWrap->req, work, delay, interval);
    }

    return uv_run(loop, UV_RUN_DEFAULT);
}
```

### uv_timer_init

libuv 라이브러리에서 제공하는 타이머(timer) 기능을 사용하기 위해 타이머 객체(timer handle)를 초기화하는 역할을 수행한다.

### uv_timer_start

타이머를 시작하는 함수이다.

### uv_run

libuv 라이브러리에서 제공하는 이벤트 루프(event loop) 를 실행하는 함수이다.

## analysis uv_thread example

```cpp
int main() {
    int counter = 10;
    uv_thread_t taskId;
    uv_thread_create(&taskId, dowork, &counter);

    uv_thread_join(&taskId);
    return 0;
}
```

libuv 를 이용하면 단 두 줄만으로 스레드를 생성할 수 있다.

상단 예시는 libuv 라이브러리를 사용하여 스레드를 생성하는 예시이다.

> **해당 코드의 ChatGPT 분석 내용이다.**
> 
> 1. **`main()`** 함수에서는 스레드 ID(**`uv_thread_t`**)와 카운터 변수(**`counter`**)를 생성합니다.
> 2. **`uv_thread_create()`** 함수를 호출하여 스레드를 생성합니다. 이때, 첫 번째 인자는 스레드 ID를 저장할 포인터이며, 두 번째 인자는 실행할 함수를 가리키는 포인터입니다. 세 번째 인자는 실행할 함수에 전달할 인자를 가리키는 포인터입니다.
> 3. 생성한 스레드가 작업을 완료하기 전에는 메인 스레드가 대기해야 하므로, **`uv_thread_join()`** 함수를 호출하여 생성한 스레드가 종료될 때까지 대기합니다.
> 4. **`main()`** 함수는 0을 반환하고 종료됩니다.
> 5. 생성한 스레드는 **`dowork()`** 함수를 실행하고, **`counter`** 변수를 1씩 감소시키면서 0이 될 때까지 대기합니다. **`dowork()`** 함수가 종료되면 생성한 스레드도 종료됩니다.
> 
> 위 코드에서 생성한 스레드가 완료될 때까지 대기하는 부분은 **`uv_thread_join()`** 함수를 사용하므로 블로킹(blocking) 방식으로 대기합니다. 따라서, 이 코드는 메인 스레드가 대기하는 동안 다른 작업을 수행할 수 없습니다. 비동기(non-blocking) 방식으로 스레드를 대기시키려면 **`uv_async_t`**나 **`uv_cond_t`**와 같은 비동기 대기 기능을 사용해야 합니다.
> 

## analysis v8-print-hello example

```cpp
int main(int argc, char *argv[])
{
  // Initialize V8.
  v8::V8::InitializeICUDefaultLocation(argv[0]);
  v8::V8::InitializeExternalStartupData(argv[0]);
  std::unique_ptr<v8::Platform> platform = v8::platform::NewDefaultPlatform();
  v8::V8::InitializePlatform(platform.get());
  v8::V8::Initialize();

  // Create a new Isolate and make it the current one.
  v8::Isolate::CreateParams create_params;
  create_params.array_buffer_allocator =
      v8::ArrayBuffer::Allocator::NewDefaultAllocator();
  v8::Isolate *isolate = v8::Isolate::New(create_params);
  {
    v8::Isolate::Scope isolate_scope(isolate);

    // Create a stack-allocated handle scope.
    v8::HandleScope handle_scope(isolate);
    
    // Create a new context.
    v8::Local<v8::Context> context = CreateContext(isolate);
    
    // Enter the context for compiling and running the hello world script.
    v8::Context::Scope context_scope(context);

    {
      // Create a string containing the JavaScript source code.
      v8::Local<v8::String> source =
          v8::String::NewFromUtf8Literal(isolate, "print('Hello, World!...');");

      // Compile the source code.
      v8::Local<v8::Script> script =
          v8::Script::Compile(context, source).ToLocalChecked();

      // Run the script to get the result.
      v8::Local<v8::Value> result = script->Run(context).ToLocalChecked();

      // Convert the result to an UTF8 string and print it.
      v8::String::Utf8Value utf8(isolate, result);
      // printf("%s\n", *utf8);
    }
  }

  // Dispose the isolate and tear down V8.
  isolate->Dispose();
  v8::V8::Dispose();
  v8::V8::DisposePlatform();
  delete create_params.array_buffer_allocator;
  return 0;
}
```

```cpp
global->Set(isolate, "print", v8::FunctionTemplate::New(isolate, Print));
```

핵심코드는 다음과 같다.

위 코드는 V8 엔진에서 JavaScript 를 호출할 수 있도록 C++ 함수를 연결하는 코드이다.

핵심인 print 구현부를 보자

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
            printf("%s", *str);
        }
        printf("\n");
        fflush(stdout);
    }
```

간단하게 for loop 을 이용하여 문자열 출력을 처리한다.

- **ChatGPT 분석 구문**
    
    해당 코드는 V8 엔진에서 C++로 작성된 함수인 **`Print`**를 나타냅니다. 코드를 분석해보면 다음과 같은 내용을 알 수 있습니다:
    
    1. **`Print`** 함수는 **`v8::FunctionCallbackInfo<v8::Value>`** 타입의 참조 매개변수 **`args`**를 받습니다. 이 매개변수는 V8 엔진의 JavaScript 함수 호출 시 전달되는 인자들을 포함하고 있는 객체입니다.
    2. **`bool`** 타입의 **`first`** 변수를 선언하고 **`true`**로 초기화합니다. 이 변수는 출력 시 첫 번째 인자인지를 나타내는 플래그로 사용됩니다.
    3. **`args.Length()`**를 통해 전달된 인자들의 개수를 가져옵니다.
    4. **`for`** 루프를 사용하여 각 인자에 대해 처리합니다.
    5. **`v8::HandleScope handle_scope(args.GetIsolate());`**를 사용하여 V8 엔진의 핸들 스코프를 생성합니다. 이는 V8 객체들의 수명을 관리하는 데 도움을 줍니다.
    6. **`first`**가 **`true`**인 경우, 아무 작업도 하지 않고 **`first`**를 **`false`**로 설정합니다. 이는 첫 번째 인자를 처리하는 경우이므로 공백 문자를 출력할 필요가 없습니다.
    7. 그렇지 않은 경우, 공백 문자(" ")를 출력합니다.
    8. **`v8::String::Utf8Value str(args.GetIsolate(), args[i]);`**를 사용하여 **`args[i]`**의 값을 UTF-8 문자열로 변환하여 **`str`**에 저장합니다. 이는 V8 엔진에서 JavaScript 문자열을 C++의 문자열로 변환하는 과정입니다.
    9. **`printf("%s", *str);`**를 사용하여 **`str`**에 저장된 UTF-8 문자열을 출력합니다.
    10. **`printf("\n");`**을 사용하여 줄 바꿈 문자를 출력합니다.
    11. **`fflush(stdout);`**을 사용하여 출력 버퍼를 비웁니다.
    
    즉, **`Print`** 함수는 V8 엔진에서 JavaScript 함수 호출 시 전달된 인자들을 C++ 콘솔에 출력하는 역할을 합니다. 각 인자를 UTF-8 문자열로 변환하여 공백 문자로 구분하여 출력합니다.
    

## Libuv 를 활용하여 타이머 구현하기

```cpp
/** Timer 함수 구현부 **/
static void Timeout(const v8::FunctionCallbackInfo<v8::Value> &args)
        {
            auto isolate = args.GetIsolate();
            auto context = isolate->GetCurrentContext();
            int64_t sleep = args[0]->IntegerValue(context).ToChecked();
            int64_t interval = args[1]->IntegerValue(context).ToChecked();
            v8::Local<v8::Value> callback = args[2];
            if (!callback->IsFunction()) {
                printf("callback is not declared!");
                return;
            }
            timer *timerWrap = new timer();
            timerWrap->callback.Reset(isolate, callback.As<v8::Function>());
            timerWrap->uvTimer.data     = (void *)timerWrap;
            timerWrap->isolate = isolate;

            uv_timer_init(loop, &timerWrap->uvTimer);
            uv_timer_start(&timerWrap->uvTimer, onTimerCallback, sleep, interval);
        }
```

```cpp
/** JS 언어 레벨에 바인딩 **/
Timer timer;
timer.Initialize(DEFAULT_LOOP);
global->Set(isolate, "timeout", v8::FunctionTemplate::New(isolate, timer.Timeout));
```

타이머 기능에서 핵심인 코드는 다음 두 줄이다.

```cpp
uv_timer_init(loop, &timerWrap->uvTimer);
uv_timer_start(&timerWrap->uvTimer, onTimerCallback, sleep, interval);
```

해당 이벤트 루프 함수에 대한 설명이다.

int **uv_timer_init**([uv_loop_t](http://docs.libuv.org/en/v1.x/loop.html#c.uv_loop_t) *loop, [uv_timer_t](http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_t) *handle)

handle 을 초기화 합니다.

int **uv_timer_start**([uv_timer_t](http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_t) *handle, [uv_timer_cb](http://docs.libuv.org/en/v1.x/timer.html#c.uv_timer_cb) cb, uint64_t timeout, uint64_t repeat)

타이머를 시작합니다. 

timeout 및 repeat은 밀리초 단위를 사용합니다.

timeout 이 0이면, 다음 이벤트 루프 반복에서 콜백이 실행됩니다.

반복이 0이 아닌 경우, 콜백은 시간 초과 밀리초 후 먼저 실행되고 repeat 밀리초 후에 반복적으로 실행된다.

<aside>
💡 이벤트 루프가 “now” 개념은 갱신하지 않습니다.
자세한 내용은 [uv_update_time()](http://docs.libuv.org/en/v1.x/loop.html#c.uv_update_time) 을 참조하세요.
타이머가 이미 활성화되어 있으면 단순히 갱신됩니다.

</aside>

갑자기 now 개념은 뭘까?

단순하게 요약하자면 Libuv 에서 시간 관련 시스템 호출 수를 줄이기 위해 이벤트 루프의 Tick 이 시작 될 때 현재 시간을 캐시에 저장한다.

위 내용 자체를 Libuv 자체적으로 now 라는 개념으로 칭하는 듯 하다.

## 마치며

Node.js 를 주로 다루는 개발자로써, Node.js 내부적으로 v8 이 대략적으로 어떻게 구성되어있는 지,

우리가 일반적으로 JavaScript 를 코딩했을 때 Node.js 는 코드 문자열을 어떻게 실행하는 지에 대해 간단하게 분석해보고 커스텀해봄으로써 기존에 가지고 있던 몇몇 오해와 기술에 대한 이해도가 향상되었다.

앞으로는 Libuv 자체만으로 몇몇 예제 코드를 작성하고 이벤트 루프의 핵심인 Libuv 동작 구조에 대해 좀 더 공부해볼 예정이다.