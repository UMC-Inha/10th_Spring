- 세션과 토큰의 차이는?

  **세션과 토큰**

  기본적으로 상태를 기억하지 않는 환경에서 “이 사용자가 누구인지”를 이어서 확인하기 위한 방식

    - 세션

      서버가 인증 상태를 세션에 저장, 클라이언트는 세션 ID를 보유

    - 토큰

      클라이언트가 인증에 사용할 토큰을 보유, 서버는 요청마다 토큰을 검증


    **세션 방식**
    
    로그인에 성공하면 서버가 세션 저장소에 사용자 인증 상태를 저장
    
    클라이언트는 세션 ID를 쿠키로 받고, 이후 요청마다 그 쿠키를 같이 전송
    
    ```
    1. 클라이언트가 로그인 요청
    2. 서버가 세션 생성
    3. 서버가 세션 ID를 쿠키로 전달
    4. 클라이언트가 이후 요청마다 세션 ID 쿠키 전송
    5. 서버가 세션 ID로 사용자 상태 조회
    ```
    
    ```
    Client → Server : 로그인
    Server → Client : Set-Cookie: JSESSIONID=...
    Client → Server : Cookie: JSESSIONID=...
    Server : 세션 저장소에서 사용자 확인
    ```
    
    세션 방식 : 서버가 상태를 기억→ Stateful
    
    장점
    
    - 서버가 인증 상태를 직접 관리하므로 로그아웃, 만료, 강제 종료 처리가 비교적 명확함
    - 민감한 사용자 정보를 클라이언트에 직접 담지 않아도 됨
    
    단점
    
    - 서버가 세션 상태를 저장해야 함. 여러 대라면? 공유 저장소 필요
    - 쿠키 기반이면 CSRF 같은 문제도 같이 고려해야 함
    
    **토큰 방식**
    
    로그인에 성공하면 서버가 토큰을 발급, 클라이언트가 토큰을 저장
    
    이후 요청마다 토큰을 함께 전송, 서버는 그 토큰을 검증해서 사용자를 확인
    
    ```
    1. 클라이언트가 로그인 요청
    2. 서버가 토큰 발급
    3. 클라이언트가 토큰 저장
    4. 클라이언트가 이후 요청마다 토큰 전송
    5. 서버가 토큰 검증 후 사용자 확인
    ```
    
    ```
    Client → Server : 로그인
    Server → Client : access token
    Client → Server : Authorization: Bearer {token}
    Server : 토큰 검증 후 사용자 확인
    ```
    
    토큰 방식은 서버가 세션을 저장하지 않고 요청마다 토큰을 검증하는 구조로 만들 수 있어서 Stateless에 가깝게 설계할 수 있음
    
    다만 모든 토큰 방식이 완전히 Stateless인 것은 아님
    
    예를 들어 서버가 토큰을 DB나 Redis에 저장하고 매번 조회한다면, 서버 쪽 상태가 섞인 구조가 됨
    
    장점
    
    - 서버가 세션을 저장하지 않아 확장에 유리함
    - 서버가 여러 대여도 토큰 검증만 가능하면 인증 처리가 가능함
    
    단점
    
    - 토큰이 탈취되면 만료 전까지 위험⬆️
    - 로그아웃이나 토큰 강제 만료 처리가 세션보다 복잡함
    - 토큰 저장 위치와 재발급 전략에 주의가 요구
    
    - +JWT와 연결
        
        JWT는 토큰의 한 종류
        
        토큰 안에 사용자 식별자, 권한, 만료 시간 같은 정보를 담고, 서명을 통해 위조 여부를 검증
        
        ```
        Header.Payload.Signature
        ```
        
        하지만 JWT의 Payload는 암호화가 아니라 인코딩에 가까워서 **누구나 디코딩해서 볼 수 있음
        
        그래서 비밀번호, 주민번호, 인증번호 같은 민감한 정보는 넣으면 안 됨.
        
    
    https://velog.io/@ddangle/Session%EC%84%B8%EC%85%98%EA%B3%BC-Token%ED%86%A0%ED%81%B0%EC%9D%98-%EC%B0%A8%EC%9D%B4%EB%8A%94
    
    https://closed-on-sunday.tistory.com/6

