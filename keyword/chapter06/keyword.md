## JPA(Java Persistence API)

<aside>

자바 진영에서 **ORM(Object-Relational Mapping)** 기술 표준으로 사용되는 인터페이스의 모음이다.

</aside>

**자바 애플리케이션에서 관계형 데이트베이스를 사용하는 방식을 정의한 명세**이며, JPA 자체는 구현체가 아니다. 대표적인 구현체로는 **Hibernate**, **EclipseLink**, **OpenJPA** 등이 있으며, 실무에서는 **Hibernate**가 사실상 표준처럼 사용된다.

### **ORM(Object-Relational Mapping) 이란?**

애플리케이션 Class와 RDB(Relational DataBase)의 테이블을 매핑하는 기술이다. 기술적으로는 애플리케이션의 객체를 RDB테이블에 자동으로 영속화 해주는 것이다.

**장점**

- SQL문이 아닌 Method를 통해 DB를 조작할 수 있어 **객체 지향적인 코드 작성이 가능**하다.
- 개발자가 비즈니스 로직 구성에 집중할 수 있고, 부수적인 코드가 줄어들어 가독성이 높아진다.
- 특정 DBMS에 종속되지 않아 DB 교체가 비교적 자유롭다. (MySQL → PostgreSQL 등)

**단점**

- 복잡하고 무거운 Query는 속도를 위해 별도의 튜닝이 필요하기 때문에 결국 SQL문을 직접 써야하는 경우가 있을 수 있다.
- 잘못 사용하면 성능 이슈(N + 1 문제 등)이 발생하기 쉽다.

## EntityManager

`@Entity`  **어노테이션을 달고 있는 Entity객체들을 관리**하며, 실제 DB테이블과 매핑하여 데이터를 조회/수정/저장 하는 중요한 기능을 수행한다.

- 주요 메서드로는 `persist()`, `find()`, `remove()`, `merge()`, `flush()`, `clear()`, `detach()` 등이 있다.

EntityManager는 PerisistenceContext라는 논리적 영역을 두어, 내부적으로 Entity의 생애주기를 관리한다. 또한 스레드 간 공유하면 안 되며, 일반적으로 트랜잭션 단위로 생성되고 종료된다.

## Spring Data JPA

**Spring 프레임워크에서 JPA에 대한 Repository를 제공하는 것**으로, JPA를 이용한 데이터 접근을 일관된 프로그래밍으로 애플리케이션 개발을 용이하게 한다.

- JPA를 추상화한 인터페이스만 정의하면, Spring Data JPA가 구현체를 자동으로 생성해주는 기능을 제공한다. 이를 통해 CRUD와 같은 중복 코드를 줄일 수 있다.
- 메소드 이름을 분석하여 SQL 쿼리를 자동으로 생성하는 기능을 제공한다. (Query Method)
- 페이징과 정렬을 간단하게 적용할 수 있는 기능을 제공한다. (Pegeable, Sort)

**JpaRepository<T, ID>** 

```
Repository (마커)
   └─ CrudRepository (CRUD 기본 메서드)
       └─ PagingAndSortingRepository (페이징/정렬)
           └─ **JpaRepository (JPA 특화 기능: flush, batch 등)**
```

- JpaRepository를 상속받는 인터페이스를 정의하면, 해당 타입의 엔티티의 쿼리 메서드를 자동을 구현해준다.
- JpaRepository는 CurdRepository와 PagingAndSortingRepository를 상속 받기 때문에, CRUD 메서드는 물론이고 페이징과 정렬 기능까지 지원한다.
- 정의한 인터페이스에 원하는 기능을 하는 메서드를 선언하면, Spring Data JPA가 메서드 이름을 분석해서 자동으로 구현체를 생성한다.

## 🌱 JPA의 N + 1 문제란?

**연관 관계가 설정된 엔티티 사이에서 한 엔티티를 조회하였을 때, 조회된 엔티티의 개수(N개)만큼 연관된 엔티티를 조회하기 위해 추가적인 쿼리가 발생하는 문제**를 의미한다.

