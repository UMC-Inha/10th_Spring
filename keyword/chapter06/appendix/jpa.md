## HikariCP 작동원리

Java 애플리케이션에서 DB 연결을 효율적으로 관리하기 위한 커넥션 풀 라이브러리이다. Spring Boot 2.0부터 기본 내장되어 있으며, 미리 만들어둔 커넥션을 재사용해 연결 비용을 제거한다.

### 왜 HikariCP를 사용할까?

DB 연결 (TCP 핸드셰이크 + 인증)은 매우 비싼 작업이다. 요청마다 새로 연결하면 수십~수백ms가 낭비된다.

**커넥션을 매번 새로 열면**

```
요청 → 연결 열기(~100ms) → 쿼리 실행 → 연결 닫기
요청 → 연결 열기(~100ms) → 쿼리 실행 → 연결 닫기
요청 → 연결 열기(~100ms) → 쿼리 실행 → 연결 닫기
```

**HikariCP를 사용하면**

```
[앱 시작 시] 커넥션 N개 미리 생성 → 풀에 보관

요청 → 풀에서 커넥션 빌리기(~0ms) → 쿼리 실행 → 풀에 반납
요청 → 풀에서 커넥션 빌리기(~0ms) → 쿼리 실행 → 풀에 반납
```

→ `connection.close()`를 호출해도 실제로 연결이 끊기지 않는다. 내부적으로 풀에 반납하는 동작이다.

### 핵심 내부 구조 - ConcurrentBag

HikariCP가 빠른 핵심 이유는 ConcurrentBag라는 자체 자료구조 덕분이다.

```
일반 풀 (Lock 기반)
─────────────────────────────────────
요청 → Lock 획득 시도 → 커넥션 꺼냄 → Lock 해제
→ 스레드 경합 발생 시 대기

ConcurrentBag (HikariCP)
─────────────────────────────────────
1순위: 현재 스레드가 마지막에 썼던 커넥션 → Thread-local에서 바로 꺼냄 (Lock 없음)
2순위: 다른 스레드가 반납한 커넥션 → CAS(Compare-And-Swap) 연산으로 꺼냄
3순위: 없으면 대기 큐에서 기다림
```

같은 스레드가 같은 커넥션을 재사용하는 패턴에서 lock 없이 즉시 획득 가능하다.

### 커넥션 생명주기

1. **생성 (앱 시작 시)**
    
    `minimumIdle` 수만큼 커넥션을 미리 생성해 풀에 보관한다.
    
    ```yaml
    spring:
      datasource:
        hikari:
          minimum-idle: 5        # 항상 유지할 최소 커넥션 수
          maximum-pool-size: 10  # 풀의 최대 커넥션 수
    ```
    
2. **대여 (요청 시)**
    
    `getConnection()` 호출 시 풀에서 커넥션을 빌려준다. 풀이 가득 차 있으면 `connectionTImeout` 까지 대기한다.
    
3. **반납 (사용 후)**
    
    `close()` 호출 시 커넥션을 풀로 돌려보낸다. 이때 `autoCommit`, `readOnly` 등의 상태를 원래대로 초기화한다.
    
4. **폐기 (수명 만료 시)**
    
    `maxLifetime` 에 도달한 커넥션은 조용히 폐기하고 새 커넥션으로 교체한다.
    

### 주요 설정값 정리

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10       # 최대 커넥션 수 (기본 10)
      minimum-idle: 5             # 최소 유휴 커넥션 수
      connection-timeout: 30000   # 커넥션 못 받으면 30초 후 SQLException
      idle-timeout: 600000        # 10분 이상 안 쓰인 커넥션 제거
      max-lifetime: 1800000       # 커넥션 최대 수명 30분
      keepalive-time: 60000       # 유휴 커넥션 ping 주기
      leak-detection-threshold: 2000  # 2초 이상 반납 안 되면 누수 경고 로그
```

### 풀 사이즈는 크게 잡으면 좋을까?

아니다. PostgreSQL 에서 제안한 공식이 있으며, 커넥션이 너무 많을 경우 DB서버에서 컨텍스트 스위칭 비용이 오히려 중가한다고 한다. 무조건 크다고 좋은건 아니다.

```
적정 커넥션 수 = (CPU 코어 수 × 2) + 유효 디스크 수

