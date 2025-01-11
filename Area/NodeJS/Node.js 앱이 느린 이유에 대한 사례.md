#nodejs

`Node.js` 로 작성한 앱이 기대했던 것 보다 성능이 낮게 나오는 경우에 대한 몇몇 사례를 요약하였다.

# Event Loop 블로킹
`Node.js` 는 단일 스레드이며 많은 요청을 처리하는 기능은 비차단, 비동기 코드에 의존한다.
CPU 를 많이 사용하거나 동기식 `I/O` 호출 같은 블로킹 작업을 수행하는 경우 
전체 `Event Loop` 가 정지되어 애플리케이션의 속도가 느려질 수 있다.

대용량 파일을 `fs.readFileSync` 를 수행하거나 CPU 집약적인 연산을 `Node.js` 코드에서 직접 수행하는 등의 작업은 `Event Loop`를 차단한다.
> `Event Loop` 는 한 번에 하나의 작업만 처리할 수 있기 때문이다.
### 해결 방안
무거운 계산은 `worker` 모듈을 활용하거나 `setImmediate` 또는 `process.nextTick` 을 사용하여 블로킹을 방지할 수 있다.

# 메모리 누수
메모리 누수는 열린 db 연결, 이벤트 리스너, 대용량 변수 등 더 이상 필요하지 않은 객체를 보유하고 있을 때 주로 발생한다.
이는 시간이 지남에 따라 더 메모리를 소모하고 성능 저하를 유발할 수 있다.
### 해결 방안
* Chrome 개발자 도구 또는 검사 도구를 활용하여 메모리 사용량 모니터링
* 사용하지 않은 이벤트 리스너는 `removeListener` 또는 `off` 로 제거
* `heapdump` 패키지를 사용하여 메모리 스냅샷 검사 및 누수 식별

# 비효율적인 미들웨어 사용
일부 웹 프레임워크에서 미들웨어는 요청을 처리하는 데 필수적이지만 너무 많이 사용하거나 요청 파이프라인에 불필요한 미들웨어가 존재한다면 앱에 지연시간이 발생한다.
### 해결 방안
* 필요한 라우터에만 미들웨어가 적용되게 끔 하기 (미들웨어 전역 추가 피하기)
* 비용이 비싸거나 느린 미들웨어(로깅 같은..) 는 특정 환경에서만 수행되게 변경하기
```javascript
// 나쁜 예시
app.use(morgan('dev'));  
  
// 좋은 예시
if (process.env.NODE_ENV !== 'production') {  
  app.use(morgan('dev'));  
}
```

# 캐싱 부족
`Node.js` 앱에 캐싱이 적용되지 않은 경우 동일한 작업을 반복해서 수행할 수 있다.
특히 동일한 db 호출이나 API 요청을 반복하는 경우 앱이 느려질 수 있다.
### 해결 방안
* 자주 요청되는 데이터에 대해 `Memcached` 나 `Redis` 를 활용하여 캐싱 적용
* 정적 자원에 대한 요청 헤더에 `Cache-Control` 정책 사용
* `ETag` 또는 `Last-Modified` 헤더를 사용하여 변경되지 않은 데이터 처리하기

# References
**[원문](https://javascript.plainenglish.io/why-your-node-js-app-is-slower-than-you-think-8da4894df95c)**
