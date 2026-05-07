## 빌더 패턴 (Builder Pattern) 이란?

**복잡한 객체 생성 과정을 단계적으로 생성할 수 있도록 단순화하는 생성 디자인 패턴**이다. 즉, 객체 생성에 필요한 매개변수가 많거나, 객체 생성 과정이 복잡할 때 유용한 패턴이다.

### 빌터 패턴을 사용하지 않는다면

```java
public class Pizza {
    private String dough;      // 도우
    private String sauce;      // 소스
    private String cheese;     // 치즈
    private String topping1;   // 토핑1
    private String topping2;   // 토핑2
    private String topping3;   // 토핑3
    private int size;          // 사이즈
    
    // 기본 피자
    public Pizza(String dough, String sauce, String cheese, int size) {
        this.dough = dough;
        this.sauce = sauce;
        this.cheese = cheese;
        this.size = size;
    }
    
    // 토핑 1개 추가
    public Pizza(String dough, String sauce, String cheese, int size, 
                 String topping1) {
        this.dough = dough;
        this.sauce = sauce;
        this.cheese = cheese;
        this.size = size;
        this.topping1 = topping1;
    }
    
    // 토핑 2개 추가
    public Pizza(String dough, String sauce, String cheese, int size, 
                 String topping1, String topping2) {
        this.dough = dough;
        this.sauce = sauce;
        this.cheese = cheese;
        this.size = size;
        this.topping1 = topping1;
        this.topping2 = topping2;
    }
    
    // 토핑 3개 추가
    public Pizza(String dough, String sauce, String cheese, int size, 
                 String topping1, String topping2, String topping3) {
        this.dough = dough;
        this.sauce = sauce;
        this.cheese = cheese;
        this.size = size;
        this.topping1 = topping1;
        this.topping2 = topping2;
        this.topping3 = topping3;
    }
}

// 사용 예시
Pizza pizza1 = new Pizza("씬", "토마토", "모짜렐라", 12);
Pizza pizza2 = new Pizza("씬", "토마토", "모짜렐라", 12, "페퍼로니");
Pizza pizza3 = new Pizza("씬", "토마토", "모짜렐라", 12, "페퍼로니", "올리브");
```

위의 예시에서 토핑은 필수 매개변수가 아니며, 토핑이 필요한 개수만큼 **여러 생성자를 오버로딩**하여 사용해야한다.

만약 여기서 더 많은 클래스 필드가 생기고 생성자의 경우의 수가 많아지면 구현해야 할 생성자는 더 많아지면서 **생성자 매개변수의 순서도 헷갈릴 여지가 있고 가독성이나 유지보수 측면에서도 좋지 않다.**

**→ 빌더 패턴을 사용함으로써 이런 문제를 해결할 수 있다.**

## 빌더 패턴을 적용한다면

```java
public class Pizza {
    // 필수 필드
    private final String dough;
    private final int size;
    
    // 선택적 필드
    private final String sauce;
    private final String cheese;
    private final String topping1;
    private final String topping2;
    private final String topping3;
    
    // private 생성자 - 외부에서 직접 생성 불가
    private Pizza(Builder builder) {
        this.dough = builder.dough;
        this.size = builder.size;
        this.sauce = builder.sauce;
        this.cheese = builder.cheese;
        this.topping1 = builder.topping1;
        this.topping2 = builder.topping2;
        this.topping3 = builder.topping3;
    }
    
    // 정적 내부 클래스로 빌더 구현
    public static class Builder {
        // 필수 필드
        private final String dough;
        private final int size;
        
        // 선택적 필드 - 기본값 설정
        private String sauce = "토마토";
        private String cheese = "모짜렐라";
        private String topping1;
        private String topping2;
        private String topping3;
        
        // 필수 매개변수만 받는 생성자
        public Builder(String dough, int size) {
            this.dough = dough;
            this.size = size;
        }
        
        // 각 선택적 필드에 대한 setter 메서드
        // this를 반환하여 메서드 체이닝 가능
        public Builder sauce(String sauce) {
            this.sauce = sauce;
            return this;
        }
        
        public Builder cheese(String cheese) {
            this.cheese = cheese;
            return this;
        }
        
        public Builder topping1(String topping1) {
            this.topping1 = topping1;
            return this;
        }
        
        public Builder topping2(String topping2) {
            this.topping2 = topping2;
            return this;
        }
        
        public Builder topping3(String topping3) {
            this.topping3 = topping3;
            return this;
        }
        
        // 최종적으로 Pizza 객체를 생성하여 반환
        public Pizza build() {
            return new Pizza(this);
        }
    }
}
```

