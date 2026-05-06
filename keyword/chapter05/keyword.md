- ### 워크북 캡쳐

유리 -> 에반
![5주차.png](5%EC%A3%BC%EC%B0%A8.png)

- 빌더패턴이란?

  ### 빌더

    - 복잡한 객체들을 단계별로 생성할 수 있도록 하는 생성 디자인패턴
    - 이 패턴들을 사용하면 같은 제작 코드를 사용하여 객체의 다양한 유형들과 표현을 제작할 수 있음
    1. **Builder (인터페이스) - “주문서 양식”**
        - 모든 빌더가 공통으로 가져야 할 제품 생성 단계를 선언

    ```java
    interface PizzaBuilder {
    	void reset();                // 새 피자 준비
    	void buildDough();           // 도우 선택
    	void buildSauce();           // 소스 선택
    	void buildTopping();         // 토핑 선택
    ```

    1. **ConcreteBuilder - “각 셰프의 레시피”**
        - 같은 단계를 다르게 구현해서 서로 다른 피자를 만듬

    ```java
    // 불고기 피자 셰프
    class BulgogiPizzaBuilder implements PizzaBuilder {
        private Pizza result = new Pizza();
    
        public void reset() { result = new Pizza(); }
        public void buildDough() { result.setDough("씬도우"); }
        public void buildSauce() { result.setSauce("불고기소스"); }
        public void buildTopping() { result.setTopping("불고기+양파"); }
        public Pizza getResult() { return result; }
    }
    
    // 고르곤졸라 피자 셰프
    class GorgonzolaPizzaBuilder implements PizzaBuilder {
        private Pizza result = new Pizza();
    
        public void reset() { result = new Pizza(); }
        public void buildDough() { result.setDough("두꺼운도우"); }
        public void buildSauce() { result.setSauce("크림소스"); }
        public void buildTopping() { result.setTopping("고르곤졸라치즈+꿀"); }
        public Pizza getResult() { return result; }
    }
    ```

    1. **Product - “완성된 피자”**
        - ConcreteBuilder가 최종적으로 만들어내는 결과물
        - 서로 다른 클래스여도 상관없음

    ```java
    class Pizza {
        private String dough;
        private String sauce;
        private String topping;
        // getter/setter...
    }
    ```

    1. **Director - “매니저(레시피 순서 관리자)”**
        - 어떤 순서로 조립할지 정의해서 특정 설정을 재사용

    ```java
    class PizzaDirector {
        private PizzaBuilder builder;
    
        public PizzaDirector(PizzaBuilder builder) {
            this.builder = builder;
        }
    
        // 레시피 순서를 정의
        public void makeSimplePizza() {
            builder.reset();
            builder.buildDough();
            // 소스, 토핑 생략 (심플하게)
        }
    
        public void makeFullPizza() {
            builder.reset();
            builder.buildDough();
            builder.buildSauce();
            builder.buildTopping();  // 풀코스
        }
    }
    ```

    1. **Client - “손님(연결하는 역할)”**
        - Builder를 만들어서 Director에 주입하고, 완성된 Product를 받아감

    ```java
    // 손님이 불고기 피자를 주문
    BulgogiPizzaBuilder builder = new BulgogiPizzaBuilder();
    PizzaDirector director = new PizzaDirector(builder);
    
    director.makeFullPizza();           // 디렉터가 순서 지시
    Pizza myPizza = builder.getResult(); // 완성된 피자 수령 🍕
    
    // 이번엔 고르곤졸라로 바꿔서 주문
    GorgonzolaPizzaBuilder builder2 = new GorgonzolaPizzaBuilder();
    director.changeBuilder(builder2);   // 같은 디렉터, 다른 빌더
    
    director.makeFullPizza();
    Pizza myPizza2 = builder2.getResult(); // 🍕
    ```

    ```java
    **<전체 흐름 요약>**
    Client → Builder 생성
           → Director에 Builder 주입
           → Director.make() 호출 (순서 지시)
           → Builder.getResult() 로 완성품 수령
    ```

- record vs static class

  ### Record

    - 값을 저장하기 위한 클래스를 짧게 만드는 문법

    ```java
    < 학생 정보를 저장하는 클래스 >
    class Student {
        private final String name;
        private final int age;
    
        public Student(String name, int age) {
            this.name = name;
            this.age = age;
        }
    
        public String name() { return name; }
        public int age() { return age; }
    }
    ```

    ```java
    < record 사용 >
    record Student(String name, int age) {}
    ```

    - ! record의 필드는 기본적으로 final
    - 즉, 한 번 만들면 값을 바꾸는 용도로 쓰기 어려움

  ### Static class

    - 클래스 안에 들어있는 static 클래스

    ```java
    class Outer {
        static class Inner {
            void hello() {
                System.out.println("Hello");
            }
        }
    }
    
    Outer outer = new Outer(); // 필요 없음
    Outer.Inner inner = new Outer.Inner();
    ```

    - Outer 객체를 만들지 않아도 사용할 수 있음

  |  | recode | static class |
      | --- | --- | --- |
  | 목적 | 데이터를 간단히 저장 | 클래스 안에 관련 클래스를 묶어두기 |
  | 위치 | 독립적으로도 선언 가능 | 반드시 다른 클래스 안에 선언 |
  | 생성자, getter, toString(), equals(), hashCode() | 자동 생성 | 직접 작성 |
  | 값 변경 | 기본적으로 불변 | 만들기 나름 |