즉 N + 1에서, **1**은 한 엔티티를 조회하기 위한 쿼리의 개수이며, **N**은 조회된 엔티티의 개수만큼 연관된 데이터를 조회하기 위해 발생되는 추가적인 쿼리의 수를 의미한다.

```sql
SELECT * FROM team                          -- 1번 (팀 10개 조회)
SELECT * FROM member WHERE team_id = 1      -- N번
SELECT * FROM member WHERE team_id = 2
SELECT * FROM member WHERE team_id = 3
...
SELECT * FROM member WHERE team_id = 10
                                            -- 총 11번의 쿼리 발생
```

### LAZY vs EAGER, N+1과의 관계

**"즉시 로딩(EAGER) → N+1 발생, 지연 로딩(LAZY) → N+1 예방"**

→ ❌. 둘 다 N + 1이 발생한다. 타이밍이 다를 뿐이다.

**N+1의 근본 원인은 fetch 전략이 아니라, JPA가 연관 엔티티를 개별 쿼리로 조회하는 방식 자체에 있다.**

JPQL을 실행할 때 JPA는 fetch 전략을 무시하고 JPQL 그대로 SQL을 실행한 뒤, 그 다음에 fetch 전략을 보고 연관 데이터를 처리한다.

```
EAGER이면 → "지금 당장 가져와야 해" → 조회 즉시 N번 추가 쿼리 발생
LAZY이면  → "나중에 쓸 때 가져올게" → 실제 사용 시점에 N번 추가 쿼리 발생
```

### EAGER의 경우

```java
List<Team> teams = teamRepository.findAll(); // 여기서 바로 N+1 발생
```

```sql
SELECT * FROM team                         -- 1번
SELECT * FROM member WHERE team_id = 1     -- 즉시 실행
SELECT * FROM member WHERE team_id = 2     -- 즉시 실행
SELECT * FROM member WHERE team_id = 3     -- 즉시 실행
```

### LAZY의 경우

```java
List<Team> teams = teamRepository.findAll(); // 여기선 1번만
for (Team team : teams) {
    team.getMembers().size(); // ← 이 시점에 N+1 발생
}
```

```sql
SELECT * FROM team                         -- 1번 (findAll 시점)
SELECT * FROM member WHERE team_id = 1     -- getMembers() 시점
SELECT * FROM member WHERE team_id = 2     -- getMembers() 시점
SELECT * FROM member WHERE team_id = 3     -- getMembers() 시점
```

## N + 1 문제 해결 방법

### Fetch Join

JPQL에서 `join fetch`를 사용해 연관 엔티티를 한 번에 조회한다.

```sql
-- INNER JOIN - members가 없는 Team은 조회 안 됨
select t from Team t join fetch t.members

-- OUTER JOIN - members가 없는 Team도 조회됨 (실무에서 더 자주 사용)
select t from Team t left join fetch t.members
```

```java
public interface TeamRepository extends JpaRepository<Team, Long> {
	
	@Query("select t from Team t join fetch t.members")
	List<Team> findAllWithInnerFetchJoin();
	
	@Query("select t from Team t left join fetch t.members")
	List<Team> findAllWithOuterFetchJoin();
	
}
```

- Spring Data JPA에서는 `@Query`를 이용해 JPQL을 직접 사용할 수 있다.
- SQL join과 같이 작용하여 Team 엔티티를 가져올 때 Member 엔티티도 함께 가져오기 때문에 추가 조회 쿼리가 발생하지 않는다.

⚠️ **Fetch Join의 한계**

- 컬렉션 fetch join 시 **페이징 불가** → 메모리에서 페이징 처리하므로 OOM 위험
- **둘 이상의 컬렉션 fetch join 불가** → `MultipleBagFetchException` 발생
- 페이징이 필요하면 BatchSize를 함께 사용하는 것이 실무 해결책

### @EntityGraph

어노테이션 기반으로 fetch join과 유사한 효과를 낸다. JPQL 없이 간단하게 사용 가능하다.

```java
public interface TeamRepository extends JpaRepository<Team, Long> {

    @EntityGraph(attributePaths = {"members"})
    List<Team> findAll();

    @EntityGraph(attributePaths = {"members"})
    @Query("select t from Team t")
    List<Team> findAllWithEntityGraph();
}
```

