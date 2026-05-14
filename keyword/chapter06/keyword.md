- JPA란?

  **JPA(Java Persistence API)**

  Java 진영의 ORM 기술 표준, Java 애플리케이션에서 관계형 DB를 사용하는 방식을 정의한 인터페이스 모음

  실제로 동작하는 구현체가 아니라 명세/인터페이스이며, 대표 구현체로 Hibernate, EclipseLink, DataNucleus 등이 있음

  **ORM(Object-Relational Mapping)**

  객체와 RDB 테이블을 매핑해주는 기술

  객체는 객체대로 설계하고, RDB는 RDB대로 설계한 뒤 ORM 프레임워크가 중간에서 둘을 연결함

  **사용 이유**

    - 반복적인 CRUD SQL 작성 감소

      SQL을 직접 작성하지 않아도 `persist`, `find`, `remove` 같은 메서드 중심으로 DB 작업 가능

    - SQL 의존성 감소

      컬럼 변경 시 DAO의 SQL을 전부 수정해야 하는 부담을 줄일 수 있음

    - 객체 중심 개발

      DB 테이블 중심이 아니라 객체와 연관관계를 중심으로 비즈니스 로직 작성 가능

    - 패러다임 불일치 해결

      RDB에는 객체의 상속, 연관관계, 객체 동일성 같은 개념이 그대로 존재하지 않음 → JPA가 중간에서 매핑 처리

    - 데이터 접근 추상화

      DB 벤더가 바뀌어도 애플리케이션 코드의 변경을 줄일 수 있음


    **동작 방식**
    
    JPA는 애플리케이션과 JDBC API 사이에서 동작
    
    개발자가 엔티티 객체를 JPA에 넘기면, JPA가 매핑 정보를 분석해 SQL을 생성하고 JDBC를 통해 DB와 통신
    
    ```java
    entityManager.persist(member); // 저장
    entityManager.find(Member.class, memberId); // 조회
    entityManager.remove(member); // 삭제
    ```
    
    수정 메서드는 따로 제공X
    
    영속 상태의 엔티티를 조회한 뒤 값을 변경하면, 트랜잭션 커밋/flush 시점에 변경 감지를 통해 UPDATE SQL이 실행됨
    
    ```java
    Member member = entityManager.find(Member.class, memberId);
    member.setName("변경할 이름");
    ```
    
    - 엔티티의 상태
        
        JPA는 엔티티 객체를 영속성 컨텍스트와의 관계에 따라 여러 상태로 구분함
        
        - 비영속 상태(new/transient)
            
            엔티티 객체를 생성했지만 아직 영속성 컨텍스트가 관리하지 않는 상태
            
            DB와도 연결되어 있지 않고, 값이 바뀌어도 JPA가 감지하지 않음
            
            ```java
            Member member = new Member();
            ```
            
        - 영속 상태(managed)
            
            영속성 컨텍스트가 관리하는 상태
            
            `persist()`로 저장하거나 `find()`로 조회하면 영속 상태가 됨
            
            영속 상태의 엔티티는 변경 감지 대상이 되며, flush/commit 시점에 변경 내용이 DB에 반영될 수 있음
            
            ```java
            entityManager.persist(member);
            Member findMember = entityManager.find(Member.class, id);
            ```
            
        - 준영속 상태(detached)
            
            한 번 영속 상태였지만 현재는 영속성 컨텍스트의 관리를 받지 않는 상태
            
            값을 변경해도 변경 감지가 일어나지 않음
            
            ```java
            entityManager.detach(member); // 특정 엔티티만 분리
            entityManager.clear(); // 영속성 컨텍스트 전체 초기화
            entityManager.close(); // 영속성 컨텍스트 종료
            ```
            
        - 삭제 상태(removed)
            
            영속 상태의 엔티티를 삭제 대상으로 표시한 상태
            
            flush/commit 시점에 DELETE SQL이 실행됨
            
            ```java
            entityManager.remove(member);
            ```
            
        
        **상태 전환 흐름**
        
        ```java
        Member member = new Member(); // 비영속
        entityManager.persist(member); // 영속
        entityManager.detach(member); // 준영속
        entityManager.remove(member); // 삭제
        ```
        
        ⇒ 변경 감지는 영속 상태의 엔티티에만 적용됨
        
        비영속/준영속 상태의 객체는 값을 바꿔도 JPA가 자동으로 UPDATE SQL을 만들어주지 않음
        
    
    **장점**
    
    - 생산성⬆️
        
        SQL, JDBC 반복 코드를 JPA가 처리
        
    - 유지보수성⬆️
        
        필드 변경 시 SQL 매핑 코드를 일일이 수정하는 부담 감소
        
    - 객체지향적 설계 가능
        
        연관관계, 상속관계 등을 객체 모델에 맞춰 표현 가능
        
    - 성능 최적화 기능 제공
        
        같은 트랜잭션 안에서 동일 엔티티를 다시 조회하면 같은 객체를 반환하는 등 1차 캐시/동일성 보장 가능
        
    
    **단점**
    
    - 학습 곡선이 높음
        
        영속성 컨텍스트, 변경 감지, flush, 지연 로딩, 연관관계 매핑 등을 이해해야 함
        
    - 복잡한 쿼리는 튜닝 필요
        
        무거운 조회, 통계성 쿼리, 성능이 중요한 쿼리는 JPQL, QueryDSL, Native SQL 등을 사용할 수 있음
        
    - 잘못 설계하면 성능 저하 가능
        
        N+1 문제, 불필요한 즉시 로딩, 과도한 연관관계 탐색 등에 주의 필요
        
    
    https://dbjh.tistory.com/77
    
    https://velog.io/@bbkyoo/spring-JPA-%EC%A0%95%EB%A6%AC
    
    https://dev-jwblog.tistory.com/122
    
    https://docs.spring.io/spring-data/jpa/reference/repositories/core-concepts.html

