- ### 워크북 캡쳐

유리 -> 에반


- ### 워크북
- JPA란?

  ### JPA란?

    - 자바 객체와 DB 테이블을 자동으로 연결해주는 기술
    - 개발자가 SQL을 직접 작성하지 않아도 JPA가 자동으로 SQL을 생성해서 DB에 전달함

  ### JPA 동작 원리

    ```java
    개발자
      ↓  (객체 전달)
    JPA
      ↓  (SQL 자동 생성)
    JDBC API
      ↓  (SQL 전달)
    Database
    ```

  ### 저장 과정

    ```java
    // 개발자
    em.persist(member);
    
    // JPA 내부 동작
    // 1. Member 엔티티 분석
    // 2. INSERT SQL 자동 생성
    // 3. JDBC API로 SQL 실행
    ```

  ### 조회 과정

    ```java
    // 개발자
    Member m = em.find(Member.class, 1L);
    
    // JPA 내부 동작
    // 1. SELECT SQL 자동 생성
    // 2. JDBC API로 SQL 실행
    // 3. ResultSet → Member 객체로 자동 매핑
    ```

  ### JPA 핵심 구성 요소

    1. **EntityManagerFactory**
        - EntityManager를 생성하는 공장 역할

        ```java
        // 애플리케이션 로딩 시 1번만 생성
        EntityManagerFactory emf =
            Persistence.createEntityManagerFactory("hello");
        ```

        - 애플리케이션 전체에서 1번만 실행
        - 스레드 안전 (여러 스레드가 공유 가능)
        - 생성 비용이 매우 크므로 재사용
        - 애플리케이션 종료 시 반드기 닫아야 함

    ---

    1. **EntityManager**
        - 엔티티의 CRUD를 담당하는 핵심 객체

        ```java
        // 요청마다 새로 생성
        EntityManager em = emf.createEntityManager();
        ```

        ```java
        <주요 메서드> 
        
        // 저장
        em.persist(member);
        
        // 조회 (PK로 조회)
        Member m = em.find(Member.class, 1L);
        
        // 삭제
        em.remove(member);
        
        // JPQL 쿼리 생성
        em.createQuery("select m from Member m", Member.class);
        
        // 프록시 객체 조회 (지연 로딩)
        Member proxy = em.getReference(Member.class, 1L);
        
        // 영속성 컨텍스트 강제 반영
        em.flush();
        
        // 영속성 컨텍스트 초기화
        em.clear();
        
        // 엔티티 분리 (준영속 상태로 변경)
        em.detach(member);
        
        // 준영속 → 영속 상태로 복귀
        em.merge(member);
        ```

        - 스레드 간 공유 절대 금지
        - 요청(트랜잭션)마다 새로 생성 후 사용
        - 사용 후 반드기 닫아야 함
        - 영속성 컨텍스트와 1:1 관계

    ---

    1. **영속성 컨텍스트 (Persistence Context)**
        - 엔티티를 저장하고 관리하는 논리적 공간
        - 영속성 컨텍스트의 5가지 기능
            1. 1차 캐시
            2. 동일성 보장
            3. 쓰기 지연
            4. 변경 감지
            5. 지연 로딩

    ---

    1. **Transaction (트랜잭션)**
        - JPA의 모든 데이터 변경은 반드시 트랜잭션 안에서 실행

    ---

    1.  **Entity (엔티티)**
        - DB 테이블과 매핑되는 자바 클래스
