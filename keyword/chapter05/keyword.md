- 빌더패턴이란?

  **빌더 패턴(Builder Pattern)**
  객체 생성 과정의 분리를 통해 다양한 구성의 객체를 만드는 생성 패턴, 생성자에 들어갈 메서드로 하나씩 받아 마지막에 통합 빌드하는 방식 → 필수 값은 적고 선택 값이 많은 객체를 만들 때 유리

  기존의 점층적 생성자 패턴, 자바 빈 패턴의 문제를 해결함

    - 점층적 생성자 패턴, 자바 빈 패턴
        - 점층적 생성자 패턴(Telescoping Constructor Pattern)
            - 필요한 인스턴스 종류 마다 생성자를 오버로딩하는 방식
            - 가독성⬇️(각 매개변수의 의미가 불확실함)
            - 매개변수의 순서가 중요함(중간에 몇 개를 건너뛰려면 0이나 null을 전달해야함)
            - 생성자의 수가 많아 유지보수⬇️
        - 자바 빈 패턴(JavaBeans Pattern)
            - 기본 생성자로 객체 생성, setter로 필드의 초기값을 설정하는 방식
            - 위 패턴에 비해 가독성, 유연성⬆️
            - 일관성 문제 → 필수 매개변수의 초기화가 빠질 가능성이 있음
            - 불변성 문제 → setter가 노출되어있어, 외부에서 객체 조작 가능

      각 패턴 별 비교

        - 점층적 생성자: 단순하지만 파라미터가 많아지면 불편
        - 자바 빈: 유연하지만 생성 중간에 불완전한 객체가 생길 수 있음
        - 빌더: 조금 번거롭지만 큰 객체에서 가장 안정적


    Ex)
    
    ```java
    public class Member{ // 실제로 생성할 객체
    	private final String name;
    	private final int age;
    	private final String city;
    	
    	private Member(Builder builder) { // private 생성자
    	  this.name = builder.name;
    	  this.age = builder.age;
        this.city = builder.city;
      }
    
      public static class Builder { // 만드려는 객체를 조립하는 클래스 
        private String name;
        private int age;
        private String city;
    
    	  public Builder name(String name) {
    	    this.name = name;
          return this;
        }
    
        public Builder age(int age) {
          this.age = age;
          return this;
        }
    
        public Builder city(String city) {
          this.city = city;
          return this;
        }
    
        public Member build() { // 최종 객체를 반환, 이후에는 수정 불가(불변성)  
          return new Member(this);
        }
      }
    }
    ```
    
    사용
    
    ```java
    Member member = new Member.Builder()
    	.name("kim")
    	.age(20)
    	.city("Seoul")
    	.build();
    ```
    
    장점
    
    - 가독성⬆️ (위 예시처럼 각 매개변수의 의미를 알기 쉬움)
    - 선택 파라미터 처리에 유리
    - 객체 생성 과정이 명확함
    - 불변 객체
    - 생성 시점에 검증 로직 넣기 좋음
    
    단점
    
    - 클래스 수의 증가
    - 단순한 객체에는 오히려 과할 수 있음
        - 생성자 인자가 많은 경우
        - 같은 객체를 다양한 조합으로 생성하는 경우
        - 불변 객체를 만드는 경우
        - 생성 과정에서 유효성 검사가 필요한 경우
        
        ⇒ 이 경우에 사용하면 👍
        
    
    https://inpa.tistory.com/entry/GOF-%F0%9F%92%A0-%EB%B9%8C%EB%8D%94Builder-%ED%8C%A8%ED%84%B4-%EB%81%9D%ED%8C%90%EC%99%95-%EC%A0%95%EB%A6%AC
    https://jinwookoh.tistory.com/212