- N+1 문제란?

  **N+1 문제**

  연관관계가 있는 엔티티를 조회할 때, 최초 조회 쿼리 1번 이후 조회된 엔티티 N개만큼 추가 쿼리가 발생하는 문제

  → 한 번의 조회로 끝날 것 같았던 작업이 1+N번의 쿼리로 늘어나는 현상

  Ex)

    ```java
    List<Team> teams = teamRepository.findAll(); // Team 조회 1번
    
    for (Team team : teams) {
        team.getMembers().size(); // 각 Team마다 Member 조회 N번
    }
    ```

  **발생 원인**

  JPA는 객체와 테이블을 매핑해서 다루기 때문에, 처음 조회한 엔티티와 연관된 엔티티를 항상 한 번에 가져오지 않음

  연관 엔티티가 필요한 시점에 별도 쿼리로 조회하면서 N개의 추가 쿼리가 발생할 수 있음

  특히 다음 상황에서 자주 발생

    - `findAll()`처럼 여러 엔티티를 한 번에 조회한 뒤, 반복문 안에서 연관 엔티티를 사용하는 경우
    - JPQL로 엔티티를 조회한 뒤, 연관 객체를 접근하는 경우
    - 즉시 로딩을 사용하면 조인으로 한 번에 가져올 것 같지만, JPQL에서는 추가 쿼리가 발생할 수 있음
    - 지연 로딩도 연관 객체를 실제로 사용하는 순간 추가 쿼리가 발생할 수 있음

  **Lazy/Eager**

    - Lazy Loading

      연관 엔티티를 바로 가져오지 않고, 실제 사용하는 시점에 조회

      처음 조회 시에는 추가 쿼리가 없을 수 있지만, 반복문 안에서 연관 엔티티에 접근하면 N+1 발생 가능

    - Eager Loading

      연관 엔티티를 즉시 가져오는 전략

      항상 조인으로 가져오는 것은 아니기 때문에, JPQL 조회에서는 N+1이 발생할 수 있음


    ⇒ 그래서 단순히 `LAZY`로 바꾼다고 N+1이 해결되는 것은 아님
    
    보통 기본은 `LAZY`로 두고, 필요한 조회에서만 fetch join이나 EntityGraph로 명시적으로 함께 조회하는 방식이 권장됨
    
    **문제점**
    
    - 쿼리 수 증가
        
        데이터 수가 많아질수록 DB에 보내는 쿼리 수가 급격히 증가
        
    - 성능 저하
        
        네트워크 왕복, DB 부하, 응답 시간 증가
        
    - 의도하지 않은 SQL 발생
        
        코드상으로는 단순한 객체 접근처럼 보이지만 내부에서는 추가 SQL이 실행됨
        
    
    **해결 방법**
    
    - Fetch Join
        
        JPQL에서 연관 엔티티를 함께 조회하도록 명시하는 방법
        
        ```java
        @Query("select t from Team t join fetch t.members")
        List<Team> findAllWithMembers();
        ```
        
        Team과 Member를 SQL 한 번에 함께 조회하므로 추가 쿼리 발생을 줄일 수 있음
        
        가장 자주 사용하는 해결 방법
        
        ```sql
        select t.*,m.*
        from team t
        join member m on m.team_id = t.id;
        ```
        
    
    - @EntityGraph
        
        Spring Data JPA에서 특정 메서드 실행 시 함께 조회할 연관 엔티티를 지정하는 방법
        
        ```java
        @EntityGraph(attributePaths = {"members"})
        List<Team> findAll();
        ```
        
        JPQL을 직접 작성하지 않고도 fetch join과 비슷하게 연관 엔티티를 함께 가져올 수 있음
        
        단, 기본적으로 left join 형태로 동작하는 경우가 많아 inner join이 필요하면 JPQL fetch join을 직접 작성하는 것이 적합
        
        ```sql
        select t.*,m.*
        from team t
        left join member m on m.team_id = t.id;
        ```
        
    
    - Batch Size
        
        N개의 추가 쿼리를 완전히 없애기보다는, `IN`절을 사용해 묶어서 조회하는 방법
        
        ```java
        @BatchSize(size = 100)
        private List<Member> members = new ArrayList<>();
        ```
        
        또는 전역 설정 가능
        
        ```yaml
        spring:
          jpa:
            properties:
              hibernate:
                default_batch_fetch_size: 100
        ```
        
        N번의 쿼리를 더 적은 수의 쿼리로 줄이는 방식
        
        ```sql
        select t.*
        from team t;
        
        select m.*
        from member m
        where m.team_id in (1, 2, 3, ...100); // 다음은 (101, 102, ... 200)
        ```
        
        1 + N ⇒ 1 + celi(N/Batch size)
        
    
    - DTO 조회
        
        필요한 데이터만 직접 조회해서 DTO로 받는 방식
        
        복잡한 화면 조회, 통계성 조회, 성능이 중요한 조회에서 유용
        
    
    ```sql
    select
        t.id as team_id,
        t.name as team_name,
        m.id as member_id,
        m.name as member_name
    from team t
    left join member m on m.team_id = t.id;
    ```
    
    **주의점**
    
    - fetch join은 필요한 곳에만 사용
        
        연관 데이터를 항상 많이 가져오면 메모리 사용량이 증가할 수 있음
        
    - 1:N 컬렉션 fetch join은 중복 결과 발생 가능
        
        부모 엔티티가 자식 수만큼 중복되어 조회될 수 있어 `distinct`가 필요할 수 있음
        
    - 페이징과 컬렉션 fetch join은 함께 사용할 때 주의
        
        DB 페이징이 의도대로 동작하지 않을 수 있음
        
    - 해결 방법은 상황에 따라 선택
        
        단순 조회는 fetch join, 여러 연관 조회는 EntityGraph, 대량 조회/페이징은 Batch Size나 DTO 조회를 고려
        
    
    https://ksh-coding.tistory.com/146
    
    https://tech.trenbe.com/2022/02/23/%EC%95%BC!-%EB%84%88%EB%8F%84-%ED%95%A0-%EC%88%98-%EC%9E%88%EC%96%B4,-N+1%ED%95%B4%EA%B2%B0.html

