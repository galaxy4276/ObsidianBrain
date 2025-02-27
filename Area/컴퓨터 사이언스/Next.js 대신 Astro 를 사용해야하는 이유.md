제목에서 혼동이 올 수 있는데 Astro 가 무조건 좋다는 것이 아닌 왜 단순 컨텐츠를 전달하는 정적 사이트를 만드는데 있어 Astro 를 사용하는것이 유리한지 파악하기 위해 해당 문서에 연구 내용을 작성하였습니다.


# Markdown 콘텐츠 페이지 지원

`Astro` 는  `src/pages`  `.md` 파일을 생성하면 자동으로 페이치 콘텐츠로 추가해준다.
또한 `.md` 내 `slugger` 기능, 플러그인, 프런트매터 등 다양한 기능을 제공하고 이미지도 쉽게 추가할 수 있도록 지원해줌.
`Next.js` 또한 MDX 를 통해 `.md` 파일을 페이지로 추가해주는 기능을 지원하지만 사용자가 직접 `configuration` 해야하며
`Astro` 대비 기능이 많지 않다.

마크다운 파일을 페이지로 동적으로 추가하는데 있어 (즉 정적 컨텐츠를 추가하는데 있어) `Astro` 가 좀 더 편리한 부분이 있다.

[Next.js MDX](https://nextjs.org/docs/pages/building-your-application/configuring/mdx)
[Astro 에서 Markdown 사용하기](https://docs.astro.build/ko/guides/markdown-content/)

# Zero JavaScript


# 다양한 통합 기능 중 React 를 지원하지만..
