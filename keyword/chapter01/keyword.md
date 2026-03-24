## DB Join 이란?

- **두 개 이상의 테이블을 서로 연결해서 하나의 결과를 만들어 내는 것**
- 관계형 데이터베이스는 보통 데이터를 정규화해서 여러 테이블에 나누어 저장함.
- 하지만 실제 조회할 때는 여러 테이블의 데이터가 합쳐져야 의미가 있는 경우가 있어서, 공통된 컬럼을 기준으로 테이블을 결합하는 작업임. **(PK, FK)**
- INNER JOIN, OUTER JOIN, CROSS JOIN, SELF JOIN 네 가지 종류의 Join이 있음.

## Join의 내부 동작 방식

### Nested Loop Join

- 프로그래밍에서 사용하는 중첩 반복문과 유사한 방식으로 조인을 수행한다.
- `from A join B on A.id = B.id`
    - A 1행 → B 전체 탐색
    - A 2행 → B 전체 탐색
    - A 3행 → B 전체 탐색
    - …
- 선행 테이블(A)에 결과 행의 수가 적은 테이블이 와야 전체 일량을 줄일 수 있다.

### Sort Merge Join

- 조인 컬럼을 기준으로 데이터를 정렬하여 조인을 수행한다.
- 정렬할 데이터가 많은 경우 디스크를 사용하기 때문에 성능이 떨어질 수 있다.
- 정렬 비용이 크지만, 정렬되어 있는 경우 매우 빠르다.

### Hash Join

- 조인을 수행할 테이블의 조인 컬럼을 기준으로 해쉬 함수를 수행하여 서로 동일한 해쉬 값을 갖는 것들 사이에서 실제 값이 같은지를 비교하면서 조인을 수행한다.
- `from A join B on A.id = B.id`
    - B로 해시 테이블 생성
    - A돌면서 같은 해시값을 갖는 주소로 바로 접근

## 1️⃣ INNER JOIN

- 내부 조인
- 두 테이블에서 ‘공통된 값’을 가지고 있는 행들만을 반환한다.
- 두 테이블을 연결할 때 가장 많이 사용하는 조인.
- **NATURAL JOIN : 내부 조인의 한 종류. 조인 조건을 따로 명시하지 않고, 두 테이블에 같은 이름의 컬럼이 있으면 자동으로 그 컬럼을 기준으로 내부 조인이 수행된다.**

```sql
SELECT <열 목록>
FROM <첫 번째 테이블>
		INNER JOIN <두 번째 테이블>
		ON <조인 조건>
[WHERE 검색 조건]

#여기서 INNER JOIN을 JOIN이라고 작성해도 INNER JOIN으로 인식함.
```

## 2️⃣ OUTER JOIN

- 외부 조인
- 두 테이블에서 ‘공통된 값을 가지지 않는 행들’도 반환한다.
- 내부 조인은 두 테이블에 모두 데이터가 있어야 결과가 나오지만, 외부 조인은 어느 한쪽에만 있는 데이터도 결과에 포함됨.

```sql
SELECT <열 목록>
FROM <첫 번째 테이블(LEFT 테이블)>
		<LEFT | RIGHT | FULL> OUTER JOIN <두 번째 테이블(RIGHT 테이블)>
		ON <조인 조건>
[WHERE 검색 조건]
```

| student_id | name | dept_id |
| --- | --- | --- |
| 1 | 여니 | 10 |
| 2 | 윤샘 | 20 |
| 3 | 그린 | null |
| 4 | 미카엘 | 30 |

| dept_id | dept_name |
| --- | --- |
| 10 | 컴퓨터공학과 |
| 20 | 인공지능공학과 |
| 40 | 전기전자공학부 |

- **LEFT OUTER JOIN**: **왼쪽 테이블의 모든 값**이 출력되는 조인
    
    ```sql
    select *
    from Student S left join Department D
    		on S.dept_id = D.dept_id
    ```
    
    | student_id | name | dept_id | dept_name |
    | --- | --- | --- | --- |
    | 1 | 여니 | 10 | 컴퓨터공학과 |
    | 2 | 윤샘 | 20 | 인공지능공학과 |
    | 3 | 그린 | null | null |
    | 4 | 미카엘 | 30 | null |
