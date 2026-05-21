### Page<T>

- 전체 데이터 개수(count 쿼리)를 실행해서 총 페이지 수, 총 요소 수를 제공
- getTotalElements(), getTotalPages() 사용 가능
- count 쿼리가 추가로 나가므로 성능 비용이 더 높음
- 게시판, 검색 결과처럼 “총 몇 건 중 몇 페이지” 표시가 필요할 때 적합

```java
public interface Page<T> extends Slice<T> {
    // 전체 페이지 개수
    int getTotalPages();
    // 전체 요소 개수
    long getTotalElements();
    // / 변환기
    <U> Page<U> map(Function<? super T, ? extends U> converter); // 변환기
}
```

### Slice<T>

- count 쿼리 없이 다음 페이지 존재 여부만 확인
- 내부적으로 limit + 1개를 조회해서 다음 항목이 있는지만 판단
- hasNext() 사용 가능, getTotalELements()없음
- 무한 스크롤, “더 보기” 버튼처럼 다음 페이지 존재 여부만 필요할 때 적합

```java
public interface Slice<T> extends Streamable<T> {
    int getNumber(); // 현재 페이지
    int getSize(); // 페이지 크기
    int getNumberOfelements(); // 현재 페이지에 나올 데이터 수
    List<T> getContent(); // 조회된 데이터
    boolean hasContent(); // 조회된 데이터 존재 여부
    Sort getSort(); // 정렬 정보
    boolean isFirst(); // 현재 페이지가 첫 번째 페이지인지 여부
    boolean isLast(); // 현재 페이지가 마지막 페이지인지 여부
    boolean hasNext(); // 다음 페이지 여부
    boolean hasPrevious(); // 이전 페이지 여부
    Pageable getPageable(); // 페이지 요청 정보
    Pageable nextPageable(); // 다음 페이지 객체
    Pageable previousPageable(); // 이전 페이지 객체
    <U> Slice<U> map(Function<? super T, ? extends U> convert); // 변환기
}
```

- Java stream API

  ### Stream

    - 시간상에 나타나는 일련의 데이터 요소

  ### Java stream API

    - 일련의 데이터의 흐름을 표준화된 방법으로 쉽게 처리할 수 있도록 지원하는 클래스의 집합(패키지)

  ### Java Stream을 사용하는 이유

    1. **가독성 향상**

    ```java
    [반복문으로 처리하는 기존방식]
    
    List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");
    
    // 이름이 "A"로 시작하고 길이가 4 이상인 이름을 찾아 정렬하여 출력
    System.out.println("Using traditional loop:");
    List<String> filteredAndSortedNames = new ArrayList<>();
    for (String name : names) {
        if (name.startsWith("A") && name.length() >= 4) {
            filteredAndSortedNames.add(name);
        }
    }
    Collections.sort(filteredAndSortedNames);
    for (String name : filteredAndSortedNames) {
        System.out.println(name);
    }
    ```

    ```java
    [Java Stream API를 사용한 방식]
    
    List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David");
    
    // 이름이 "A"로 시작하고 길이가 4 이상인 이름을 찾아 정렬하여 출력
    System.out.println("Using Stream API:");
    names.stream()
         .filter(name -> name.startsWith("A") && name.length() >= 4)
         .sorted()
         .forEach(System.out::println);
    ```

    - Stream을 사용하게 되면 코딩이 훨씬 간결해지고 명료해져서 소스코드의 가독성이 좋아짐
    1. **유지보수성 향상**
        - Java Stream을 사용하기 전에는 복잡한 반복문과 조건문으로 인해 코드가 지나치게 길고 복잡
        - Java Stream을 사용하면 간결하고 명확한 코드로 데이터를 처리할 수 있어서 코드의 가독성과 유지보수성이 향상
    2. **병렬처리 지원**
        - Stream의 병렬처리는 **데이터의 흐름을 나누어 멀티 스레드로 병렬 처리 후 합치는 방식**으로, 대량의 데이터를 빠르고 쉽게 처리할 수 있음

  ### Java Stream의 처리 구조와 처리 특징

    - Java stream은 생성 → 가공 → 소비의 3단계 구조로 구성
    1. **생성**
        - 컬렉션(집합)을 stream으로 변환하는 과정
        - stream api 사용 전 최초 1번 수행
        - 모든 데이터를 한꺼번에 메모리에 로드하지 않고 필요할 때만 로드 → 메모리 효율적
    2. **가공 (중간 연산)**
        - 데이터를 원하는 형태로 변환하는 중간 처리
        - 대표 연산: filter(), map(), sort()
        - 입력값도 stream, 결과값도 stream → 중간 연산을 연결해서 연속으로 여러 번 수행 가능
    3. **소비 (최종 연산)**
        - stream에 대한 최종 연산, 최종 결과물을 얻는 과정
        - 컬렉션 또는 하나의 값(합계 등)으로 결과 반환
        - 1번만 수행 가능 - 최종 연산 후 stream은 닫혀서 재사용 불가
        - 추가 가공이 필요하면 새로운 stream을 생성해야 함
    - **데이터 처리 순서**
        - 모든 데이터에 대해 하나의 함수가 끝난 후 다음 함수가 실행되는 게 아니라
        - 일련의 데이터가 나타난 흐름의 순서대로 처리됨
        - 앞선 데이터가 먼저, 뒤의 데이터가 나중에 처리되는 구조

  ### Java stream API

    - stream은 컬렉션/배열 등의 데이터를 선언형(함수형)으로 처리하는 API
    - 데이터를 직접 변경하지 않고, 파이프라인 방식으로 연산을 연결해 처리

  ### 특징

    - 원본 데이터 불변: 원본 컬렉션을 변경하지 않음
    - 지연 연산(Lazy Evaluation): 최종 연산이 호출될 때까지 중간 연산은 실행되지 않음
    - 일회성: 한 번 사용한 stream은 재사용 불가
    - 병렬 처리 가능:  `parallelStream()` 으로 손쉽게 병렬 처리
    -
