## Page, Slice 란?

**Spring Data JPA에서 제공하는 객체**로, **전체 데이터 중 일부를 원하는 정렬 방식으로 클라이언트에게 보여주기 위한 역할**을 한다. 

### Slice

**Slice는 페이징 결과를 담는 인터페이스로, 현재 페이지의 데이터와 다음 페이지 존재 여부만을 제공**한다. 

```java
public interface Slice<T> extends Streamable<T> {
 
    int getNumber();
 
    int getSize();
 
    int getNumberOfElements();
    
    List<T> getContent();
 
    boolean hasContent();
    
    // ...
}
```

내부적으로 pageSize + 1 개를 조회한 뒤, 마지막 데이터를 제거하고 반환한다. 추가로 조회된 1개의 데이터가 존재하면 `hasNext() = ture`, 존재하지 않으면 `hasNext() = false`를 반환하는 방식으로 다음 페이지 여부를 판단한다.

Page와 다르게 `COUNT` 쿼리를 실행하지 않기 때문에 쿼리가 1번만 나가고, 전체 데이터 수나 전체 페이지 수는 알 수 없다.

### Page

**Page는 Slice를 상속받은 인터페이스로, Slice의 기능에 더해 전체 데이터 수와 전체 페이지 수까지 제공**한다.

```java
public interface Page<T> extends Slice<T> {
    
    long getTotalElements();
    
    int getTotalPages();
    
    //...
}
```

내부적으로 데이터 조회 쿼리와 함께 `COUNT`쿼리를 추가로 실행하여 전체 데이터 수를 가져온다. 이러한 이유로 쿼리가 2번 나가지만, 전체 페이지 수와 전체 데이터 수를 정확히 알 수 있다.

여러 테이블의 `join fetch`가 복잡하게 일어나는 쿼리 결과를 Page객체를 통해 반환하는 경우, `COUNT` 쿼리 비용이 커질 수 있어 커스텀해서 사용하기도 한다.

## Pageable과 PageRequest

### Pegeable

페이징 요청 정보를 담는 인터페이스로, 페이지 번호, 페이지 크기, 정렬 조건을 포함한다. Repository 메서드의 파라미터로 전달하여 페이징 조회를 수행한다.

### PageRequest

Pegeable 인터페이스의 구현체로, 실제로 페이징 요청 객체를 생성할 때 사용한다.

```java
// 기본 생성 — 0번 페이지, 10개씩
PageRequest pageRequest = PageRequest.of(0, 10);

// 정렬 조건 포함 — id 기준 내림차순
PageRequest pageRequest = PageRequest.of(0, 10, Sort.by("id").descending());

// 여러 정렬 조건
PageRequest pageRequest = PageRequest.of(0, 10,
    Sort.by("createdAt").descending()
        .and(Sort.by("id").ascending())
);
```

→ 이렇게 생성한 PageRequest 객체를 Repository 메서드 파라미터로 전달하면, 해당 정보를 이용해 Spring Data JPA가 페이징 조회를 수행한다.

---

### 🌱 Spring Data JPA에서의 활용

**1️⃣ Page 활용 - 페이지 번호 기반 (오프셋 페이징)**

반환 타입을 **Page<T>**로 선언하면 Spring Data JPA가 자동으로 COUNT 쿼리까지 실행해준다.

```java
// Service
PageRequest pageRequest = PageRequest.of(0, 10);
Page<Mission> result = missionRepository.findByStoreId(storeId, pageRequest);

// Repository
public interface MissionRepository extends JpaRepository<Mission, Long> {
    Page<Mission> findByStoreId(Long storeId, Pageable pageable);
}
```

**2️⃣ Slice 활용 - 무한 스크롤 (커서 페이징)**

반환 타입을 **Slice<T>**로 선언하면 Page와 다르게 `COUNT` 쿼리가 발생하지 않는다.

```java
// Service
PageRequest pageRequest = PageRequest.of(0, 10);
Slice<Mission> result = missionRepository
    .findByStore_IdAndIdLessThanOrderByIdDesc(storeId, idCursor, pageRequest);
    
// Repository
public interface MissionRepository extends JpaRepository<Mission, Long> {
    Slice<Mission> findByStore_IdAndIdLessThanOrderByIdDesc(
        Long storeId, Long idCursor, Pageable pageable
    );
}
```

