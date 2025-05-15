#axios #alova
## 도입
10년 넘게 Axios는 프론트엔드 개발자들의 표준 HTTP 요청 라이브러리였다. 간단한 API 설계와 브라우저와 Node.js 환경 모두를 지원하는 덕분이었다. 하지만 현대 프론트엔드 프레임워크가 발전하고 엔지니어링 요구사항이 증가함에 따라, Alova.js가 더 가볍고, 더 똑똑하고, 더 현대적인 대안으로 떠오르고 있다.

## Axios의 문제점
### 1. 불필요한 적응 로직
```javascript
// Axios의 범용 설정 (대부분 브라우저에서만 사용됨)
axios.create({ adapter: isNode ? nodeAdapter : xhrAdapter });
```

### 2. 약한 TypeScript 지원
```javascript
// Axios는 수동으로 응답 타입을 정의해야 함
interface Response<T> { data: T }
axios.get<Response<User>>('/api/user'); // 여전히 data를 수동으로 구조 분해해야 함
```

### 3. 과도한 캡슐화 안티패턴
```javascript
// 레이어드 인터셉터로 디버깅이 어려워짐
axios.interceptors.request.use(config => {
  // 인증 인터셉터
});
axios.interceptors.response.use(response => {
  // 글로벌 에러 처리 인터셉터
});
```

### 4. 파편화된 생태계
캐싱, 큐잉 등을 위해 추가 서드파티 라이브러리 필요하고, 유지보수 비용이 증가한다.

## Alova.js의 핵심 장점
### 1. 극도의 경량화와 성능
트리 쉐이킹 최적화로 사용된 모듈만 번들링하고, 제로 의존성으로 코어 패키지가 단 4KB다(Axios의 12KB 대비).
### 2. 지능적인 요청 관리 (즉시 사용 가능)

```javascript
// 요청 취소, 중복 제거, 재시도를 한 번의 설정으로
const { data } = useRequest(userInfoAPI, {
  abortOnUnmount: true,    // 컴포넌트 언마운트 시 자동 요청 취소
  dedupe: true,            // 중복 요청 자동 병합
  retry: 3                 // 자동으로 3번 재시도
});
```
### 3. 선언적 프로그래밍 패러다임
React/Vue와 깊이 통합되어 Hooks 스타일 API를 제공한다.

```javascript
// Vue3 예시: loading/error 상태를 자동으로 관리
const { 
  data, 
  loading, 
  error, 
  send: fetchUser 
} = useRequest(() => userAPI.get({ id: 1 }));
```

### 4. 내장된 다중 시나리오 솔루션
SSR 친화적이고 서버 사이드 렌더링에서 데이터 프리페칭을 지원한다. 파일 청크 업로드의 경우 내장 진행률 모니터링과 일시정지/재개를 제공하고, 다단계 캐싱 전략(메모리/SessionStorage)을 지원한다.

## 실용적인 마이그레이션 가이드
### 1. 기본 요청 변환
**Axios**

```javascript
axios.get('/api/user', { params: { id: 1 } })
  .then(res => console.log(res.data));
```

**Alova**

```javascript
// API 모듈 정의 (타입 힌트 제공)
const userAPI = {
  get: (id) => alova.Get('/api/user', { params: { id } })
};

// 요청 실행 (사용자 타입 자동 추론!)
const { data: user } = useRequest(userAPI.get(1));
```

### 2. 복잡한 인터셉터 마이그레이션
**Axios의 혼란스러운 인터셉터**

```javascript
// 요청 인터셉터
axios.interceptors.request.use(config => {
  config.headers.token = localStorage.getItem('token');
  return config;
});

// 응답 인터셉터
axios.interceptors.response.use(
  response => response.data,
  error => Promise.reject(error.response)
);
```

**Alova의 우아한 미들웨어**

```javascript
// 글로벌 통합 로직 (타입 안전!)
const alova = createAlova({
  beforeRequest: (method) => {
    method.config.headers.token = localStorage.getItem('token');
  },
  responded: (response) => response.json() // JSON 자동 파싱
});
```

## 마이그레이션 비용 걱정? Alova가 해결한다

```javascript
// 호환성 모드: Alova에서 Axios 어댑터 사용
import { axiosAdapter } from '@alova/adapter-axios';

const alova = createAlova({
  requestAdapter: axiosAdapter(axios)
});
```
## 결론
Alova.js는 차세대 HTTP 요청 라이브러리를 대표한다. 현대 웹 개발을 위한 가볍고, 지능적이며, 완벽하게 통합된 솔루션을 제공한다. Axios의 문제점을 해결하고 더 선언적이고 효율적인 접근 방식을 제공함으로써, Alova.js는 애플리케이션을 최적화하려는 개발자들에게 새로운 표준이 될 것이다.

# References
https://javascript.plainenglish.io/say-goodbye-to-axios-in-2025-04fc0772c01e