- 객체 그래프 탐색

  ### 객체 그래프란?

    - 객체들이 서로 참조로 연결된 구조인 그래프를 따라가며 탐색하는 것

    ```java
    Member ──────► Team
      │
      └──────────► Order ──────► Delivery
                      │
                      └──────► OrderItem ──────► Item ──────► Category
    ```

    ```java
    member.getTeam();                              // Member → Team
    member.getOrder().getDelivery();               // Member → Order → Delivery
    member.getOrder().getOrderItem().getItem();    // Member → Order → OrderItem → Item
    ```

  ### SQL 직접 사용할 때의 문제

    1. **SQL을 직접 쓰면 처음 실행한 SQL에 따라 탐색 범위가 고정**

    ```java
    // DAO에서 Member와 Team만 JOIN해서 조회
    SELECT M.*, T.*
    FROM MEMBER M
    JOIN TEAM T ON M.TEAM_ID = T.TEAM_ID
    ```

    ```java
    Member member = memberDAO.find(memberId);
    
    member.getTeam();      // ✅ 가능 (JOIN했으니까)
    member.getOrder();     // ❌ null (SQL에 없었으니까)
    ```

    1. **엔티티를 신뢰할 수 없음**

    ```java
    class MemberService {
        public void process() {
            Member member = memberDAO.find(memberId);
    
            member.getTeam();              // 될까? 🤔
            member.getOrder().getDelivery(); // 될까? 🤔
            // SQL 직접 열어봐야 알 수 있음 😰
        }
    }
    ```

    1. **DAO 메서드가 계속 늘어남**

    ```java
    memberDAO.getMember();                       // Member만
    memberDAO.getMemberWithTeam();               // Member + Team
    memberDAO.getMemberWithOrderWithDelivery();  // Member + Order + Delivery
    // 경우의 수만큼 메서드가 무한정 늘어남 😱
    ```

  ### **JPA가 해결하는 방법**

    1. **지연 로딩**
    - JPA는 실제로 객체를 사용하는 시점에 자동으로 SQL을 실행

    ```java
    Member member = jpa.find(Member.class, memberId);
    // 이 시점엔 Member SELECT만 실행
    
    Team team = member.getTeam();
    // 이 시점에 Team SELECT 실행 ← 지연 로딩!
    
    Order order = member.getOrder();
    // 이 시점에 Order SELECT 실행 ← 지연 로딩!
    ```

    1. **지연 로딩이 가능한 이유 — 프록시**
        - JPA는 실제 객체 대신 가짜 객체(프록시)를 먼저 넣어두고, 실제 사용 시점에 DB를 조회

        ```java
        member.getTeam() 호출
                │
                ▼
          Team 프록시 반환 (가짜 객체, DB 조회 안 함)
                │
                ▼
          team.getName() 호출 ← 실제 값이 필요한 순간!
                │
                ▼
          DB에 SELECT 실행 → 진짜 Team 데이터 채움
        ```

    - **N+1 문제 주의**

    ```java
    List<Member> members = memberRepository.findAll();
    // SELECT * FROM MEMBER → 1번
    
    for (Member member : members) {
        System.out.println(member.getTeam().getName());
        // 루프마다 SELECT * FROM TEAM → N번 추가 실행
    }
    // Member 100명이면 총 1 + 100 = 101번 쿼리 😱
    ```

    - **fetch join으로 해결**

    ```java
    @Query("SELECT m FROM Member m JOIN FETCH m.team")
    List<Member> findAllWithTeam();
    // Member + Team을 한 번에 JOIN → 쿼리 1번으로 해결 ✅
    ```