- 내부적으로 LEFT OUTER JOIN을 사용한다.
- Fetch Join과 동일한 한계(페이징 불가)를 가진다.

### Batch Fetching

추가 쿼리를 없애는 게 아니라 **IN절을 사용해 추가 쿼리를 1~몇 번으로 줄이는** 방식이다.

```java
// 방법 A: 엔티티에 직접 설정
@Entity
public class Team {
		...
		
		@OneToMany(mappedBy = "team", fetch = FetchType.LAZY)
		@BatchSize(size = 100)
		private List<Member> members = new ArrayList<>();
		
		...
		
}
```

```yaml
# 방법 B: 전역 설정 (실무에서 이 방법을 더 많이 씀)
spring:
  jpa:
    properties:
      hibernate:
        default_batch_fetch_size: 100
```

- IN절을 활용해 설정한 size만큼 묶어서 한 번에 조회한다.
- size는 보통 **100~500** 사이로 설정한다.
- 페이징과 함께 사용 가능 ✅  다중 컬렉션과 함께 사용 가능 ✅

### Subselect Fetching

```java
@Entity
public class Team {
		...
		
		@OneToMany(mappedBy = "team", fetch = FetchType.LAZY)
		@Fetch(value = FetchMode.SUBSELECT)
		private List<Member> members = new ArrayList<>();
		
		...
		
}
```

- `@Fetch(value = FetchMode.SUBSELECT)` 을 사용하면, IN절과 서브쿼리를 사용하여 한 번에 조회할 수 있다.
- 항상 **전체를 한 번에** 조회하므로 데이터가 많을 때 오히려 부담이 될 수 있다.
- BatchSize보다 덜 선호되는 방법이다.

## 어떤 방법을 사용할까?

`default_batch_fetch_size: 100` 전역 설정을 **기본으로 깔아두고**, 상황에 따라 Fetch Join을 조합하는 패턴이 가장 보편적이다.

| 상황 | 선택 전략 |
| --- | --- |
| 단순 단건 조회, 페이징 없음 | Fetch Join 또는 @EntityGraph |
| 목록 조회 + 페이징 필요 | BatchSize |
| 컬렉션 2개 이상 + 페이징 | BatchSize만 사용 |
| 성능이 극도로 중요한 경우 | DTO 직접 조회 |

**DTO 직접 조회**: 처음부터 필요한 데이터만 DTO로 조회하여 불필요한 컬럼을 SELECT하지 않는다.

```java
@Query("select new com.example.dto.TeamDto(t.id, t.name, count(m)) " +
       "from Team t left join t.members m group by t.id, t.name")
List<TeamDto> findTeamDtos();
```

**조회 메서드에는 `@Transactional(readOnly = true)` 를 항상 붙이자.**

- 변경 감지(Dirty Checking)를 비활성화하여 스냅샷을 만들지 않음 → 메모리와 성능 최적화

## 즉시 로딩(Eager Loading)이란?

**엔티티를 조회할 때 해당 엔티티와 연관된 모든 엔티티를 동시에 조회하는 방식**

- 객체 간의 관계를 활용하기 편리하다.
- 조인을 사용하지 않아도 한번에 연관 데이터를 가져올 수 있다.
- 하지만 **불필요한 연관 엔티티도 무조건 불러오기 때문에** 성능 낭비가 발생할 수 있다.
- `@ManyToOne`, `@OneToOne` 연관 관계의 **기본(default) Fetch Type**이다.
- `@OneToMany`, `@ManyToMany`에 `fetch = FetchType.EAGER` 설정을 넣으면 즉시 로딩을 사용할 수 있다.

## 지연 로딩(Lazy Loading)이란?

**연관된 엔티티를 처음에 조회하지 않고, 실제로 해당 엔티티가 필요한 시점에 조회하는 방식**

- **불필요한 쿼리 발생을 방지**할 수 있다.
- 연관된 엔티티가 지연 로딩으로 호출될 경우, **프록시 객체**를 반환한다.
- 실제로 엔티티가 필요한 시점에 프록시가 초기화되면서 실제 객체로 동작한다.
- `@OneToMany`, `@ManyToMany` 연관 관계의 **기본(default) Fetch Type**이다.
- `@ManyToOne`, `@OneToOne`에 `fetch = FetchType.LAZY` 설정을 넣으면 지연 로딩을 사용할 수 있다.