- 지연로딩과 즉시로딩의 차이는?

  **Fetch Type**

  JPA가 엔티티를 조회할 때, 연관관계에 있는 엔티티를 어떤 시점에 가져올지 정하는 설정

  대표적으로 `FetchType.LAZY`와 `FetchType.EAGER`가 있음

  **지연 로딩(Lazy Loading)**

  연관 엔티티를 처음부터 조회하지 않고, 실제로 사용하는 시점에 조회하는 방식

  처음에는 연관 엔티티 대신 프록시 객체를 넣어두고, 해당 객체의 실제 값이 필요해질 때 DB 조회가 발생함

    ```java
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;
    ```

    ```java
    Member member = entityManager.find(Member.class, id); // Member만 조회
    member.getTeam().getName(); // 이 시점에 Team 조회
    ```

  **즉시 로딩(Eager Loading)**

  엔티티를 조회할 때 연관 엔티티도 함께 조회하는 방식

  연관 데이터를 바로 사용할 수 있지만, 필요하지 않은 데이터까지 조회할 수 있음

    ```java
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "team_id")
    private Team team;
    ```

  **차이점**

    - 조회 시점

      지연 로딩 : 연관 엔티티를 실제 사용할 때 조회

      즉시 로딩 : 엔티티를 조회할 때 연관 엔티티도 함께 조회

    - 초기 쿼리

      지연 로딩 : 최초 조회 쿼리가 단순해짐

      즉시 로딩 : 조인 또는 추가 쿼리로 연관 데이터까지 조회될 수 있음

    - 메모리 사용

      지연 로딩 : 필요한 데이터만 조회하므로 메모리 사용을 줄일 수 있음

      즉시 로딩 : 필요 없는 데이터까지 가져오면 메모리 낭비 가능

    - 추가 쿼리 가능성

      지연 로딩 : 연관 엔티티 접근 시점에 추가 쿼리 발생 가능

      즉시 로딩 : 처음부터 함께 가져오지만, JPQL에서는 예상하지 못한 추가 쿼리 발생 가능


    **지연 로딩을 주로 사용하는 이유**
    
    - 불필요한 데이터 조회 방지 ⇒ 성능 최적화
        
        사용하지 않는 연관 데이터까지 미리 가져오지 않는다 → 초기 조회 쿼리가 가벼움
        
    - 예측 가능한 조회 설계
        
        기본은 지연 로딩으로 두고, 필요한 조회에서만 fetch join, EntityGraph 등으로 명시적으로 함께 조회하는 방식
        
    
    **즉시 로딩의 주의점**
    
    - 예상하지 못한 SQL 발생 가능
        
        엔티티 하나만 조회한다고 생각했는데 연관 엔티티까지 조회될 수 있음
        
    - JPQL에서 N+1 문제 발생 가능
        
        앞의 N+1문제에서 설명한 내용처럼, 최초 쿼리 이후 연관 엔티티 조회 쿼리가 추가로 발생 가능
        
    - 연관관계가 많아질수록 성능 예측이 어려움
        
        즉시 로딩이 여러 곳에 걸려 있으면 의도보다 큰 객체 그래프가 한 번에 로딩될 수 있음
        
    
    https://sjh9708.tistory.com/160#google_vignette
    
    https://jskim-dev.tistory.com/34