- N+1 문제란?

  ### N+1 문제란?

    - 연관 관계가 설정된 엔티티를 조회할 때, 조회된 데이터 수(N)만큼 연관관계 조회 쿼리가 추가로 발생하는 현상
    - ex) 고양이 집사 10명이 각각 고양이 10마리를 키울 때
        - 집사 전체 조회 쿼리 1번 실행
        - 각 집사의 고양이 조회 쿼리 10번 추가 실행
        - 총 1+10 = 11번 쿼리 발생 → N+1 문제 !

  ### FetchType.LAZY로 바꾸면 해결될까?

    - 아니다. FetchType을 LAZY로 바꾸면 처음엔 쿼리가 1번만 나가는 것처럼 보이지만, 실제로 연관 데이터(고양이 이름 등)를 사용하는 시점에 똑같이 N번의 추가 쿼리가 발생
    - LAZY는 N+1을 해결하는 게 아니라 발생 시점을 미루는 것.

  ### 해결방법

    1. **Fetch.Join**

    ```java
    @Query("select o from Owner o join fetch o.cats")
    List<Owner> findAllJoinFetch();
    ```

    - 장점: 쿼리 1번으로 해결, 연관관계 중첩도 처리 가능
    - 단점: 페이징 쿼리 사용 불가, FetchType.LAZY 설정이 무의미
        - 페이징 쿼리: 대량의 데이터를 한 번에 가져오지 않고, 일정한 단위(페이지)로 나눠서 조회하는 쿼리
    1. **@EntityGraph**

    ```java
    @EntityGraph(attributePaths = "cats")
    @Query("select o from Owner o")
    List<Owner> findAllEntityGraph();
    ```

    - Fetch Join과 유사하지만 OUTER JOIN으로 실행
    1. FetchMode.SUBSELECT

    ```java
    @Fetch(FetchMode.SUBSELECT)
    @OneToMany(mappedBy = "owner", fetch = FetchType.EAGER)
    private Set<Cat> cats = new LinkedHashSet<>();
    ```

    - 연관 데이터를 서브쿼리로 한 번에 조회. 총 2번의 쿼리로 처리
    - 장점: N번 쿼리 → 2번으로 감소
    - 단점: FetchType.EAGER 설정 필요
    1. **@BatchSize**

    ```java
    @BatchSize(size=5)
    @OneToMany(mappedBy = "owner", fetch = FetchType.EAGER)
    private Set<Cat> cats = new LinkedHashSet<>();
    ```

    - 지정된 size만큼 SQL IN절을 묶어서 조회
    - 고양이가 10마리면 size=5일 때 IN절 쿼리가 2번 실행
- 지연로딩과 즉시로딩의 차이는?

  ### 지연 로딩(LAZY)

    ```java
    @ManyToOne(fetch = FetchType.LAZY)
    private Team team;
    ```

    - `Member`를 조회할 때 `Team`은 프록시 객체로만 가져오고, 실제 DB 조회는 하지 않음.
    - `Team` 데이터가 실제로 필요한 시점에 쿼리가 나감

    ```java
    Member m = em.find(Member.class, member1.getId());
    // 아직 Team 쿼리 안 나감 (프록시 상태)
    
    m.getTeam(); // 아직 쿼리 안 나감
    
    // 이 시점에 Team 쿼리 나감
    m.getTeam().getName();
    ```

    - `getTeam()`이 아니라 `getTeam().getName()`처럼 실제 값을 꺼낼 때 쿼리가 나가는 점을 주의

  ### 즉시 로딩(EAGER)

    ```java
    @ManyToOne(fetch = FetchType.EAGER)
    private Team team;
    ```

    - `Member` 를 조회할 때 `Team` 을 JOIN해서 한 번에 가져옴
    - `Team` 이 프록시가 아닌 진짜 객체로 들어옴

  ### 즉시 로딩의 문제점

    1. 예상치 못한 거대 쿼리 발생
        - 연관된 엔티티가 많아질수록, `find()` 한 번에 모든 연관 테이블을 JOIN하면서 예상 밖의 거대한 쿼리가 실행
    2. JPQL에서 N+1문제 발생
- JPQL란?

  ### JPQL이란?

    - JPA의 일부로 정의된 플랫폼 독립적인 객체지향 쿼리 언어
    - SQL과 유사하지만 DB 테이블이 아니라 JPA 엔티티를 대상으로 동작
    - 따라서 쿼리에 테이블 컬럼이 아닌 엔티티의 필드명을 사용
    - JPA가 JPQL을 분석해서 SQL을 자동 생성해 DB에 질의

  ### 동작 과정

    1. JPQL 실행
    2. 영속성 컨텍스트로 요청 전달
    3. 1차 캐시 여부와 무관하게 DB에 직접 질의
    4. DB 조회 결과를 영속성 컨텍스트가 수신
    5. 엔티티 초기화 후 1차 캐시에 저장
    6. 엔티티 반환
    - 영속성 컨텍스트: 엔티티를 저장하고 관리하는 저장소

  ### JPQL 문법 특징

    1. 대소문자 구분
        - 엔티티 이름과 속성은 대소문자를 구분
            - ex)  Member== member
        - JPQL 키워드는 대소문자 구분 없이 사용 가능
            - ex)  SELECT == select
    2. 엔티티명
        - `FROM` 절 뒤에 사용하는 것은 클래스명이 아니라 엔티티명 사용
        - `@Entity(name==xx)` 혹은 클래스명과 동일하면 생략 가능

        ```java
        // 테이블명(X) → 엔티티명(O)
        select m from Member m
        ```

    3. 별칭
        - SQL과 달리 JPQL에서는 별칭이 필수
        - `AS`는 생략 가능

        ```java
        select m from Member m          // m이 별칭
        select m from Member AS m       // AS 명시 (동일)
        ```

    4. 파라미터 바인딩
        - 쿼리에 변수를 직접 문자열로 넣지 않고, 외부에서 값을 주입하는 방식
        - 프로퍼티 앞에 `:` 를 붙여 파라미터를 바인딩

        ```java
        select m from Member m where m.name = :name
        ```

       ! JPQL에 직접 문자열을 넣으면 **SQL Injection** 위험.

       반드시 파라미터 바인딩을 사용해야 함

    5. 페이징 API
        - 복잡한 페이징 SQL 없이 두 줄로 간단하게 처리할 수 있음

        ```java
        em.createQuery("select m from Member m", Member.class)
          .setFirstResult(0)   // 조회 시작 위치 (0부터 시작)
          .setMaxResults(10)   // 조회할 데이터 수
          .getResultList();
        ```

    6. DTO 반환
        - 엔티티 자체를 반환하는 것은 바람직하지 않아 DTO 사용을 권장
        - `new 패키지명.DTO명(...)` 형태로 생성자를 호출해야 함

        ```java
        select new com.example.dto.MemberDto(m.name, m.age)
        from Member m
        ```

       ! 패키지명을 전부 써야 해서 불편. 이 단점은 QueryDSL을 사용하면 해결