### 지연 로딩의 원리 (프록시)

- 엔티티 매니저가 엔티티를 로드할 때, JPA는 참조하고 있는 객체를 실제 엔티티 대신 **프록시 객체**로 반환한다.
- 프록시 객체 사용 시점까지는 실제 데이터를 로드하지 않는다.
- 프록시 객체의 메서드 호출 시, 실제 데이터가 로딩되고 프록시 객체가 초기화된다.
- 한 번 프록시 객체가 초기화되면, 그 이후에는 실제 객체처럼 동작한다.

```java
em.find(Team.class, 1L) 호출
         │
         ▼
  Team 엔티티 반환 (DB 조회)
  members 필드 → 실제 List<Member> 아님
              → Hibernate가 생성한 프록시 객체
                 (껍데기만 있고 데이터 없음)
         │
         ▼
  team.getMembers().get(0) 호출 ← 이 시점에 SELECT * FROM member WHERE team_id = 1
         │
         ▼
  프록시 초기화 완료 → 이후엔 실제 객체처럼 동작
```

> ⚠️ **LazyInitializationException**: 트랜잭션이 종료된 후(영속성 컨텍스트가 닫힌 후) 지연 로딩을 시도하면 예외가 발생한다. 트랜잭션 안에서 DTO로 변환 후 반환하는 것이 올바른 패턴이다.
> 

### **왜 대부분 LAZY를 쓸까?**

- **불필요한 쿼리 방지**: 연관 데이터를 실제로 안 쓰면 LAZY는 쿼리가 아예 안 나간다.
- **예측 가능한 성능**: EAGER는 연관관계가 깊어질수록 어디서 얼마나 쿼리가 나가는지 파악하기 어렵다.
- **N+1 해결이 쉬움**: LAZY 상태에서 필요한 경우에만 Fetch Join으로 가져오는 패턴이 제어하기 훨씬 편하다.

→ LAZY는 N+1을 예방하는 게 아니라, 발생 시점을 늦추고 제어를 쉽게 만드는 것이다. 실제 N+1 해결은 Fetch Join, BatchSize 같은 별도 수단으로 해야 한다.

# JPQL(Java Persistence Query Language)

## JPQL이란?

데이터 기반이 아닌 엔티티 객체를 기반으로 조회하는 객체 지향 쿼리

- SQL을 추상화하여 정의되어 있기 때문에, 데이터 베이스에 의존하지 않는다.
- 데이터 베이스 ‘테이블과 컬럼’이 아닌 ‘자바 클래스와 변수(객체)’에 작업을 수행한다.
- JPQL은 결국 SQL로 변환되어 실행된다.

## JPQL의 쿼리 반환 타입

### TypedQuery

- 반환되는 타입이 명확할 때 사용하는 클래스이다.
- 변환 타입을 미리 지정하기 때문에 컴파일 시점에 오류를 잡을 수 있어 안정적이다.

```java
EntityManager em;

TypedQuery(Member) typedQuery = em.createQuery("select m from Member as m where m.id = ?", Member.class);
```

### Query

- 반환되는 타입이 명확하지 않을 때 사용하는 클래스이다.
- 다양한 타입의 결과로 반환 받을 수 있지만, 반환 타입을 런타임 시점에 확인할 수 있어 안정성이 떨어진다.

```java
EntityManager em;

Query query = em.createQuery("select m from Member as m where m.id = ?");
```

## JPQL 파라미터 바인딩

**JPQL 쿼리를 처리할 때 파라미터에 따라 동적으로 처리하는 방식**

### 이름 기준 파라미터 바인딩

- 쿼리 내에서 `“:변수명”` 형태로 선언한 후에 setParameter메서드를 사용하여 값을 설정하는 방식이다.

```java
EntityManager em;

TypedQuery(Member) typedQuery = em
				.createQuery("select m from Member as m where m.id = :id and m.name = :name", Member.class);
				.setParameter("id", 1)
				.setParameter("name", seoyeon);
```

