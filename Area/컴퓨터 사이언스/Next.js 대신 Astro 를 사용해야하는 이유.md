제목에서 혼동이 올 수 있는데 Astro 가 무조건 좋다는 것이 아닌 왜 단순 컨텐츠를 전달하는 정적 사이트를 만드는데 있어 Astro 를 사용하는것이 유리한지 파악하기 위해 해당 문서에 연구 내용을 작성하였습니다.


# Markdown 콘텐츠 페이지 지원

`Astro` 는  `src/pages`  `.md` 파일을 생성하면 자동으로 페이치 콘텐츠로 추가해준다.
또한 `.md` 내 `slugger` 기능, 플러그인, 프런트매터 등 다양한 기능을 제공하고 이미지도 쉽게 추가할 수 있도록 지원해줌.
`Next.js` 또한 MDX 를 통해 `.md` 파일을 페이지로 추가해주는 기능을 지원하지만 사용자가 직접 `configuration` 해야하며
`Astro` 대비 기능이 많지 않다.

마크다운 파일을 페이지로 동적으로 추가하는데 있어 (즉 정적 컨텐츠를 추가하는데 있어) `Astro` 가 좀 더 편리한 부분이 있다.

[Next.js MDX](https://nextjs.org/docs/pages/building-your-application/configuring/mdx)
[Astro 에서 Markdown 사용하기](https://docs.astro.build/ko/guides/markdown-content/)

# 아일랜드 아키텍쳐
아일랜드 아키텍처는 페이지의 상호작용이 필요한 부분을 "아이랜드"로 정의하고, 이 부분만 클라이언트 측에서 JavaScript로 활성화하며 나머지 부분은 서버에서 정적 HTML로 렌더링한다.
예를 들어, [Islands architecture | Docs](https://docs.astro.build/en/concepts/islands/)에 따르면, 아이랜드는 독립적으로 작동하며, 여러 아이랜드가 한 페이지에 존재할 수 있습니다. 이는 전통적인 SPA 프레임워크(예: Next.js)가 전체 페이지를 JavaScript로 로드하는 것과 달리, 불필요한 JavaScript 로드를 줄여 성능을 향상시킨다.

| **유형**     | **설명**                                             | **지시어**                                  | **장점**                                      | **예시**                 |
| ---------- | -------------------------------------------------- | ---------------------------------------- | ------------------------------------------- | ---------------------- |
| 클라이언트 아이랜드 | 상호작용이 필요한 JavaScript UI 컴포넌트를 별도로 활성화, 정적 HTML에 포함 | client:load, client:idle, client:visible | 성능(정적 HTML, 선택적 JS), 병렬 로드, 컴포넌트 수준 로드 우선순위 | 헤더, 이미지 캐러셀            |
| 서버 아이랜드    | 동적 콘텐츠를 서버에서 렌더링, 메인 렌더링과 병렬 처리                    | server:defer                             | 캐싱을 통한 빠른 성능, 대체 콘텐츠 제공, 레이아웃 변화 없음         | 사용자 아바타, 특가 상품, 사용자 리뷰 |
`Next.js` 에도 비슷한 기능으로 서버 컴포넌트가 존재하므로 일반적으로 사용하기에 크게 차이는 없는것같다.

# Zero JavaScript
Astro는 속도와 성능에 더 중점을 두기 때문에 정적 콘텐츠에 유리하다고 한다.
이는 페이지에서 꼭 필요한 부분만 `JavaScript` 로 처리하고, 나머지는 모두 HTML로 유지해 `JavaScript` 사용을 최소화하는 점이 큰 역할을 한다.

# 다양한 통합 기능 중 React 를 지원하지만..
`Next.js` 보다 불편하다. `React` 컴포넌트의 하위에서 `client side` 선언이 되지않고 `.astro` 내부에 컴포넌트를 선언하는데 제한이 존재하기때문에 `React` 로 작성된 동적 컨텐츠가 많은 사이트에서 마이그레이션은 고민을 해봐야할 것 같다.

[Astro 공식문서 - React 통합](https://docs.astro.build/ko/guides/integrations-guide/react/)


# 결론
정적컨텐츠가 많은 블로그, 회사 사이트 같은 사례에서 `Astro` 는 충분히 매력적이다.