- **RIGHT OUTER JOIN**: 오른쪽 테이블의 모든 값이 출력되는 조인
    
    ```sql
    select *
    from Student S right join Department D
    		on S.dept_id = D.dept_id
    ```
    
    | student_id | name | S.dept_id | D.dept_id | dept_name |
    | --- | --- | --- | --- | --- |
    | 1 | 여니 | 10 | 10 | 컴퓨터공학과 |
    | 2 | 윤샘 | 20 | 20 | 인공지능공학과 |
    | null | null | null | 40 | 전기전자공학과 |
- **FULL OUTER JOIN**: 왼쪽 외부 조인과 오른쪽 외부 조인이 합쳐진 것
    
    ```sql
    select *
    from Student S full outer join Department D
    		on S.dept_id = D.dept_id
    ```
    
    | student_id | name | S.dept_id | D.dept_id | dept_name |
    | --- | --- | --- | --- | --- |
    | 1 | 여니 | 10 | 10 | 컴퓨터공학과 |
    | 2 | 윤샘 | 20 | 20 | 인공지능공학과 |
    | 3 | 그린 | null | null | null |
    | 4 | 미카엘 | 30 | null | null |
    | null | null | null | 40 | 전기전자공학부 |
    - 많은 DBMS에서 `FULL OUTER JOIN`을 지원하지 않기 때문에 `LEFT OUTER JOIN` + `RIGHT OUTER JOIN`의 결과를 `UNION` 해서 사용하기도 한다.

## 3️⃣ CROSS JOIN

- 상호 조인. CARTESIAN PRODUCT
- 한쪽 테이블의 모든 행과 다른 쪽 테이블의 모든 행을 조인시키는 기능.
- 상호 조인 결과의 전체 행 개수는 두 테이블의 각 행의 개수를 곱한 수만큼 됩니다.

```sql
SELECT *
FROM <첫 번째 테이블>
		CROSS JOIN <두 번째 테이블>
```

## 4️⃣ SELF JOIN

- 자체 조인
- 자기 자신과 조인하므로 1개의 테이블만 사용한다.
- 별도의 문법이 있는 것은 아니고 1개로 조인하면 자체 조인이 된다.
- 한 테이블 내의 레코드를 다른 레코드와 연결할 수 있다.
- 계층 구조 데이터를 표현하거나 같은 집합 내 비교 연산이 필요할 경우 사용됨.

```sql
SELECT <열 목록>
FROM <테이블> 별칭A
		INNER JOIN <테이블> 별칭B
[WHERE 검색 조건]
```

## 데이터베이스 트랜잭션이란?

- **트랜잭션 = DB의 상태를 변경시키는 작업의 단위**
- 한꺼번에 수행되어야만 하는 연산들을 모아놓은 것.
- 하나의 트랜잭션 안에 있는 연산들을 모두 처리하지 못 한 경우에는 원 상태로 복구함.
- 즉, 작업의 일부만 적용되는 현상이 발생하지 않음.
- 사용자의 입장에서는 작업의 논리적 단위이고, 시스템의 입장에선 데이터들을 접근 또는 변경하는 프로그램의 단위가 됨.

## 트랜잭션의 4가지 특징: ACID

- **Atomicity (원자성)**
    - 트랜잭션이 DB에 모두 반영되거나, 혹은 전혀 반영되지 않아야 된다. (ALL or NOTHING)
- **Consistency (일관성)**
    - 모든 트랜잭션은 일관성 있는 데이터베이스 상태를 유지해야 한다.
    - 시스템이 가지고 있는 고정 요소는 트랜잭션 수행 전과 수행 후의 사태가 같아야 한다.
    - DB의 제약조건을 위배하는 작업을 트랜잭션 과정에서 수행할 수 없음을 나타낸다.