- @Valid vs @Validated

  ### @Valid 언제 어떻게 사용하는가?

    - `valid` 어노테이션은 주로 request body를 검증하는데 많이 사용
    - 아래와 같이 User를 추가하는 간단한 Request dto가 있고 `NotNull, NotBlank` 등의 유효성 검사 어노테이션을 적용

    ```java
    public class UserRequest {
        @Email
        private String email;
    
        @NotBlank
        private String password;
        
        @NotNull
        private Address address;
    
       // 생성자 및 getter 함수
    }
    ```

    - Controller 내의 User 회원가입 함수(signUp) 파라미터 부분에 `valid` 어노테이션을 적어야 기능이 정상 작동

    ```java
    @PostMapping()
    public String signUp(@Valid @RequestBody UserRequest request) {
        return "ok";
    }
    ```

    - 이 때 실제로 동작을 시켜보면 address 멤버 변수가 가진 `city, zipcode`에 대한 유효성 검증은 실행되지 않음
    - 즉, 아래와 같은 요청이 예외 처리되지 않고 정상적으로 들어옴

    ```java
    {
        "email": "test@gmail.com",
        "password": "password",
        "address": {
            "city": "",       // 빈 문자열
            "zipCode": null   // null
        }
    }
    ```

    - 위와 같이 nested dto를 검증하려면 address에 NotNull 대신 `valid` 어노테이션을 붙여야 정상적으로 동작

    ```java
    public class UserRequest {
        @Email
        private String email;
    
        @NotBlank
        private String password;
        
        @Valid // @NotNull 대신 @Valid를 사용해야함
        private Address address;
    
        // 생성자 및 getter 함수
    }
    ```

  ### **Validated는 언제 어떻게 사용하는가?**

    - 검증할 입력 값에는 크게 3가지 유형이 있음

    ```java
    1. query string.    ex) /users?teamId=1
    2. query parameter. ex) /users/1
    3. request body
    ```

    - request body의 경우 위와 같이 `valid` 어노테이션으로 처리하면 됨
    - query string이나 parameter를 검증해야 하는 경우
        - 쿼리 파라미터로 특정 사용자를 조회하는 api가 있다고 가정
        - id는 보통 db의 auto_increment로 1부터 시작하니 이걸 검증한다고 하면, 아래와 같이 `validated` 어노테이션을 클래스 레벨에 선언 후 유효성 검사하는 어노테이션을 추가

        ```java
        @RestController
        @RequestMapping("/users")
        @Validated
        public class UserController {
            .
            .
            
            @GetMapping("/{id}")
            public String find(@PathVariable @Min(1)  Long id) {
                return "ok";
            }
        }
        ```

        - 만약 class 레벨에 `validated` 어노테이션이 없다면 `Min` 어노테이션은 동작하지 않음

  ### 예외 처리

    - `valid` 방법을 선택했는데 입력 값 검증 과정에서 예외가 발생한다면 `MethodArgumentNotValidException` 예외를 발생시키고 Exception Handler로 핸들링 할 수 있음

    ```java
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseMessage<String> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        return ResponseMessage.badRequest("");
    }
    ```

    - `Validated` 방법을 사용했다면 `ConstreaintVoilationException` 예외가 발생하고 아래와 같이 처리

    ```java
    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseMessage<String> handleMethodConstraintViolationException(ConstraintViolationException e) {
        return ResponseMessage.badRequest("");
    }
    ```