- JPQL란?

  **JPQL(Java Persistence Query Language)**

  JPA에서 엔티티 객체를 대상으로 조회, 수정, 삭제를 수행하기 위해 사용하는 객체 지향 쿼리 언어

  SQL과 문법이 비슷하지만, 테이블과 컬럼이 아니라 엔티티와 엔티티의 필드를 대상으로 쿼리한다는 점이 다름

  **SQL과의 차이**

    - SQL

      DB 테이블과 컬럼을 대상으로 쿼리 작성

        ```sql
        SELECT * FROM member WHERE name = 'kim';
        ```

    - JPQL

      엔티티 클래스와 필드를 대상으로 쿼리 작성

        ```java
        select m from Member m where m.name = :name
        ```


    즉, JPQL의 `Member`는 테이블명이 아니라 엔티티 이름이고, `m.name`은 컬럼명이 아니라 엔티티의 필드명
    
    JPA 구현체는 JPQL을 분석해 실제 DB에 맞는 SQL로 변환해서 실행함
    
    **사용 이유**
    
    - 복잡한 조회 처리
        
        단순 CRUD보다 복잡한 조건, 조인, 정렬, 집계 등이 필요한 경우 사용
        
    - 객체 중심 쿼리 작성
        
        테이블 구조가 아니라 엔티티와 연관관계 기준으로 쿼리 작성 가능
        
    - DB 독립성
        
        JPQL 자체는 특정 DB 문법에 종속되지 않고, JPA 구현체가 DB별 SQL로 변환
        
    - 동적/정적 쿼리 지원
        
        코드 안에서 `createQuery()`로 동적 쿼리를 만들거나, `@NamedQuery`로 미리 정의 가능
        
    
    **파라미터 바인딩**
    
    JPQL에서는 값을 문자열로 직접 이어붙이기보다 파라미터를 사용해 전달하는 것이 좋음
    
    - 이름 기준 파라미터
        
        `:name`처럼 이름을 붙여 사용하는 방식
        
        ```java
        select m from Member m where m.name = :name
        ```
        
        ```java
        query.setParameter("name", "kim");
        ```
        
    - 위치 기준 파라미터
        
        `?1`, `?2`처럼 위치 번호를 사용하는 방식
        
        ```java
        select m from Member m where m.name = ?1
        ```
        
        ```java
        query.setParameter(1, "kim");
        ```
        
    
    가독성과 유지보수 측면에서 보통 이름 기준 파라미터를 더 많이 사용
    
    **연관관계 탐색**
    
    JPQL은 엔티티의 연관관계를 `.`으로 탐색 가능
    
    ```java
    select m
    from Member m
    where m.team.name = :teamName
    ```
    
    `m.team.name`은 Member에서 Team으로 이동한 뒤 Team의 name 필드를 조건으로 사용하는 것
    
    SQL이 테이블 조인을 직접 작성하는 것과 달리, JPQL은 객체의 연관관계를 따라가는 방식으로 표현함
    
    단, 컬렉션 연관관계는 바로 계속 탐색할 수 없어서 조인으로 별칭을 만들어 사용해야 함
    
    ```java
    select t
    from Team t join t.members m
    where m.name = :name
    ```
    
    **주의점**
    
    - 정적 쿼리만 작성 가능
        
        런타임에 동적으로 변경 불가능, 문자열 기반이라 컴파일 타임에 오류 확인 X
        
    - 별칭 필수
        
        `from Member m`처럼 엔티티에 별칭을 주고 사용
        
    - 실제 SQL은 JPA 구현체가 생성
        
        성능이 중요한 쿼리는 실행 SQL을 확인하는 습관이 필요
        
    - N+1 문제 가능
        
        JPQL로 연관 엔티티를 조회한다고 해서 항상 한 번에 가져오는 것은 아님. 이 부분은 앞에서 설명한 `N+1 문제란?` 내용과 연결됨
        
    
    참고자료
    
    https://jakarta.ee/learn/docs/jakartaee-tutorial/current/persist/persistence-querylanguage/persistence-querylanguage.html
    
    https://docs.oracle.com/cd/E29542_01/apirefs.1111/e13946/ejb3_langref.html