1. 객체의 필수 매개변수를 `private final` 필드로 갖고, 객체의 선택 매개변수는 일반 `private` 필드로 갖는다.
2. 필수 매개변수를 빌더 생성자의 매개변수로 받고, 선택 매개변수들은 빌더에 매서드를 추가해 주입 가능하도록 한다. 이때, 매서드는 `this`를 반환하여 매서드 체이닝을 가능하게 한다.
3. `build()` 매서드를 사용해 `private` 생성자를 호출하면서 최종 객체를 생성한다.

**➡️ 빌더 패턴 적용 전, 후 사용 예시**

```java
// 기본 피자 (필수 필드만)
Pizza pizza1 = new Pizza.Builder("씬", 12)
    .build();
    
// 토핑 2개 추가 (순서 상관없음!)
Pizza pizza3 = new Pizza.Builder("씬", 12)
    .topping1("페퍼로니")
    .topping2("올리브")
    .build();
    
// 원하는 필드만 선택적으로 설정
Pizza pizza4 = new Pizza.Builder("씬", 12)
    .sauce("크림")
    .topping2("베이컨")  // topping1은 건너뛰고 topping2만 설정 가능
    .topping3("양파")
    .build();
```

### 빌더 패턴의 장점

**1️⃣ 가독성 향상**

- 기존 방식
    
    ```java
    Pizza old = new Pizza("씬", "토마토", "모짜렐라", 12, "페퍼로니", "올리브");
    ```
    
    **→ 어떤 값이 어떤 필드인지 직관적으로 확인하기 어렵다.**
    
- 빌더 패턴
    
    ```java
    Pizza new = new Pizza.Builder("씬", 12)
        .sauce("토마토")
        .cheese("모짜렐라")
        .topping1("페퍼로니")
        .topping2("올리브")
        .build();
    ```
    
    **→ 각 값이 무엇을 의미하는지 명확하게 확인 가능하다.**
    

**2️⃣ 유연성 증가**

```java
Pizza flexiblePizza = new Pizza.Builder("씬", 12)
    .topping3("베이컨")  // 중간 필드를 건너뛸 수 있음
    .build();
```

**→ 중간 필드를 건너 뛰거나 순서를 신경쓰지 않고 편의대로 객체를 생성할 수 있다.**

**3️⃣ 생성자 폭발 문제 해결**

- 빌더 패턴을 사용하면 가능한 모든 경우의 생성자를 정의할 필요 없이, 빌더 클래스 하나로 모든 경우의 수를 포함할 수 있다.

**4️⃣ 불변 객체 생성**

- 빌더 패턴을 사용하면 모든 필드를 final로 선언이 가능하기 때문에 불변 객체를 생성할 수 있다.
- 만약 setter 주입과 같은 방법을 사용한다면 final로 선언할 수 없기 때문에 불변 객체를 생성할 수 없다.

**5️⃣ 유효성 검증 추가 용이**

- 빌더 클래스 내부 매서드에 유효성 검증하는 로직을 추가할 수 있다.
    
    ```java
    public Pizza build() {
        // 객체 생성 전 유효성 검증
        if (size < 8 || size > 20) {
            throw new IllegalArgumentException("피자 크기는 8~20인치여야 합니다.");
        }
        
        if (dough == null || dough.isEmpty()) {
            throw new IllegalArgumentException("도우는 필수입니다.");
        }
        
        return new Pizza(this);
    }
    ```
    

### Lombok 라이브러리의 @Builder

Spring에서 제공하는 Lombok라이브러리의 `@Builder` 어노테이션을 이용하면 쉽게 빌더패턴을 적용할 수 있다.

```java
@Builder
public class Pizza {
    // 필수 필드
    private final String dough;
    private final int size;
    
    // 선택적 필드
    private final String sauce;
    private final String cheese;
    private final String topping1;
    private final String topping2;
    private final String topping3;
}
```

- 빌더 패턴을 적용하고자 하는 클래스 위에 @Builder를 붙인다.
- 컴파일할 때 **빌더 객체를 반환하는 정적 메서드**가 생성되고, **정적 내부 클래스로 빌더 클래스**가 생성된다.