- record vs static class

  **record DTO**

    ```java
    public record MemberDto(
    	String name,
      int age,
      String city 
    ) {}
    ```

  사용:

    ```java
    MemberDto dto = new MemberDto(1L, "Kim", 20);
    
    String name = [dto.name](http://dto.name/)();
    int age = dto.age();
    String city = dto.city();
    ```

  장점

    - DTO 길이 ⬇️
    - 불변성 (record의 필드는 사실상 private final)
    - 자동 생성
        - 생성자
        - 접근자(ex: name(), age(), …)
        - equals()
        - hashCode()
        - toString()

  검증 추가 가능

    - 예시

        ```java
        public record MemberDto(
        	String name,
        	int age,
        	String city
        ) {
        		public MemberDto {
        			if (name == null || name.isBlank()) {
        				throw new IllegalArgumentException("name은 비어 있을 수 없습니다.");
        		}
        			if (age < 0) {
        				throw new IllegalArgumentException("age는 0 이상이어야 합니다.");
        		}
        	}
        }
        ```


    단점
    
    - 부분 수정이 필요한 DTO에는 사용 불가
    
    **static class DTO** 
    
    ```java
    public static class MemberDto{
    	private String name;
    	private int age;
    	private String city;
    	
    	public MemberDto(String name, int age, String city){
    		this.name = name;
    		this.age = age;
    		this.city = city;
    	}
    	
    	public String getName() {
    		return name;
    	}
    	
    	public void setName(String name) {
    		this.name = name;
    	}
    	
    	// +각 필드에 대한 getter, setter
    ```
    
    장점
    
    - 유연성(가변, 불변 가능/생성 방식 설계 가능/구조 확장, 잘 쓰진 않으나 필요하면 상속도 가능 )
    - 호환성 → getter, setter의 구조가 레거시 코드나 일부 라이브러리와의 충돌이 적다고 함
    
    단점:
    
    - 보일러플레이트⬆️
    - 불변 객체로 만드려면 추가적인 설정 필요(final 키워드, 혹은 setter를 만들지 않을 것)
    
    ⇒ DTO의 역할이 ‘데이터 전달’  뿐이라면 record가 유리, 생성 방식의 제어나 데이터 변경이 필요한 경우는 static class가 유리
    
    https://velog.io/@devjoong/DTOClass-vs-RecordJava-14-%EC%B0%A8%EC%9D%B4
    
    https://zerorok.tistory.com/17

- 제네릭이란?

  **제네릭(Generic)**

  특정 타입만 다루지 않고, 여러 종류의 타입으로 변할 수 있도록 클래스나 메서드를 일반화하는 방법

  Ex)

    ```java
    public class Box<T> { // 클래스 제네릭
    	private T value;
    	
    	public void set(T value) {
    	  this.value = value;
      }
    
      public T get() {
    	  return value;
      }
      
    Box<String> box = new Box<>(); // 사용
    box.set("abc");
    String value = box.get();
    ```

    ```java
    public static <T> T first(T a, T b) { // 메서드 제네릭
    	return a;
    }
    
    String s = first("a", "b"); // 사용
    Integer n = first(1, 2);
    ```

  T는 타입 매개 변수, 실제로 사용할 때 String, Integer 와 같은 구체 타입으로 바뀜

    - T: Type
    - E: Element
    - K: Key
    - V: Value

  사용 이유

    - 중복 코드⬇️ → 재사용성⬆️
    - 타입 안정성⬆️ → 컴파일 시점에 타입 체크 가능
    - 형변환(casting)⬇️

  주의

    - 기본형 타입은 불가능 → Integer, Double 같은 wrapper를 사용
    - 타입 소거(Type Erasure) 때문에 런타임에는 제네릭 타입 정보가 일부 사라짐 → 타입 매개 변수 자체로는 new 불가

  https://cabi.oopy.io/00ba0ada-433f-4be0-ba1f-529994f34b68