- **Isolation (독립성)**
    - 둘 이상의 트랜잭션이 동시에 병행 실행되고 있을 때, 어떤 트랜잭션도 다른 트랜잭션 연산에 끼어들 수 없다.
- **Durability (지속성)**
    - 트랜잭션이 성공적으로 완료되었으면, 결과는 영구적으로 반영되어야 한다.

## 트랜잭션제어 연산

1. **BEGIN / START TRANSACTION 연산**
    - 트랜잭션 시작 연산.
    - 트랜잭션 시작 연산을 사용하면 DBMS의 자동 커밋 모드가 암묵적으로 비활성화 되고, 트랜잭션이 끝나면 다시 자동 커밋 모드가 켜진다. (MySQL 기준)
2. **COMMIT 연산**
    - 트랜잭션이 성공적으로 수행되었음을 선언하는 연산.
    - COMMIT 연산의 실행을 통해 트랜잭션의 수행이 성공적으로 완료되었음을 선언하고, 그 결과를 최종 DB에 반영한다.
    - Partially Committed → 트랜잭션의 COMMIT 명령이 도착한 상태. 트랜잭션의 이전 SQL문이 수행되고, COMMIT만 남은 상태를 말한다.
    - Committed → 트랜잭션 완료 상태. COMMIT을 정상적으로 완료한 상태를 말한다.
    
    ```
    Active ➡️ Partially Committed ➡️ Committed
            ↘ Failed ➡️ Aborted (Rollback)
    ```
    
3. **ROLLBACK 연산**
    - 트랜잭션 수행이 실패했음을 선언하고 작업을 취소하는 연산.
    - 트랜잭션이 수행되는 도중 일부 연산이 처리되지 못한 상황이라면, ROLLBACK 연산을 실행하여 DB를 트랜잭션 수행 전과 일관된 상태로 되돌린다.
4. **SAVEPOINT 연산**
    - SAVEPOINT를 지정하면, ROLLBACK시 해당 지정 위치로 복원이 가능하다.
    - SAVEPOINT 명령어로 지점을 저장하고, ROLLBACK 명령어로 복원한다.
    
    ```sql
    COMMIT;
    SELECT * FROM test_table;
    
    UPDATE test_table set data1 = '새로운 문자열', data2 = 44 WHERE data3 = 1;
    SAVEPOINT aa;
    DELETE FROM test_table WHERE data3 = 2;
    SELECT * FROM test_table;
    ROLLBACK TO aa;
    SELECT * test_table;
    
    -- ROLLBACK이 COMMIT 시점이 아니라, SAVEPOINT aa를 선언한 시점이 된다.
    -- 따라서 UPDATE문은 적용이 되어있고, DELETE문은 ROLLBACK된다.
    ```
    

## 트랜잭션의 격리 수준 (Isolation Level)

### ⭐️ SERIALIZABLE

- 가장 엄격한 격리 수준으로, 트랜잭션을 순차적으로 진행시킨다.
- 여러 트랜잭션이 동일한 레코드에 동시 접근할 수 없으므로, 데이터의 일관성과 정합성에 어떠한 문제도 발생하지 않지만 동시 처리 성능이 매우 떨어진다.
- 순수한 SELECT 작업에서도 대상 레코드에 **넥스트 키 락을 읽기 잠금**(읽는 건 허용, 쓰느 건 금지)으로 걸기 때문에 넥스트 키 락이 걸린 레코드를 다른 트랜잭션에서 절대 추가/수정/삭제할 수 없다.

### MVCC란? (Multi-Version Concurrency Control)

- MVCC는 **동시에 실행되는 여러 트랜잭션이 데이터의 서로 다른 버전을 볼 수 있게 함**으로써, 읽기 작업에서는 Lock없이도 동시성 제어가 가능하도록 한다.
- 과거 데이터를 undo log에 저장하고, 트랜잭션 버전(스냅샷)을 통해 값이 변경된 경우에는 undo log에 저장되어 있는 값을 가져온다.
- **각 트랜잭션은 읽는 시점에 저장한 스냅샷**을 통해 데이터를 관리하기 때문에 다른 트랜잭션이 데이터를 수정하더라도 서로 영향을 주지 않는다.

