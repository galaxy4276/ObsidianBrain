#nextjs #cloud #cloudflare #vercel

Vercel의 높은 비용과 벤더 락인 문제로 인해 Cloudflare Workers로 Next.js 프로젝트를 이전하게 된 경험을 정리하였다.

## Vercel의 비용 문제
최근 한 클라이언트가 Vercel에서 한 달 만에 1900달러를 지불했다는 사실을 접했는데, 이는 특히 사용자 기반 요금제와 방화벽 같은 추가 기능의 부가 비용 때문이었다. 이러한 고비용은 Vercel의 벤더 락인 문제와 함께 다른 플랫폼으로의 이전을 고민하게 만들었다.

## OpenNext 프로젝트
OpenNext는 Next.js를 Vercel 플랫폼에서 분리시키는 오픈소스 이니셔티브다. AWS Lambda, Cloudflare Workers, Netlify 등 여러 플랫폼에서 Next.js 애플리케이션을 자체 호스팅할 수 있는 유연성을 제공한다.

## Cloudflare의 장점
Cloudflare Pages는 JAMstack 앱을 위한 새로운 호스팅 제공업체로, 다음과 같은 장점이 있다:
- 무제한 사이트, 무제한 대역폭, 무제한 요청을 무료로 제공
- 매일 많은 페이지 뷰를 받더라도 비용을 지불할 필요가 없음
- Vercel에 비해 현저히 낮은 비용
## 마이그레이션 과정
### 기본 요구사항
- GitHub 리포지토리 연결
- Build Command와 Output Directory 확인 (Vercel 설정에서)
- 기존 도메인 설정
### 마이그레이션 도구
Diverce라는 오픈소스 마이그레이션 도구를 활용하면 Vercel에서 Cloudflare로 프로젝트를 쉽게 이전할 수 있다. Diverce는 다음과 같은 작업을 자동화한다:
- @opennextjs/cloudflare 통합
- wrangler.jsonc 파일 설정
- package.json 스크립트 조정
- Vercel 전용 패키지와 설정 제거

### 주의사항
- Vercel의 Edge Functions와 Cloudflare Workers의 런타임 차이를 고려해야 함
- 환경 변수는 수동으로 마이그레이션해야 함
- Vercel 전용 API를 사용하는 코드는 수정이 필요할 수 있음

## 플랫폼별 비교
### Vercel의 강점
- 압도적인 개발자 경험
- 빠른 배포와 컴파일 속도
- Next.js와의 완벽한 통합
### Cloudflare의 강점
- 비용 효율성
- 전역 CDN과 엣지 컴퓨팅
- 무료 티어의 관대한 제한

## 개인적 의견
만약 포트폴리오 사이트나 블로그 정도의 단순한 프로젝트라면 Cloudflare Pages가 더 나은 선택이라고 생각한다. 하지만 복잡한 기능이 많은 애플리케이션을 개발한다면 Vercel이 여전히 최고의 옵션이다. 결국 개발자로서 어떤 부분에서 타협할지 결정하는 것이 중요하다.

완벽한 플랫폼은 없으며, 프로젝트의 요구사항과 예산에 맞는 선택이 필요하다.

## References
https://blog.prateekjain.dev/i-switched-from-vercel-to-cloudflare-for-next-js-e2f5861c859f
