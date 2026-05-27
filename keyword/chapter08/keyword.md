## 🔐 Spring Security란?

Spring 기반 애플리케이션의 인증(Authentication)과 인가(Authorization)를 담당하는 보안 프레임워크이다. Spring과 완벽하게 통합되며 별도의 보안 로직을 직접 구현하지 않아도 강력한 보안 기능을 제공한다. 

Spring Security는 필터기반으로 동작하며스프링 MVC와 분리되어 관리 및 동작한다.

### 인증 - 동작 구조

```
POST /login
   ↓
UsernamePasswordAuthenticationFilter
  → UsernamePasswordAuthenticationToken 생성 (미인증)
   ↓
AuthenticationManager (ProviderManager)
  → supports()로 처리 가능한 Provider 탐색
   ↓
AuthenticationProvider
  → UserDetailsService.loadUserByUsername() 호출
  → PasswordEncoder.matches()로 비밀번호 검증
  → UsernamePasswordAuthenticationToken 반환 (인증 완료)
   ↓
SecurityContextHolder → SecurityContext → Authentication 저장
   ↓
인증 완료
```

1️⃣ **UsernamePasswordAuthenticationFilter**

Security Filter Chain에서 로그인 요청을 가로채며, `HttpServletRequest`에서 아이디와 비밀번호를 추출하여 아직 인증되지 않은 `UsernamePasswordAuthenticationToken`을 생성하고 `AuthenticationManager`에게 위임한다.

**2️⃣ AuthenticationManager**

전달받은 `Authentication` 타입을 처리할 수 있는 `AuthenticationProvider`를 찾아 인증을 위임한다. 직접 인증하지 않고 위임만 하며 구현체는 `ProviderManager`이다. `supports()`로 처리 가능한 Provider를 판단하여 여러 Provider를 순서대로 시도한다.

![ProviderManager가 가지고 있는 AuthenticationProvider 리스트](attachment:d4cfb8a4-3a96-4024-9570-42b4e4f85874:image.png)

ProviderManager가 가지고 있는 AuthenticationProvider 리스트

![AuthenticationProvider의 supports() 함수](attachment:6fdf196f-4499-49dd-bb8c-84b448aa3b49:image.png)

AuthenticationProvider의 supports() 함수

3️⃣ **AuthenticationProvider**

실제 인증 로직을 수행하는 핵심 컴포넌트이다. `UserDetailService`로 사용자를 조회하고 `PasswordEncoder`로 비밀번호를 검증한다. 인증 성공 시 `authenticated = true`의 `UsernamePasswordAuthenticationToken`을 반환한다.

4️⃣ **UserDetailService**

`AuthenticationProvider`가 호출하며 username을 기반으로 DB에서 사용자를 조회해 `UserDetails`로 반환한다.

5️⃣ **UserDetails**

DB에서 조회한 사용자 정보를 담는 인터페이스다. `AuthenticationProvider`가 비밀번호 검증과 권한 확인에 사용한다. `implements`하여 커스텀 구현체를 만들 수 있다.

6️⃣ **SecurityContext / SecurityContextHolder** 

인증에 성공하면 `Authentication` 객체를 `SecurityContext`에 담고 `SecurityContextHolder`가 **TreadLocal**로 보관한다. 같은 요청 스레드 내에서라면 어디서든 꺼낼 수 있다.

### 인가 - 동작 구조

```
리소스 요청
   ↓
AuthorizationFilter
  → SecurityContext에서 Authentication 꺼냄
   ↓
AuthorizationManager
  → GrantedAuthority와 필요 권한 비교
   ↓
권한 있음 → Controller 도달 → 정상 응답
권한 없음 → AccessDeniedException
              → AccessDeniedHandler → 403
미인증    → AuthenticationException
              → AuthenticationEntryPoint → 401
```

**1️⃣ AuthorizationFilter**

Security Filter Chain의 마지막에 위치하며 인가 판단을 시작하는 필더다. `SecurityContext`에서 `Authentication`을 꺼내 `AuthorizationManager`에게 넘긴다

**2️⃣ AuthorizationManager**

현재 사용자의 권한과 요청한 리소스에 필요한 권한을 비교해 접근 허용 여부를 결정한다. `SecurityFilterChain`에서 설정한 권한 규칙을 기반으로 판단한다.

3️⃣ **GrantedAuthority**

`Authentication` 안에 담긴 권한 정보 인터페이스이다. `ROLE_ADMIN`, `ROLE_USER` 형태로 표현하며 `AuthorizationManager`가 이 값을 비교해 접근을 허용하거나 막는다. 구현체는 `SimpleGrantedAuthority`이다.

4️⃣ **AccessDeniedHandler**

인증은 됐지만 권한이 부족할 때(AccessDeniedException) 호출된다. 403 응답을 반환하도록 커스터마이징할 수 있다.

5️⃣ **AuthenticationEntryPoint**

인증 자체가 안 된 상태에서 보호된 리소스에 접근할 때 호출된다. 401 응답을 반환하도록 커스터마이징할 수 있다.

## 인증 (Authentication)

**“이 사용자는 누구인가”**를 확인하는 과정이다. 시스템에 접근하려는 주체가 본인임을 증명하는 단계로, 가장 흔한 예시는 아이디/비밀번호로 로그인하는 것이다.