커서 페이징을 구현할 때 Slice객체를 사용하는 이유는 `hasNext`을 자동으로 판단해주기 때문이다. 따라서 nextCursor계산, 커서 파싱, 복합 커서 사용 시 JPQL 작성 등은 개발자가 직접 처리해야한다.

→ Page 객체를 이용해 오프셋 페이징을 구현할 때보다 개발자가 직접해야하는 일이 많다.

**3️⃣ @Query와 Page/Slice 함께 사용하기**

`@Query`를 사용할 때 `join fetch`가 포함되어 있으면 JPA가 자동 생성하는 `COUNT` 쿼리에도 불필요한 `join fetch`가 포함된다. 이 경우 countQuery를 따로 작성하여 성능을 최적화할 수 있다.

```java
@Query(
    value = """
        select mm
        from MemberMission mm
        join fetch mm.mission m
        join fetch m.store s
        where mm.member.id = :memberId
            and mm.status in :statuses
        """,
    countQuery = """
        select count(mm)
        from MemberMission mm
        where mm.member.id = :memberId
            and mm.status in :statuses
        """
)
Page<MemberMission> findMyMissions(
    @Param("memberId") Long memberId,
    @Param("statuses") List<MemberMissionStatus> statuses,
    Pageable pageable
);
```

## Stream API란?

람다식을 이용한 기술 중에 하나로 데이터 소스(컬렉션, 배열 등)를 조작 및 가공, 변환하여 원하는 값으로 변환해주는 인터페이스 이다.

Stream API는 데이터를 추상화하고, 처리하는 데 자주 사용되는 함수들을 제공한다.

### 람다식(Lambda Expression)이란?

**함수를 하나의 식으로 표현한 함수형 인터페이스 함수**로, 람다식으로 표현하면 메서드의 이름이 없기 때문에 익명 함수의 한 종류이기도 하다.

### Stream API 특징

**1️⃣ 원본의 데이터를 변경하지 않는다.**

- Stream API는 원본의 데이터를 조회하여 별도의 Stream을 생성한다.
- 원본의 데이터로부터 읽기만 할 뿐이며, 정렬이나 필터링 등의 작업은 별도의 Stream요소들에서 처리 된다.
    
    ```java
    String[] nameArr = {"IronMan", "Captain", "Hulk", "Thor"}
    List<String> nameList = Arrays.asList(nameArr);
    
    // 별도의 스트림을 생성함.
    Stream<String> nameStream = nameList.stream();
    Stream<String> arrayStream = Arrays.stream(nameArr);
    
    // 복사된 데이터를 정렬하여 출력함
    nameStream.sorted().forEach(System.out::println);
    arrayStream.sorted().forEach(System.out::println);
    ```
    

**2️⃣ 일회용이다.**

- Stream API는 일회용이기 때문에 **한번 사용이 끝나면 재사용이 불가능**하다.
- Stream이 또 필요한 경우에는 Stream을 다시 생성해야 한다.
- 만약 닫힌 Stream을 다시 사용한다면 `IllegalStateException`이 발생한다.
    
    ```java
    userStream.sorted().forEach(System.out::print);
    
    // 스트림이 이미 사용되어 닫혔으므로 에러 발생
    int count = userStream.count();
    ```
    

**3️⃣ 내부 반복으로 작업을 처리한다.** 

- for이나 while문 같은 반복 문법을 메서드 내부에 숨기고 있기 때문에 간결한 코드 작성이 가능하다.
    
    ```java
     // 반복문이 forEach라는 함수 내부에 숨겨져 있다.
    nameStream.forEach(System.out::println); 
    ```
    

### Stream 연산

1. **Stream 생성**
    
    ```java
    Stream<Object> emptyStream = Stream.empty();       // 빈 스트림
    Stream<String> listStream = nameList.stream();     // 컬렉션으로부터
    Stream<String> arrayStream = Arrays.stream(nameArr); // 배열로부터
    ```
    
2. **중간 연산**
    
    중간 연산은 Stream을 반환하기 때문에 체이닝이 가능하고, 최종 연산이 호출되기 전까지 호출되지 않는다.
    
    - `filter()` → 조건에 맞는 요소만 필터링한다.
    - `map()` → 요소들을 원하는 값으로 변화하여서 반환하기 위해 사용된다. (1:1 변환)
        
        ```java
        list.stream()
                .map(String::toUpperCase) // 각 요소를 대문자로 변환
                .forEach(System.out::println);
        ```
        
    - `sorted()` → 요소들에 대해서 오름/내림 차순을 수행하여 반환하기 위해 사용된다.
    - `distinct()`, `flatMap()`, `limit()`, `skip()` 등