### 위치 기준 파라미터 바인딩

- 쿼리 내에 파라미터를 `“?번호”`형태로 선언한 후에 setParameter메서드를 사용하여 값을 설정하는 방식이다.
- 이때, 위치 번호는 1부터 시작한다.

```java
EntityManager em;

TypedQuery(Member) typedQuery = em
				.createQuery("select m from Member as m where m.id = ?1 and m.name = ?2", Member.class);
				.setParameter(1, 1)
				.setParameter(2, seoyeon);
```

## JPQL 쿼리 결과 조회

### getSingleResult()

이 함수는 쿼리의 결과로 **‘단일 엔티티 객체’를 반환**한다.

- 쿼리의 결과가 없을 때 → `NoResultException`
- 쿼리의 결과가 2개 이상일 때 → `NonUniqueResultException`

```java
Member member = em
				.createQuery("select m from Member as m where m.id = ?1 and m.name = ?2", Member.class);
				.setParameter(1, 1)
				.setParameter(2, seoyeon)
				.getSingleResult();
```

### getResultList()

이 함수는 쿼리의 결과로 **‘List 형태의 객체’로 반환**한다.

- 쿼리 결과가 없는 경우 빈 리스트를 반환한다.

```java
List<Member> members = em
				.createQuery("select m from Member as m where m.id = ?1 and m.name = ?2", Member.class);
				.setParameter(1, 1)
				.setParameter(2, seoyeon)
				.getResultList();
```

**‼️ getSingleResult()의 결과가 없을 경우 예외를 피하기 위해 getResultList()를 사용할 수 있다.**

- List로 반환한 다음, 리스트의 첫 번째 값을 가져온다.

```java
List<Member> members = em
				.createQuery("select m from Member as m where m.id = ?1 and m.name = ?2", Member.class);
				.setParameter(1, 1)
				.setParameter(2, seoyeon)
				.getResultList();
				
Member member = members.isEmpty() ? null : member.get(0);
```

## JPQL의 한계

### 1. 동적 쿼리의 사용이 어렵다.

- JPQL의 경우 컴파일 시점에 쿼리가 결정되기 때문에 사용자의 입력 값에 따라 동적으로 쿼리를 변경하기 어렵다.
- 동적 쿼리가 필요한 경우에는 Criteria API나 QueryDSL과 같은 도구를 사용하는 것이 더 효율적이다.

### 2. 문자열 오류 확인이 어렵다.

- 쿼리를 문자열로 작성하기 때문에, 문자열 내부에 있는 쿼리의 문법 오류나 오타를 컴파일 시점에 체크할 수 없다.
- 따라서, 잘못된 쿼리를 입력하면 실행 시점에 예상하지 못한 오류가 발생할 수 있다.

### 3. SQL의 모든 기능을 사용할 수 없다.

- SQL을 추상화하여 데이터 베이스에 의존하지 않는 대신, 특정 데이터 베이스에 특화된 SQL문법을 사용할 수 없다.
- 특화된 문법을 사용하고 싶은 경우에는 native query를 사용해야 한다.

### 4. 복잡한 Join을 이용한 쿼리를 작성하는 데에 제약이 있다.

- JPQL에서 서브 쿼리는 Where절 내에서만 부분적으로 허용하기 때문에, 복잡한 Join 조건을 사용할 수 없다.
- 필요할 경우에는 native query를 사용해야 한다.

## 🌱 Spring Data JPA와 JPQL

실제로 개발할 때는 `em.createQuery()`를 직접 쓰는 경우가 거의 없다. Spring Data JPA가 복잡한 코드를 전부 대신 처리해준다. 우리가 실제로 접하는 방식은 다음과 같다.

### 1️⃣ Repository 기본 기능

JpaRepository를 상속받는 것만으로 **기본 CRUD가 자동으로 제공된다.**

```java
public interface MemberRepository extends JpaRepository<Member, Long> {
    // save(), findById(), findAll(), delete() ...
}
```

### 2️⃣ 메서드 이름으로 쿼리 자동 생성