예) 4코어 서버, SSD 1개 → 4 × 2 + 1 = 9개ㅌ
```

## SQM (Semantic Query Model)

Hibernate 6에서 도입된 **JPQL/HQL의 내부 추상 구문 트리 표현 모델**이다. JPQL 문자열을 실행하기 전에 트리 구조로 파싱해두고, 이를 순회하며 최종 SQL을 생성한다.

### SQM 동작 과정

JPQL 문자열이 실행되는 흐름은 다음과 같다.

```
JPQL 문자열
    │
    ▼
HqlParser (ANTLR4 기반)
    │  문자열을 토큰으로 쪼갬
    ▼
SemanticQueryBuilder
    │  토큰을 SQM 노드로 변환
    ▼
SQM 트리 (AST)
    │  SqmSelectStatement
    │  ├── SqmFromClause (from Member m)
    │  ├── SqmWhereClause (where m.age > 20)
    │  └── SqmSelectClause (select m)
    ▼
SqlAstTranslator
    │  SQM 노드를 SQL AST로 변환
    ▼
최종 SQL 실행
```

```java
// 개발자가 작성하는 JPQL
String jpql = "select m from Member m where m.age > :age";

// 내부적으로 SQM 트리가 생성됨
// SqmSelectStatement
//   └── SqmWhereClause
//         └── SqmComparisonPredicate (m.age > :age)
//               ├── SqmPath (m.age)
//               └── SqmNamedParameter (:age)
```

### SQM 주요 노드 종류

**쿼리 노드**

`SqmSelectStatement` → SELECT 쿼리 전체를 표현하는 루트 노드

`SqmUpdateStatement` → UPDATE 쿼리 루트

`SqmDeleteStatement` → DELETE 쿼리 루트

**절 노드**

```
SqmSelectStatement
├── SqmFromClause      → FROM Member m
├── SqmSelectClause    → SELECT m
├── SqmWhereClause     → WHERE m.age > 20
└── SqmOrderByClause   → ORDER BY m.name DESC
```

**조건 노드**

```
// where m.age > 20 AND m.name like 'Kim%'
SqmWhereClause
└── SqmJunctionPredicate (AND)
      ├── SqmComparisonPredicate   (m.age > 20)
      └── SqmLikePredicate         (m.name like 'Kim%')
```

## PartTree

**Spring Data에서 메서드 이름을 파싱해 쿼리 조건으로 변환하는 파서**이다. findByNameAndAge와 같은 메서드명을 규칙에 따라 토큰으로 분해하고, 이를 바탕으로 JPQL 또는 SQM을 생성한다.

PartTree는 JPA 전용이 아니며, Spring Data MongoDB, Redis 등 모든 Spring Data 모듈에서 공통으로 사용한다.

### PartTree 동작 과정

메서드 이름을 읽어 트리 구조로 분해하는 흐름이다. 이 파싱은 애플리케이션 시작 시 단 한 번 일어난다.

```
메서드 이름
findTop3ByLastNameAndFirstNameStartingWithOrderByAgeDesc
    │
    ▼
PartTree 파싱
    │
    ├── Subject   → findTop3     (SELECT + LIMIT 3)
    ├── Predicate
    │     ├── OrPart 1
    │     │     └── Part: LastName = ?          (= 키워드 없음 = Equal)
    │     └── OrPart 2
    │           ├── Part: FirstName LIKE '?%'   (StartingWith)
    │           └── Part: (And로 연결)
    └── OrderBy   → age DESC
    │
    ▼
JPQL 생성
    │
    ▼
SQM 트리 → SQL 실행
```

### PartTree 구조 - Subject, Predicate, Part

**Subject (어떤 쿼리인가)**

```java
findTop3By...      // SELECT ... LIMIT 3
countByAge...      // SELECT COUNT(*) WHERE age = ?
existsByEmail...   // SELECT CASE WHEN COUNT(*) > 0
deleteByStatus...  // DELETE WHERE status = ?
```

**Predicate (어떤 조건인가)**

`By` 뒤에 오는 조건 부분이다. `Or`로 최상위를 나누고, `And`로 내부를 나눈다.

```java
findByLastNameOrFirstNameAndAge
                │
                ▼
