---
tags: RDBMS, MySQL, index
---
# MySQL 인덱스

태그: B-Tree, MySQL, 인덱스
Date: September 23, 2023 7:07 PM
공개 여부: 공개
설명: 인덱스 너무 복잡함 하지만 멋있는.
카테고리: 데이터베이스

![Untitled](Untitled%2023.png)

# 디스크 읽기 방식

`순차 읽기 I/O` 와 `랜덤 읽기 I/O` 가 존재하며 **DB 의 성능 튜닝은 어떻게 디스크 I/O 를 줄이느냐**가 관건이다.

<aside>
💡 **[랜덤 I/O와 순차 I/O](https://hudi.blog/storage-and-random-sequantial-io/)**
</aside>

랜덤 I/O 를 줄이기 위해서는 쿼리를 처리하는데 **꼭 필요한 데이터만 읽도록 쿼리를 개선**하는 것을 의미한다.

# Unique 인덱스

데이터의 중복 허용 여부를 Unique 인덱스와 Non-Unique 인덱스로 분류할 수 있다.

이 것은 DBMS 의 쿼리를 실행해야 하는 옵티마이저에게 꽤 중요한 정보이며

**Unique 인덱스에 대해 Equal 검색을 수행하는 것은 항상 한 건의 레코드만 찾으면 된다는 것을 옵티마이저에게 알려주는 효과를 낸다.**

# 인덱스 구조는 B-Tree

B-Tree 는 따로 정리한 글이 있어 확인바란다.

[[B-Tree 예제와 살펴보기]] 

B-Tree 구조인 인덱스에서 **수정 작업을 수행하면 삭제 후 삽입하는 과정을 거친다.**

내부적으로 **루트 노드, 브랜치 노드, 리프 노드**로 나뉘는데 아래 링크를 참고하자.

**[[MySQL] B-Tree로 인덱스(Index)에 대해 쉽고 완벽하게 이해하기](https://mangkyu.tistory.com/286)**

# 루스 스캔와 스킵 스캔의 차이

루스 스캔은 GROUP BY 나 MIN, MAX 와 같은 집합 함수를 사용하는 쿼리를 사용할 때 최적화되어 수행되며 중간에 불필요한 인덱스를 무시하고 스캔한다.

<aside>
💡 인덱스는 정렬되어서 생성되는 특징을 이용한다.

</aside>

스킵 스캔은 인덱스의 뒤에 존재하는 컬럼만 검색하는 경우 옵티마이저가 자동으로 쿼리를 최적화하는 방식이다.

# Random I/O 가 발생할 수 있는 가능성 (GPT)

1. **인덱스 랜덤 액세스**: 특히 인덱스를 사용하여 데이터를 검색할 때 랜덤 I/O가 발생할 수 있습니다. 인덱스는 데이터베이스의 레코드 위치를 가리키며, 원하는 데이터를 찾기 위해 여러 인덱스 블록을 읽어야 할 수 있습니다.
    - **[인덱스 스캔 튜닝](https://seokrae.gitbook.io/sr/book/tune/_2)**
2. **대용량 테이블 스캔**: 대용량 테이블을 스캔할 때 랜덤 I/O가 발생할 수 있습니다. 이는 데이터가 랜덤하게 분포되어 있을 때 더욱 심화됩니다. 예를 들어, 특정 컬럼의 값을 기준으로 정렬되어 있지 않은 경우입니다.
3. **파티션된 테이블**: 데이터가 파티션으로 나누어져 있는 경우, 원하는 데이터가 여러 파티션에 분산되어 있을 수 있습니다. 이때 랜덤 I/O가 발생할 수 있으며, 여러 파티션을 스캔해야 합니다.
4. **데이터베이스 페이지 크기**: 데이터베이스 페이지 크기보다 작은 레코드를 조회하는 경우에도 랜덤 I/O가 발생할 수 있습니다. 페이지 크기보다 작은 레코드를 읽을 때는 해당 페이지에 여러 레코드가 저장되어 있어 다른 페이지로 이동해야 할 수 있습니다.

# 클러스터형 인덱스

데이터가 테이블에 물리적으로 저장되는 순서를 정의하며 특정 컬럼을 기준으로 데이터들을 정렬시킨다.

테이블 데이터는 오직 한 가지 방법으로만 정렬되기 때문에 한 테이블 당 하나의 클러스터형 인덱스만 존재한다.

<aside>
💡 정렬 기준으로 오직 하나의 컬럼만 선택 가능하다.

</aside>

대표적인 예시로 PK 가 존재하며 PK 를 기준으로 자료가 자동으로 정렬되게 된다.

PK 를 설정하지 않는 테이블을 생성하면 무작위로 데이터를 `insert` 하고 테이블을 조회하면 뒤죽박죽인 데이터를 보게된다.

## 클러스터형 인덱스 주의사항

모든 세컨더리 인덱스가 프라이머리 키(클러스터링 키) 값을 포함하기 때문에 프라이머리 키의 크기가 커지면

세컨더리 인덱스도 같이 커진다.

그러므로 데이터가 많아질수록 기하급수적으로 용량이 늘어나기 때문에 프라이머리 키는 신중히 선택해야한다.

## PK 는 반드시 명시할 것

InnoDB 테이블에서 PK 를 명시하지 않으면 내부적으로 일련번호 칼럼을 추가하여 관리한다.

이렇게 자동으로 추가된 컬럼은 관리자가 접근(사용)할 수 없기 때문에 `AUTO_INCREMENT` 칼럼으로라도 추가해두는 것이 좋다.

# 유니크 인덱스

내가 유니크 인덱스에 대해 오해하고 있던 점을 먼저 말하자면,

유니크 인덱스는 **속도 개선을 위해서 사용하는 것은 잘못된 행위**이다.

유니크하지 않은 보조 인덱스에서 한번 더 해야하는 작업은 디스크 읽기가 아닌 CPU 에서 칼럼 값을 비교하는 작업이기 때문에 성능 상 영향이 없기 때문이다.

새로운 레코드가 삽입되거나 인덱스 칼럼의 값이 변경되는 경우 중복된 값이 있는 지 체크하는 과정이 한 단계 더 필요하기 때문에 유니크 하지 않은 세컨더리 인덱스의 쓰기보다 느린 편이다.

# 외래키

MySQL 에서 외래키는 InnoDB 엔진에서만 생성할 수 있으며 **외래키 제약이 생성되면**

**자동으로 연관되는 테이블의 칼럼에 인덱스까지 생성된다.**

InnoDB 외래키 관리는 두 가지 특성이 있다.

- 테이블의 변경(쓰기 잠금)이 발생하는 경우 잠금 경합(잠금 대기)이 발생한다.
- 외래키와 연관되지 않은 칼럼의 변경은 최대한 잠금 경합(잠금 대기)을 발생시키지 않는다.

# References

**[순차(Sequential) I/O와 랜덤(Random) I/O](https://velog.io/@ddangle/%EC%88%9C%EC%B0%A8Sequential-IO%EC%99%80-%EB%9E%9C%EB%8D%A4Random-IO)**

랜**[덤 I/O와 순차 I/O](https://hudi.blog/storage-and-random-sequantial-io/)**

**[데이터베이스 인덱스는 왜 'B-Tree'를 선택하였는가](https://helloinyong.tistory.com/296)**

**[[MySQL] B-Tree로 인덱스(Index)에 대해 쉽고 완벽하게 이해하기](https://mangkyu.tistory.com/286)**

**[인덱스 스캔 튜닝](https://seokrae.gitbook.io/sr/book/tune/_2)**

**[MySQL 8.0의 공유 락(Shared Lock)과 배타 락(Exclusive Lock) - hudi.log](https://hudi.blog/mysql-8.0-shared-lock-and-exclusive-lock/)**

**[쉽게 이해하는 MySQL 인덱스 한판 정리](https://livvjh.com/posts/develop/real-mysql-index/)**

**[Clustered vs NonClustered (index 개념)](https://gwang920.github.io/database/clusterednonclustered/)**

**[[Real MySQL] 그외 인덱스(유니크, 외래키)](https://12bme.tistory.com/150)**

**[[8장] 인덱스 #9](https://github.com/Jane-s-Lab/books/issues/9)**