### ⭐️ REPEATABLE READ

- 한 트랜잭션 내에서 동일한 결과를 보장한다.
- MVCC를 통해 한 트랜잭션 내에서 읽는 시점의 스냅샷을 보관하고, 트랜잭션 도중 데이터의 수정이 발생해도 미리 저장된 스냅샷을 통해 일관된 값을 읽어올 수 있다.
- 하지만, 새로운 레코드가 삽입된 경우에는 이전에 없었던 데이터가 나타나는 **유령 읽기(Phantom Read)**가 발생할 수 있다. → 부정합 발생
    - 갭 락이 존재하는 MySQL에서는 특정 범위에 락을 걸 수 있기 때문에 유령 읽기 현상이 발생하지 않지만, 대부분의 DBMS에서는 발생할 수 있는 현상이다.

### ⭐️ READ COMMITED

- 커밋된 데이터만 조회할 수 있다.
- REPEATABLE READ에서 발생하는 **Phantom Read**에 더해 **Non-Repeatable Read**문제까지 발생한다.
- 트랜잭션 내에서 특정 레코드를 읽고, 다른 트랜잭션에서 수정 및 커밋한다면 다음에 레코드를 읽을 때 변경된 값이 읽힌다.
- REPEATABLE READ와 다르게 중간에 다른 트랜잭션이 커밋하면, 스냅샷이 아닌 새로 변경된 값을 읽어오는 것이다.

### ⭐️ READ UMCOMMITED

- **커밋되지 않은 데이터도 접근할 수 있다.**
- 특정 트랜잭션의 작업이 완료(commited)되지 않은 상태에서도 다른 트랜잭션에서 볼 수 있는 부정합 문제를 **Dirty Read(오손 읽기)**라고 한다.
- 특정 데이터가 조회되었다가 사라지는 현상이 발생할 수 있으므로 시스템에 상당한 버그를 초래할 수 있다.
- READ UNCOMMITED는 DBMS 표준에서 인정하지 않을 정도로 정합성에 문제가 많다.

## MySQL의 AutoCommit

- autocommit은 MySQL에서 DML(INSERT, UPDATE, DELETE) 명령을 실행할 때 자동으로 COMMIT을 수행할 지 여부를 결정하는 설정 값이다.
- 트랜잭션 시작 연산을 사용하면, 해당 트랜잭션은 암묵적으로 autocommit이 비활성화 된다.
- autocommit = 1 : 기본 값. 각 SQL 실행 시마다 자동으로 COMMIT 된다.
- autocommit = 0 : 트랜잭션을 수동으로 제어. COMMIT 또는 ROLLBACK을 명시적으로 호출해야 한다.

```sql
SET autocommit = 0; -- 수동 트랜잭션 모드
SET autocommit = 1; -- 자동 커밋 모드 (기본값)

-- autocommit = 0을 설정해야만 START TRANSACTION, COMMIT, ROLLBACK, SAVEPOINT 등이 의미 있게 작동하게 된다.
```

## JOIN ON vs WHERE

<aside>

JOIN ON 은 **조인 대상 결정**, WHERE은 **최종 결과 필터링 역할**을 한다.

</aside>

**SQL 실행 순서**

- **FROM → JOIN → ON → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT**

### JOIN ON

- JOIN을 수행할 때, 조건을 설정하여 해당 조건에 만족하는 행만 JOIN을 수행한다.
- ON 조건으로 조인 대상을 먼저 결정한 후, WHERE에서 최종 결과를 필터링 한다.
- OUTER JOIN에서, 매칭되지 않으면 NULL을 유지한다.

### WHERE

- JOIN이 끝난 결과 집합에서 조건을 필터링한다.
- 추가적인 조건을 줄 때에 사용하기도 한다.
- OUTER JOIN에서 WHERE조건을 사용하면 NULL이 제거되어 INNER JOIN처럼 동작할 수 있다.