- Spring Security가 무엇인가?

  **Spring Security**

  Spring 기반 애플리케이션에서 인증, 인가, 보안 공격 방어를 처리하는 보안 프레임워크

  **목적**

  일반적인 보안 처리 필요

    - 로그인한 사용자인지 확인
    - 로그인한 사용자의 권한 확인
    - 비밀번호 암호화
    - CSRF, XSS 같은 보안 위협 대응
    - 인증/인가 실패 시 응답 처리

  Spring Security는 이런 보안 흐름을 필터 기반으로 제공해서, 개발자가 설정을 통해 보안 구조를 만들 수 있게 도움

  **핵심 흐름**

  Spring Security는 요청이 Controller에 도착하기 전에 여러 필터를 거치게 함

  이 필터들의 묶음 : SecurityFilterChain

    ```
    Client
    → Servlet Container
    → Servlet Filter Chain
        → DelegatingFilterProxy
            → SecurityFilterChain
        → Other servlet filters
    → DispatcherServlet
    → Controller
    ```

  **주요 구성 요소**

    - SecurityFilterChain

      요청이 통과하는 보안 필터들의 묶음

    - …AuthenticationFilter

      각자 담당하는 인증 방식에 맞게 요청을 처리, 필요하면 AuthenticationManager에 요청을 위임

      폼 로그인에서는 대표적으로 UsernamePasswordAuthenticationFilter가 사용됨

    - AuthenticationManager

      인증 요청을 받아서 어떤 AuthenticationProvider가 처리할지 넘겨주는 역할

      대표적인 구현체는 ProviderManager

    - …AuthenticationProvider

      실제로 인증 로직을 수행하는 객체

    - UserDetailsService

      DB나 저장소에서 사용자 정보를 가져오는 역할, 결과를 UserDetails로 반환

    - SecurityContextHolder

      현재 요청의 SecurityContext를 보관, SecurityContext 내부에는 `Authentication`이 들어있고, 그 안에는 인증 주체, 권한, 인증 여부, 부가 정보 등이 담긴다.


    ```java
    Authentication authentication = SecurityContextHolder
            .getContext()
            .getAuthentication();
    ```
    
    **인증 흐름 예시**
    
    폼 로그인 기준
    
    ```
    로그인 요청
     → UsernamePasswordAuthenticationFilter
     → ProviderManager(AuthenticationManager)
     → AuthenticationProvider
     → UserDetailsService
     → SecurityContext에 인증 정보 저장
    ```
    
    - +예외처리
        
        Spring Security에서 인증이나 인가에 실패 → 일반 Controller 예외 처리와는 다른 흐름
        
        보안 예외는 Controller에 도달하기 전에 필터에서 발생하는 경우가 다수
        
        ⇒ `ExceptionTranslationFilter`가 처리 (@ControllerAdvice가 아님)
        
        - 인증 실패 → `AuthenticationException`
            
            `AuthenticationEntryPoint` 호출
            
            → 401 Unauthorized
            
        - 인가 실패 → `AccessDeniedException`
            
            `AccessDeniedHandler` 호출
            
            → 403 Forbidden
            
    
    https://www.elancer.co.kr/blog/detail/235
    
    https://docs.spring.io/spring-security/reference/servlet/authentication/architecture.html

- 인증(Authentication) vs 인가(Authorization)

  **인증(Authentication)**

  사용자의 신원을 확인하는 과정

  ex) 로그인 시 ID, 비밀번호를 검사하는 과정

    ```
    사용자 로그인 요청
     → ID/비밀번호 확인
     → 사용자 정보가 맞으면 인증 성공
    ```

  **인가(Authorization)**

  인증된 사용자가 특정 리소스에 접근할 권한이 있는지 확인하는 과정

  ex) 로그인은 했지만 관리자 페이지에 접근할 수 없는 경우

    ```
    사용자 요청
     → 로그인 여부 확인
     → 권한 확인
     → 권한이 있으면 접근 허용, 없으면 접근 거부
    ```

  **상태 코드**

  인증 실패와 인가 실패는 HTTP 상태 코드도 다르게 볼 수 있음

    - 401 Unauthorized

      인증되지 않은 사용자 → 로그인 필요

    - 403 Forbidden

      인증은 되었지만 권한이 부족한 사용자 → 접근 권한 필요


    https://dev-hui.tistory.com/11
    
    https://programmer-may.tistory.com/260

- Stateful vs Stateless


    **Stateful**
    
    서버가 클라이언트의 상태를 기억하는 방식
    
    ⇒ 다음 요청을 처리할 때 이전 요청의 정보를 참고
    
    ```
    1번째 요청 : A 작업 시작
    서버 : A 작업 중이라는 상태 저장
    
    2번째 요청 : 다음 단계 진행
    서버 : 이전에 저장한 A 작업 상태를 보고 이어서 처리
    ```
    
    요청 하나만 따로 보면 의미가 부족한 경우가 존재
    
    서버가 이전 상태를 기억하고 있기 때문에, 다음 요청은 그 상태에 의존해서 처리
    
    ex)
    
    - 세션 기반 로그인
        
        서버 세션에 로그인 상태를 저장하고, 다음 요청에서 그 세션을 기준으로 사용자를 식별
        
    - TCP 연결
        
        연결 수립 이후 같은 연결 안에서 상태를 이어가며 통신
        
    
    장점
    
    - 사용자가 매 요청마다 모든 정보를 다시 보내지 않아도 됨
    - 복잡한 흐름을 이어서 처리하기 쉬움
    - 서버가 상태를 알고 있으므로 제어하기 편함
    
    단점
    
    - 서버가 상태를 저장해야 하므로 부담⬆️
    - 서버가 여러 대일 때 상태 공유 문제 발생 가능
    - 특정 서버에 상태가 저장되어 있으면 서버 장애 시 복구가 어려울 수 있음
    
    **Stateless**
    
    서버가 클라이언트의 상태를 기억하지 않는 방식
    
    각 요청은 독립적으로 처리되고, 요청 하나 안에 필요한 정보가 최대한 포함되어 있어야 함
    
    ```
    1번째 요청 : 필요한 정보를 담아서 요청
    서버 : 요청만 보고 처리 후 상태를 저장하지 않음
    
    2번째 요청 : 다시 필요한 정보를 담아서 요청
    서버 : 이전 요청을 몰라도 현재 요청만 보고 처리
    ```
    
    ex)
    
    - 일반적인 HTTP 요청
    - RESTful API
        
        요청 하나가 필요한 정보를 가지고 있고, 서버는 그 요청을 독립적으로 처리하는 방향을 지향
        
    - JWT 기반 인증
        
        서버가 세션을 저장하지 않고, 요청에 포함된 토큰을 검증해서 처리
        
    
    장점
    
    - 서버가 클라이언트 상태를 저장X → 구조가 단순
    - 특정 서버에 의존하지 않기 때문에 확장에 유리 → 서버를 늘리기 쉽다.
    
    단점
    
    - 매 요청마다 필요한 정보를 함께 보내야 함
    - 클라이언트가 상태를 더 많이 관리
    - 요청 데이터가 길어지거나 중복될 수 있음
    
    https://inpa.tistory.com/entry/WEB-%F0%9F%93%9A-Stateful-Stateless-%EC%A0%95%EB%A6%AC
    
    https://blog.naver.com/dev-cloudwoon/223278845744