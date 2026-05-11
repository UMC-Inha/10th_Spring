- 피어리뷰 (주니꺼)
![alt text](image.png)
    service를 command랑 queryService로 나누고, readOnly를 사용하여 최적화한 부분이 인상 깊습니다!

- 미션 스웨거 캡쳐
- **미션 기록**
    1. 리뷰 작성 쿼리
        
        ![alt text](image-1.png)
        
    2. [진행 중인/ 완료한] 나의 미션 보기
        
        ![alt text](image-2.png)
        
    3. 마이 페이지 화면 쿼리
        
        ![alt text](image-3.png)
        
    4. 홈 화면 쿼리

        ![alt text](image-4.png)
- JPA란?
    
    자바 객체와 관계형 데이터베이스 테이블을 매핑하여 데이터를 관리하는 ORM 기술 표준
    
    → 복잡한 SQL 작성 없이 객체지향적인 코드로 데이터베이스를 다룰 수 있게 해줌.
    
    개발자가 엔티티 클래스랑 매핑 어노테이션만 정의하면 쿼리 작성 없이 JPA가 엔티티 상태 변화에 따라 SQL을 자동으로 만들어 DB에 반영해준다.
    
    1. Entity 정의
        
        @Entity로 클래스를 선언하면 JPA가 관리하는 엔티티가 되고, 필드는 컬럼과 매핑
        
        ```java
        @Entity
        @Table(name = "member")
        public class Member {
        
            @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
            private Long id;
        
            private String name;
        
            private String email;
        
            protected Member() { } // JPA 기본 생성자
        
            public Member(String name, String email) {
                this.name = name;
                this.email = email;
            }
        
            // getter/setter 생략
        }
        ```
        
    2. Spring Data JPA Repository
        
        ```java
        public interface MemberRepository extends JpaRepository<Member, Long> {
        	List<Member> findByName(String name);
        	// 메서드 이름 규칙만 맞으면 쿼리 메서드 자동 생성
        }
        ```
        
        JpaRepository<엔티티, ID타입>를 상속받아 별도 구현 없이 save, findById, findAll, delete 같은 기본 CRUD 메서드 사용 가능
        
    3. Service에서 사용
    
    **장점**
    
    - 반복적인 CRUD SQL 작성을 없애줌
    - 객체 지향적인 코드 작성
    - 엔티티만 수정 하면 UPDATE SQL도 JPA가 처리
    - 캐시 및 성능 최적화 (1차 캐시, 지연 로딩 제공)
    
- N+1 문제란?
    
    예시 상황)
    
    Team (10개), Member(각 팀에 여러 명), Team과 Member는 1:N 관계
    
    기능 : 모든 팀의 이름을 출력하고, 그 팀에 속한 멤버 이름 출력하기
    
    1. 모든 팀 조회 (1번의 쿼리 발생)
        
        SELECT * FROM Team
        
    2. 각 팀의 회원 목록 찾기 (N번의 추가 쿼리)
        
        SELECT * FROM Member WHERE team_id = (1,2,..10);
        
    
    → why? : 지연로딩 때문에!
    
    팀을 조회할 때 멤버 데이터가 필요할지 아닐지 모르니까, 팀 정보만 가져옴. 그 뒤에 회원 데이터에 접근하는 순간 조회 쿼리 다시 생성
    
    JPQL은 기본적으로 Fetch 전략을 무시하고, JPQL만 가지고 SQL을 생성하기 때문
    
    → 데이터가 많이질수록 쿼리가 엄청나게 늘어서 서버 성능이 떨어짐.
    
    → 해결법 Fetch Join 등으로 처음부터 필요한 데이터들을 묶어서 한 번에 가져와야 함.
    