메서드 이름 규칙을 따르면 **Spring Data JPA가 JPQL을 자동으로 만들어준다.**

```java
List<Member> findByName(String name);
// → "select m from Member m where m.name = :name" 자동 생성

List<Member> findByAgeGreaterThan(int age);
// → "select m from Member m where m.age > :age" 자동 생성
```

### 3️⃣ @Query

메서드 이름으로 표현하기 복잡한 쿼리만 직접 JPQL을 작성한다. 조회/파라미터 바인딩 같은 처리는 Spring Data JPA가 다 해주기 때문에, 우리는 JPQL문만 작성하면 된다.

```java
// fetch join
@Query("select m from Member m join fetch m.team where m.age > :age")
List<Member> findWithTeam(@Param("age") int age);

// 복잡한 조건
@Query("select m from Member m where m.name like %:keyword% order by m.age desc")
List<Member> search(@Param("keyword") String keyword);
```

## Fetch Join이란?

**JPQL에서 성능 최적화를 위해 제공하는 Join의 종류**이다. 연관된 엔티티나 컬렉션을 SQL 한 번에 함께 조회하는 기능으로, **프록시가 아닌 진짜 데이터를 한 번에 가져온다.**

<aside>

[ LEFT [ OUTER ] | INNER ] JOIN FETCH 

</aside>

```sql
// JPQL
	Select m From Member m Join Fetch m.team
	
// 실제 실행 SQL 
	Select m.*, t.* From Member m Inner Join Team t On m.team_id = t.id
```

## Fetch Join을 왜 사용할까?

보통 엔티티 간의 연관 관계는 FetchType.LAZY로 설정해 지연 로딩을 사용한다. 이 상태에서 연관 엔티티를 조회할 때 일반 Join을 사용하면 문제가 생긴다.

**일반 Join과의 차이**

**일반 Join**은 조회 대상 엔티티만 영속성 컨텍스트에 저장하고, 연관된 엔티티는 프록시 상태로 둔다. 실제로 사용하는 시점에 추가 쿼리가 발생한다.

```sql
// JPQL - 일반 join
select m from Member m join m.team t

// 실행 SQL
SELECT m.* FROM member m INNER JOIN team t ON m.team_id = t.id
// team 데이터는 SELECT하지 않음 → 이후 team 접근 시 추가 쿼리 발생
```

**Fetch Join**은 연관 엔티티까지 **한 번에 Select해서 영속성 컨텍스트에 저장**한다. 이후 연관 엔티티에 접근해도 추가 쿼리가 발생하지 않는다.

```sql
// JPQL - fetch join
select m from Member m join fetch m.team

// 실행 SQL
SELECT m.*, t.* FROM member m INNER JOIN team t ON m.team_id = t.id
// team 데이터도 함께 SELECT → 추가 쿼리 없음
```

```
일반 Join
─────────────────────────────────────
SELECT m.*, t.* FROM member m JOIN team t
           │
           ▼
영속성 컨텍스트: [ Member만 저장 ]
Team은 SQL로 가져왔지만 영속성 컨텍스트에 올리지 않음
→ team.getName() 호출 시 추가 쿼리 발생

Fetch Join
─────────────────────────────────────
SELECT m.*, t.* FROM member m JOIN team t
           │
           ▼
**영속성 컨텍스트: [ Member 저장 + Team도 저장 ]**
→ team.getName() 호출해도 이미 있으니 추가 쿼리 없음
```

## Fetch Join 종류

### 엔티티 Fetch Join

`@ManyToOne`, `@OneToOne` 처럼 단일 엔티티 연관 관계에서 사용한다.

```java
@Query("select m from Member m join fetch m.team")
List<Member> findAllWithTeam();
```

### 컬렉션 Fetch Join

`@OneToMany`, `@ManyToMany` 처럼 컬렉션 연관 관계에서 사용한다.

```java
@Query("select distinct t from Team t join fetch t.members")
List<Team> findAllWithMembers();
```

→ 컬렉션 Fetch Join 시에는 데이터 중복이 발생할 수 있다. Team 1개에 Member가 3명이면 결과 row가 3개로 늘어난다. 따라서 `distinct`로 중복을 제거해야 한다.

