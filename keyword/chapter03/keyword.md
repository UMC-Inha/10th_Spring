- **SOLID원칙이란?**

  객체지향으로 설계를 할 때에 지켜야 할 5가지 원칙

  ### SRP (단일 책임 원칙 / single responsibility principle)

    - 한 클래스는 하나의 책임만 가져야 한다
        - 책임은 상황에 따라 다른 모호한 것
        - ex) 주문 서비스(OrderService)가 할인 정책의 구체적인 계산 로직을 모르고, 할인 정책 인터페이스를 통해서만 결과를 받아오는 설계
            - 할인 정책 바뀌어도 OrderService는 수정 안 해도 됨
            - → 책임이 분리됨
    - **중요한 기준은 변경**
        - 변경할 때 파급효과가 적으면 SRP를 잘 따른 것

  ### [OCP](https://inpa.tistory.com/entry/OOP-%F0%9F%92%A0-%EC%95%84%EC%A3%BC-%EC%89%BD%EA%B2%8C-%EC%9D%B4%ED%95%B4%ED%95%98%EB%8A%94-OCP-%EA%B0%9C%EB%B0%A9-%ED%8F%90%EC%87%84-%EC%9B%90%EC%B9%99) (개방 폐쇄 원칙 / open/closed principle)

    - 소프트웨어 요소는 확장에는 열려있으나 변경에는 닫혀있어야함
        - 기존의 코드를 변경하지 않으면서, 기능을 추가할 수 있도록 설계가 되어야 한다는 원칙
    - 다형성을 이용!
        - 인터페이스를 구현한 새로운 클래스로 새로운 기능!!!!

  ### LSP (리스코프 치환 원칙 / liskov substitution principle)

    - 자식 객체는 언제나 부모 객체를 대체할 수 있어야 한다
        - 하위 클래스가 상위 클래스의 기능을 변경해서는 안 된다
    - 예상치 못한 오류를 방지하기 위해서 오버라이딩을 조심스럽게 따져가며 해야 한다

  ### DIP (의존 역전 원칙 / dependency inversion principle)

    - 객체에서 어떤 클래스를 참조 해야하는 상황이 생긴다면 해당 클래스를 직접 참조하는 것이 아니라 그 클래스의 상위 요소(추상 클래스 or 인터페이스)를 참조해야 한다
    - OCP랑 비슷하면서도 다르다~
        - OCP는 기능 추가를 할 때 기존의 코드가 변경이 되지 않게 막는 방법
        - DIP는 차 종류가 바뀔 때에 운전자의 코드가 영향을 받지 않게 하는 것
- **DI란?**

  ### DI (의존 관계 주입 / Dependency Injection)

  의존 관계 주입은 쉽게 말하자면 클래스가 필요한 객체를 직접 내부에서 생성하는게 아니라 외부에서 입력 받는 것을 말한다

  EX)

    ```java
    public class RegularCoffeeBean{
    	    public void grind() {
            System.out.println("기본 원두로 갈고 있습니다");
        }
    }
    ```

    ```java
    public class CoffeeMachine {
        private RegularCoffeeBean regularCoffeeBean;
    
        public CoffeeMachine() {
            this.regularCoffeeBean = new RegularCoffeeBean();
        }
    }
    ```

  → 강한 결합

    - 직접 객체를 생성했기 때문에 원두를 바꾸고 싶으면 멤버 바꾸고 생성자도 수정해줘야함

    ```java
    public interface CoffeeBeans {
        void grind();
    }
    ```

    ```java
    @Component("regularBean")
    public class RegularCoffeeBeans **implements** CoffeeBeans {
    
    	  @Override
        public void grind() {
            System.out.println("기본 원두로 갈고 있습니다");
        }
    }
    ```

    ```java
    @Component
    public class CoffeeMachine {
    
    		**@Autowired
    		@Qualifier("regularBean")
        private CoffeeBeans coffeeBeans;**
    
        public void brew() {
            coffeeBeans.grind();
            System.out.println("원두로 커피를 내립니다.");
        }
    }
    ```

  → 느슨한 결합

    - 원두를 바꾸고 싶을 때 어노테이션만 수정하면 바꾸기 가능!

  이렇게 DI를 사용하면 OCP도 자연스럽게 지켜진다!

- **IoC란?**

  ### 제어의 역전 IoC(Inversion of Control)

  일반적인 자바 프로그램에서는 main를 통해 프로그램의 시작을 제어하고 객체의 생성과 필요한 메서드 호출 등을 개발자가 관리하는 반면 제어의 역전은 이런 프로그램의 흐름을 개발자가 아닌 프레임워크 같은 외부 시스템이 관리하는 것을 의미한다

  즉, 객체의 생성과 실행 시점, 메서드 호출 등을 개발자가 아닌 컨테이너가 대신 관리한다

  ### 컨테이너에서의 제어의 역전 예시 : 서블릿

    - 개발자가 서블릿을 작성하고 배포하면, 이후의 실행 흐름은 서블릿 컨테이너가 관리한다
    - 컨테이너는 서버가 시작될 때 서블릿 객체를 생성하고
    - HTTP 요청이 들어오면 요청에 맞는 서블릿을 찾아 적절한 메서드를 호출한다

  → DI는 이런 제어의 역전을 구현하는 대표적인 방법이다

