## Hibernate 2차 캐시란?

Hibernate에서 SessionFactory 범위로 공유되는 캐시로, 여러 Session과 트랜잭션에 걸쳐 동일한 데이터를 재사용하여 DB접근을 줄이는 기능이다.

1차 캐시가 Session 단위로 동작하는 것과 달리, 2차 캐시는 애플리케이션 전체에서 공유된다.

### 2차 캐시의 동작 방식

1. 영속성 컨텍스트 → 2차 캐시 조회
2. 캐시 미스 → DB 조회 후 결과를 2차 캐시에 저장
3. 이후 요청 → 2차 캐시에서 복사본 생성 후 반환

**왜 복사본을 반환할까?**

만약 복사본 없이 캐시에 저장된 객체의  참조값을 그대로 반환한다면 여러 트랜잭션에서 같은 객체를 수정하는 문제가 발생할 수 있다.

즉, 여러 Session이 동시에 같은 객체를 수정하면 캐시가 오염되고 다른 Session에도 의도치 않은 변경이 전파된다. 이를 방지하기 위해 복사본을 만들어 반환하는 것이다. Lock을 걸어 동시성 문제를 해결할 수 있지만, 성능 개선의 이점을 가져갈 수 없기 때문에 복사본을 이용한다.

### Hibernate에서 지원하는 2차 캐시 종류

**1️⃣ Entity 캐시**

가장 기본적인 캐시로, 엔티티 단위로 캐싱한다. @Cache를 엔티티 클래스에 붙여 적용한다.

```java
@Entity
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE) // ← 엔티티 캐시 적용
public class Member {
    @Id
    private Long id;
    private String name;
}
```

**2️⃣ Collection 캐시**

엔티티 캐시와 별개로, @OneToMany 등의 연관 컬렉션도 따로 캐시 설정을 해줘야 한다.

컬렉션 캐시는 컬렉션에 속한 엔티티의 ID 목록만 저장한다. 실제 엔티티 데이터는 엔티티 캐시에서 가져온다. 따라서 엔티티 캐시 없이 컬렉션 캐시만 사용하면 ID마다 DB 조회가 발생하므로 반드시 엔티티 캐시와 함께 사용해야한다.

```java
@Entity
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class Team {
    @Id
    private Long id;

    @OneToMany(mappedBy = "team")
    @Cache(usage = CacheConcurrencyStrategy.READ_WRITE) // ← 컬렉션 캐시 별도 적용 필수
    private List<Member> members;
}
```

**3️⃣ Query 캐시**

`em.find()` 가 아닌 JPQL/HQL 쿼리 결과를 캐싱한다. 쿼리 문자열 + 파라미터를 키로 사용한다.

쿼리 캐시도 내부적으로는 결과 엔티티의 ID 목록만 저장하며, 실제 데이터는 엔티티 캐시에서 조회한다. 마찬가지로 엔티티 캐시 없이 단독 사용 시 효과가 없다.

하지만 쿼리 대상 테이블에 변경이 발생하면 해당 테이블과 연관된 쿼리 캐시 전체가 무효화된다. 쓰기가 빈번한 테이블에는 오히려 역효과가 날 수 있다.
