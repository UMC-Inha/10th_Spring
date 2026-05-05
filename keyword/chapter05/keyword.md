- 빌더패턴이란?

  ## Builder Pattern

  복잡한 객체를 단계적으로 값을 채워 생성할 수 있게 해주는 생성 디자인 패턴

  ### 사용하는 이유

  보통 객체를 생성할 때 생성자 이용하거나 setter를 이용해서 생성한다
  하지만 **생성자**를 이용하는 방식은 받을 필드의 값을 미리 매개변수로 지정해야 하기 때문에 선택적으로 필드의 값을 채우고 싶다고 한다면 **생성자 오버로딩이 끝없이 늘어나는 문제점**이 존재한다

  또한 **Setter**를 이용하는 방식은 위 문제를 해결할 수 있겠지만 setter 메서드가 존재한다면 객체를 처음 생성할 때 값 초기화 이외에도 언제든지 필드의 값이 변경될 수 있는 **불변성을 보장할 수 없다는 문제점**이 존재한다

  → 빌더 패턴을 통해 이러한 문제들을 해결!!!

  ### 사용 방법

    1. 객체의 클래스 내부에 static으로 builder 클래스를 생성한다
    2. 필드 멤버 구성을 객체의 필드 멤버와 동일하게 구성 후 이에 대한 setter 메서드를 구현
        1. **이 때 setter 마지막에 `return this;` 로 자신을 반환해줘야함**
    3. 최종으로 객체를 완성해주는 build 메서드를 구성

    ```java
    public class User {
        private String name;
        private int age;
        
        public static class Builder {
            private String name;
            private int age;
            
            public Builder name(String name) {
                this.name = name;
                return this;
            }
            
            public Builder age(int age) {
                this.age = age;
                return this;
            }
            
            public User build() {
                User user = new User();
                user.name = this.name;
                user.age = this.age;
                return user;
            }
        }
        
        public static void main(String[] args) {
            **User user = new User.Builder().name("Henry").age(30).build(); //사용 예시**
        }
    }
    ```

  → 위 코드 작성 없이 Lombok의 **@Builder** 어노테이션을 사용하여 빌더 패턴을 구현 가능!!

  ### 장단점

    - 장점
        - 어떤 데이터에 어떤 값이 들어가는지 직관적으로 알 수 있다
        - 선택적으로 필드에 값이 들어가는 경우가 많을 때 유용하다
        - 자바에서는 구현이 복잡한 디폴트 매개변수를 간접적으로 지원
            - 빌더 클래스에서 필드 선언할 때 값 지정
        - 초기화가 필수인 멤버를 빌더 클래스의 생성자로 넣어서 필수 멤버로 설정 가능
        - 값 검증을 빌더 클래스 내부에서 Setter를 통해 각각 검증 가능
    - 단점
        - 초기 코드의 복잡성 증가와 구현의 번거로움
        - 단순한 객체에서는 오버 엔지니어링이 될 가능성이 있음
- record vs static class

  ## record class

  변경 불가한 데이터를 저장하고 옮기는 역할

    ```java
    public record User(Long id, 
            String Name,
            String email, 
            int age) { }
    ```

    - 모든 필드가 private final로 선언되므로 한 번 선언하면 내부값을 절대 바꿀 수 없다
    - 간결한 코드
    - 위처럼 선언만 해도 생성자, getter, equals등 메서드를 자동으로 생성
        - getter를 사용할 때에는 필드의 이름만 메서드 이름으로 작성
    - 객체 간에 불변하는 데이터를 전달하는 것이 목적이기 때문에 주 사용처는 API의 요청 및 응답 DTO이다

  ## static class

  클래스 안에 선언된 클래스로 외부 클래스의 인스턴스 생성 없이도 독립적으로 생성

    ```java
    class Outer 
    	static class StaticInner { }
    }
    
    Outer.StaticInner instance = new Outer.StaticInner();
    ```

    - 필드에 final을 붙이지 않으면 setter를 통해서 값을 자유롭게 바꿀 수 있음
    - 상속과 인터페이스 구현이 자유로움
    - 빌더 패턴을 구현할 때 사용된다, DTO에서도 사용 가능

  ### DTO로 사용할 때 비교

    - record
        - 응답용 DTO에서 주로 사용
        - 조회한 데이터를 클라이언트로 내려보낼 때에 적합 ← 응답 데이터는 중간에 값이 조작될 일이 거의 없음
    - static
        - 클라로부터 들어온 데이터를 넘기기 전에 데이터 포맷을 변환하거나 기본값 세팅 등이 필요한 요청 DTO, 요청/응답 DTO를 하나로 묶어서 관리할 때 주로 사용
        - 기본 생성자를 필요로 하는 라이브러리 사용 가능
