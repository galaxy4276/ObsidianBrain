#javascript 

[Stack Overflow](https://stackoverflow.com/questions/42416783/where-to-use-arraybuffer-vs-typed-array-in-javascript) 답변 내용이 너무 유익하여 요약

## ArrayBuffer

`ArrayBuffers` 는 물리적 메모리의 바이트 배열을 나타냄.
직접 읽을 수 없고 참조만 전달할 수 있으며, 서버 - 클라이언트 간 `Blob` 을 통해 사용자의 파일 시스템에서 바이너리 데이터를 전송할 때 사용 됨

![[ArrayBuffer vs Typed Array-20241017021215796.webp]]

## Typed Array 는 View 일 뿐이다.
필요에 따라 다양한 뷰가 사용되며 `Uint8Array` 와 같은 `Array` 는 배열이 아닌 사실 상 `ArrayBuffer` 에 대한 뷰일 뿐이다.
`ArrayBuffer` 자체로는 데이터를 직접 읽거나 조작할 수 없다.
