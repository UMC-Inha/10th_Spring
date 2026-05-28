# 1. Session과 Token

## 한 줄 정의

Session과 Token은 사용자의 로그인 상태를 유지하는 방식이다.

```text
Session
-> 서버가 로그인 상태를 기억하고, 클라이언트는 session id를 들고 다닌다.

Token
-> 클라이언트가 인증에 필요한 token을 들고 다니고, 서버는 요청마다 token을 검증한다.
```

둘을 구분할 때 가장 먼저 봐야 하는 질문은 이것이다.

```text
인증 상태를 서버가 기억하는가?
아니면 클라이언트가 증명 수단을 들고 오는가?
```

---

## 왜 필요한가

로그인은 한 번만 하고 끝나는 기능이 아니다.
사용자는 로그인한 뒤에도 계속 여러 API를 호출한다.

```text
로그인
-> 내 정보 조회
-> 리뷰 작성
-> 마이페이지 조회
-> 로그아웃
```

서버는 매 요청마다 이 사용자가 누구인지 알아야 한다.
여기서 문제는 HTTP 자체가 기본적으로 이전 요청을 기억하지 않는다는 점이다.
즉 각 요청은 독립적이다.

```text
첫 번째 요청: 로그인했습니다.
두 번째 요청: 내 정보를 주세요.

서버 입장:
두 번째 요청을 보낸 사람이 첫 번째 요청의 사용자와 같은 사람인가?
```

이 문제를 해결하기 위해 세션이나 토큰을 사용한다.

---

## 예시로 이해하기

세션 기반 로그인을 은행 창구 번호표처럼 생각할 수 있다.

```text
1. 사용자가 로그인한다.
2. 서버가 session을 만든다.
3. 브라우저는 JSESSIONID 같은 session id cookie를 받는다.
4. 이후 요청마다 cookie를 보낸다.
5. 서버는 session id로 저장된 로그인 상태를 찾는다.
```

흐름은 다음과 같다.

```mermaid
sequenceDiagram
    participant Browser
    participant Server
    participant SessionStore

    Browser->>Server: email/password 로그인
    Server->>SessionStore: session id와 사용자 정보 저장
    Server-->>Browser: Set-Cookie: JSESSIONID
    Browser->>Server: Cookie: JSESSIONID
    Server->>SessionStore: session id로 사용자 조회
    Server-->>Browser: 인증된 사용자 응답
```

토큰 기반 인증은 출입증을 들고 다니는 방식에 가깝다.

```text
1. 사용자가 로그인한다.
2. 서버가 access token을 발급한다.
3. 클라이언트는 token을 저장한다.
4. 이후 요청마다 Authorization header에 token을 담는다.
5. 서버는 token이 유효한지 검증한다.
```

```http
Authorization: Bearer access-token
```

---

## Cookie와 Token은 같은 층위가 아니다

인증을 공부할 때 `cookie`와 `token`을 비교하기 보다는 일단 둘은 같은 종류의 개념이 아니다.

```text
Session / Token
-> 인증 상태를 관리하는 방식

Cookie / localStorage / sessionStorage / memory
-> 값을 저장하거나 전달하는 위치와 수단
```

Cookie는 HTTP 자체의 영구 저장공간이 아니다.
브라우저가 가지고 있는 저장소이면서, HTTP header와 함께 동작하는 규칙이다.
[MDN HTTP Cookie 문서](https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/Cookies)는 cookie를 서버가 브라우저에 보내고, 브라우저가 이후 요청에서 다시 서버로 보낼 수 있는 작은 데이터라고 설명한다.

```text
서버 응답:
Set-Cookie: JSESSIONID=abc123; HttpOnly; Path=/

브라우저 저장:
JSESSIONID=abc123

다음 요청:
Cookie: JSESSIONID=abc123
```

전통적인 session 방식에서는 클라이언트가 session id를 cookie에 저장하고, 실제 로그인 상태는 서버 session store에 저장한다.

```text
브라우저 cookie
-> JSESSIONID=abc123

서버 session store
-> abc123 -> memberId=9
```