- Fetch Join란?

  ### Fetch Join

    - JPQL에서 연관된 엔티티를 한 번의 쿼리로 함께 조회하는 기능
    - SQL의 JOIN과 다르게, JPA에서 N+1문제 해결과 성능 최적화를 위해 특별히 제공하는 기능

    ```java
    // 일반 JOIN → Member만 조회, Team은 지연 로딩 상태
    "select m from Member m join m.team"
    
    // Fetch JOIN → Member + Team 한 번에 조회
    "select m from Member m join fetch m.team"
    ```

  ### Fetch Join 종류

    1. **엔티티 Fetch Join (다대일 / @ManyToOne)**

    ```java
    // Member → Team (다대일)
    String jpql = "select m from Member m join fetch m.team";
    
    List<Member> members = em.createQuery(jpql, Member.class)
        .getResultList();
    
    for (Member m : members) {
        // Team 이미 로딩됨 → 추가 쿼리 없음
        System.out.println(m.getTeam().getName());
    }
    ```

    1. **컬렉션 Fetch Join (일대다 / @OneToMany)**

    ```java
    // Team → Member 목록 (일대다)
    String jpql = "select t from Team t join fetch t.members";
    
    List<Team> teams = em.createQuery(jpql, Team.class)
        .getResultList();
    
    for (Team t : teams) {
        // Member 목록 이미 로딩됨
        System.out.println(t.getMembers().size());
    }
    ```

  ! 중복 문제 주의 !

    - 일대다 Fetch Join 시 데이터 중복이 발생

    ```java
    Team A ─── Member 1
            ─── Member 2
            
    // 실행 결과 (중복 발생)
    Team A, Member 1
    Team A, Member 2   ← Team A가 2번 조회됨!
    ```

    - 해결방법 - DISTINT 사용

    ```java
    // JPQL DISTINCT → 같은 식별자의 엔티티 중복 제거
    String jpql = "select distinct t from Team t join fetch t.members";
    
    List<Team> teams = em.createQuery(jpql, Team.class)
        .getResultList();
    // Team A 1개만 반환 (members는 [Member1, Member2] 포함)
    ```

    1. **Left Join Fetch (NULL허용)**

    ```java
    // Team이 없는 Member도 포함해서 조회
    String jpql = "select m from Member m left join fetch m.team";
    
    List<Member> members = em.createQuery(jpql, Member.class)
        .getResultList();
    ```