- 제네릭이란?
    - **클래스 내부에서 지정하는 것이 아닌 외부에서 사용자에 의해 지정되는 것**

  <장점>

    - 제네릭을 사용하면 잘못된 타입이 들어올 수 있는 것을 컴파일 단계에서 방지할 수 있음
    - 클래스 외부에서 타입을 지정해주기 때문에 따로 타입을 체크하고 변환해줄 필요가 없음. 즉, 관리하기가 편함
    - 비슷한 기능을 지원하는 경우 코드의 재사용성이 높아짐

  | 타입 | 설명 |
      | --- | --- |
  | <T> | Type |
  | <E> | Element |
  | <K> | Key |
  | <V> | Value |
  | <N> | Number |

  ### 1. 클래스 및 인터페이스 선언

    ```java
    // 기본적으로 제네릭 타입의 클래스나 인터페이스의 경우
    public class ClassName <T> { ... }
    public interface InterfaceName <T> { ... }
    
    // 제네릭 타입 두 개
    public class ClassName <T, K> { ... }
    public interface InterfaceName <T, K> { ... }
    
    // HashMap의 경우
    public class HashMap <K, V> { ... }
    ```

    ```java
    public class ClassName <T, K> { ... }
    
    public class Main {
    	public static void main(String[] args) {
    		ClassName<String, Integer> a = new ClassName<String, Intger>();
    	}
    }
    ```

    - 객체를 생성해야 하는데 구체적인 타입을 명시
    - T는 String, K는 Integer이 됨
    - !주의! 타입 파라미터로 명시할 수 있는 것은 참조 타입(Reference Type)
    - 즉, int,double, char 같은 primitive type 올 수 없음
    - 그래서 int, double 등의 경우 Integer, Double과 같은 Wrapper Type으로 씀

  ### 2. 제네릭 클래스

    - 객체를 만들 때 타입을 정해두는 방식

    ```java
    class ClassName<E> {
    	private E element;
    	
    	void set(E element){
    		this.element = element;
    	}
    	E get() {
    		return element;
    	}
    }
    
    class Main {
    	public static void main(String[] args) {
    		ClassName<String> a = new ClassName<String>();
    		CLassName<Integer> b = new ClassName<Integer>();
    		
    		a.set("10");
    		b.set(10);
    		
    		System.out.println("a data : " + a.get());
    		// 반환된 변수의 타입 출력 
    		System.out.println("a E Type : " + a.get().getClass().getName());
    		
    		System.out.println();
    		System.out.println("b data : " + b.get());
    		// 반환된 변수의 타입 출력 
    		System.out.println("b E Type : " + b.get().getClass().getName());
    		
    	}
    }
    ```

    - ClassName이란 객체를 생성할 때 <> 안에 타입 파라미터를 지정
    - a 객체의 ClassName의 E 제네릭 타입은 String으로 모두 변환
    - b 객체의 ClassName의 E 제네릭 타입은 Integer으로 모두 변환

    ```java
    // 출력 결과
    a data : 10
    a E Type : java.lang.String
    
    b data : 10
    b E Type : java.lang.Integer
    ```

  ### 3. 제네릭 메소드

    - 별도 메소드에 한정한 제네릭도 사용할 수 있음
    - 메소드를 호출할 때 넣은 값에 따라 타입이 그때그때 정해지는 방식

    ```java
    public <T> T genericMethod(T o) {	// 제네릭 메소드
    		...
    }
     
    [접근 제어자] <제네릭타입> [반환타입] [메소드명]([제네릭타입] [파라미터]) {
    	// 텍스트
    }
    ```

    - 클래스와는 다르게 반환타입 이전에 <> 제네릭 타입을 선언

    ```java
    class ClassName {
        <T> T genericMethod(T o) { //제네릭 메소
            return o;
        }
    }
    
    public class Main {
        public static void main(String[] args) {
            ClassName a = new ClassName();
    
            System.out.println(a.genericMethod(3).getClass().getName());
            System.out.println(a.genericMethod("ABCD").getClass().getName());
            System.out.println(a.genericMethod(3.14).getClass().getName());
        }
    }
    ```