## Fetch Join 한계

### 페이징 불가 (컬렉션 Fetch Join 시)

컬렉션을 Fetch Join하면서 페이징을 함께 사용하면 메모리에서 페이징을 처리하게 된다. 데이터가 많을 경우 OOM(Out of Memory)이 발생할 수 있다.

```java
// ⚠️ 위험 — Hibernate 경고 발생
@Query("select t from Team t join fetch t.members")
Page<Team> findAllWithMembers(Pageable pageable);
```

페이징이 필요한 경우에는 `@BatchSize`나 `default_batch_fetch_size` 설정을 사용해야 한다.

### 둘 이상의 컬렉션 Fetch Join 불가

컬렉션을 2개 이상 Fetch Join하면 `MultipleBagFetchException`이 발생한다.

```java
// ❌ 불가
@Query("select t from Team t join fetch t.members join fetch t.projects")
List<Team> findAll();
```

### Fetch Join 대상에 별칭 사용 주의

Fetch Join한 대상에 별칭을 붙여 WHERE 절에서 필터링하는 것은 JPA 표준에서 권장하지 않는다. 영속성 컨텍스트와 실제 데이터 간의 불일치가 발생할 수 있다.

```sql
// ⚠️ 권장하지 않음
select t from Team t join fetch t.members m where m.age > 20
```

## Spring Data JPA에서 사용하는 방법

실제로는 `@Query`안에 Fetch Join JPQL을 작성하는 방식으로 사용한다.

```java
public interface TeamRepository extends JpaRepository<Team, Long> {

    // 엔티티 Fetch Join
    @Query("select m from Member m join fetch m.team")
    List<Member> findAllWithTeam();

    // 컬렉션 Fetch Join + distinct
    @Query("select distinct t from Team t join fetch t.members")
    List<Team> findAllWithMembers();

    // 조건과 함께 사용
    @Query("select m from Member m join fetch m.team where m.age > :age")
    List<Member> findWithTeamAndAge(@Param("age") int age);
}
```

## @EntityGraph란?

엔티티의 연관 관계를 지연 로딩으로 설정하면, 연관된 엔티티는 프록시 객체로 가져오게 된다. 이후 해당 프록시 객체를 호출할 때마다 객체마다 Select 쿼리가 실행되는 N + 1 문제가 발생한다.

이런 문제를 JPQL의 `fetch join`으로 해결할 수 있는데, **`@EntityGraph`는 fetch join을 어노테이션으로 간편하게 적용할 수 있는 기능이다.**

## 🥊  Fetch Join과의 차이

기능적으로는 동일하게 동작하지만 작성 방식에 차이가 있다.

|  | Fetch Join | @EntityGraph |
| --- | --- | --- |
| 작성 방식 | JPQL에 직접 작성 | 어노테이션으로 선언 |
| Join 방식 | INNER JOIN (기본) | LEFT OUTER JOIN (기본) |
| 가독성 | JPQL이 길어질 수 있음 | 간결함 |
| 복잡한 조건 | 유연하게 표현 가능 | 단순한 경우에 적합 |

가장 중요한 차이는 JOIN 방식이다. Fetch Join은 기본적으로 INNER JOIN을 사용해서 연관 엔티티가 없는 경우 결과에서 제외된다. 반면 `@EntityGraph` 는  LEFT OUTER JOIN을 사용해서 연관 엔티티가 없어도 결과에 포함된다.

## @EntityGraph 적용 방법

### 함수 오버라이딩

`JpaRepository` 가 제공하는 기본 메서드에 Fetch Join을 적용하고 싶을 떄 오버라이딩해서 사용한다.

```java
@Override
@EntityGraph(attributePaths = {"team"})
List<Member> findAll();
-> 멤버가 속한 팀의 정보를 모두 영속성 컨텍스트에 불러옴
```

### JPQL과 함께 사용

직접 작성한 JPQL에 추가로 적용할 수 있다.

```java
@Query("select m from Member m")
@EntityGraph(attributePaths = {"team"})
List<Member> findAllEntityGraph();
```

### 메서드 이름 쿼리와 함께 사용