3. **최종 연산**
    - `forEach()` → 배열 혹은 리스트 내에서 순회하며 요소에 대한 값을 출력하거나 새로운 형태로 변환하여 구성하기 위한 목적으로 사용된다. (반환값 없음)
    - `reduce()` → 요소들을 하나의 값으로 반환한다.
    - `collect()` → Stream의 요소를 컬렉션 등으로 수집한다.
        
        ```java
        List<String> result = list.stream()
                .filter(s -> s.length() > 3)
                .collect(Collectors.toList());
        ```
        

### Collectors 인터페이스

자바 StreamAPI에서 제공하는 기능 중 하나로, Stream에서 수행한 연산 결과를 수집하여 다양한 Collection을 반환할 수 있는 메서드를 제공하는 클래스이다.

- `toLIst()`: Stream을 List로 변환한다.
    
    ```java
    // Java 16 이전
    List<String> list = stream.collect(Collectors.toList());
    
    // Java 16 이후 — 바로 .toList() 사용 가능
    List<String> list = stream.toList();
    ```
    
    → `.toList()`로 반환된 리스트는 수정이 불가능하다. 따라서 `add()`, `remove()` 등 수정 시 예외가 발생하므로 주의해야 한다.
    
- `toSet()`: Stream을 Set으로 변환한다. 중복을 제거하고 유일한 값들로만 구성된 컬렉션을 반환한다.
    
    ```java
    List<Integer> numbers = Arrays.asList(1, 2, 3, 4, 5, 5); 
    Set<Integer> uniqueNumbers = numbers.stream().collect(Collectors.toSet());
    
    System.out.println(uniqueNumbers): // 출력 결과: [1, 2, 3, 4, 5]
    ```
    
- `toMap()`: 매핑 함수와 값 추출 함수를 인수로 받으며 Stream을 Map으로 변환한다.
    - 만약 keyMapper에서 중복이 발생한 경우, IllegalStateException이 발생한다.
    - 세 번째 인자로 mergeFunction을 넣으면 중복 key를 처리할 수 있다.
    
    ```java
    List<String> fruits = Arrays.asList("apple", "banana", "cherry");
    Map<String, Integer> fruitLengthMap = fruits.stream().collect(Collectors.toMap(
    																			fruit -> fruit, fruit -> fruit.length()));
    System.out.println(fruitLengthMap(); // 출력 결과: {banana=6, cherry=6, apple=5}																			
    ```
    
- `joining()`: Stream의 문자열 요소를 결합하여 하나의 문자열로 반환한다.
    
    ```java
    List<String> strings = Arrays.asList("ha", "hai", "haaaai");
    String result = strings.stream().collect(Collectors.joining(", "));
    System.out.println(result); // 출력 결과: "ha, hai, haaaai"
    
    result = strings.stream().collect(Collectors.joining(", ", "[", "]"));
    System.out.pringln(result); // 출력 결과: "[ha, hai, haaaai]"
    ```
    

### 🌱 Stream 실제 활용 예시

1. **엔티티 리스트 → DTO 리스트 변환**
    
    Repository에서 조회한 엔티티 리스트를 응답 DTO 리스트로 변환할 때 `map()`과 `toList()`를 조합하여 많이 사용한다.
    
    ```java
    List<MissionResDTO.MissionListDto.MissionDto> missionDtos = results.stream()
            .map(mm -> MissionResDTO.MissionListDto.MissionDto.builder()
                    .memberMissionId(mm.getId())
                    .missionId(mm.getMission().getId())
                    .missionDescription(mm.getMission().getDescription())
                    .missionPoints(mm.getMission().getPoints())
                    .missionStatus(mm.getMissionStatus())
                    .storeId(mm.getMission().getStore().getId())
                    .storeName(mm.getMission().getStore().getName())
                    .build())
            .toList();
    ```
    
2. **집계**
    
    리스트의 요소들을 합산하거나 평균, 최댓값 등을 계산할 때 사용한다.
    
    ```java
    // 주문 목록에서 총 금액 합산
    int totalPrice = orders.stream()
        .mapToInt(Order::getPrice)
        .sum();
    ```

