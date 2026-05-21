- Page와 Slice

  **Page, Slice**

  Spring Data JPA에서 페이징 조회 결과를 담기 위해 사용하는 타입

  `Pageable`을 파라미터로 받아 정해진 범위만큼 데이터를 조회

    ```java
    Page<Mission> findByStore(Long storeId, Pageable pageable);
    Slice<Mission> findByStore(Long storeId, Pageable pageable);
    ```

  **Pageable**

  페이지 번호, 페이지 크기, 정렬 정보를 담는 객체

  보통 `PageRequest.of()`로 생성해서 Repository 메서드에 넘김

    ```java
    // PageRequest.of(page, size, sort)
    Pageable pageable = PageRequest.of(0, 10, Sort.by("id").descending());
    ```

    - `page` : 몇 번째 페이지인지, 0부터 시작
    - `size` : 한 페이지에 가져올 데이터 개수
    - `sort` : 정렬 기준

  **Page**

  현재 페이지 데이터뿐 아니라 전체 데이터 개수와 전체 페이지 수까지 알려주는 페이징 결과

  데이터 조회 쿼리 + 전체 개수를 구하는 count 쿼리가 추가로 실행

    ```java
    Page<Mission> page = missionRepository.findByStore(storeId, pageable);
    
    // return Type, methods
    List<Mission> missions = page.getContent();
    long totalElements = page.getTotalElements();
    int totalPages = page.getTotalPages();
    boolean hasNext = page.hasNext();
    ```

  ⇒ 전체 페이지 수가 필요한 일반 게시판형 페이지네이션에 적합

  **Slice**

  현재 페이지 데이터와 다음 페이지 여부를 알려주는 페이징 결과

  전체 데이터 개수나 전체 페이지 수는 알 수 없음

  대신 count 쿼리를 실행X → Page보다 가벼움

    ```java
    Slice<Mission> slice = missionRepository.findByStore(storeId, pageable);
    
    List<Mission> missions = slice.getContent();
    boolean hasNext = slice.hasNext();
    ```

  Slice는 요청한 size보다 1개 더 조회해서 다음 데이터가 있는지 판단

  ⇒ 무한 스크롤이나 ‘더 보기 버튼’ 처럼 전체 개수가 필요 없는 경우에 적합

  https://docs.spring.io/spring-data/jpa/reference/4.1/repositories/query-methods-details.html

  https://dallog.github.io/data-jpa-slice-page/

  https://kjs990114.tistory.com/70

- Java stream API

  **Java Stream API**

  컬렉션, 배열 같은 데이터 소스를 함수형 스타일로 처리할 수 있게 해주는 Java API

  `filter`, `map`, `collect` 등의 메서드를 연결해서 데이터를 가공

    ```java
    List<String> result = missions.stream()
            .filter(mission -> mission.getPoint() >= 1000)
            .map(Mission::getTitle)
            .toList();
    ```

  **Stream의 특징**

    - 원본 데이터 직접 변경X

      `filter`, `map`을 사용해도 기존 컬렉션이 바뀌는 것이 아니라 새로운 결과를 만들어냄

    - 일회용

      최종 연산까지 수행한 Stream은 다시 사용X

    - **지연 평가(Lazy Evaluation)**

      Stream의 중간 연산은 최종 연산이 호출되기 전까지 실행X

      ⇒ 필요한 만큼만 데이터를 처리, 불필요한 연산⬇️

        ```java
        List<String> result = missions.stream()
                .filter(mission -> mission.getRewardPoint() >= 1000)
                .limit(3)
                .map(Mission::getTitle)
                .toList();
        ```

      조건에 맞는 데이터 3개를 찾으면 더 이상 뒤의 데이터를 전부 처리X


    **중간 연산**
    
    Stream을 반환하는 연산
    
    중간 연산만 작성해두면 실제 처리는 아직 일어나지 않음
    
    대표적인 중간 연산
    
    - `filter`
        
        조건에 맞는 데이터만 필터링
        
    - `map`
        
        각 데이터를 다른 형태로 변환
        
    - `sorted`
        
        정렬
        
    - `limit`
        
        개수 제한
        
    - `distinct`
        
        중복 제거
        
    
    ```java
    missions.stream()
            .filter(mission -> mission.getRewardPoint() >= 1000)
            .map(Mission::getTitle);
    ```
    
    ⇒ 중간 연산까지만 작성되어 있기 때문에 실제 결과X
    
    **최종 연산**
    
    Stream을 실제로 실행하고 결과를 만들어내는 연산
    
    최종 연산이 호출되는 순간 앞에 연결된 중간 연산들이 함께 실행됨
    
    대표적인 최종 연산
    
    - `toList`, `collect`
        
        결과를 컬렉션으로 모음
        
    - `forEach`
        
        각 요소에 대해 작업 수행
        
    - `count`
        
        개수 계산
        
    - `sum`, `average`
        
        숫자 집계
        
    - `findFirst`, `findAny`
        
        특정 원소 반환
        
    
    ```java
    List<String> result = missions.stream()
            .filter(mission -> mission.getRewardPoint() >= 1000)
            .map(Mission::getTitle)
            .toList();
    ```
    
    `toList()`가 호출되는 시점에 `filter`와 `map` 실행
    
    https://docs.oracle.com/en/java/javase/24/docs/api/java.base/java/util/stream/Stream.html#method-summary
    
    https://innovation123.tistory.com/278

