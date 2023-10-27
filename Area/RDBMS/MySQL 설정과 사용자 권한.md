---
tags: RDBMS, MySQL
---

![Untitled](Untitled%2023.png)

# 클린 셧다운 기능

<aside>
💡 원글 출처
[http://intomysql.blogspot.com/2010/12/mysqlinnodb-clean-shutdown.html](http://intomysql.blogspot.com/2010/12/mysqlinnodb-clean-shutdown.html)

</aside>

MySQL 의 InnoDB 는 데이터 변경이 발생하여도 즉시 변경내용을 반영하지 않고 Redo log 라는 트랜잭션 로그에 기록한다.

일반적으로 MySQL 비정상적 종료 시 데이터 파일로 기록하지 못한 내용은 InnoDB 의 시스템 테이블스페이스와 로그 트랜잭션으로 남게되어 재기동시 로그를 읽어들어 동기화 작업을 수행하는데 이 과정은 언제완료될 지 모르고, 작업이 진행되는 도중에 사용자가 접속해 쿼리를 수행할 수 있다.

이러한 현상을 방지하도록 MySQL 종료 시 모든 커밋된 내용을 데이터 파일에 기록하고 종료될 수 있는 옵션을 지원한다.

```sql
SET GLOBAL innodb_fast_shutdown=0;
```

# 서버 설정 파일의 순서

```mermaid
flowchart LR
	A["/etc/my.conf"] --> B;
  B["/etc/mysql/my.cnf"] --> C;
	C["/usr/etc/my.cnf"] --> D;
	D["~/.my.cnf"]
```

다음 순서로 서버설정 파일을 찾게 된다.

# 글로벌 변수와 세션 변수

### 글로벌 변수

서버 인스턴스에 전체적으로 영향을 미치는 시스템 변수

<aside>
💡 innodb_buffer_pool_size, key_buffer_size 등

</aside>

### 세션 변수

클라이언트가 MySQL 서버에 접속했을 때 기본으로 부여하는 옵션의 기본값을 제어하는 목적

<aside>
💡 autocommit, …

</aside>

세션 범위의 시스템 변수 가운데 서버의 설정 파일`*my.cnf` 에 명시에 초기화 할 수 있는 변수는 대부분 범위가 `Both` 로 명시되어 있다.

# 사용자 및 권한

계정명은 중복될 수 있으며, 아이디와 호스트를 항상 명시해야하며 `홑따옴표(`)`를 사용해 명시한다.

<aside>
💡 `svc_id`@`127.0.0.1`

</aside>

모든 외부 컴퓨터에서 접속이 가능한 사용자 계정을 생성하고 싶다면 호스트에 `%` 를 대입한다.