## 객체 그래프 탐색이란

**객체가 서로 연관 관계로 연결되어 있을 때**, 한 객체를 시작 점으로 **다른 객체까지 참조를 따라가며 원하는 데이터를 조회하는 과정**을 말한다.

**즉, 객체 = 노드(node), 연관 관계 = 간선(edge) → Graph**

### 예시

```java
class Review {
    @ManyToOne
    private Member member;
}

class Member {
		private String name;
}
```

- `review.getMember().getName();` → **객체 그래프 탐색**
- `memberRepository.findById().getName()` → 레파지토리를 이용한 탐색, Member의 id를 직접 알고 있어야한다.

### 객체 그래프 탐색의 장단점

원하는 데이터를 별도의 쿼리를 사용하지 않고 메서드 체이닝으로 간편하게 접근할 수 있으며, 객체지향적인 코드 작성이 가능하다.

지연 로딩 사용 시에 N + 1 문제가 발생할 수 있다.

- `review.getMember()` → 여기서는 JPA가 Member의 **프록시 객체로 반환**한다. (실제 DB 조회는 일어나지 않음)
- 이후에 `.getName()` 이 호출되면, `select * from member where member_id = ?` 쿼리가 추가로 날아가서 해당 객체의 이름을 불러온다.
- 만약 여기서 10개의 리뷰를 조회한다면? → 추가 쿼리도 10번 실행됨! → **N + 1** 문제
    
    ```java
    List<Reviews> reviews = reviewRepository.findAll(); -> 1번 쿼리
    
    for(Review r : reviews) {
    		r.getMember().getName();  -> 추가 쿼리 N 번 발생
    } 
    ```
    
    → 따라서 객체 그래프 탐색을 이용할 때 발생할 수 있는 N + 1 문제에 대해 미리 예측하고 대비해야한다!

## @Valid란?

RestController에서 `@RequestBody` 객체로 들어오는 값을 검증할 수 있는 어노테이션이다. 검증의 세부사항은 객체 내부에 정의한다.

```java
// MemberReq DTO
public class MemberReq {

		@NotNull // 세부 사항 객체 내부 정의
		private String name;
		
		@Positive
		private int age;
}
```

```java
// Member Controller
@RestController
public class MemberController {

		@PostMapping("/api/members")
		public Member save (
				@Valid @RequestBody MemberReq memberReq // @Valid 설정 
		) {
				...
		}
}
```

- `message = “”`  속성으로 해당 필드에 유효하지 않은 값이 오는 경우 알릴 메시지를 지정할 수 있다.
- 유효성 검증에 실패할 경우 `MethodArgumentNotValidException`이 발생한다.

### @Valid 적용 방법

검증할 대상의 앞에 `@RequestBody`와 함께 `@Valid` 어노테이션을 붙여주면 해당 input에 대해서 검증을 진행한다.

단일 파라미터를 검증 하고 싶은 경우 `@Valid`가 아닌 유효성 검사 어노테이션을 바로 붙여서 검증할 수 있다.

검증할 객체 안에 중첩된 DTO가 존재한다면 `@Valid`를 붙여 중첩으로 검증할 수 있다.

```java
public class OrderReq {
    @Valid            // 중첩 DTO 검증
    private MemberReq memberReq;

    @NotNull
    private String productName;
}
```

## @Valid vs @Validated

`@Valid` 는 Java 표준 스펙이고, `@Validated` 는 Spring에서 제공하는 어노테이션이다. 기본적인 검증 기능은 동일하지만 동작 방식과 적용 범위에서 차이가 있다.

|  | @Valid | @Validated |
| --- | --- | --- |
| 제공 | Java 표준 | Spring 프레임워크 |
| 동작 방식 | ArgumentResolver | Spring AOP |
| 적용 위치 | 컨트롤러 | 스프링 빈 |
| 그룹 검증 | 불가능 | 가능 |
| 발생 예외 | MethodArgumentNotValidException | ConstraintViolationException |

🧩 `@Valid` **동작방식**

`@Valid` 는 Spring MVC의 `ArgumentResolver`가 `@RequestBody`를 바인딩하는 시점에 검증을 수행한다.