OrPart 1: LastName = ?
OrPart 2: FirstName = ? AND Age = ?
```

**Part (단일 조건 하나)**

각 조건은 **프로퍼티명 + 키워드**로 이루어진다.

```java
// 프로퍼티    키워드
NameContaining        → name LIKE '%?%'
AgeGreaterThan        → age > ?
EmailIsNull           → email IS NULL
CreatedAtBetween      → created_at BETWEEN ? AND ?
FirstNameStartingWith → first_name LIKE '?%'
```

### 지원 키워드 목록

```java
// 동등 비교
findByName(String name)                  // WHERE name = ?
findByNameIs(String name)                // WHERE name = ?
findByNameNot(String name)               // WHERE name != ?

// 범위 비교
findByAgeGreaterThan(int age)            // WHERE age > ?
findByAgeLessThanEqual(int age)          // WHERE age <= ?
findByAgeBetween(int from, int to)       // WHERE age BETWEEN ? AND ?

// 문자열
findByNameLike(String pattern)           // WHERE name LIKE ?
findByNameContaining(String keyword)     // WHERE name LIKE '%?%'
findByNameStartingWith(String prefix)    // WHERE name LIKE '?%'
findByNameEndingWith(String suffix)      // WHERE name LIKE '%?'

// null 체크
findByEmailIsNull()                      // WHERE email IS NULL
findByEmailIsNotNull()                   // WHERE email IS NOT NULL

// 컬렉션
findByAgeIn(List<Integer> ages)          // WHERE age IN (?, ?, ...)
findByAgeNotIn(List<Integer> ages)       // WHERE age NOT IN (?, ?, ...)

// 정렬 + 개수 제한
findTop5ByOrderByCreatedAtDesc()         // ORDER BY created_at DESC LIMIT 5
```

### SQM과 PartTree의 관계

```
개발자가 작성
    │
    ├── 메서드 이름으로 작성      findByNameAndAgeGreaterThan(...)
    │         │
    │         ▼
    │      PartTree 파싱          [Spring Data 영역]
    │         │  메서드명을 조건 트리로 변환
    │         ▼
    └── JPQL로 직접 작성          "select m from Member m where ..."
              │
              ▼
           SQM 생성               [Hibernate 영역]
              │  JPQL → AST 노드로 변환
              ▼
           SQL 변환 및 실행
```

PartTree는 Spring Data가 메서드 이름을 읽는 시점에 동작하고, SQM은 Hibernate가 쿼리를 실행하는 시점마다 관여한다.

## EntityHolder

**Spring Data JPA 내부에서 엔티티와 그 메타데이터를 함께 묶어 보관하는 래퍼 객체**이다. 영속성 컨텍스트와 별개로, Spring Data 레이어에서 엔티티를 다룰 때 필요한 부가 정보(ID, 버전, 상태)를 함께 들고 다닌다.

개발자가 직접 사용하는 클래스가 아니며, `SimpleJpaRepository`, `JpaEntityInformation` 등 Spring Data JPA 내부 구현에서 사용하는 인프라 계층 개념이다.

### 왜 EntityHolder가 필요할까?

Spring Data는 JPA 위에서 동작하는 추상화 레이어이다. 엔티티를 저장, 수정, 삭제할 때 JPA에 위임하기 전에 “이 엔티티가 새 것인지, 기존 것인지”를 판단해야 한다.

```java
개발자 코드
    │
    repository.save(entity)
    │
    ▼
SimpleJpaRepository.save()
    │
    ├── 새 엔티티?  → em.persist()   (INSERT)
    └── 기존 엔티티? → em.merge()    (UPDATE)