- 제네릭이란?

  ## 제네릭

  클래스나 메소드에서 사용할 내부의 데이터 타입을 외부에서 지정 받는 방식

  특정 메서드에서의 사용 예시

    ```java
    public class Utils {
    
        public static <T> void printArray(T[] array) {
            for (T element : array) {
                System.out.println(element);
            }
        }
    }
    ```

  클래스에서의 사용 예시

    ```java
    class MyArray<T> {
    		T element;
    
    		void setElement(T element) { this.element = element; }
    		T getElement() { return element; }
    }
    
    //사용 예시
    
    MyArray<Integer> myArr = new MyArray<Integer>(); //<>안 Integer는 생략 가능
    ```

    - 제네릭에 할당 할 수 있는 타입은 레퍼런스 타입만 가능
        - int, double같은 타입은 불가!
    - <T, U>와 같이 여러 타입을 넘겨 받을 수 있음
    - 사용 시 주의
        - 제네릭 타입의 객체 생성 불가
            - T t = new T(); ← 안됨
        - static에 제네릭 타입이 올 수 없다
- @RestControllerAdvice이란?

  ## @RestControllerAdvice

  프로젝트 내의 모든 컨트롤러에서 발생하는 예외를 가로채어서 처리해주는 역할
  @ControllerAdvice와 @ResponseBody가 합쳐진 형태이다
  @ControllerAdivice와 다르게 에러가 발생하였을 때 json 형식으로 에러 응답을 보냄

    - 사용 배경
        - 모든 예외처리를 try-catch로 하다 보니 중복 코드와 코드의 복잡성이 증가되었다 → RestControllerAdvice이 해결책
    - 사용 방법
        - 예외 처리만을 담당하는 클래스를 생성하고 @RestControllerAdvice 어노테이션을 붙여서 모든 컨트롤러의 예외가 모이게 한다
        - 클래스 내부에 @ExceptionHandler(Exception.class) 같은 어노테이션을 붙인 메서드를 정의하여 그 안에서 에러를 다룬다
            - 이 때 가장 구체적인 예외 클래스를 처리하는 메서드부터 찾아서 실행한다

    ```java
    @RestControllerAdvice
    public class GlobalExceptionHandler {
    
        @ExceptionHandler(MenuNotFoundException.class) //커스텀 예외
        public ResponseEntity<ErrorResponse> handleMenuNotFound(MenuNotFoundException ex) {
           
        }
    
        // 예상치 못한 서버 내부의 모든 에러를 마지막으로 방어합니다.
        @ExceptionHandler(Exception.class)
        public ResponseEntity<ErrorResponse> handleGeneralException(Exception ex) {
       
        }
    }
    ```

- Optional이란?

  ## Optional

  null이 올 수 있는 값을 안전하게 감싸서 보관해주는 wrapper 클래스
  내부에는 데이터가 들어있을 수도 있고 비어있을 수도 있음

    - 사용 이유
        - nullpointerexception을 방지
        - if (obj ≠ null) 을 줄여서 코드를 간결하게
        - optional을 명시해서 이 결과는 데이터가 없을 수 있음을 전달
    - optional 생성
        - Optional.ofNullable(value): 파라미터로 null이 올 수도 있고 아닐 수도 있을 때 사용
        - Optional.of(value): 절대 null이 아닌 확신하는 값을 담을 때 사용 (null을 넣으면 즉시 에러 발생)
        - Optional.empty(): 아무 데이터도 없는 텅 빈 상자를 생성할 때 사용
    - optional에서 값 꺼내기
        - .orElse(기본값): 상자가 비어있으면, 괄호 안에 지정해 둔 '미리 만들어둔 기본값'을 대신 반환
        - .orElseGet(() -> 로직): 상자가 비어있을 때만 괄호 안의 코드를 실행해서 기본값을 계산해 반환 (메모리 낭비를 줄임)
        - .orElseThrow(() -> 예외**):** 상자가 비어있으면 내가 원하는 예외(Exception)를 던짐
        - .ifPresent(값 -> 로직): 상자 안에 값이 존재할 때만 특정 로직을 실행 (값이 없으면 그냥 넘어감)
    - 주의
        - 반환 타입으로 사용하지 않으면 성능 저하 등의 문제를 일으실 수 있음
        - 리스트, 맵 등은 비어있으면 Collections.emptyList()를 반환, 두 번 감쌀 필요는 없다