- 지연로딩과 즉시로딩의 차이는?
    
    **즉시 로딩**
    
    데이터를 조회할 때 연관된 객체까지 한꺼번에 모두 조회!
    
    `@MantToOne(fetch = FetchType.EAGER)`  
    
    → Team을 조회하게 되면, 그 순간 JPA가 내부적으로 JOIN 쿼리를 사용하여 Member 데이터까지 한 번에 다 가져와서 객체에 채움.
    
    - 연관된 테이블이 많아질수록 한 번의 조회에 많은 테이블이 조인되어 성능 저하가 일어남
    
    **지연 로딩**
    
    연관된 객체는 일단 비워두고, 실제로 그 데이터가 필요한 시점에 DB를 조회!
    
    `@ManyToOne(fetch = FetchType.LAZY)` 
    
    → Team을 조회하면 팀 정보만 가져오고, Member 자리에는 프록시(가짜 객체)를 넣어두고, 나중에 코드에서 멤버 정보가 필요할 때 DB에 쿼리 보냄
    
    - 불필요한 조인을 줄여 초기 조회 속도가 빠르다
    - 네트워크 리소스 효율적 사용
    
    두 경우 모두 N+1문제가 발생
    
    오히려 즉시 로딩의 경우 데이터 조회 시점에 즉시 N+1문제가 발생하기 때문에 제어가 어려움.
    
    그래서 가급적 지연로딩 사용!
    
- JPQL란?
    
    SQL과 달리 객체지향 모델에 대한 쿼리를 작성할 수 있는 쿼리 언어.
    
    SQL은 DB의 테이블을 보고 쿼리를 짠다면, JPQL은 엔티티 객체(클래스)를 보고 쿼리를 짠다.
    
    대소문자 구분을 엄격히 하고, 별칭이 필수이다.
    
    ```sql
    SELECT m.username FROM Member m WHERE m.age > 20;
    ```
    
    Member는 자바 클래스, username은 클래스의 필드이다.
    
    특징
    
    - 객체지향적이다.
        
        `m.team.name`  처럼 멤버와 연관된 팀의 이름을 바로 참조할 수 있다.(조인 대신 그래프 탐색)
        
    - DB를 바꿔도 적절한 SQL로 알아서 바꿔준다.
    
- Fetch Join란?
    
    JPQL에서 성능 최적화를 위해 제공하는 기능으로, 연관된 엔티티를 SQL 한 번에 조회하는 기능이다.
    
    아까 모든 팀 + 이름 출력하는 기능을 실행하면
    
    영속성 컨텍스트에 Team 객체 10개가 올라간다. 팀 안에 member는 프록시가 아니라 진짜 멤버 데이터임.
    
    team.getName을 하게 되면 영속성 컨텍스트에 Team 객체를 쓰기 때문에 추가 쿼리 발생 X
    
    기본은 지연로딩이고, 실행 시점에 즉시 로딩처럼!
    
    **장점**
    
    - N+1 문제 해결
    - 가져온 데이터가 진짜 엔티티이기 때문에, 트랜잭션 끝난 뒤에도 데이터를 자유롭게 사용 가능
    
    **단점**
    
    - 페이징 API 불가
    - 한 번에 두개 이상을 패치 조인할 수 없음(카테시안 곱)
    
- @EntityGraph란?
    
    어노테이션 기반으로 JPQL 쿼리 없이 fetch join을 사용할 수 있다(기본적으로 Left Outer Join)
    
    ```sql
    public interface MemberRepository extends JpaRepository<Member, Long> {
    
    		// ("select m from Member m left join fetch m.team")
    		@Override
        @EntityGraph(attributePaths = {"team"})
        List<Member> findAll();
    }
    ```
    
    Fetch Join은 Inner Join이 기본인데 반해, Left Outer Join이 기본.
    
    단순한 전체 조회 최적화에 유리
    
    **장점**
    
    - 가독성!
    - 편의성 findAll과 같은 메서드 오버라이딩해서 바로 사용 가능
    
    **단점**
    
    - 복잡한 쿼리, 조인 조건이 복잡하거나, 여러 단계의 엔티티 거쳐야 하면, Fetch Join 써야 댐
    
- commit과 flush 차이점은?
    - fluch()
        
        영속성 컨텍스트의 변경사항을 즉시 DB에 반영하는 역할
        
        DB와 영속성 컨텍스트 사이의 스냅샷 동기화 작업
        
        DB에 쿼리를 전송하기는 하지만, 최종 확정은 X
        
        플러시를 해도 영속성 컨텍스트가 비워지지 않고, 변경 내용을 전달만 함
        
    - commit
        
        현재 트랜잭션을 완료하고, 모든 변경 사항을 확정하는 역할
        
        내부적으로 flush() 실행하고, 실제로 트랜잭션 커밋
        
        트랜잭션이 종료되고, Rollback 불가