반대로 JWT를 cookie에 넣을 수도 있다.
이 경우는 session 방식이 아니라 **token 기반 인증 + cookie 전달 방식**이다.

```text
Cookie에 sessionId 저장
-> session 기반

Cookie에 JWT 저장
-> token 기반 + cookie 전달

localStorage에 JWT 저장
-> token 기반 + JavaScript가 Authorization header로 전달
```

---

## SSR, CSR, Next.js, React Native 관점

클라이언트 형태에 따라 인증 방식의 자연스러움이 달라진다.

```text
SSR
-> 서버가 HTML을 조립해서 브라우저에 보냄
-> 페이지 요청에 cookie가 자동으로 붙음
-> 서버가 렌더링 전에 인증하기 쉬움

CSR
-> 브라우저 JavaScript가 화면을 만들고 API를 호출
-> fetch 요청에 Authorization header를 직접 붙이기 쉬움
```

Next.js는 React 기반 프레임워크지만 서버 기능도 함께 제공한다.
그래서 Next는 프론트만 담당할 수도 있고, BFF처럼 동작할 수도 있고, Route Handler나 Server Action으로 풀스택처럼 사용할 수도 있다.
[Next.js Authentication Guide](https://nextjs.org/docs/app/guides/authentication)는 session management와 cookie 기반 인증 흐름을 함께 다룬다.

```text
Next를 프론트로만 사용
-> Next -> Spring/Nest API

Next를 BFF로 사용
-> Browser -> Next -> Spring/Nest API

Next를 풀스택처럼 사용
-> Browser -> Next Server Action/Route Handler -> DB
```

Next가 검색 엔진에 유리하다고 말할 때의 키워드는 보통 SEO, 크롤링, 인덱싱이다.
Next는 SSR뿐 아니라 SSG, ISR, Server Components 같은 방식을 지원한다.
처음 내려가는 HTML에 본문과 metadata가 이미 들어 있으면 검색 엔진이나 소셜 미리보기 봇이 페이지 내용을 이해하기 쉽다.

```text
CSR 중심 React
-> 처음 HTML이 비어 있고 JavaScript 실행 후 화면 구성

SSR/SSG 중심 Next
-> 처음 HTML에 제목, 본문, meta tag가 포함될 수 있음
```

다만 Next를 쓴다고 인증 방식이 하나로 정해지는 것은 아니다.
[Auth.js Session Strategies](https://authjs.dev/concepts/session-strategies)처럼 JWT session과 database session을 모두 지원하는 라이브러리도 있다.

```text
JWT cookie
-> session store 부담을 줄이고 싶을 때 편할 수 있음

database session
-> 강제 로그아웃, 기기별 세션 관리, 즉시 폐기가 중요할 때 편할 수 있음
```

React Native는 React를 쓰지만 브라우저가 아니라 모바일 앱 런타임이다.
따라서 브라우저 cookie를 기본 전제로 보기보다, 보통은 access token이나 refresh token을 Keychain, Keystore, SecureStore 같은 모바일 보안 저장소에 두고 `Authorization: Bearer` 방식으로 API를 호출하는 구성이 자연스럽다.

```text
웹 SSR 중심
-> HttpOnly Cookie 기반 session이 자연스러울 수 있음

웹 + 모바일 앱 + 외부 클라이언트
-> Authorization header 기반 token API가 더 일관적일 수 있음
```

---

## 비교

| 구분 | Session 기반 | Token 기반 |
|---|---|---|
| 인증 상태 위치 | 서버 session store | 클라이언트 token |
| 대표 전달 방식 | Cookie | Authorization header |
| 서버가 하는 일 | session id로 로그인 상태 조회 | token 서명, 만료, claim 검증 |
| 로그아웃 | 서버 session 삭제로 처리 쉬움 | token 폐기 전략 필요 |
| 잘 맞는 환경 | 서버 렌더링 웹, 관리자 페이지 | 모바일 앱, SPA, 외부 API |
| 주의점 | CSRF, session 공유 | XSS, token 탈취, refresh 전략 |

중요한 것은 "토큰이 세션보다 무조건 좋다"가 아니다.
브라우저 서버 렌더링 웹은 cookie/session이 단순할 수 있고, 모바일 앱이나 여러 클라이언트가 공통으로 호출하는 독립 API는 token이 자연스러울 수 있다.

---

## 공부하면서 얻어갈 점

> **Session과 Token은 우열이 아니라 클라이언트 형태와 운영 조건으로 고르는 도구다.**  
> 서버 렌더링 웹은 cookie/session이 단순하고, 모바일 앱이나 SPA는 Authorization header 기반 token이 명확할 수 있다. 중요한 것은 "요즘은 무조건 JWT"가 아니라, 어떤 클라이언트가 어떤 방식으로 인증 상태를 보낼 것인지다.

> **세션은 서버가 상태를 들고 있어서 폐기가 쉽고, 토큰은 서버 간 공유 부담이 줄어드는 대신 폐기가 어렵다.**  

> **브라우저에서 cookie를 쓰면 CSRF를, JavaScript에서 token을 다루면 XSS를 같이 떠올려야 한다.**  
> 인증 방식은 서버 코드만의 문제가 아니라 브라우저가 요청을 자동으로 보내는 방식, JavaScript가 token에 접근할 수 있는지와 연결된다.

> **Cookie와 Token은 경쟁 관계가 아니라 서로 다른 층위의 개념이다.**  
> Cookie는 저장/전송 수단이고, token은 인증을 증명하는 값이다. 그래서 `Cookie에 sessionId 저장`, `Cookie에 JWT 저장`, `localStorage에 JWT 저장`이 모두 가능하다. 이 조합을 구분해야 SSR, CSR, 모바일 앱 인증 방식을 덜 헷갈리게 이해할 수 있다.

---

# 2. Access Token과 Refresh Token

## 한 줄 정의

Access Token과 Refresh Token은 token 기반 인증에서 역할을 나누기 위해 사용하는 두 종류의 토큰이다.

```text
Access Token
-> 실제 API에 접근할 때 사용하는 짧은 수명의 토큰

Refresh Token
-> Access Token이 만료되었을 때 새 Access Token을 발급받기 위한 긴 수명의 토큰
```

---

## 왜 필요한가

Access Token 하나만 아주 길게 만들면 구현은 쉽다.
하지만 token이 탈취되었을 때 피해 시간이 길어진다.

```text
Access Token 만료 시간 30일
-> 탈취되면 30일 동안 API 접근 가능

Access Token 만료 시간 30분
-> 탈취되어도 피해 시간을 줄일 수 있음
-> 대신 사용자가 자주 다시 로그인해야 함
```

Refresh Token은 이 불편함을 줄이기 위한 장치다.

```text
Access Token은 짧게 유지한다.
Refresh Token으로 Access Token을 재발급한다.
```

---

## 예시로 이해하기

모바일 앱을 예로 들어보자.

```text
1. 사용자가 로그인한다.
2. 서버는 Access Token과 Refresh Token을 발급한다.
3. 앱은 Access Token으로 API를 호출한다.
4. Access Token이 만료되면 401이 발생한다.
5. 앱은 Refresh Token으로 새 Access Token을 요청한다.
6. 새 Access Token으로 다시 API를 호출한다.
```

흐름은 다음과 같다.

```mermaid
sequenceDiagram
    participant Client
    participant AuthServer
    participant ApiServer

    Client->>AuthServer: 로그인
    AuthServer-->>Client: Access Token + Refresh Token
    Client->>ApiServer: API 요청 + Access Token
    ApiServer-->>Client: 200 OK
    Client->>ApiServer: 만료된 Access Token으로 요청
    ApiServer-->>Client: 401 Unauthorized
    Client->>AuthServer: Refresh Token으로 재발급 요청
    AuthServer-->>Client: 새 Access Token
```

---

## 저장 위치와 주의점

Refresh Token은 Access Token보다 수명이 길다.
그래서 어디에 저장하고 어떻게 폐기할지 더 중요하다.

| 저장 방식 | 장점 | 주의점 |
|---|---|---|
| Memory | 새로고침 시 사라져 피해 범위가 작음 | 사용자 경험이 불편할 수 있음 |
| localStorage | 브라우저에 오래 유지, 구현이 쉬움 | XSS에 취약, 서버로 자동 전송되지 않음 |
| sessionStorage | 탭 단위로 유지 | XSS에 취약, 탭을 닫으면 사라짐 |
| HttpOnly Cookie | JavaScript에서 직접 읽기 어려움, 서버 요청에 자동 포함 | CSRF, SameSite, CORS 고려 필요 |
| DB/Redis | 강제 로그아웃, rotation, 재사용 감지 가능 | 서버 저장소 관리 필요 |

`HttpOnly Cookie`에 넣으면 JavaScript에서 직접 읽기 어렵다는 장점이 있다.
하지만 cookie는 브라우저가 자동으로 붙여 보내기 때문에 CSRF 관점도 함께 봐야 한다.

Cookie는 만료 방식도 함께 봐야 한다.

```text
Session Cookie
-> Expires / Max-Age가 없음
-> 보통 브라우저 세션이 끝나면 삭제

Persistent Cookie
-> Expires 또는 Max-Age가 있음
-> 지정된 시간까지 유지
```

Cookie가 만료되면 브라우저는 더 이상 요청에 붙여 보내지 않는다.
다시 발급하려면 서버가 응답에서 `Set-Cookie`를 다시 내려줘야 한다.

```text
다시 로그인
-> 새 session cookie 발급

sliding session
-> 요청이 있을 때 만료 시간을 연장하며 Set-Cookie 재발급

refresh token 방식
-> refresh token이 유효하면 새 access token 또는 session cookie 발급
```

JWT를 cookie에 넣는 방식은 전통 session의 모든 단점을 해결하려는 방식이라기보다, 서버 session store 의존성을 줄이려는 stateless session 전략에 가깝다.

| 방식 | 장점 | 단점 |
|---|---|---|
| SessionId in Cookie | 서버에서 즉시 폐기 쉬움, 권한 변경 반영 쉬움 | session store 필요, 서버 확장 시 공유 고민 |
| JWT in HttpOnly Cookie | JS가 token을 읽기 어려움, SSR에서 자연스러움, session store 조회 부담 감소 | CSRF 고려, JWT 즉시 폐기 어려움 |
| JWT in Authorization Header | 모바일/API에 자연스러움, 요청마다 인증 정보가 명시적 | 브라우저 저장 위치 고민, localStorage 사용 시 XSS 위험 |

---

## 공부하면서 얻어갈 점

> **Access Token과 Refresh Token을 나누는 이유는 보안과 사용자 경험의 균형 때문이다.**  
> Access Token을 짧게 두면 탈취 피해를 줄일 수 있지만 사용자가 자주 로그인해야 한다. Refresh Token은 이 불편함을 줄이지만, 수명이 긴 만큼 저장 위치와 폐기 전략이 더 중요해진다.

> **Refresh Token은 "있으면 더 안전한 토큰"이 아니라, 관리 책임이 더 큰 토큰이다.**  
> 실무에서는 Refresh Token rotation, 재사용 감지, 서버 저장소 기반 폐기, 로그아웃 시 삭제 같은 전략이 함께 나온다. 단순히 Refresh Token을 하나 더 발급한다고 인증 설계가 완성되는 것은 아니다.

> **OAuth provider가 주는 access token과 우리 서비스 access token은 구분해야 한다.**  
> Kakao access token은 Kakao API를 호출하기 위한 토큰이고, 우리 서비스 JWT는 우리 API를 호출하기 위한 토큰이다. OAuth 로그인을 구현할 때 이 둘을 섞어 이해하면 흐름이 헷갈린다.

> **JWT를 cookie에 넣는다고 session 방식이 되는 것은 아니다.**  
> cookie는 전달 수단이고 JWT는 token 형식이다. JWT cookie 방식은 서버 session store 부담을 줄일 수 있지만, 이미 발급된 token 폐기와 CSRF 대응을 함께 고민해야 한다.

---

# 3. JWT

## 한 줄 정의

JWT(JSON Web Token)는 JSON claim을 담고, 서명으로 위조 여부를 검증할 수 있는 token 형식이다.

```text
header.payload.signature
```

| 구분 | 내용 |
|---|---|
| Header | token 타입, 서명 알고리즘 |
| Payload | subject, memberId, role, 만료 시간 같은 claim |
| Signature | header와 payload가 위조되지 않았는지 검증하기 위한 서명 |

---

## 왜 필요한가

서버가 session store를 매번 조회하지 않고도 요청을 인증하려면, token 자체에서 필요한 정보를 확인할 수 있어야 한다.
JWT는 이때 자주 쓰이는 형식이다.

```text
클라이언트가 JWT 전달
-> 서버가 서명 검증
-> 만료 시간 확인
-> claim에서 사용자 식별 정보 확인
-> 인증 객체 생성
```

이 방식은 여러 서버가 같은 서명 키나 공개키를 사용해 token을 검증할 수 있다는 장점이 있다.

---

## 예시로 이해하기

쇼핑몰에서 사용자가 내 주문 목록을 조회한다고 하자.

```http
GET /orders/me
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
```

서버는 요청을 Controller로 바로 보내지 않고, 먼저 인증 필터에서 token을 확인한다.

```text
Authorization header 확인
-> Bearer token 추출
-> JWT 서명 검증
-> 만료 시간 검증
-> 사용자 claim 추출
-> SecurityContext에 인증 정보 저장
-> Controller 진입
```

---

## JWT는 암호화가 아니라 서명이다

JWT에서 가장 자주 헷갈리는 부분은 이 지점이다.
JWT의 payload는 Base64URL로 인코딩되어 있을 뿐이며, 누구나 디코딩해서 볼 수 있다.

```text
JWT에 넣으면 안 되는 값
-> 비밀번호
-> 주민등록번호
-> 카드번호
-> 노출되면 안 되는 민감정보
```

JWT의 목적은 내용을 숨기는 것이 아니라, 중간에 바뀌지 않았고 우리 서버가 발급한 token이 맞는지 확인하는 것이다.
[RFC 7519](https://www.rfc-editor.org/rfc/rfc7519)는 JWT를 JSON 객체의 claim을 안전하게 전달하기 위한 compact한 방식으로 정의한다.

---

## 공부하면서 얻어갈 점

> **JWT는 암호화된 상자가 아니라 서명된 문서에 가깝다.**  
> payload는 숨겨진 정보가 아니므로 민감정보를 넣으면 안 된다. JWT를 공부할 때는 "무엇을 넣을 수 있는가"보다 "무엇을 넣으면 안 되는가"를 먼저 생각하는 편이 좋다.

> **JWT를 쓰면 Stateless 인증이 쉬워지지만, 로그아웃과 강제 폐기는 별도 설계가 필요하다.**  
> 서버가 session을 들고 있지 않다는 것은 장점이지만, 이미 발급된 token을 즉시 무효화하기 어렵다는 뜻이기도 하다. 그래서 만료 시간, blacklist, token version, refresh token 폐기 같은 전략이 함께 등장한다.

> **JWT 검증은 Controller가 아니라 Filter에서 끝내는 것이 자연스럽다.**  
> Spring Security는 요청이 Controller에 도달하기 전 Filter Chain에서 인증을 처리한다. 그래서 Controller는 token 문자열을 직접 파싱하기보다, 인증된 사용자 객체를 받아 비즈니스 로직에 집중하는 편이 좋다.

---

# 4. OAuth 1.0과 OAuth 2.0

## 한 줄 정의

OAuth는 사용자의 비밀번호를 직접 공유하지 않고, 제3자 애플리케이션이 사용자의 리소스에 제한적으로 접근할 수 있게 하는 권한 위임 표준이다.

```text
OAuth 1.0
-> 요청마다 서명을 붙여 위조를 막는 방식

OAuth 2.0
-> HTTPS 위에서 bearer token을 주고받는 방식
```

---

## 왜 필요한가

어떤 앱이 사용자의 Kakao 프로필 정보를 가져오고 싶다고 하자.
가장 위험한 방식은 사용자의 Kakao 아이디와 비밀번호를 직접 받는 것이다.

```text
우리 서비스가 Kakao 비밀번호를 직접 받음
-> 사용자는 비밀번호를 제3자에게 알려줘야 함
-> 서비스가 필요 이상의 권한을 가질 수 있음
-> 비밀번호가 유출되면 피해가 커짐
```

OAuth는 이 문제를 권한 위임 방식으로 해결한다.

```text
사용자는 Kakao에서 로그인하고 동의한다.
Kakao는 우리 서비스에 제한된 access token을 발급한다.
우리 서비스는 사용자가 동의한 범위의 Kakao API만 호출한다.
```

---

## OAuth 1.0과 OAuth 2.0 비교

| 구분 | OAuth 1.0 | OAuth 2.0 |
|---|---|---|
| 핵심 방식 | 요청마다 서명 | Bearer Token |
| 보안 전제 | 클라이언트가 요청 서명 생성 | HTTPS와 token 관리가 중요 |
| 구현 난이도 | 상대적으로 복잡 | 상대적으로 단순 |
| 토큰 흐름 | request token, access token | authorization code, access token, refresh token 등 |
| 현재 사용성 | 레거시 성격 | 대부분의 현대 OAuth provider가 사용 |

OAuth 2.0의 bearer token은 이름 그대로 "들고 있는 사람이 사용할 수 있는 토큰"이다.
그래서 전송은 HTTPS로 하고, 저장 위치와 만료 시간을 신중히 설계해야 한다.

---

## 예시로 이해하기

Kakao 로그인을 예로 들면 사용자는 우리 서비스에 Kakao 비밀번호를 알려주지 않는다.

```text
1. 사용자가 "Kakao로 로그인"을 누른다.
2. 사용자는 Kakao 화면에서 로그인한다.
3. 사용자는 프로필, 이메일 제공에 동의한다.
4. Kakao는 우리 서비스로 authorization code를 돌려준다.
5. 우리 서비스는 code를 Kakao access token으로 교환한다.
6. 우리 서비스는 Kakao 사용자 정보를 조회한다.
7. 우리 서비스 회원을 찾거나 만든다.
8. 우리 서비스 JWT를 발급한다.
```

여기서 OAuth는 1번부터 6번까지의 권한 위임 흐름을 설명한다.
7번과 8번은 우리 서비스의 회원 정책과 인증 정책이다.

---

## 공부하면서 얻어갈 점

> **OAuth는 "소셜 로그인" 자체가 아니라 권한 위임 표준이다.**  
> [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749)는 OAuth 2.0을 제3자 애플리케이션이 리소스 소유자를 대신해 제한된 접근 권한을 얻는 프레임워크로 설명한다. 소셜 로그인은 이 권한 위임 흐름을 사용자 식별에 활용한 대표 사례로 보면 된다.

> **OAuth 2.0은 OAuth 1.0보다 구현이 단순해졌지만, bearer token 관리 책임이 커졌다.**  
> [RFC 5849](https://www.rfc-editor.org/rfc/rfc5849)의 OAuth 1.0은 요청 서명 중심이고, OAuth 2.0은 HTTPS와 bearer token을 전제로 한다. 그래서 OAuth 2.0을 쓸 때는 token 탈취, 저장 위치, 만료, scope 관리가 중요해진다.

> **OAuth 로그인 후에도 우리 서비스 인증 체계는 별도로 필요하다.**  
> Kakao가 사용자 정보를 확인해주더라도, 우리 API를 호출할 때 어떤 session이나 JWT를 사용할지는 우리 서비스가 결정해야 한다. 그래서 OAuth 성공 후 우리 서비스 JWT를 발급하는 흐름이 자연스럽다.

---

# 5. OAuth 2.0 Login과 Spring OAuth-Client

## 한 줄 정의

Spring OAuth-Client는 Spring Security에서 OAuth 2.0 Login 흐름을 구현할 때 반복되는 표준 절차를 대신 처리해주는 기능이다.

```text
authorization request 생성
-> provider 로그인 페이지로 redirect
-> authorization code 수신
-> access token 교환
-> user-info endpoint 호출
-> OAuth2User 생성 흐름 연결
```

---

## 왜 필요한가

OAuth 2.0 Login을 직접 구현하려면 생각보다 많은 일을 해야 한다.

```text
Kakao authorization URL 생성
state 생성과 검증
redirect URI 처리
authorization code 수신
token endpoint 호출
user-info endpoint 호출
provider별 응답 파싱
인증 성공 후 후처리
```

이 중 표준적인 OAuth 흐름은 프레임워크가 맡고, 우리는 서비스 정책에 집중하는 편이 좋다.

```text
Spring OAuth-Client가 맡는 부분
-> OAuth 표준 흐름

우리 코드가 맡는 부분
-> Kakao 사용자 정보를 우리 Member로 매핑
-> 우리 서비스 JWT 발급
```

---

## 예시로 이해하기

Kakao OAuth 로그인 흐름은 다음처럼 볼 수 있다.

```mermaid
sequenceDiagram
    participant User
    participant Spring
    participant KakaoAuth as Kakao Authorization Server
    participant KakaoApi as Kakao Resource Server
    participant DB

    User->>Spring: GET /oauth2/authorization/kakao
    Spring-->>User: Kakao 로그인 화면으로 redirect
    User->>KakaoAuth: 로그인 및 동의
    KakaoAuth-->>Spring: /login/oauth2/code/kakao?code=...
    Spring->>KakaoAuth: code로 Kakao access token 요청
    KakaoAuth-->>Spring: Kakao access token
    Spring->>KakaoApi: 사용자 정보 조회
    KakaoApi-->>Spring: id, email, nickname
    Spring->>DB: Member 조회 또는 생성
    Spring-->>User: 우리 서비스 JWT 응답
```

Spring Security 문서의 [OAuth2 Login Advanced Configuration](https://docs.spring.io/spring-security/reference/6.5/servlet/oauth2/login/advanced.html)을 보면 OAuth login 설정은 `authorizationEndpoint`, `redirectionEndpoint`, `tokenEndpoint`, `userInfoEndpoint` 같은 지점으로 나뉜다.
워크북에서 `authorizationEndpoint.baseUri`, `redirectionEndpoint.baseUri`, `userInfoEndpoint.userService`, `successHandler`를 연결하라고 한 이유도 이 흐름 때문이다.

---

## OAuth 역할 구분

OAuth 2.0 문서를 볼 때는 역할 이름을 정확히 구분해야 한다.

| 역할 | Kakao 로그인 예시 |
|---|---|
| Resource Owner | 사용자 |
| Client | 우리 Spring 애플리케이션 |
| Authorization Server | Kakao 인가 서버 |
| Resource Server | Kakao 사용자 정보 API 서버 |

Authorization Server를 단순히 "인증 서버"라고만 이해하면 OAuth의 핵심이 흐려질 수 있다.
OAuth의 중심은 "이 client가 이 사용자의 어떤 리소스에 어떤 범위로 접근해도 되는가"를 허용하는 인가다.

---

## OAuth2와 OIDC는 어떻게 다른가

OAuth2와 OIDC는 비슷한 흐름을 사용하지만 중심 질문이 다르다.

```text
OAuth2
-> 이 앱이 사용자의 어떤 리소스에 접근해도 되는가?

OIDC
-> 이 사용자는 누구인가?
```

OAuth2는 권한 위임 표준이고, OIDC는 OAuth2 위에 사용자 인증 정보를 표준화해서 얹은 로그인/인증 계층이다.
OIDC를 사용하면 `id_token`이 등장하고, 이 token 안에는 `sub`, `iss`, `aud`, `exp`, `email` 같은 표준 claim이 들어갈 수 있다.

그렇다고 OIDC가 없으면 사용자 정보를 DB에 저장할 수 없는 것은 아니다.

```text
OIDC 없이도 가능한 흐름:
OAuth2 access token 발급
-> provider user-info API 호출
-> provider user id, email, nickname 조회
-> 우리 서비스 Member로 저장
```

이번 Kakao 구현도 `openid` scope와 `id_token` 검증을 사용하지 않았으므로, OIDC라기보다 **OAuth2 + Kakao user-info API 방식**으로 보는 것이 정확하다.

---

## Spring Security와 개발자 책임 구분

OAuth 로그인을 구현할 때는 프레임워크가 해주는 일과 개발자가 결정해야 하는 일을 나눠서 봐야 한다.

| 구분 | 맡는 일 |
|---|---|
| Spring Security OAuth-Client | redirect, state 처리, callback 수신, code 교환, user-info 호출 |
| 개발자 코드 | provider 응답 해석, Member 조회/생성, 계정 연결 정책, 우리 서비스 JWT 발급 |

즉 Spring Security는 OAuth 표준 흐름을 많이 처리해주지만, **provider 사용자를 우리 서비스 회원으로 어떻게 연결할지**는 알 수 없다.
이 부분이 `CustomOAuthService`와 `OAuthSuccessHandler`에서 직접 이어줘야 하는 핵심이다.

---

## 공부하면서 얻어갈 점

> **Spring OAuth-Client를 쓰면 OAuth 표준 흐름과 서비스 회원 정책을 분리해서 볼 수 있다.**  
> code 교환, user-info 호출 같은 반복 흐름은 Spring이 처리하고, 우리는 provider 사용자 정보를 우리 서비스 회원으로 어떻게 연결할지 결정한다. 이 관점으로 보면 `CustomOAuthService`와 `OAuthSuccessHandler`의 책임이 더 선명해진다.

> **OAuth provider token을 우리 서비스 API token처럼 그대로 쓰지 않는다.**  
> Kakao access token은 Kakao API를 호출하기 위한 권한이고, 우리 서비스 JWT는 우리 API를 호출하기 위한 인증 수단이다. provider가 바뀌어도 우리 API 인증 방식은 유지되도록 분리하는 편이 좋다.

> **OAuth 로그인에서 어려운 부분은 코드보다 정책이다.**  
> Kakao email이 없을 때 어떻게 할지, 같은 email의 local 회원이 이미 있을 때 자동 연결할지, provider token을 저장할지 같은 결정은 서비스 정책의 영역이다. 미션에서는 단순 조회/생성이 가능하지만, 실무에서는 이 정책을 먼저 정해야 한다.

---

# 6. 함께 보면 좋은 보안 키워드

## Bearer Token

Bearer Token은 "이 token을 가진 사람이 권한을 가진다"는 방식이다.

```text
Authorization: Bearer access-token
```

서명이 유효하고 만료되지 않은 token이면 서버는 요청자를 인증된 사용자로 본다.
그래서 bearer token은 탈취되지 않도록 전송과 저장을 신중히 다뤄야 한다.

## Scope

Scope는 OAuth에서 client가 요청하는 권한 범위다.

```text
profile_nickname
account_email
```

Kakao 로그인에서 사용자가 어떤 정보 제공에 동의하는지와 연결된다.
필요 이상의 scope를 요구하면 사용자가 동의를 꺼릴 수 있고, 보안적으로도 좋지 않다.

## Authorization Code

Authorization Code는 provider가 redirect URI로 돌려주는 임시 코드다.
최종 access token이 아니라 token endpoint에서 access token으로 교환하기 위한 값이다.

```text
/login/oauth2/code/kakao?code=...
```

## 공부하면서 얻어갈 점

> **Bearer Token은 탈취되면 곧 권한이 되므로 HTTPS, 저장 위치, 만료 시간이 중요하다.**  
> OAuth 2.0과 JWT를 공부할 때 token 생성 코드만 보면 부족하다. token이 어디에 저장되고, 어떤 경로로 전송되고, 탈취되었을 때 얼마나 오래 유효한지가 보안 설계의 핵심이다.

> **Scope는 기능 요구사항이 아니라 사용자 동의와 최소 권한의 문제다.**  
> [Kakao Login REST API 문서](https://developers.kakao.com/docs/latest/en/kakaologin/rest-api)를 볼 때도 어떤 사용자 정보를 요청하는지와 동의 항목 설정을 함께 봐야 한다. 필요한 정보만 요청하는 습관이 중요하다.