- Fetch Join란?

  **Fetch Join**

  JPQL에서 연관된 엔티티나 컬렉션을 한 번의 SQL로 함께 조회하기 위해 사용하는 기능

  일반 조인처럼 조회 조건을 만들기 위한 조인이 아니라, 연관 객체까지 실제 엔티티 그래프에 채워 넣기 위한 조인

  앞에서 설명한 것처럼 JPA는 기본적으로 연관 엔티티를 필요한 시점에 따로 조회할 수 있음

  이때 반복문 안에서 연관 엔티티에 접근하면 N+1 문제가 발생할 수 있는데, Fetch Join은 필요한 연관 데이터를 처음부터 함께 조회해 이 문제를 줄이는 대표적인 방법

  **기본 문법**

    ```java
    select m
    from Member m
    join fetch m.team
    ```

  `Member`를 조회하면서 연관된 `Team`도 함께 조회함

  결과로 반환되는 것은 `Member`이고, `Team`은 조회 결과에 직접 드러나기보다는 `Member.team` 안에 채워짐

  **컬렉션 Fetch Join**

    ```java
    select t
    from Team t
    join fetch t.members
    ```

  `Team`을 조회하면서 `Team.members` 컬렉션도 함께 조회함

  다만 1:N 관계에서는 DB row가 자식 수만큼 늘어나므로, 같은 Team이 중복되어 조회될 수 있음

  이 경우 JPQL의 `distinct`를 함께 사용하는 경우가 많음

    ```java
    select distinct t
    from Team t
    join fetch t.members
    ```

  **일반 Join과의 차이**

    - 일반 Join

      조회 조건이나 필터링을 위해 조인

      연관 엔티티를 영속성 컨텍스트에 함께 로딩한다고 보장하지 않음

        ```java
        select m
        from Member m join m.team t
        where t.name = :teamName
        ```

    - Fetch Join

      연관 엔티티까지 함께 조회해서 객체 그래프를 초기화

      조회 후 연관 객체에 접근해도 추가 쿼리가 발생하지 않도록 만들 수 있음

        ```java
        select m
        from Member m join fetch m.team
        ```


    **사용 이유**
    
    - N+1 문제 해결
        
        필요한 연관 엔티티를 SQL 한 번으로 함께 조회
        
    - 지연 로딩 유지 + 필요한 곳만 즉시 조회
        
        엔티티의 기본 fetch 전략은 `LAZY`로 두고, 특정 조회에서만 Fetch Join으로 필요한 연관 데이터를 가져올 수 있음
        
    - 객체 그래프 유지
        
        조회한 엔티티의 연관 객체가 실제로 채워져 있어, 이후 비즈니스 로직에서 객체 탐색을 자연스럽게 사용할 수 있음
        
    
    **Fetch Join의 특징**
    
    - JPQL에서 동적으로 fetch 전략을 정하는 방법
        
        매핑에 고정된 글로벌 로딩 전략보다 조회 목적에 맞게 조절 가능
        
    - 글로벌 로딩 전략보다 우선
        
        연관관계가 `LAZY`로 설정되어 있어도 Fetch Join을 사용한 쿼리에서는 함께 조회됨
        
    - SQL 조인을 사용하지만 목적은 객체 그래프 로딩
        
        단순히 row를 합치는 것이 아니라, 연관 엔티티를 영속성 컨텍스트에 함께 로딩하는 것이 핵심
        
    
    **주의점**
    
    - 필요한 곳에만 사용
    - 컬렉션 Fetch Join은 중복 결과 발생 가능
    - 둘 이상의 컬렉션 Fetch Join은 지양
    - 컬렉션 Fetch Join과 페이징은 함께 사용 주의
    
    **사용하면 좋은 경우**
    
    - 화면/API에서 부모와 연관 엔티티를 함께 반드시 사용하는 경우
    - N+1 문제가 실제로 발생하는 조회
    - 객체 그래프 형태를 유지한 채 비즈니스 로직에서 연관 객체를 탐색해야 하는 경우
    
    **다른 방법을 고려하는 경우**
    
    - 여러 테이블을 조인해서 엔티티 모양과 다른 결과가 필요한 경우
        
        일반 join + DTO 조회가 더 적합할 수 있음
        
    - 대량 데이터 + 페이징이 중요한 경우
        
        Batch Size, DTO 조회, 쿼리 분리 등을 고려
        
    - 여러 컬렉션을 동시에 가져와야 하는 경우
        
        한 번에 Fetch Join으로 해결하려 하기보다 조회를 나누거나 다른 fetch 전략을 고려
        
    
    https://docs.hibernate.org/orm/5.2/userguide/html_single/chapters/fetching/Fetching.html
    
    https://ym1085.github.io/jpa/JPA-%ED%8E%98%EC%B9%98%EC%A1%B0%EC%9D%B8-%EB%A7%88%EB%AC%B4%EB%A6%AC/