`@Builder.Default` 를 이용해 초기값을 설정하고 싶은 필드에 default값을 설정할 수 있다. `final` 변수가 아니라면 빌더 패턴을 사용하여 값을 재주입할 수 있다.

양방향 매핑을 설정해 필드로 **컬렉션 타입**을 가지고 있는 경우에는 초기화가 되지 않는 경우를 주의해야하며, `@Builder.Default`를 사용해 빌더 패턴을 통해 값을 주입하지 않아도 초기화가 되도록 해야한다.

```java
// 컬렉션 필드 초기화 예시
@OneToMany(mappedBy = "aiAnalysis", cascade = CascadeType.ALL, orphanRemoval = true)
@Builder.Default
private List<AIMatchedMaterial> aiMatchedMaterials = new ArrayList<>();
```

## public static DTO

- **하나의 클래스 안에 여러개의 static class를 정의해 여러개의 DTO를 체계적으로 관리할 수 있는 방식**이다.
- static class를 선언하면 더 적은 메모리를 사용하며, 바깥 클래스에 대한 참조가 필요 없기 때문에 가비지 컬렉션의 대상이 된다.

```java
public class MemberDTO {
		
		public static class MemberSimpleDTO {
				public Long id,
				public String name
		}
		
		public static class MemberDetailDTO {
				public Long id,
				public String name,
				public int age,
				public String birth
		}
}
```

## Record 란?

Java 16 에서 정식으로 출시된 특별한 유형의 클래스로, **불변** 데이터를 간결하고 읽기 쉽게 전달하는 데 초점을 두고 있으며 DTO를 기존 클래스로 구현했을 때 필요했던 반복적인 코드를 많이 줄여준다.

- 불변성: record 객체가 한 번 생성되면, 내부 데이터를 변경할 수 없다.
- 간결한 문법: 필드만 선언하면 Java가 자동으로 **생성자, Getter, equals(), hashCode(), toString()** 메서드를 생성한다. 따라서 코드가 간결해지고 가독성이 좋아진다.
- Setter 없음: Record는 불변 객체이기 때문에 Setter를 사용할 수 없다.

```java
@Builder
public record MatchingRes(
        Long id,
        Long requestUserId,
        Long targetUserId
) {}
```

→ 빌더패턴은 자동으로 제공하지 않기 때문에 보통 같이 붙여 사용한다.

```java
public class AuthReqDTO {

    public record SignUpDTO(
            String name,
            String phoneNumber,
            String companyName,
            String email,
            String regionName, 
            String password,
            String passwordCheck
    ){}

    public record LoginDTO(
            String email,
            String password
    ) {}

    public record RefreshTokenDTO(
            String refreshToken
    ) {}
}
```

→ `static class`와 마찬가지로 하나의 클래스안에서 여러 레코드를 적용해 **맥락이 유사한 DTO들을 체계적으로 관리할 수 있다.**

### DTO(class) vs Record

보통 DTO는 데이터를 담고, 옮기는 역할로 사용된다. **수정자가 필요한 경우는 거의 없다.** 또한 데이터베이스에 저장되지 않고 일회성으로 사용되기 때문에 중간에 값이 변경되는 경우도 드물다.

이러한 이유로 개인적으로 자바의 record를 최대한 활용해 DTO 클래스를 정의할 때 생기는 보일러 플레이트 코드를 최대한 줄이는 방식으로 구현하는 방식을 선호한다.

## Java 제네릭(Generic)이란?

**클래스, 인터페이스, 메서드**에서 사용할 데이터 타입을 외부에서 지정하는 기법이다.

제네릭을 사용하여 클래스나 메서드의 내부에서 사용되는 **객체의 타입 안정성을 높일 수 있으며**, 컴파일 시 타입 검사를 수행하기 때문에 **타입 변환 및 타입 검사에 직접 신경쓰지 않아도 된다.**

### 제네릭 등장 배경

```java
List list = new ArrayList();

list.add("안녕"); // String 추가
list.add(new Integer(12)); // Integer 추가
list.add(new Car("자동차")); // Car 추가
```

→ 위와 같이 하나의 `List`에 여러 타입의 객체들이 들어갈 수 있다.

```java
String string = (String) list.get(0);
```

→ `list.get()`의 반환 타입이 무조건 Object이기 때문에, **casting이 필수이다.**

```java
String string = (String) list.get(1);
```

→ 만약, 다른 타입의 객체를 잘못 꺼낸다면 `ClassCastException` 예외가 발생한다.