- @RestControllerAdvice이란?

  ### @ControllerAdvice

    - Spring 3.2에서 도입된 어노테이션
    - 모든 @Controller 클래스가 공유하는 공통 로직을 정의할 때 사용
    - 주로 예외 처리와 바인딩 설정, 모델 객체 등에 사용

    ```java
    // NotFoundException이 발생할 경우 "error"라는 이름의 뷰로 이동하고 메시지를 출력
    @ControllerAdvice
    public class GlobalControllerExceptionHandler {
    
        @ExceptionHandler(NotFoundException.class)
        public ModelAndView handleNotFoundException(NotFoundException ex) {
            ModelAndView mav = new ModelAndView("error");
            mav.addObject("message", ex.getMessage());
            return mav;
        }
    }
    ```

  ### @RestControllerAdvice

    - @ControllerAdvice와 거의 동일
    - 한 가지 차이점은 어노테이션을 사용하면 @ResponseBody가 암시적으로 추가된다는 것
    - 따라서 JSON 형태로 바로 응답을 보낼 수 있음

    ```java
    @RestControllerAdvice
    public class GlobalRestControllerAdvice {
    
        @ExceptionHandler(NotFoundException.class)
        public ResponseEntity<?> handleNotFoundException(NotFoundException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
        }
    }
    ```

  ### 어떤 것을 선택할까?

    - 전통적인 웹 애플리케이션을 구축한다면 @ControllerAdvice
    - RESTful API를 만든다면 @RestControllerAdvice가 적합
- Optional이란?

  ### NPE(NullPointerException)

    - null인 객체를 참조하려 할 때 발생하는 런타임 예외

    ```java
    List<String> names = getNames();
    names.sort(); // names가 null이라면 NPE가 발생함
    
    List<String> names = getNames();
    // NPE를 방지하기 위해 null 검사를 해야함
    if(names != null){
        names.sort();
    }
    ```

  ### Optional

    - Optional<T>는 null이 올 수 있는 값을 감싸는 Wrapper 클래스로, 참조하더라도 NPE가 발생하지 않도록 도와줌
    - Optional 클래스는 아래와 같은 value에 값을 저장하기 때문에 값이 null이더라도 바로 NPE가 발생하지 않으며, 클래스이기 때문에 각종 메소드를 제공해줌

    ```java
    public final class Optional<T> {
      private final T value;
      ...
    }
    ```

    1. Optional 생성하기

        1) Optional.empty() - 값이 NULL인 경우

        - Optional은 Wrapper 클래스이기 때문에 값이 없을 수도 있는데, 이때는 Optional.empty()로 생성

        ```java
        Optional<String> optional = Optional.empty();
        
        System.out.println(optional); // Optional.empty
        System.out.println(optional.isPresent()); // false
        ```

        - Optional 클래스는 내부에서 static 변수로 EMPTY 객체를 미리 생성해서 가지고 있음. 이러한 이유로 빈 객체를 여러 번 생성해줘야 하는 경우에도 1개의 EMPTY 객체를 공유함으로써 메모리를 절약.

        ```java
        public final class Optional<T> {
        
            private static final Optional<?> EMPTY = new Optional<>();
            private final T value;
            
            private Optional() {
                this.value = null;
            }
            ...
        }
        ```

        2) Optional.of() - 값이 NULL이 아닌 경우

        - 만약 데이터가 절대 null이 아니라면 Optional.of()로 생성할 수 있음

        ```java
        Optional<String> optional = Optional.of("MyName");
        ```

        3) Optional.ofNullbale() - 값이 Null일수도, 아닐수도 있는 경우

        - Optional.ofNullbale로 생성 할 수 있음.
        - 그 이후에 orElse 또는 orElseGet 메소드를 이용해서 값이 없는 경우라도 안전하게 값을 가져올 수 있음

        ```java
        Optional<String> optional = Optional.ofNullable(getName());
        String name = optional.orElse("anonymous"); // 값이 없다면 "anonymous"리터
        ```

    2. Optional 사용법

        ```java
        // 우편번호를 꺼내는 null 검사 코드
        public String findPostCode() {
            UserVO userVO = getUser();
            if (userVO != null) {
                Address address = user.getAddress();
                if (address != null) {
                    String postCode = address.getPostCode();
                    if (postCode != null) {
                        return postCode;
                    }
                }
            }
            return "우편번호 없음";
        }
        ```

        ```java
        // Optional 사용
        public String findPostCode() {
            // 위의 코드를 Optional로 펼쳐놓으면 아래와 같다.
            Optional<UserVO> userVO = Optional.ofNullable(getUser());
            Optional<Address> address = userVO.map(UserVO::getAddress);
            Optional<String> postCode = address.map(Address::getPostCode);
            String result = postCode.orElse("우편번호 없음");
        
            // 그리고 위의 코드를 다음과 같이 축약해서 쓸 수 있다.
            String result = user.map(UserVO::getAddress)
                .map(Address::getPostCode)
                .orElse("우편번호 없음");
        }
        ```
