## @BatchSize

Hibernate에서 연관 엔티티나 컬렉션을 조회할 때 발생하는 N + 1 문제를 완화하기 위한 설정이다. 한 버에 로딩할 프록시/컬렉션 개수를 지정하여 DB 쿼리 횟수를 줄인다.

### 동작 방식

BatchSize = 10 설정 시,

```sql
기존: SELECT * FROM member WHERE team_id = 1
     SELECT * FROM member WHERE team_id = 2
     SELECT * FROM member WHERE team_id = 3
     ... (N번)
```

```sql
적용 후: SELECT * FROM member WHERE team_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
         SELECT * FROM member WHERE team_id IN (11, 12, ...)
         ... (N/10번)
```

→ 만약 Team이 100개라면 기존 100번 쿼리가 10번으로 줄어든다.

### 적용 방법

**1️⃣ 컬렉션에 적용 (@OneToMany)**

가장 일반적인 사용 방식으로, 컬렉션을 로딩할 때 IN 절로 묶어 조회한다.

```java
@Entity
public class Team {
    @Id
    private Long id;

    @OneToMany(mappedBy = "team")
    @BatchSize(size = 100) // ← 한 번에 100개씩 IN 절로 조회
    private List<Member> members;
}
```

**2️⃣ 엔티티 클래스에 적용**

엔티티 자체가 프록시로 로딩될 때 IN 절로 묶어 조회한다.

```java
@Entity
@BatchSize(size = 100) // ← 이 엔티티가 프록시로 로딩될 때 적용
public class Member {
    @Id
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    private Team team;
}
```

**3️⃣ 글로벌 설정**

모든 컬렉션과 엔티티에 일괄 적용할 수 있다. 개별 `@BatchSize`가 있으면 그게 우선된다.

```java
spring:
  jpa:
    properties:
      hibernate:
        default_batch_fetch_size: 100
```

보통 BatchSize는 **100~500**로 설정한다고 한다. IN 절에 들어가는 ID 수가 너무 많으면 DB에 부담이 생기고, 너무 적으면 쿼리가 많아진다.

## transform - groupBy

- 쿼리의 결과를 원하는 결과로 가공하여 `Map<key, value>` 형태로 한번에 반환할 수 있는 기능이다.
- 이때의 groupBy는 SQL의 groupBy와는 의미가 다르며, transform과 함께 사용해야 의미가 있다.
    - groupBy로 사용한 필드는 Key로 매핑되며 as를 통해 매핑될 value값을 선언한다.

```java
@Override
public Map<String, List<Member>> getMembersByFoodName {
		return query.from(memberFood)
								.join(memberFood.member, member)
								.transform(GroupBy.groupBy(memberFood.food.type).as(list(member)));
}
```

### 여기서 transform-groupBy를 사용하지 않으면?!

```java
@Override
public List<MemberFoodDto> getMemberFoodDtos {
		return query.select(
												new QMemberFoodDto(
													member,
													memberFood.type
												)
									.from(memberFood)
									.join(memberFood.member, member).fetchJoin()
									.fetch();
}
```

```java
public Map<String, List<Member>> groupingMembersByFoodName {
		return memberFoodRepository.getMemberFoodDtos()
																.stream()
																.collect(Collectors.groupingBy(MemberFoodDto::getType,
																Collectors.mapping(
																		MemberFoodDto::getMember,
																		Collectors.toList()
																)));
}
```

- transform과 groupBy를 함께 사용하면 이 코드들을 한번에 구현할 수 있다.!

## order by

- order by를 사용하여 특정 컬럼을 기준으로 정렬하고자 했을 때, NULL 값이 포함되어 있다면 어떻게 처리하는 지는 DBMS에 따라 다르다.

|  | 오름차순 | 내림차순 |
| --- | --- | --- |
| NULL 처음 | My SQL, SQLite | PostgreSQL, Oracle |
| NULL 마지막 | PostgreSQL, Oracle | MySQL, SQLite |

### QueryDSL을 사용했을 때