인증에 성공하면 해당 사용자가 “시스템에 알려진 사람”임이 확인된다.

## 인가 (Authorization)

**“이 사용자가 무엇을 할 수 있는가”**를 확인하는 과정이다. 인증이 완료된 사용자가 특정 리소스나 기능에 접근할 권한이 있는지 판단하는 단계이다.

인증없이 인가는 불가능하며, 인증이 먼저 일어나고 인가는 그 다음 단계이다.

### 인증 vs 인가

|  | 인증 | 인가 |
| --- | --- | --- |
| 확인 대상 | 신원 | 권한 |
| 실패 시 | 401 Unauthorized | 403 Forbidden |
| Spring Security | AuthenticationManager | Authorizationmanager |

### 🌱 Spring Security 핵심 컴포넌트

**Authentication**

인증 주체의 정보와 권한을 담는 인터페이스이다. 인증 전후로 담기는 내용이 달라진다.

`UsernamePasswordAuthenticationToken`는 `Authentication` 인터페이스의 구현체이다.

```java
// 인증 전 → username + password만 담긴 상태
new UsernamePasswordAuthenticationToken(username, password);

// 인증 후 → UserDetails + 권한 목록까지 담긴 상태
new UsernamePasswordAuthenticationToken(userDetails, null, authorities);
```

내부적으로 이런 정보를 가진다.

```java
getPrincipal();    // 인증된 사용자 정보 (UserDetails)
getCredentials();  // 자격 증명 (비밀번호, 인증 후엔 null 처리)
getAuthorities();  // 권한 목록 (ROLE_ADMIN 등)
isAuthenticated(); // 인증 여부
```

## Stateful

**서버가 클라이언트 상태를 직접 저장하고 관리하는 방식**이다. 클라이언트가 요청을 보낼 때마다 서버가 이전 상태를 기억하고 있다.

대표적인 예시가 **세션(Session)**이다.

**🧩 세션기반 로그인 동작 방식**

1. 클라이언트가 로그인 요청
2. 서버가 세션 생성 후 세션 저장소에 저장
3. 클라이언트에게 Session ID(쿠키)를 발급
4. 이후 요청마다 Sessioin ID를 보내면 서버가 세션 저장소에서 꺼내 인증 확인

세션 기반 로그인을 사용한다면 **서버가 상태를 관리하기 때문에 즉시 세션 무효화 (강제 로그아웃)이 가능**하며 **구현이 비교적 단순**하다.

하지만 서버에 세션을 저장하기 때문에 **서버 자원을 소비**하고, 서버가 여러 대일 경우 **세션 공유 문제가 생길 수 있다**. 또, 매 요청마다 **세션 저장소를 조회하는 조회 비용이 발생**한다.

## Stateless

**서버가 클라이언트의 상태를 저장하지 않는 방식**이다. 클라이언트가 요청할 때마다 인증에 필요한 정보를 직접 들고 온다.

대표적인 예시가 **JWT(JSON Web Token)** 이다.

**🧩 JWT기반 로그인 동작 방식**

1. 클라이언트가 로그인 요청
2. 서버가 JWT 생성 후 클라이언트에게 발급
3. 이후 요청마다 JWT를 헤더에 담아 보냄
4. 서버가 JWT 서명을 검증하여 인증 확인 (DB/저장소 조회 없음)

JWT 기반 로그인을 사용한다면 서버가 상태를 저장하지 않으므로 **서버 부하가 줄어들며** **서버가 여러 대여도 문제가 생기지 않는다.** 

하지만 세션 기반 로그인과는 다르게 서버가 상태를 저장하지 않기 때문에 **토큰을 강제로 무효화하기 어려우며**, **토큰 자체에 정보가 담기기 때문에 탈취 위험**이 있다.

### Stateful + Stateless

**1️⃣ JWT + 블랙리스트 (Redis)**

JWT는 서버가 상태를 저장하지 않기 때문에 로그아웃된 토큰을 강제로 무효화하기 어렵다. 이를 해결하기 위해 로그아웃된 토큰을 Redis에 블랙리스트롤 저장하고 매 요청마다 블랙리스트에 있는지 확인하는 방식이다.

```
로그아웃 요청
   ↓
해당 JWT를 Redis 블랙리스트에 저장 (토큰 만료시간만큼 TTL 설정)
   ↓
이후 요청마다 블랙리스트 조회
   ↓
블랙리스트에 있으면 → 401 반환
없으면 → 정상 처리
```

**2️⃣ JWT + Refresh Token 저장소(Redis)**

Access Token은 짧게, Refresh Token은 길게 설정하고 Refresh Token을 Redis에 저장하는 방식이다. 로그아웃 시 Refresh Token을 삭제해서 재발급을 막는다. 

Refresh Token을 저장소에 저장하지 않고 클라이언트가 들고 있게 하는 완전 Stateless 방식도 존재하지만 탈취 시 만료 전까지 막을 방법이 없다는 단점이 있다.

```
Access Token  → 짧은 만료 (ex. 30분), 검증만 수행
Refresh Token → 긴 만료 (ex. 2주), Redis에 저장해서 관리
   ↓
Access Token 만료 시 Refresh Token으로 재발급 요청
   ↓
Redis에 저장된 Refresh Token 검증 후 Access Token 재발급
   ↓
로그아웃 시 Redis에서 Refresh Token 삭제 → 재발급 불가
```
