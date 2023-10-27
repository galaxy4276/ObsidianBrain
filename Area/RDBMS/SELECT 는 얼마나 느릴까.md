---
tags: RDBMS, index
---
![느린 이유 요약](Untitled%2050.png)

느린 이유 요약

행 저장 DB에서 각 행은 페이지라는 단위로 저장 되는데 각 페이지에는 고정 헤더가 있고,

여러 행이 포함되며 각 행에는 레코드 헤드와 열 데이터가 존재합니다.

아래는 그 예시입니다.

![Untitled](Untitled%2051.png)

# 인덱스 사용 불가

`SELECT *` 를 사용하면 `DB 옵티마이저`가 인덱스 스캔을 사용할 수 없습니다.

<aside>
💡 DB 옵티마이저?
가장 효율적인 방법으로 SQL을 수행할 최적의 처리 경로를 생성해주는 DBMS의 핵심 엔진

</aside>

또한 모든 필드를 가져와야 하기 때문에 DB는 필드를 전부 가져오기 위해 힙 데이터 페이지에 접근해야 하므로 `랜덤 액세스`가 증가하여 훨씬 더 많은 I/O 가 발생하게 됩니다.

반대로 `SELECT *` 를 사용하지 않았다면 필요한 필드에 대한 인덱스만 검색할 수 있었습니다.

# References

****[[DB] 데이터베이스 옵티마이저(Optimizer)에 대하여](https://coding-factory.tistory.com/743)****

**[권순용의 DB 이야기](http://www.gurubee.net/lecture/2230)**

[How Slow is SELECT * ?](https://medium.com/@hnasr/how-slow-is-select-8d4308ca1f0c)