**따라서 제네릭을 사용하지 않는다면**

- 컴파일러가 타입관련한 에러를 발견하지 못해서, 런타임에 의도치 않은 에러가 발생할 수 있다.
- 데이터를 꺼낼때마다 직접 캐스팅을 해주어야하기 때문에 코드가 지저분해지고 번거롭다.
- 런타임 에러를 예측하기 힘들기 때문에 프로그램이 의도치 않게 죽어버릴 수 있다.

## 제네릭 사용 방법

### 타입 매개변수

**다이아몬드 연산자 (<>)**에 파라미터 기호를 넣어 어떤 값이 들어 가야 하는지 명시적으로 표시할 수 있다. 

**타입 파라미터에 할당받을 수 있는 타입은 Reference 타입 뿐**이고, int형이나 double형 같은 자바 원시 타입을 제네릭 타입 파라미터로 넘길 수 없다.

- **E** - Element (컬렉션에서 주로 사용)
- **K** - Key
- **V** - Value
- **N** - Number
- **T** - Type
- **S**, **U**, **V** - 2번째, 3번째, 4번째 타입

### 제네릭 클래스

제네릭을 클래스 단위로 적용해 원하는 타입을 클래스 내부에서 사용할 수 있다.

```java
public class Box<T> {  // T는 타입 매개변수
    private T item;
    
    public void setItem(T item) {
        this.item = item;
    }
    
    public T getItem() {
        return item;
    }
}
```

### 제네릭 인터페이스

클래스와 마찬가지로 인터페이스 단위로 적용해 원하는 타입을 인터페이스 내부에서 사용할 수 있다.

```java
public interface Repository<T> {
    void save(T item);
    T findById(Long id);
    List<T> findAll();
    void delete(T item);
}
```

### 제네릭 메서드

제네릭을 매서드 단위로 적용해 원하는 타입을 지정해 메서드를 호출할 수 있다.

```java
public class Util {
    // 제네릭 메서드: 반환 타입 앞에 <T> 선언
    public static <T> T getMiddle(T... array) {
        return array[array.length / 2];
    }
    
    // 두 개의 타입 매개변수 사용
    public static <K, V> void printPair(K key, V value) {
        System.out.println(key + ": " + value);
    }
}
```

### 제네릭의 타입 제한과 와일드 카드

**extends T : 상한 경계 →** `<K extends T>`: T와 T의 자손 타입만 가능 (K는 들어오는 타입으로 지정)

**super T : 하한 경계 →** `<K super T>` : T와 T의 부모(조상) 타입만 가능 (K는 들어오는 타입으로 지정)

**<?> : 와일드 카드**

- `<? extends T>` : T와 T의 자손 타입만 가능
- `<? super T>` : T와 T의 부모(조상) 타입만 가능
- `<?>` : 모든 타입 가능 = `<? extends Object>`

## @ControllerAdvice란?

`@ExceptionHandler`, `@ModelAttribute`, `@InitBinder` 가 적용된 메소드들에 **AOP**를 적용하여 Controller에 적용하기 위해 사용되는 어노테이션이다. (보통은 ExceptionHandler목적으로 많이 사용한다.)

`@ControllerAdvice`는 클래스에 선언되며, 모든 컨트롤러에 걸쳐 공통으로 부가 기능을 설정 할 수 있게 해준다.

`@RestControllerAdvice` 는 이런 기능에 `@ResponseBody` 가 추가된 어노테이션으로 응답을 **Json**형태로 하고자 할 때 사용한다.

### ⭐️ @ExceptionHandler

- 컨트롤러에서 **전역적으로 발생하는 예외**를 한번에 처리 가능하게 해준다.
- 프로그램 실행 시 발생하는 예외를 전역적으로 처리해주기 때문에, **try-catch 문을 작성하지 않아도 앱이 죽지 않으며 예외를 처리할 수 있다.**

```java
@RestControllerAdvice
public class GeneralExceptionAdvice {
	
	@ExceptionHandler(IllegalArgumentException.class) // IllegalArugumentException이 발생하면 이 핸들러가 실행되는거임.
	public ResponseEntity<String> handleException(
		IllegalArgumentException ex
	) {
		return ResponseEntity.status(HttpStatus.BAD_REQUEST)
													.body(new ErrorResponse(ex.getMessage()));
	}
```