- QueryDSL을 사용했을 때, 함수를 통해 NULL값의 위치를 지정할 수 있다.
- null을 맨 마지막으로 보내고 싶을 경우

```sql
List<Member> members = query.select(member.name)
														.from(member)
														.orderBy(member.username.asc().nullsLast())
														.fetch();
```

→ nullsLast() 함수를 사용해 NULL값이 존재할 경우 마지막으로 보낼 수 있다. 

- null을 맨 앞으로 보내고 싶을 경우

```sql
List<Member> members = query.select(member.name)
														.from(member)
														.orderBy(member.username.asc().nullsFirst())
														.fetch();
```

## 카테시안 곱 (Cartesian Product)

두 개 이상의 테이블을 JOIN할 때 ON 조건 없이 조합 가능한 모든 행의 쌍을 반환하는 것이다. SQL에서는 `CROSS JOIN` 또는 WHERE 절 없는 `JOIN`으로 발생한다.

### Hibernate/JPA에서 카테시안 곱이 문제되는 경우

JPA에서는 Fetch Join으로 여러 컬렉션을 동시에 로딩할 때 카테시안 곱이 발생한다.

```java
// Order 1건이 orderItems 3개, coupons 2개를 가진다고 가정

em.createQuery(
    "SELECT o FROM Order o " +
    "JOIN FETCH o.orderItems " +
    "JOIN FETCH o.coupons"  // 두 컬렉션 동시 Fetch Join
).getResultList();
```

→ Order 1건이 3 * 2 = 6 행으로 불어난다. Hibernate가 이를 중복 제거하려 하지만, 컬렉션이 두 개 이상이면 정확히 매핑하지 못해 `MultipleBagFetchException` 이 발생한다.

### 페이징 + 카테시안 곱

컬렉션 Fetch Join + 페이징을 동시에 사용하면 Hibernate 가 경고를 발생시키며 메모리에서 페이징을 수행한다.

카테시안 곱으로 행이 뻥튀기된 상태에서 DB 레벨 페이징을 적용하면 잘못된 결과가 나오기 때문에, Hibernate는 전체 데이터를 메모리에 올린 뒤 페이징 한다. 따라서 데이터가 많으면 OOM(OutOfMemoryError)위험이 있다.

## MultipleBagFetchException

Hibernate에서 두 개 이상의 컬렉션을 동시에 Fetch Join할 때 발생하는 예외이다.

**Bag란?**

Hibernate에서 컬렉션 타입을 분류하는 방식이 있다.

| Hibernate 타입 | Java 타입 | 특징 |
| --- | --- | --- |
| Bag | `List` | 중복 허용, 순서 없음 |
| Set | `Set` | 중복 불허 |
| List | `List` + `@OrderColumn` | 순서 보장 |
| Map | `Map` | 키-값 구조 |

### 왜 Bag 두 개를 동시에 Fetch Join하면 안 되는가?

컬렉션 Fetch Join은 행을 뻥튀기시킨다.

Bag는 순서도 없고 중복도 허용하기 때문에, Hibernate가 행들을 보고 정확하게 구분해서 매핑할 방법이 없다. 결과를 신뢰할 수 없으므로 아예 예외를 던지는 것이다.

### 해결 방법

1️⃣ `Set`으로 변경

Set은 중복을 허용하지 않기 때문에 Hibernate가 결과를 정확히 매핑할 수 있다.

단, Set은 equals(), hashCode() 가 올바르게 구현되어 있어야 하고, 카테시안 곱 자체는 여전히 발생하므로 데이터가 많으면 성능 문제를 해결할 수 없다.

2️⃣ `@OrderColumn` 추가

List 에 `@OrderColumn`을 붙이면 Hibernate가 Bag가 아닌 순서 있는 List로 취급한다.

```java
@OneToMany(mappedBy = "order")
@OrderColumn(name = "order_item_order")
private List<OrderItem> orderItems; // 이제 Bag이 아님 → 예외 해결
```

3️⃣ `Fetch Join`을 하나만 사용하고 나머지는 BatchSize

근본적인 해결책이며 실무에서 가장 많이 선택하는 방식이다.
