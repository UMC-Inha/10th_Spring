# 미션 기록

이번 주차는 Spring Security를 적용하고, 회원가입 API와 form login 흐름을 구현했습니다.

## 1. 회원가입 API 구현

회원가입 요청에 `email`, `password`를 포함하도록 수정했고, 비밀번호는 원문이 아니라 BCrypt hash로 저장되도록 구현했습니다.

![](https://img.boostad.site/2026/05/3bada31cbc3fb7f1c7eceb8fe89cd483.png)

BCryptPasswordEncoder를 사용해 비밀번호를 해싱했고, 회원가입 API에서는 해싱된 비밀번호가 DB에 저장되는 것을 확인했습니다.

![](https://img.boostad.site/2026/05/9294ea7a0fc52bd82c02d1ee1621d564.png)

## 2. form login 확인

로그인은 별도 Controller API가 아니라 Spring Security의 form login 기능을 사용했습니다.
이때 302, 301 같은 redirect 응답을 받았을 때 자동으로 다음 Location URL까지 다시 요청할지 정하는 옵션이 Postman에서는 기본값으로 켜져 있는데, 이 옵션을 끄고 로그인 API를 호출해보니 302 응답을 받는 것을 확인했습니다.

![](https://img.boostad.site/2026/05/293267d942b8d0b32331a6d99ebb947f.png)


로그인 성공 시 `JSESSIONID` 쿠키가 발급됩니다.

![](https://img.boostad.site/2026/05/259ef4e8cdd14594b15b84d90284e473.png)

## 3. Public API / Private API 분리

회원가입, 로그인, Swagger는 Public API로 열어두고, 그 외 API는 로그인 필요 상태로 설정했습니다.

로그인하지 않고 Private API를 호출하면 아래처럼 401 응답이 내려오는 것을 확인했습니다.

![](https://img.boostad.site/2026/05/90b510dc45cf6c9a817de8ad00670ff0.png)

로그인 후 같은 API를 호출하면 정상 응답이 내려왔습니다.

![](https://img.boostad.site/2026/05/4eeda365883d98f1044527c407808d52.png)

현재 8주차 최소 구현에서는 role 기반 권한 분리나 소유권 인가 API가 아직 없어서 실제 403 케이스는 별도로 만들지 않았습니다.
다만 `AccessDeniedHandler`를 `SecurityConfig`에 연결해두었기 때문에, 이후 ADMIN/OWNER 권한이나 본인 리소스 검증이 추가되면 `COMMON403` 형식으로 응답을 통일할 수 있습니다.

---

물론 Postman에서 저장된 쿠키이기에 Swagger 화면을 띄운 브라우저 등의 다른 프로세스에서는 로그인 상태가 아니라 Private API가 막히는 상황이 발생합니다.

![](https://img.boostad.site/2026/05/0341f63dcc6a1c370539e1677f57d85b.png)

또한 현재 8주차 범위에서는 로그인 여부만 확인하는 최소 Private API 보호를 적용했고, 기존 API는 아직 `memberId`를 요청 파라미터로 받습니다.
따라서 로그인한 세션이 있으면 다른 `memberId` 값을 넣어도 API가 호출될 수 있습니다.
이는 JWT가 없어서라기보다, 아직 인증된 사용자와 요청 리소스의 소유권을 비교하는 인가 로직이 없기 때문입니다.
이 부분은 이후 인증 principal에서 `memberId`를 꺼내 사용하거나, 요청 `memberId`와 인증 `memberId`를 비교하는 방식으로 보강할 수 있을 듯 싶습니다!

아래는 `memberId=4`로 로그인한 상태에서 `memberId=1`의 Private API를 호출한 상황입니다.

![](https://img.boostad.site/2026/05/a15a62faafa8e278f99d8f2b6a30eaa7.png)

---

# 피어 리뷰