- @EntityGraph란?

  ### @EntityGraph란?

    - 연관된 엔티티를 한 번에 조회할 때 사용하는 어노테이션
    - Fetch Join과 동일한 효과를 내지만, JPQL 없이 어노테이션만으로 간편하게 사용

    ```java
    // Fetch Join 방식
    @Query("select m from Member m join fetch m.team")
    List<Member> findAllWithTeam();
    
    // @EntityGraph 방식 (더 간편!)
    @EntityGraph(attributePaths = "team")
    @Query("select m from Member m")
    List<Member> findAllWithTeam();
    ```

  ### 사용방법

    1. **attributePaths 직접 지정 (가장 많이 사용)**

    ```java
    public interface MemberRepository extends JpaRepository<Member, Long> {
    
        // 기본 메서드에 @EntityGraph 추가
        @EntityGraph(attributePaths = "team")
        List<Member> findAll();
    
        // @Query와 함께 사용
        @EntityGraph(attributePaths = "team")
        @Query("select m from Member m")
        List<Member> findAllWithTeam();
    
        // 조건 메서드에도 사용 가능
        @EntityGraph(attributePaths = "team")
        List<Member> findByName(String name);
    }
    ```

    2.  **@NamedEntityGraph — 엔티티에 미리 정의**

    ```java
    // Entity에 미리 정의
    @Entity
    @NamedEntityGraph(
        name = "Member.withTeam",
        attributeNodes = @NamedAttributeNode("team")
    )
    public class Member {
    
        @Id
        private Long id;
        private String name;
    
        @ManyToOne(fetch = FetchType.LAZY)
        private Team team;
    }
    ```

    1. **여러 연관관계 동시 로딩**

    ```java
    @Entity
    @NamedEntityGraph(
        name = "Member.withAll",
        attributeNodes = {
            @NamedAttributeNode("team"),
            @NamedAttributeNode("orders")  // 여러 연관관계 동시 로딩
        }
    )
    public class Member {
        private Long id;
    
        @ManyToOne(fetch = FetchType.LAZY)
        private Team team;
    
        @OneToMany(mappedBy = "member", fetch = FetchType.LAZY)
        private List<Orders> orders;
    }
    ```

    1. **중첩 연관관계 로딩**

    ```java
    // Order → OrderItem → Item 까지 한 번에 로딩
    @Entity
    @NamedEntityGraph(
        name = "Order.withAll",
        attributeNodes = {
            @NamedAttributeNode(
                value = "orderItems",
                subgraph = "orderItems"  // 중첩 로딩
            )
        },
        subgraphs = @NamedSubgraph(
            name = "orderItems",
            attributeNodes = @NamedAttributeNode("item")
        )
    )
    public class Orders {
        @OneToMany
        private List<OrderItem> orderItems;
    }
    ```

- commit과 flush 차이점은?

  ### Commit이란?

    - 트랜잭션을 완전히 확정해서 DB에 영구 반영하는 것

    ```java
    commit() 호출
        ↓
    ① flush() 자동 실행 (SQL 전송)
        ↓
    ② 트랜잭션 완전 종료
        ↓
    ③ DB에 영구 반영 (롤백 불가!)
        ↓
    ④ 다른 트랜잭션에서도 변경 내용 확인 가능
    ```

  ### Flush란?

    - 영속성 컨텍스트의 변경 내용을 DB에 전송하는 것

    ```java
    flush() 호출
        ↓
    ① 변경 감지 (Dirty Checking)
        ↓
    ② 쓰기 지연 SQL 저장소 → DB로 SQL 전송
        ↓
    ③ 영속성 컨텍스트 유지 (초기화 X)
        ↓
    아직 트랜잭션 진행 중 → 롤백 가능!
    ```

  ### 핵심 차이 비교

    1. **롤백 가능 여부**

    ```java
    tx.begin();
    
    em.persist(member);
    
    tx.commit(); // flush + 트랜잭션 종료
    // ❌ 롤백 불가!
    // DB에 영구 반영
    
    ------------------------------------------------
    
    tx.begin();
    
    em.persist(member);
    
    em.flush();
    // SQL → DB 전송 완료
    // 하지만 트랜잭션 아직 진행 중
    
    tx.rollback(); // ✅ 롤백 가능!
    // DB에서 INSERT 취소
    // 데이터 없던 상태로 복구
    ```

    1. **영속성 컨텍스트 유지 여부**

    ```java
    em.persist(member);
    
    tx.commit();
    // 트랜잭션 종료
    // Spring에서는 영속성 컨텍스트도 함께 종료
    
    // 트랜잭션 밖에서 접근 시
    member.getTeam().getName();
    // ❌ LazyInitializationException 발생!
    
    -----------------------------------------------
    
    em.persist(member);
    
    em.flush();
    // SQL 전송 완료
    // 영속성 컨텍스트는 그대로 유지!
    
    Member found = em.find(Member.class, 1L);
    // 1차 캐시에서 바로 반환 (SQL 실행 안 함)
    ```

    1. **다른 트랜잭션 가시성**

    ```java
    // 트랜잭션 A
    tx.begin();
    em.persist(member);
    em.flush(); // SQL 전송했지만 커밋 안 함
    
    // 트랜잭션 B (동시에 실행)
    Member found = em.find(Member.class, 1L);
    // ❌ 못 찾음! (A가 아직 커밋 안 했으므로)
    
    // 트랜잭션 A
    tx.commit(); // 이제 커밋
    
    // 트랜잭션 B
    Member found2 = em.find(Member.class, 1L);
    // ✅ 찾음! (A가 커밋했으므로)
    ```

