- JPA란?

  JPA(Java Persistence API)란,
  **자바 진영에서 ORM(Object-Relational Mapping) 기술의 표준으로 사용되는 인터페이스의 모음**

  ⇒ 즉, 실제로 동작하는 것이 아닌 인터페이스를 구현하여 사용해야 한다.

    - 구현체 종류
    - JPA표준을 엄격하게 준수할수록 다른 구현체로의 전환성을 높이고,
      표준 기능을 적용하는데 도움이 된다.
        - Hibernate
        - EclipseLink
        - DataNucleus
        - OpenJPA

  ![image.png](attachment:c17e5f16-7dae-4fbc-9b8f-98328abc0248:image.png)

  JPA 어노테이션(워크북 기준)

    - @Entity: DB 테이블과 일대일로 매칭되는 객체 단위, 클래스를 테이블과 매핑한다고 알려줌
    - @Table: 엔티티로 선언된 클래스에 매핑할 테이블이름,
      이 어노테이션이 없으면 클래스 이름을 테이블 이름으로 매핑한다.
    - @Column: DB 테이블에 있는 속성에 자바 필드를 매핑한다.
    - @Id: 클래스의 필드를 DB 테이블의 기본키로 매핑한다.
    - @GeneratedValue: 새로운 인스턴스 생성 시 마지막 값에서
      자동으로 +1 해줘야 하는 컬럼인 것을 알려준다. ex) PK
    - @Enumerated: Enum 형태로 되어있는 미리 정의되어 있는 코드 값이나 구분값을
      데이터 타입으로 사용할 때 작성한다.

    - 장단점
        - 생산성 향상
            - JPA에 객체를 전달만 하면 되므로 SQL, JDBC 를 사용하는 반복적인 작업을 JPA가 대신 처리한다.
        - 유지보수
            - SQL을 직접 다루면 필드 하나 추가해도 전부 수정해야 했지만, JPA는 이를 대신 처리한다.
        - 벤더 독립성
            - RDB는 같은 기능이라도 벤더마다 사용법이 다른데 JPA는 추상화된(인터페이스) 데이터 접근을 제공하므로 종속되지 않도록 도와준다.
        - 학습 곡선이 높음
            - 영속성 컨텍스트를 이해하지 못하면 잘 활용하지 못할 수 있다.
            - 관계형 DB의 맵핑 방법도 학습해야 한다.
        - 속도 저하 가능성
            - 복잡하고 무거운 쿼리는 속도를 위해 SQL문을 작성하는 것이 나을 수도 있다.

- N+1 문제란?

  연관 관계에서 발생하는 이슈로 연관 관계를 가지는 엔티티를 조회할 경우에
  데이터 개수(N)만큼 조회 쿼리가 추가로 발생하여 데이터를 읽어오는 문제를 말한다.

  **⇒ 불필요한 쿼리 수행은 통신 비용과 지연을 증가시켜 성능을 저하시킬 수 있다!**

    - 지연 로딩에서도 발생한다.
        - 사용되지 않는 엔티티를 프록시 객체로 두었다.
        - 데이터에 접근하는 순간, N+1 문제가 발생한다.

  **발생이유**

  JpaRepository에 정의한 인터페이스 메소드 실행

    1.  JPA가 메서드 이름을 분석해서 JPQL생성
        ⇒ JPQL은 특정 SQL에 종속되지 않고 엔티티 객체와 필드 이름을 가지고 쿼리를 보낸다.
    2. findAll() 메소드를 수행하였을 때 해당 엔티티를 조회하는
       <select * from 테이블명> 쿼리만 실행한다.
       ⇒JPQL 입장에서는 연관관계 데이터를 무시하고 해당 엔티티 기준으로 쿼리를 조회한다.
    3. **FetchType으로 지정한 시점**에 조회를 별도로 호출하게 된다.(EAGER이든 LAZY이든 발생!)

- 지연로딩과 즉시로딩의 차이는?

  FetchType이란, JPA가 하나의 Entity를 조회할 때 연관관계에 있는 객체들을 어떻게 가져올 지
  나타내는 설정값이다.

    - **fetch = fetchType.EAGER 즉시로딩**
        - 데이터를 조회할 때, 연관된 모든 객체의 데이터까지 한 번에 불러오는 것이다.
        - ex) 게시물 10개, 게시물 1개에 달린 댓글 여러 개
            - 애플리케이션 단에서 게시물 10개를 요청하면 DB에서
              게시물 10개를 조회하는 쿼리(1)와 동시에 댓글(10개의 게시물)까지 다 준다고 생각

                ```sql
                SELECT * FROM post; //게시글 10개 조회 - 1번
                SELECT * FROM comment WHERE post_id = 1; //1번 게시글의 댓글 조회
                SELECT * FROM comment WHERE post_id = 2; //2번 게시글의 댓글 조회
                ,,,
                ,,
                ,
                ```
              
    - **fetch = fetchType.LAZY 지연로딩**
      - 필요한 시점에 연관된 객체의 데이터를 불러오는 것이다. 
        - ex) 게시물 10개, 게시물 1개에 달린 댓글 여러 개
        - 게시글 10개 조회 쿼리(1) / 나중에 댓글 데이터 사용 시 쿼리가 **1번씩** 발생