- **생성자 주입 vs 수정자, 필드 주입 차이는?**

  ### 생성자 주입

    - 객체가 생성될 때 필요한 의존성(멤버)를 모조리 받아서 생성하는 것
        - 객체가 생성될 때 무조건 필드에 들어갈 값들을 받아야 한다
        - 생성자는 객체 생성 시점에 딱 1번 호출되기 때문에 주입받는 객체가 변하지 않을 때 주로 사용
            - 추가로 final 키워드로 한 번 주입 받은 값을 변경 못하게 설정 가능

        ```java
        @Service
        public class MemberSignupService {
            private final MemberRepository memberRepository;
        
            **@Autowired
            public MemberSignupService(final MemberRepository memberRepository) {
                this.memberRepository = memberRepository;
            }**
        
        		/* 나머지 로직들 */
        }
        ```

        - Lombok 어노테이션의 @RequiredArgsConstructor 로 대체 가능

  ### Setter 주입

    - 필드 값을 변경하는 Setter 메서드로 의존성(필드의 값들을) 주입
        - 의존성이 주입 되지 않아도 (필드의 값들이 비어있더라도) 객체 생성 가능
        - 따라서 여러 번 해당 메서드를 호출 가능하므로 생성자 주입과 다르게 1회 호출 보장 X
        - 선택적 의존성이 사용되거나 주입 받는 객체가 변할 가능성이 있는 경우 사용 ← 거의 드물다

        ```java
        @Service
        public class MemberSignupService {
        	private MemberRepository memberRepository;
        	
        	@Autowired
        	public void **setMemberRepository**(MemberRepository memberRepository) {
        			this.memberRepository = memberRepository;
        	}
        	
        	/* 나머지 로직들 */
        }
        ```

        - 단점
            - Setter가 호출되지 않으면 memberRepository가 null인 상태로 실행될 수 있다
            - 생성자 주입은 선택적 의존성에 사용되지만, null 위험 때문에 생성자 주입이 더 권장된다
        - @Setter 어노테이션으로 대체 가능

  ### 필드 주입

    - 필드에 직접 의존성을 부여
        - Setter 주입과 마찬가지로 의존성이 주입 되지 않아도 객체 생성 가능
        - 코드가 간단하고 짧다

        ```java
        @Service
        public class MemberSignupService {
        		**@Autowired
        		private MemberRepository memberRepository;**
        	
        	/* 나머지 로직들 */
        }
        ```

        - 단점
            - 외부에서 변경 불가능
            - 테스트가 어렵다
                - 객체를 직접 생성할 때 의존성 주입 불가능
            - 의존성이 뚜렷하게 드러나지 않아서 순환 참조 문제 발생 가능
- **AOP란?**

  ### AOP

  관점 지향 프로그래밍 (Aspect Oriented Programming)

    - 프로젝트 구조를 바라보는 관점을 바꿔보자는 의미
    - 여러 객체에 공통으로 적용할 수 있는 기능을 분리해서 개발자는 반복 작업을 줄이고 핵심 기능 개발에만 집중할 수 있음
        - 공통 관심사: 여러 곳에서 반복되는 기능 (ex. 로그, 보안, 트랜잭션)

  즉,  **AOP는 공통된 기능을 재사용하는 기법**

  ### AOP 주요 개념

    - Target
        - 부가 기능을 추가할 대상
    - Aspect
        - 부가 기능을 가지고 있는 모듈
        - Advice + PointCut
    - Advice
        - Aspect에서 실질적으로 어떤 일을 해야할지에 대한 부가 기능을 담은 구현체
        - Aspect가 무엇을 언제 할지를 정의
    - PointCut
        - 부가기능이 적용될 대상를 선정하는 방법
        - 밑에서 나올 JoinPoint의 상세한 기능을 정의하는 것이라고 생각
    - JoinPoint
        - Advice가 적용될 위치(메서드)
    - Proxy
        - Target을 대신 호출되어 요청을 먼저 받아 처리하는 객체
        - Target 실행 전후에 부가 기능을 끼워 넣을 수 있도록 중간에서 가로채는 역할

  ### 실행 흐름

    1. 핵심 로직 메서드 호출
    2. AOP가 가로채서 (프록시)
    3. 공통 기능 실행 (Advice)
    4. 원래 메서드 실행
    5. 필요하면 이후에도 공통 기능 실행
- **서블릿이란?**

  ### 서블릿

  서블릿은 자바를 사용하여 웹 요청을 처리하고 그에 대한 응답을 생성하는 서버 측 프로그램이다

  주로 클라이언트의 HTTP 요청을 받아 처리하고, 그 결과를 웹 브라우저에 반환하는 역할을 한다

  **동작 방식**

  브라우저가 특정 URL로 HTTP 요청을 보내면, WAS는 `web.xml`에 정의된 **서블릿과 URL 매핑 정보**를 확인 → 매핑된 서블릿이 있다면 해당 서블릿으로 요청 전달 후 결과를 브라우저로 다시 전달

  **서블릿 컨테이너**

  서블릿을 관리하는 환경

    - 서블릿 객체 생성 및 초기화
    - 요청이 들어오면 적절한 서블릿 호출
    - 서블릿의 생명주기 관리
    - 요청과 응답 객체 생성 및 전달

  **생명주기**

    1. init()

    - 서블릿이 처음 생성될 때 한 번 호출
    - 초기화 작업 수행

    2. service()

    - 클라이언트의 요청이 올 때마다 호출
    - 실제 요청 처리 로직 수행

    3. destroy()

    - 서블릿이 종료될 때 한 번 호출
    - 자원 정리 작업 수행