```

이런 판단을 내리려면 엔티티 객체만으로는 부족하다. ID가 null인지, 버전이 있는지 같은 메타데이터가 함께 필요하다. EntityHolder는 이 정보를 하나로 묶는 역할을 한다.

### EntityHolder 구조

```java
EntityHolder
├── entity    → 실제 엔티티 인스턴스 (Member, Team 등)
├── id        → @Id 필드 값 (null이면 신규, 값 있으면 기존)
└── (내부)    → JpaEntityInformation (버전, 타입 정보 등)
```

### JpaEntityInformation과의 관계

EntityHolder는 단독으로 동작하지 않는다.JpaEntityInformation이 엔티티의 메타데이터를 분석해 정보를 공급한다. 

```java
JpaEntityInformation
├── getIdAttribute()    → @Id 필드 정보
├── getVersion()        → @Version 필드 정보
├── isNew(entity)       → 신규 여부 판단
└── getId(entity)       → 현재 ID 값 추출
```

## EntityEntry

**Hibernate 영속성 컨텍스트 내부에서 엔티티 하나의 상태를 추적하는 메타데이터 객체**이다. 엔티티 인스턴스 자체가 아니라, 그 엔티티가 현재 어떤 상태인지, 스냅샷은 무엇인지, lock은 어떻게 걸려있는지 등을 기록하는 일종의 관리 장부이다.

### 왜 EntityEntry가 필요할까?

영속성 컨텍스트는 단순히 엔티티를 저장하는 Map이 아니다. **엔티티를 관리하려면 엔티티 인스턴스 외에도 여러 부가 정보가 필요하다.**

예를 들어 flush() 시점에 변경 감지를 하려면 엔티티가 처음 로딩됐을 때의 상태가 있어야 현재 값과 비교할 수 있다. 또한 엔티티가 지금 영속 상태인지, 삭제 예정인지, 로딩 중인지도 알아야 한다. 이 모든 정보를 EntityEntry 하나가 담당한다.

### EntityEntry가 담고 있는 정보

**상태 (Status)**

**엔티티가 현재 영속성 컨텍스트에서 어떤 상태인지**를 나타낸다. `MANAGED`, `DELETED`, `GONE`, `LOADING`, `SAVING` 중 하나이다.

**스냅샷 (loadedState)**

**엔티티가 처음 DB에서 로딩됐을 때의 필드 값들을 Object 배열로 보관**한다. flush() 시점에 현재 엔티티 값과 비교해 변경 여부를 판단하는 데 쓰인다.

**Lock 모드 (LockMode)**

**해당 엔티티에 걸린 락의 종류를 기록**한다. `NONE`, `READ`, `OPTIMISTIC`, `PESSIMISTIC_WRITE` 등이 있다.

**EntityPersister**

해당 엔티티 타입의 INSERT, UPDATE, DELETE SQL을 실행하는 방법을 알고 있는 객체에 대한 참조이다.

### 영속성 컨텍스트 내부 구조

영속성 컨텍스트는 두 개의 Map으로 엔티티를 관리한다. 하나는 엔티티 인스턴스를 보관하는 1차 캐시고, 다른 하나는 EntityEntry를 보관하는 관리 장부이다.

```
영속성 컨텍스트
├── 1차 캐시 (EntityKey → Entity 인스턴스)
│     └── (Member, 1L) → member 객체
│
└── EntityEntryContext (Entity 인스턴스 → EntityEntry)
      └── member 객체 → EntityEntry {
                            status      = MANAGED
                            loadedState = ["김철수", 25, ...]  ← 스냅샷
                            lockMode    = NONE
                            persister   = MemberPersister
                        }
```

엔티티 인스턴스를 key로 EntityEntry를 찾기 때문에, 같은 엔티티라도 인스턴스가 다르면 별개로 관리된다.

### Dirty Checking에서의 역할

변경 감지는 EntityEntry의 loadedState가 있어야 가능하다. `flush()`가 호출되면 Hibernate는 영속성 컨텍스트 안의 모든 EntityEntry를 순회하며 현재 엔티티 스냅샷을 필드 단위로 비교한다.

변경된 필드가 있으면 UPDATE SQL을 생성하고, 없으면 아무것도 하지 않는다. 개발자가 member.setName(”서연”) 만 호출해도 자동으로 UPDATE가 나가는 이유가 바로 이 구조 덕분이다.

```java
Member member = em.find(Member.class, 1L);
// EntityEntry 생성: loadedState = ["여니", 23]

member.setName("서연");
// EntityEntry의 loadedState는 여전히 ["여니", 23]

em.flush();
// 현재값 ["서연", 23] vs 스냅샷 ["여니", 23] → name 변경 감지
// → UPDATE member SET name = '서연' WHERE id = 1
```