```java
@RestControllerAdvice(assignableTypes = UserController.class)  // 특정 컨트롤러만
public class UserExceptionHandler { }

@RestControllerAdvice(basePackages = "com.example.api")  // 특정 패키지만
public class ApiExceptionHandler { }
```

→ 특정 컨트롤러, 특정 패키지에만 핸들러를 적용할 수 있다.

### @ModelAttribute

- 모든 컨트롤러의 Model에 공통으로 담아줄 데이터를 설정할 수 있다.

```java
@ControllerAdvice
public class GeneralModelAdvice {
	
	@ModelAttribute("username") // 모든 컨트롤러 모델에 username이 자동으로 들어가는거
	public String addUserName() {
			return userService.getLoginUser();
	}
}
```

- json형태를 반환하는 REST방식에서는 컨트롤러가 View를 랜더링 하지 않기 때문에 @RestControllerAdvice 에선 이 행위가 의미가 없다.

### @InitBinder

- 요청 데이터를 객체로 바인딩할 때 사용하는 변환 규칙을 커스터마이징할 수 있다.

```java
@RestControllerAdvice
public class GeneralInitAdvice {
	
	@InitBinder
	public void initBinder(WebDataBinder binder) {
			binder.registerCustomEditor(LocalDate.class, new PropertyEditorSupport() {
				@Override
				public void setAsText(String text) {
						setValue(LocalDate.parse(text));
				}
			});
}
```

- LocalDate 타입의 파라미터를 받을 경우에, 이 바인더가 호출돼서 사용자가 정의한대로 문자열을 바인딩 해준다.

## Optional 이란?

Java 8에서 도입된 클래스로, **값이 있을 수도 있고 없을 수도 있는 상황을 명시적으로 표현하기 위한 컨테이너 객체**이다.

Optional 객체는 값이 존재할 수도 있고, 없을 수도 있다. → `NullPointerException` 예외를 방지할 수 있다.

### Optional의 필요성

- 어떤 메서드가 null을 반환할지 확신할 수 없거나, null 처리를 놓쳐서 발생하는 예외를 피할 수 있다.
- Optional을 사용하게 되면 **코드를 더 명확하게 작성할 수 있고**, **예외 처리를 더 쉽게 할 수 있어** 코드 가독성이 높아지며 유지 보수도 더 편리해진다.

### Optional 객체 생성하기

```java
// 빈 Optional
Optional<Car> optCar1 = Optional.empty();

// null이 아닌 값을 담는 Optional
// car가 null이면 NullPointerException 발생
Optional<Car> optCar2 = Optional.of(car);

// null값을 담을 수 있는 Optional
// car가 null이면 빈 Optional 객체 반환
Optional<Car> optCar3 = Optional.ofNullable(car);
```

### Optional이 제공하는 메서드

- `isPresent()`: Optional의 값이 존재하면 true, 해당 값이 없으면 false를 리턴한다.
- `isEmpty()`: isPresent() 메서드와 반대로 작용한다.
- `get()`: Optional이 감사고 있는 실제 값을 얻기 위해서 사용하며, 만약 Optional의 값이 비어있는 경우, `NoSuchElementException`이 발생한다.
- `ifPresent()`/`ifPresentOrElse()`: 값이 있는 경우이거나,  값이 있거나 없는 경우를 처리할 수 있다.

```java
Optional<String> optionalString = Optional.of("Hello");
optionalString.ifPresent( val -> System.out.println("Optional contains a value: " + val),
() -> System.out.println("Optional is empty") );
```

- `orElse()`/`orElseGet()`/`orElseThrow()`: 값이 없을 경우를 처리하는 메서드이다.

```java
Optional<String> opt = Optional.ofNullable(null);

// 값이 없으므로 "default" 반환
String result = opt.orElse("default");  
System.out.println(result); // default

// 값이 없으므로 람다 실행 -> "computed" 반환
String result2 = opt.orElseGet(() -> "computed");
System.out.println(result2); // computed

// 값이 없으므로 IllegalArgumentException 발생
String result3 = opt.orElseThrow(() -> new IllegalArgumentException("값 없음"));
```

### ✅ Optional 사용 예시

**MemberRepository**

```java
@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {

   Optional<Member> findByEmail(String email);
}
```

**Service**

```java
Member member = memberRepository.findByEmail(email)
			.orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다: " + email));
```

→ `orElseThrow()` 를 활용해서 만약 회원이 존재하지 않는다면 예외를 날리는 방식으로 Optional을 활용할 수 있다.