- @RestControllerAdvice이란?

  **@RestControllerAdvice**

  @ControllerAdvice + @ResponseBody를 합친 축약 어노테이션

  예외 처리 메서드의 반환값을 ResponseBody로 렌더링하는 @ControllerAdvice

  기본 적용 대상은 모든 컨트롤러, 즉@Controller, @RestController 모두 포함

  목적

    - @ExceptionHandler
    - @InitBinder
    - @ModelAttribute

  위 어노테이션이 붙은 메서드들을 특정 컨트롤러 클래스 안에 두면 그 컨트롤러에만 적용되는데, @ControllerAdvice나 @RestControllerAdvice가 붙은 클래스 안에 두면 전역적으로 여러 컨트롤러에 적용됨
  ⇒ 보통 @ExceptionHandler를 전역 예외 처리 용도로 사용

    ```java
    @RestControllerAdvice
    public class GlobalExceptionHandler {
    	@ExceptionHandler(IllegalArgumentException.class)
    	public ResponseEntity<String> handleIllegalArgument(IllegalArgumentException e){
    		return ResponseEntity.badRequest().body(e.getMessage());
    	}
    }
    ```

    - 예외 처리 코드 중복⬇️
    - 응답 형식 통일, 유지보수⬆️

  https://docs.spring.io/spring-framework/reference/web/webflux/controller/ann-advice.html#page-title

    - 참고

      @RestControllerAdvice는 @ResponseBody가 붙어 있으므로, 예외 처리 결과를 뷰로 넘기기보다 JSON 같은 HTTP Response Body 로 내려주는 데 적합(@ControllerAdvice는 뷰 반환 MVC에도 사용 가능)

      전역 @ExceptionHandler는 로컬 컨트롤러의 예외 처리보다 나중에 적용

      반대로 전역 @ModelAttribute, @InitBinder는 로컬의 것보다 먼저 적용

      기본적으로 전역 컨트롤러에 적용되지만, Optional Element 설정을 통해 적용 범위를 좁힐 수 있다. 다만, 이 범위가 런타임에 평가되므로 과도하게 사용 시 성능에 부정적이다.

      https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/RestControllerAdvice.html


- Optional이란?

  **Optional<T>**

  값이 있을 수도 없을 수도 있는 컨테이너 객체

  주로 메서드 반환 타입으로 사용, 목적은 ‘no result’를 표현하기 위한 것
  ⇒ 기존의 null을 사용하는 방식은 NullPointerException 이 발생, Optional은 이 문제를 해결

  주로 사용하는 메서드

    - Optional.of(value)

      null이 아닌 값(value)로 Optional 객체 생성

    - Optional.ofNullable(value)

      값(value)이 null 일 가능성이 있을 때의 Optional 객체 생성

    - Optional.empty()

      빈 Optional 객체 생성

    - isPresent()

      값이 존재하면 true, 존재하지 않으면 false

    - ifPresent(…)

      값이 존재하는 경우에만 (…)을 실행

    - orElse(//기본값)

      값이 없는 경우 기본값 사용

    - orElseGet(…)

      값이 없는 경우에만 기본값 계산

    - orElseThrow(…)

      값이 없는 경우 예외 발생


    JpaRepository를 상속하면 기본 제공 메서드 중 일부가 이미 Optional을 반환
    
    ```java
    public interface UserRepository extends JpaRepository<User, Long> {
    } // 이 안에 이미 Optional<User> findById(Long id) 가 있음
    ```
    
    ```java
    // service에서 이렇게 사용
    User user = userRepository.findById(id)
              .orElseThrow(() -> new IllegalArgumentException("사용자 없음"));
    ```
    
    - 참고
        
        Optional은 value-based class → ==와 같은 동일성 비교나 동기화 용도로 사용하지 말라고 함
        
        ```java
        Optional<String> o1 = Optional.of("Kim");
        Optional<String> o2 = Optional.of("Kim");
        // 이 경우에 o1 == o2 는 false일 수 있음, 필요 시 equals()로 비교 
        
        synchronized(optional) {
              ...
          }
        // 이런 lock 객체로 믿을 만한 객체가 아님
        ```
        
    
    https://docs.oracle.com/en/java/javase/26/docs/api/java.base/java/util/Optional.html
    
    https://www.elancer.co.kr/blog/detail/265