- @EntityGraph란?

  **EntityGraph**

  JPA에서 특정 조회나 `find` 작업을 실행할 때, 어떤 필드와 연관 엔티티를 함께 가져올지 정의하는 fetch plan

  기본 fetch 전략을 바꾸지 않고도, 조회 상황에 맞게 필요한 연관 데이터만 즉시 로딩하도록 지정할 수 있음

  **@EntityGraph**

  Spring Data JPA에서 Repository 메서드에 EntityGraph를 쉽게 적용하기 위해 제공하는 어노테이션

  JPQL에 `join fetch`를 직접 작성하지 않아도, 함께 조회할 연관 필드를 선언적으로 지정할 수 있음

    ```java
    public interface TeamRepository extends JpaRepository<Team, Long> {
        @EntityGraph(attributePaths = {"members"})
        List<Team> findAll();
    }
    ```

  `Team`을 조회할 때 `members`도 함께 조회하도록 fetch plan을 지정한 것

  앞에서 설명한 N+1 문제를 줄이는 방법 중 하나로 사용할 수 있음

  **사용 이유**

    - JPQL 수정 없이 fetch 전략 지정

      Repository 메서드에 어노테이션만 붙여 연관 엔티티를 함께 조회 가능

    - 기본 fetch 전략 유지

      엔티티 매핑은 `LAZY`로 두고, 필요한 조회에서만 연관 데이터를 함께 가져올 수 있음

    - 재사용 가능한 fetch plan 구성

      자주 사용하는 조회 형태를 Named EntityGraph로 정의해 여러 곳에서 사용할 수 있음

    - Fetch Join 대안

      단순히 특정 연관관계를 함께 조회하는 경우 JPQL fetch join보다 간결하게 표현 가능


    **Named EntityGraph**
    
    엔티티 클래스에 `@NamedEntityGraph`를 선언해 이름 있는 fetch plan을 미리 정의하는 방식
    
    ```java
    @Entity
    @NamedEntityGraph(
        name = "Team.withMembers",
        attributeNodes = @NamedAttributeNode("members")
    )
    public class Team {
        @OneToMany(mappedBy = "team")
        private List<Member> members = new ArrayList<>();
    }
    ```
    
    ```java
    @EntityGraph(value = "Team.withMembers")
    List<Team> findAll();
    ```
    
    **동적 EntityGraph**
    
    Spring Data JPA에서는 `attributePaths`를 사용해 Repository 메서드에서 바로 fetch 대상 경로를 지정할 수 있음
    
    ```java
    @EntityGraph(attributePaths = {"members"})
    List<Team> findAll();
    ```
    
    `attributePaths`가 지정되면 이름 있는 EntityGraph를 사용하기보다, 해당 경로를 기준으로 동적 EntityGraph처럼 처리됨
    
    직접 속성뿐 아니라 `members.orders`처럼 중첩 속성도 지정 가능
    
    **Fetch Join과의 차이**
    
    - Fetch Join
        
        JPQL 안에 `join fetch`를 직접 작성
        
        조인 방식이나 조건을 명확히 제어하기 좋음
        
        ```java
        @Query("select t from Team t join fetch t.members")
        List<Team> findAllWithMembers();
        ```
        
    - EntityGraph
        
        쿼리와 fetch plan을 분리해서 작성
        
        Repository 메서드에 어노테이션으로 연관 로딩 범위를 지정
        
        ```java
        @EntityGraph(attributePaths = {"members"})
        List<Team> findAll();
        ```
        
    
    Fetch Join은 쿼리 안에서 직접 fetch를 지정하는 방식
    EntityGraph는 쿼리 실행 시 사용할 fetch plan을 별도로 지정하는 방식
    
    **주의점**
    
    - 복잡한 조건 제어에는 한계
    - 너무 많은 연관관계를 지정하면 성능 저하 가능
    - 컬렉션 조회 시 주의
    - 구현체별 SQL 확인 필요
    
    **사용하면 좋은 경우**
    
    - Repository 메서드 기반 조회에서 특정 연관관계를 함께 가져오고 싶은 경우
    - JPQL을 직접 작성하지 않고 N+1 문제를 줄이고 싶은 경우
    - 같은 쿼리에 상황별로 다른 fetch plan을 적용하고 싶은 경우
    - 엔티티의 기본 fetch 전략은 `LAZY`로 유지하면서 조회별 최적화를 하고 싶은 경우
    
    https://jakarta.ee/learn/docs/jakartaee-tutorial/current/persist/persistence-entitygraphs/persistence-entitygraphs.html
    
    https://docs.spring.io/spring-data/jpa/docs/current/api/org/springframework/data/jpa/repository/EntityGraph.html