- 객체 그래프 탐색

  **객체 그래프 탐색**

  연관관계로 연결된 객체들을 참조를 따라가며 탐색하는 것

    ```java
    Member member = memberRepository.findById(memberId).get();
    Team team = member.getTeam();
    String teamName = team.getName();
    ```

  `member.getTeam()`처럼 엔티티 안에 있는 다른 엔티티 참조를 따라 탐색 가능

  SQL을 직접 작성해서 `member`와 `team`을 조인X → 객체의 필드를 따라가듯이 연관 객체에 접근
  ⇒ 객체지향

  **연관관계 매핑 예시**

    ```java
    @Entity
    public class Member {
    
        @Id
        private Long id;
    
        @ManyToOne(fetch = FetchType.LAZY)
        @JoinColumn(name = "team_id")
        private Team team;
    }
    ```

    ```java
    @Entity
    public class Team {
    
        @Id
        private Long id;
    
        @OneToMany(mappedBy = "team")
        private List<Member> members = new ArrayList<>();
    }
    ```

  `Member → Team`, `Team → Member 목록` 방향으로 객체 그래프를 탐색 가능

    ```java
    Team team = member.getTeam();
    List<Member> members = team.getMembers();
    ```

  **단방향/양방향 연관 관계**

    - 단방향 연관 관계

      한쪽 객체만 다른 객체를 참조

      `Member`에서 `Team`은 알 수 있지만, `Team`에서 `Member` 목록은 모른다.

    - 양방향 연관 관계

      양쪽 객체가 서로를 참조 → 두 개의 단방향 연관 관계

      `Member`는 `Team`을 알고, `Team`도 `members`를 통해 회원 목록을 앎


    객체 그래프 탐색은 참조가 있는 방향으로만 가능
    
    - +참고
        
        연관 객체를 언제 조회할지는 따로 생각해야 함
        
        ```java
        Member member = memberRepository.findById(memberId).get();
        Team team = member.getTeam();
        team.getName();
        ```
        
        `team`이 지연 로딩이면 `member.getTeam()` 시점에는 프록시만 가져오고, 실제로 `team.getName()`처럼 값을 사용할 때 Team 조회 SQL이 나갈 수 있음
        
        6주차의 지연 로딩/즉시 로딩, N+1 문제와 연결
        
    
    [JPA 연관관계 매핑을 통한 객체 그래프 탐색](https://rebugs.tistory.com/684)

- @Valid vs @Validated

  **@Valid, @Validated**

  요청 값이나 객체의 필드 값이 올바른지 검증할 때 사용하는 어노테이션

  컨트롤러에서 DTO 앞에 붙이면  `@NotNull`, `@NotBlank` 등의 제약 조건을 확인

    ```java
    @PostMapping("/stores/{storeId}/missions")
    public ApiResponse<Void> createMission(
    				@PathVariable Long storeId,
            @RequestBody @Valid MissionReqDTO.CreateMission dto
    ) {
    
    }
    ```

    ```java
    public record CreateMission {
    				@NotNull(message = "마감기한은 필수입니다.")
    				LocalDate deadLine,
    				@NotNull(message = "미션 성공 포인트는 필수입니다.")
    				Integer point,
    				@NotBlank(message = "조건은 빈칸일 수 없습니다.")
    				String conditional
    }{}
    ```

  제약 조건을 위반하면 컨트롤러가 실행되기 전에 검증 예외가 발생

  **@Valid**

  Jakarta Bean Validation에서 제공하는 표준 어노테이션

  요청 DTO를 검증할 때 가장 많이 사용

  **@Validated**

  Spring에서 제공하는 어노테이션, `@Valid`처럼 검증을 수행

    ```java
    @PostMapping("/missions")
    public ResponseEntity<Void> createMission(
            @RequestBody @Validated MissionCreateRequest request
    ) {
        missionService.create(request);
        return ResponseEntity.ok().build();
    }
    ```

  단순 DTO 검증에선 `@Valid`와 비슷하게 동작

  But, 검증 그룹이나 메서드 파라미터 검증을 사용할 때 차이가 있음

  검증 그룹을 사용하면 같은 DTO라도 생성할 때와 수정할 때 검증 조건을 다르게 설정 가능

    - +검증 그룹과 메서드 파라미터 검증


        ```java
        public interface Create {}
        public interface Update {}
        ```
        
        ```java
        public class MissionRequest {
        
            @NotNull(groups = Update.class)
            private Long id;
        
            @NotBlank(groups = Create.class)
            private String title;
        }
        ```
        
        ```java
        @PostMapping("/missions")
        public void create(@RequestBody @Validated(Create.class) MissionRequest request) {
        }
        
        @PatchMapping("/missions")
        public void update(@RequestBody @Validated(Update.class) MissionRequest request) {
        }
        ```
        
        생성 요청에서는 `title`을 검증, 수정 요청에서는 `id`를 검증
        
        `@Validated`는 클래스에 붙여서 서비스 메서드의 파라미터 검증에 사용 가능
        
        ```java
        @Service
        @Validated
        public class MissionService {
        
            public void findMission(@Min(1) Long missionId) {
            }
        }
        ```
        
        이 경우 AOP 프록시 기반으로 동작
        
    
    **예외 처리**
    
    컨트롤러에서  검증 실패 → `MethodArgumentNotValidException` 발생
    
    `@RestControllerAdvice`로 전역 예외 처리 가능
    
    ```java
    @RestControllerAdvice
    public class GlobalExceptionHandler {
    
        @ExceptionHandler(MethodArgumentNotValidException.class)
        public ResponseEntity<String> handleValidationException(MethodArgumentNotValidException e) {
            return ResponseEntity.badRequest().body("요청 값이 올바르지 않습니다.");
        }
    }
    ```
    
    https://shoi.tistory.com/8
    
    https://junroot.github.io/blog/posts/valid-vs-validated/