메서드 이름으로 자동 생성되는 쿼리에도 적용할 수 있다.

```java
@EntityGraph(attributePaths = {"team"})
List<Member> findEntityGraphByUsername(@Param("username") String username);
```

### 중첩 연관 관계

연관 관계가 2단계 이상 중첩된 겨웅에도 `“.”` 으로 연결해서 한 번에 로드할 수 있다.

```java
// Member → Team → Coach 까지 한 번에 로드
@EntityGraph(attributePaths = {"team", "team.coach"})
List<Member> findAll();
```

## `@EntityGraph` 의 한계

Fettch Join고 동일한 한계를 가진다.

- 컬렉션 연관 관계에서 페이징 불가 → LEFT OUTER JOIN 결과가 너무 커지기 때문에 OOM 위험이 있다.
- 둘 이상의 컬렉션에 동시 적용 불가 → `MultipleBagFetchException`이 발생한다.
- 단순한 경우에만 적합 → 복잡한 조건이 필요한 경우 결국 JPQL의 fetch join을 써야 한다.

## flush()란?

영속성 컨텍스트의 변경 내용을 데이터베이스에 반영하는 작업이다. SQL 쿼리는 DB로 전송되지만, 트랜잭션이 커밋되지 않으면 최종 반영은 되지 않는다. 즉, DB에 SQL을 보내지만 아직 확정은 아닌 상태다.

### 왜 flush()가 필요할까?

JPA는 변경사항을 즉시 DB에 반영하지 않고 쓰지 지연 메커니즘을 사용한다.

```
em.persist(member)  →  영속성 컨텍스트에만 저장
                        SQL 저장소에 INSERT 쿼리 보관
                        DB에는 아직 안 감

em.flush()          →  SQL 저장소의 쿼리를 DB로 전송
                        DB에 반영은 됐지만 아직 확정 아님

em.commit()         →  트랜잭션 확정 → DB에 영구 저장
```

`flush()`실행 시 내부 동작 순서:

1. 변경 감지 - 1차 캐시의 스냅샷과 현재 엔티티를 비교해 변경된 부분을 감지한다.
2. 쓰기 지연 SQL 저장소의 쿼리를 DB로 전송 - INSERT, UPDATE, DELETE가 실행된다.
3. 영속성 컨텍스트는 그대로 유지된다. (1차 캐시 안 지워짐)

**같은 트랜잭션 안에서 데이터 정합성 보장**

JPQL은 영속성 컨텍스트가 아니라 DB를 직접 조회한다. 따라서 같은 트랜잭션 내에서 flush() 없이 JPQL을 실행하면 방금 persist()한 데이터가 DB에 없어서 조회가 되지 않는다. 이런 문제를 해결하기 위해 flush() 가 필요하다.

### flush() 호출 시점

직접 호출하는 경우는 거의 없고, 아래 상황에서 자동으로 호출된다.

```
트랜잭션 커밋 시     → 자동 flush 후 commit
JPQL 쿼리 실행 전   → 자동 flush (데이터 정합성 보장)
em.flush() 직접 호출 → 수동 flush
```

JPQL 실행 전에 자동으로 flush되는 이유는, 영속성 컨텍스트에 쌓인 변경사항이 DB에 반영되지 않은 상태에서 JPQL을 실행하면 최근에 변경한 데이터가 조회에 잡히지 않는 문제가 생기기 때문이다.

## commit()

**현재 트랜잭션을 완료하고 모든 변경 사항을 확정하는 역할**을 한다. 내부적으로는 flush()를 먼저 수행한 뒤 트랜잭션을 커밋한다. 이 시점에 데이터베이스에 영구적으로 저장된다.

```
commit() = flush() + 트랜잭션 확정
```

## flush() vs commit() 비교

|  | flush() | commit() |
| --- | --- | --- |
| SQL 전송 | ✅ | ✅ (내부적으로 flush 포함) |
| 트랜잭션 확정 | ❌ | ✅ |
| DB 영구 저장 | ❌ | ✅ |
| 영속성 컨텍스트 유지 | ✅ 유지 | ❌ 종료 |
| 롤백 가능 여부 | ✅ 가능 | ❌ 불가 |
