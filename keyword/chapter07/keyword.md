- Page와 Slice

  Spring Data JPA에서 페이징 구현을 위해 제공하는 두 가지 인터페이스가 바로 Page와 Slice

    ```java
    //MemberRepository
    
    ...
    
        Page<Member> findPageBy(Pageable pageable);
        Slice<Member> findSliceBy(Pageable pageable);
    
    ...
    ```

  ## Page

    - Page는 Slice를 상속했기 때문에 현재 페이지의 데이터에 더해서 전체 데이터의 개수와 전체 페이지 수를 모두 알고 있다
    - 조회(SELECT) 쿼리 이후 전체 데이터 개수를 조회(SELECT COUNT)하는 쿼리가 한 번 더 실행
    - 전체 페이지 개수나 데이터 개수가 필요한 경우 유용 (게시판 형태)

  ## Slice

    - 현재 페이지에 포함된 데이터 목록과 다음 페이지가 있는지 여부에 대한 정보만 제공
    - 조회 쿼리 한 번만 실행
        - 사용자가 요청한 데이터 개수(limit)보다 하나 더 많은 데이터를 요청해서 다음 데이터 존재의 여부를 판단
        - COUNT 실행되지 않음
    - COUNT 쿼리가 생략되므로 대용량 데이터 조회 시 성능 상 유리
    - 총 데이터 개수가 필요 없는 상황에서 유용 (무한 스크롤)

- Java stream API

  ## Java stream API

  데이터의 묶음을 반복문 없이 함수형 프로그래밍 방식으로 간결하게 처리 가능하게 해준다

  ### 과정

    ```java
    List<String> words = Arrays.asList("show", "me", "the", "money", "money");
    
    List<String> distinctWords =
            words.stream()                        // 1. Stream 생성
            .filter(word -> word.length() > 3)    // 2. 중간연산
            .distinct()                          // 2. 중간연산
            .collect(Collectors.toList());        // 3. 최종연산
    ```

    1. 생성
        - 컬렉션이나 배열 등의 데이터를 스트림 객체로 만든다
            - .stream
    2. 중간 연산
        - 데이터를 조건에 맞게 걸러내거나 변형
        - 연산
            - .filter(조건) : 조건이 참인 것만 통과
            - .distinct() : 중복 요소 제거
            - .map(Function) : 데이터를 함수를 통해서 내가 원하는 다른 형태로 변환 추출
            - .limit(size) : 스트림의 맨 앞부터 size만큼만 가져오기
            - sorted(condition) : 조건에 맞게 데이터 정렬, 없으면 오름차순
    3. 최종 연산
        - 가공된 데이터를 최종적인 결과물로 변환
        - 연산
            - .collect(.toList) : 스트림을 통과하며 가공된 데이터들을 List, Set, Map 같은 컬렉션 형태로 다시 포장
            - .count() : 최종 결과물에 데이터가 몇 개 남아있는지를 계산, long 리턴
            - .forEach(작업) : 스트림을 통과한 데이터들을 차례대로 하나씩 꺼내서 특정 작업을 실행, 변수에 담아서 반환X

  ### 특징

    - 반복문을 사용하지 않고, 선언적으로 데이터 흐름을 표현
    - 중간 연산은 최종 연산이 호출되기 전까지 실제로 실행되지 않아 성능을 향상
    - 원본을 바꾸지 않음
- 객체 그래프 탐색

  ## 객체 그래프 탐색

  객체들이 서로 참조(Reference)를 통해 연결되어 있는데, 이 연결된 것이 그래프 같다고 해서 객체 그래프라고 함

  그리고 이 객체 그래프를 따라가면서 찾는 것이 **객체 그래프 탐색**

    ```java
    String univName = menu.getCafeteria().getUniversity().getName();
    ```

  ### JPA에서 왜 중요함?

  RDB에서는 객체처럼 다른 테이블의 데이터를 마음대로 가지고 올 수 없고 JOIN 해야함따라서 SQL을 어떻게 짰느냐에 따라 자바 코드에서 객체를 탐색할 수 있는 범위가 한정됨

  **→ JPA가 지연 로딩을 통해 해결!!**

    ```java
    // 1. DB에서 메뉴 번호 1번을 가져옴 (메뉴 테이블만 SELECT)
    Menu menu = menuRepository.findById(1L).orElseThrow(); 
    
    // 2. 이때 식당(Cafeteria) 객체는 진짜 객체가 아니라 '가짜(프록시) 객체'가 들어있음
    Cafeteria cafeteria = menu.getCafeteria(); 
    
    // 3. 실제로 식당의 이름이 필요한 순간
    // JPA가 몰래 DB에 SELECT 쿼리를 날려서 식당 데이터를 가져옴 (지연 로딩)
    System.out.println(cafeteria.getName());
    ```

    - 이 때 반복문으로 인한 N+1 문제를 조심해야함
        - fetch join!!
- @Valid vs @Validated

  ## @Valid

    - java에서 제공
    - 주로 밑 예시처럼 Controller에서 유효성 검증이 필요한 파라미터에 붙여서 사용

    ```java
    @PostMapping("/users")
    public ResponseEntity<?> createUser(@Valid @RequestBody UserDto userDto) {
        // userDto 내부의 @NotBlank, @NotNull 등이 검증됨
        return ResponseEntity.ok().build();
    }
    ```

  ## @Validated

    - spring 제공
    - 계층과 무관하게 Spring Bean이라면 유효성 검증을 진행
    - valid 기능을 모두 제공하면서 추가 기능 제공
        - 그룹 검증 지원
            - 같은 DTO 객체라도 로직(생성, 수정 등)에 따라 검증 조건이 다를 때 사용

        ```java
        // 1. 마커 인터페이스(그룹) 생성
        public interface CreateGroup {}
        public interface UpdateGroup {}
        
        public class UserDto {
            @NotNull(groups = {UpdateGroup.class}) // 수정할 때만 필수
            private Long id;
        
            @NotBlank(groups = {CreateGroup.class, UpdateGroup.class}) // 생성, 수정 모두 필수
            private String name;
        }
        
        // 2. 컨트롤러에서 사용할 그룹 지정
        @PostMapping("/users")
        public ResponseEntity<?> createUser(@Validated(CreateGroup.class) @RequestBody UserDto dto) {
            // id 필드는 검증하지 않고, name 필드만 검증함
            return ResponseEntity.ok().build();
        }
        ```

        - 컨트롤러 클래스 파라미터 단일 검증
            - dto가 아닌 @RequestParam, @PathVariable 검증 시 사용
            - 클래스 위에 @Validated 선언

        ```java
        @RestController
        **@Validated // 컨트롤러 클래스 상단**
        @RequestMapping("/users")
        public class UserController {
        
            @GetMapping("/{id}")
            public ResponseEntity<?> getUser(
                @PathVariable **@Min(1)** Long id // id가 1 이상인지 단일 검증
            ) {
                return ResponseEntity.ok().build();
            }
        }
        ```


    → 일반적인 dto 검증은 @Valid 권장