```
HTTP 요청
    ↓
DispatcherServlet
    ↓
ArgumentResolver — 여기서 @RequestBody 바인딩 + @Valid 검증 수행
    ↓
Controller 메서드 실행
```

- Spring MVC 레이어에서 동작하기 때문에 컨트롤러에서만 사용 가능하다.
- 검증 실패 시 `MethodArgumentNotValidException`이 발생한다.

🧩 `@Validated` **동작 방식**

`@Validated` 는 Spring AOP 기반의 프록시가 메서드 호출을 가로채서 검증을 수행한다.

```
메서드 호출
    ↓
Spring AOP 프록시 — 여기서 @Validated 검증 수행
    ↓
실제 메서드 실행
```

```java
@Service
@Validated // 서비스 레이어에서도 검증 가능
public class MemberService {

    public Member save(
        @NotNull String name,
        @Positive int age
    ) { ... }
}
```

🧑‍🧑‍🧒 `@Validated`**의 그룹 검증**

`@Validated`의 핵심 기능은 그룹 검증이다. 같은 DTO를 사용하더라도 상황에 따라 다른 검증 조건을 적용할 수 있다.

```java
// 그룹 인터페이스 정의
public interface CreateGroup {}
public interface UpdateGroup {}
```

```java
public class MemberReq {
    @NotNull(groups = CreateGroup.class)  // 회원가입 시에만 필수
    private String name;

    @Positive(groups = {CreateGroup.class, UpdateGroup.class}) // 둘 다 적용
    private int age;
}
```

### 다양한 @Valid + @Validated 사용 경우의 수

1. **컨트롤러 - @RequestBody + @Valid (객체 검증)**
    
    ```java
    @RestController
    public class MemberController {
        public Member save(@Valid @RequestBody MemberReq req) { ... }
        // ArgumentResolver가 처리
        // @Validated 불필요
    }
    ```
    
2. **컨트롤러 - @RequestParam + 검증 어노테이션 직접** 
    
    ```java
    // Spring Boot 3.2 이상
    @RestController
    public class MemberController {
        public Member find(@RequestParam @NotNull Long id) { ... }
        // @Validated 없어도 동작
    }
    ```
    
3. **서비스 - @Valid (객체 검증)**
    
    ```java
    @Service
    @Validated // 필수 — 없으면 동작 안 함
    public class MemberService {
        public Member save(@Valid MemberReq req) { ... }
        // AOP 프록시가 처리
    }
    ```
    
4. **서비스 - 검증 어노테이션 직접 (단일 파라미터)**
    
    ```java
    @Service
    @Validated // 필수 — 없으면 동작 안 함
    public class MemberService {
        public Member save(@NotNull String name, @Positive int age) { ... }
        // AOP 프록시가 처리
    }
    ```
    

**‼ 발생 예외 정리**

| 경우 | 예외 |
| --- | --- |
| `@RequestBody` + `@Valid` 검증 실패 | MethodArgumentNotValidException |
| 컨트롤러 단일 파라미터 검증 실패 | HandlerMethodValidationException |
| 서비스 레이어 검증 실패 (`@Validated`) | ConstraintViolationException |

→ Spring Boot 3.2 부터 컨트롤러 단일 파라미터에 검증 어노테이션을 직접 붙이는 경우 기존 `ConstraintViolationException` 대신 `HandlerMethodValidationException` 으로 변경되었다. 따라서 글로벌 예외 처리 시 버전에 따라 처리하는 예외 타입이 달라질 수 있으므로 주의해야 한다.

**정리**

ArgumentResolver가 검증하는 경우는 1번, @RequestBody + @Valid 로 객체를 검증하는 경우 단 하나이다. 이때, `MethodArgumentNotValidException`이 발생하는 것이다.

그 외 나머지 경우의 수는 전부 AOP가 처리하고 `ConstraintViolationException`이나 `HandlerMethodValidationException` 이 발생한다.

유효성 검증 방법은 `@Valid`, `@Validated`, 검증 어노테이션 직접 사용 등 다양한 방식이 있으며, 개발자가 상황과 기준에 따라 맞는 방식을 채택하면 된다. 

컨트롤러와 서비스 레이어의 책임 분리 측면에서 일반적으로 컨트롤러 단에서 요청에 대한 검증을 최대한 처리하고 넘겨주는 것이 좋다고 생각한다.