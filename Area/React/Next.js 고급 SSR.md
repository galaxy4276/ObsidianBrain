#react #nextjs #ssr 

**SSR(Server-Side Rendering)**은 서버에서 페이지를 렌더링하여 클라이언트로 전송하는 기술
- **장점**: SEO 최적화, 빠른 초기 로딩, 동적 콘텐츠 처리에 적합
- **단점**: 서버 부하 증가, 클라이언트 측 렌더링보다 복잡한 설정

## **Next.js에서 SSR의 장점**

Next.js는 SSR을 쉽게 구현할 수 있도록 도와주는 강력한 프레임워크
1. **데이터 페칭**: 서버에서 비동기적으로 데이터를 가져올 수 있음
2. **SEO 최적화**: 사전 렌더링된 HTML을 제공하여 검색 엔진에 친화적
3. **성능 및 확장성**: ISR(Incremental Static Regeneration)을 통해 성능과 유연성을 동시에 확보
4. **유연성**: SSR, SSG, CSR을 혼합하여 사용 가능


## **고급 SSR 기법**

### **Streaming SSR**
페이지를 청크 단위로 나누어 클라이언트에 점진적으로 전송

1. **빠른 TTFB(Time To First Byte)**  
    Streaming SSR은 페이지 전체가 렌더링될 때까지 기다리지 않고, 일부 HTML을 먼저 클라이언트로 전송
    `이를 통해 사용자는 페이지의 일부를 빠르게 볼 수 있으며, 초기 로딩 시간이 단축`
    
2. **점진적인 렌더링**  
    페이지의 중요한 부분(예: 헤더, 메인 콘텐츠)을 먼저 전송하고, 나머지 부분(예: 이미지, 부가 정보)은 나중에 전송
    **복잡한 UI를 가진 애플리케이션에서 유용함**

3. **서버 부하 감소**  
    전체 페이지를 한 번에 렌더링하지 않고 청크 단위로 전송하기 때문에 서버의 부하를 줄일 수 있음.
    트래픽이 많은 SaaS 애플리케이션에서 중요한  장점

4. **사용자 경험 개선**  
    사용자는 페이지가 완전히 로딩되기 전에도 콘텐츠와 상호작용할 수 있어, 전반적인 사용자 경험 향상

- **구현 방법**: React 18의 `Suspense`와 Next.js 13의 App Router를 활용

```typescript
// on Server Side

export async function GET() {
	const stream = new ReadableStream({
		start(controller) {
			controller.enqueue('<div>Part 1</div>');
			setTimeout(() => {
				controller.enqueue('<div>Part 2</div>');
			});
			setTimeout(() => {
				controller.close();
			}, 2000);
		}
	});

	return new NextResponse(stream, { headers: { "Content-Type": "text/html" }});
}
```
```typescript
// on Client Side
const StreamPage = () => {
	const [content, setContent] = useState('');

	useEffect(() => {
		consts fetchStream = async () => {
			const response = await fetch("/api/stream");
			const reader = response.body.getReader();
			const decoder = new TextDecoder("utf-8);
			let result = "";
			let done = false;
		
											while (!done) {
				const { value, done: streamDone } = await reader.read();
				done = streamDone;
				if (value) {
					result += decoder.decode(value);
					setContent(prev => prev + decoder.decode(value));
				}
			}
			setLoading(false);
		}
	fetchStream();
	}, []);

	return (
		...
		<div dangerouslySetInnerHTML={{ _html: content }} />
	);

}
```

### **SSR + ISR(증분 정적 재생성) 결합**

```javascript
// pages/blog/[slug].js
export async function getStaticProps({ params }) {
  const res = await fetch(`https://api.example.com/blog/${params.slug}`);
  const post = await res.json();

  return {
    props: {
      post,
    },
    revalidate: 10, // 10초마다 재생성
  };
}

export async function getStaticPaths() {
  const res = await fetch('https://api.example.com/blog');
  const posts = await res.json();

  const paths = posts.map((post) => ({
    params: { slug: post.slug },
  }));

  return { paths, fallback: 'blocking' };
}

export default function BlogPost({ post }) {
  return (
    <div>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
    </div>
  );
}
```

## **SSR 사용 시 주의사항**
1. **과도한 SSR 사용 금지**: 정적 페이지에는 SSG를 사용하는 것이 더 효율적
2. **성능 최적화**: 불필요한 데이터 페칭을 피하고, 캐싱 전략을 활용
3. **캐싱 활용**: CDN 및 `Edge Function` 을 사용하여 서버 부하를 분산

# References
* [# Mastering Server-Side Rendering in Next.js: An Advanced Guide](https://medium.com/digital-minds/mastering-server-side-rendering-in-next-js-an-advanced-guide-2b63d9f4f3cf);
- [Next.js Documentation](https://nextjs.org/docs)
- [React Server Components](https://react.dev/reference/rsc/server-components)
- [Vercel Edge Functions](https://vercel.com/docs/functions)
- [Caching Strategies](https://www.pixelmatters.com/blog/caching-strategies-for-your-website-ssg-ssr-and-cdn)
- [Full Code](https://github.com/digital-minds-hub/ssr-demo)