- 엑세스 토큰과 리프레시 토큰이란?

  **액세스 토큰과 리프레시 토큰**

    - Access Token

      실제 API에 접근할 때 사용하는 토큰

    - Refresh Token

      Access Token이 만료되었을 때 새 Access Token을 발급받기 위한 토큰


    **Access Token**
    
    사용자가 보호된 리소스에 접근할 때 제출하는 토큰
    
    서버는 Access Token을 보고 “이 요청을 보낸 사용자가 누구인지”, “어떤 권한을 가졌는지”를 확인함
    
    ```
    Client → Server
    Authorization: Bearer {accessToken}
    ```
    
    Access Token은 보통 유효 시간을 짧게 둠
    
    탈취되었을 때 공격자가 그 토큰으로 API를 호출할 수 있기 때문
    
     ex) JWT Access Token
    
    ```json
    {
      "sub": "user@example.com", // subject
      "role": "USER",
      "iat": 1710000000, // issued at -> 발급 시간
      "exp": 1710001800 // expiration time
    }
    ```
    
    **Refresh Token**
    
    Access Token을 새로 발급받기 위해 사용하는 토큰
    
    ```
    1. Access Token 만료
    2. Client가 Refresh Token으로 재발급 요청
    3. Server가 Refresh Token 검증
    4. 새로운 Access Token 발급
    ```
    
    ```
    Client → Server : refresh token
    Server → Client : new access token
    ```
    
    보통 Access Token보다 오래 유지 ⇒ 더 조심해서 관리
    
    **나누는 이유**
    
    Access Token 길게 유지 → 사용자는 편리, but 탈취되었을 때 위험 시간⬆️
    
    Access Token 짧게 유지 → 사용자가 자주 다시 로그인해야 해서 불편
    
    ⇒ **Refresh Tok**en을 두어 Access Token을 재발급 받을 때만 사용
    
    **주의점**
    
    로그아웃을 구현하려면 Refresh Token을 삭제하거나 더 이상 사용할 수 없게 만드는 처리가 필요함
    
    JWT Access Token은 이미 발급된 뒤 만료 전까지 유효
    
    ⇒ 즉시 무효화가 필요하다면 블랙리스트나 토큰 버전 관리 같은 추가 전략이 필요
    
    https://inpa.tistory.com/entry/WEB-%F0%9F%93%9A-Access-Token-Refresh-Token-%EC%9B%90%EB%A6%AC-feat-JWT

- OAuth 1.0과 OAuth 2.0의 차이는?

  **OAuth**

  사용자가 자신의 비밀번호를 직접 넘기지 않고, 특정 서비스가 내 정보나 리소스에 제한적으로 접근할 수 있도록 권한을 위임하는 방식

  ⇒ 비밀번호를 알려주지 않고 접근 권한만 위임하는 프레임워크

  ex) 카카오 계정으로 로그인, 구글 캘린더 접근 권한을 허용

  **OAuth 1.0**

  OAuth의 초기 버전

  요청마다 서명을 만들어서 요청이 변조되지 않았는지 확인하는 방식

  OAuth 1.0에서는 클라이언트가 요청을 보낼 때 여러 값들을 조합해서 서명을 만들고, 서버는 같은 방식으로 서명을 검증함

  ⇒ 보안⬆️, but 구현이 복잡함

  특징

    - 요청마다 서명(signature)을 생성해서 검증
    - 토큰뿐 아니라 토큰 시크릿도 함께 다룸
    - HTTPS에만 의존하지 않고 요청 자체의 서명 검증을 중요하게 봄
    - 구현 난이도가 높고, 클라이언트 입장에서 처리할 것이 많음

    ```
    요청 정보 + nonce + timestamp + secret
    → signature 생성
    → 서버가 signature 검증
    ```

  **OAuth 2.0**

  OAuth 1.0을 더 단순하고 유연하게 다시 설계한 버전

  오늘날 대부분의 소셜 로그인, 외부 API 권한 위임에서 OAuth 2.0이 사용

  OAuth 2.0에서는 Access Token을 발급, 클라이언트는 그 토큰을 이용해서 리소스 서버에 요청

  Bearer Token 방식 → 토큰을 가진 사람이 권한을 가짐
  ⇒ 토큰이 탈취되지 않도록 HTTPS 사용과 토큰 보관이 중요

  특징

    - Access Token 중심의 구조
    - Authorization Code, Client Credentials 같은 여러 흐름을 제공
    - 모바일 앱, SPA, 서버 사이드 웹 등 다양한 클라이언트 환경을 고려
    - Refresh Token을 통한 재발급 구조를 사용할 수 있음
    - 구현은 OAuth 1.0보다 단순하지만, 토큰 보호가 매우 중요

    ```
    1. 사용자가 권한 동의
    2. 클라이언트가 Authorization Code 받음
    3. 클라이언트가 Code로 Access Token 요청
    4. Access Token으로 리소스 서버에 접근
    ```

  https://velog.io/@hyg8702/OAuth%EB%9E%80-OAuth1-vs-OAuth2