- JPQL란?

  **Java Persistence Query Language**

  SQL을 기반으로 한 객체 모델용 쿼리 언어

    - SQL과 매우 유사한 형태지만, DB의 테이블과 컬럼이 아닌 자바 클래스와 객체에 작업을 수행한다.
    - 엔티티를 대상으로 쿼리를 수행한다고 생각하자

    - 예시

        ```sql
        Query query = em.createQuery(
        		"select u from UserEntity u where u.id = :id"
        );
        ```

    - 특징 & 장점
        - 기본적인 연산 지원
            - select, update, delete 등 기본적인 연산 지원, 키워드 제공
        - 객체지향 쿼리 언어
            - 쿼리 결과를 객체 또는 객체의 컬렉션으로 직접 반환받을 수 있다.
        - 타입 안정성 제공
            - **컴파일 오류**를 활용할 수 있다.

    - Spring Data JPA와의 차이
        - Spring Data JPA에서 제공하는 인터페이스로 JPA를 아주 쉽게 사용할 수 있다.
        - 인터페이스 생성만으로 간단하게 CRUD를 사용할 수 있다.
        - 복잡한 쿼리는 JPQL이 더 효율적이다.

    - JPQL쿼리 2가지 방식
        - TypedQuery: 반환하는 타입이 명확할 떄 사용하는 클래스
            - 미리 타입을 지정하므로 컴파일 오류 활용 가능

                ```sql
                TypedQuery<UserEntity> typedQuery = em.createQuery("~");
                
                ```

        - Query: 반환하는 타입이 명확하지 않을 떄 사용하는 클래스
            - 다양한 타입 반환, 런타임 시점에 오류 체크

                ```sql
                Query query = em.createQuery("~");
                Object result = query.getSingleResult();
                ```
      
    - 쿼리 결과 조회 방식
      - getSingleResult()
        - 쿼리의 결과로 단일 엔티티 객체 반환 → 없거나 2개 이상이면 예외 발생
      - getResultList()
        - 쿼리의 결과를 List 형태의 객체로 반환 → 없으면 빈 리스트 반환
    
    - 단점
        - 동적 쿼리 사용 어려움
            - 실행 시점에 SQL문이 결정되는 쿼리
        - SQL의 모든 기능 사용 못함
        - 복잡한 JOIN 문제


- Fetch Join란?

  JPQL에서 성능 최적화를 위해 제공하는 기능이다.

  SQL의 조인 종류는 아님!

  ⇒연관된 엔티티나 컬렉션을 쿼리문 한 번으로 함께 조회하는 기능

    - 사용
        - join fetch 명령어로 사용한다.

            ```sql
            String query "select b from Book b join fetch b.library";
            
            List<Book>books = em.createQuery(query, Book.class).getResultList();
            
            for(Book book: books){
            	System.out.println(book.getLibrary());
            }
            ```

        - JOIN 쿼리문이 나가면서 데이터가 함께 조회된다.
          ⇒ 추가적인 쿼리가 나가지 않는다.
        - 만약 컬렉션에서 사용한다면 DISTINCT 명령를 통해 중복 데이터를 거를 수 있다.

    - 특징
        - fetchType은 엔티티에 직접 적용하는 로딩 전략으로 글로벌 로딩 전략이라고 부른다.
        - fetch join은 글로벌 로딩보다 우선시된다.
          ⇒ LAZY로 설정해도 fetch join을 사용하면 데이터가 즉시 조회되는 결과를 가져오게 된다.
        - 글로벌 로딩 전=LAZY, 최적화 필요 시 = fetch join

    - 장단점
        - fetch join 대상에 별칭을 줄 수 없다. (지원하는 곳도 있음)
        - 둘 이상의 컬렉션을 fetch할 수 없다. (컬렉션 * 컬렉션 의 cartesian product가 만들어짐)
        - 페이징 API를 사용할 수 없다. (하나의 쿼리문으로 데이터를 가져옴)
        - N+1 문제를 해결할 수 있다.
        - 단일 쿼리 조회를 이용 → 객체 그래프 일관성을 유지할 수 있다.

- @EntityGraph란?

  Spring Data JPA에서 JPA가 제공하는 엔티티 그래프 기능을 편리하게 사용하도록 제공하는 기능이다.

  ⇒ JPQL로 fetch join을 직접 작성하지 않고 @EntityGraph 어노테이션을 붙임으로서 **fetch join을 사용**

  ex)Member 조회할 때 Team도 같이 조회하는 경우

    ```sql
    @EntityGraph(attributePaths = {"team"})//연관된 엔티티 지정
    List<Member> findAll();
    ```

    - 주의점
        - @EntityGraph는 left outer join만을 지원한다.

- commit과 flush 차이점은?

  영속성 컨텍스트 ⇒ Entity 객체를 영속성 상태로 관리하는 공간

  “**영속성**”: DB와 동기화하여 오래 지속 되도록 하는 것

  JPA에서는 EntityManager를 통해 Persistence Context에 접근할 수 있다.

    - persist()
        - 1차 캐시 저장소에 저장된다.
        - DB에 들어간 건 아니다.
        - SQL은 쓰기 지연 저장소에 저장된다.
    - flush()
        - persist()로 준비한 단계, 즉 영속성 컨텍스트의 변경 내용을 DB와 동기화
        - 아직 Context가 비워지지 않음 → 우리는 확인 가능하다.
          만약 옆에 있는 동료가 DB를 조회한다면? → 아직 변경 결과 나오지 않음
        - **SQL실행만 하고 트랜잭션 유지**
    - commit()
        - DB에 실제 반영!
        - 내 Context 에서 뿐만 아니라 다른 사람도 반영 결과를 볼 수 있다. → 영속성을 가지게 된다.
        - **flush() 실행 후 트랜잭션 종료**

    - flush가 자동 실행되는 경우
        - commit()을 호출할 때 내부적으로 자동 flush() 호출된다.
        - JPQL실행 시 자동 실행된다.
        - flush() 모드 설정 → JPA 기본 설정은 AUTO모드이다.

            ```sql
            em.setFlushMode(FlushModeType.AUTO); // (기본값)
            
            ```