- commit과 flush 차이점은?

  **flush**

  영속성 컨텍스트의 변경 내용을 DB에 SQL로 반영하는 작업

  쓰기 지연 SQL 저장소에 모아둔 `INSERT`, `UPDATE`, `DELETE` 쿼리를 DB로 보내고, 변경 감지를 통해 수정된 엔티티도 반영함

  단, flush는 트랜잭션을 끝내는 작업이 아님

  SQL이 DB에 전달되더라도 아직 commit되지 않았기 때문에, 이후 rollback하면 flush로 실행된 SQL 결과도 취소될 수 있음

    ```java
    transaction.begin();
    
    Member member = new Member("kim");
    entityManager.persist(member);
    
    entityManager.flush(); // INSERT SQL 실행
    
    transaction.rollback(); // flush된 INSERT도 롤백됨
    ```

  **commit**

  현재 트랜잭션을 종료하고, 트랜잭션 안에서 발생한 변경 내용을 DB에 확정하는 작업

  JPA에서는 commit을 호출하면 먼저 flush가 실행되고, 그 다음 DB 트랜잭션이 commit됨

    ```java
    transaction.begin();
    
    Member member = new Member("kim");
    entityManager.persist(member);
    
    transaction.commit(); // flush 실행 후 commit
    ```

  **차이점**

    - 역할

      flush : 영속성 컨텍스트의 변경 내용을 DB에 동기화

      commit : 트랜잭션을 종료하고 변경 내용을 확정

    - SQL 실행 여부

      flush : SQL이 DB에 전송됨

      commit : commit 전에 flush가 실행되어 SQL이 전송되고, 이후 트랜잭션이 확정됨

    - 트랜잭션 종료 여부

      flush : 트랜잭션 종료 X

      commit : 트랜잭션 종료 O

    - 롤백 가능 여부

      flush : flush 후에도 commit 전이라면 rollback 가능

      commit : commit 후에는 일반적으로 rollback 불가

    - 사용 목적

      flush : 현재까지의 변경 내용을 DB와 동기화해야 할 때

      commit : 작업 단위를 성공으로 확정할 때


    **flush가 일어나는 시점**
    
    - `em.flush()` 직접 호출
        
        개발자가 명시적으로 영속성 컨텍스트를 DB와 동기화
        
    - 트랜잭션 commit 시 자동 호출
        
        commit 전에 변경 내용을 DB에 반영해야 하므로 JPA가 자동으로 flush 호출
        
    - JPQL 실행 시 자동 호출
        
        JPQL은 DB를 직접 조회하므로, 쿼리 결과가 영속성 컨텍스트의 변경 내용과 어긋나지 않도록 실행 전에 flush가 호출될 수 있음
        
    
    ```java
    em.persist(new Team("teamA"));
    em.persist(new Team("teamB"));
    
    // JPQL 실행 전 flush가 발생할 수 있음
    List<Team> teams = em.createQuery("select t from Team t", Team.class)
            .getResultList();
    ```
    
    https://cheese10yun.github.io/jpa-flush/
    https://velog.io/@hoonrara/JPA%EC%97%90%EC%84%9C-flush-vs-commit-%EC%B0%A8%EC%9D%B4