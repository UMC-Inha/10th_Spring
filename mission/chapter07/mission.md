# 미션

우선 테스트용 DB를 구성하기 위해 `mock_seed.sql` 파일로 회원, 가게, 미션, 회원 미션, 리뷰 데이터를 삽입했습니다.

## 1. 내가 진행중인 미션 조회하기

진행중인 회원 미션을 페이지 번호 기반으로 조회하도록 구현했습니다.  
워크북 요구사항에 맞춰 Request Body로 `memberId`를 받고, `pageNumber`, `pageSize`를 Query Parameter로 받아 `PageRequest` 기반 페이징을 적용했습니다.

![](https://img.boostad.site/2026/05/927d739ca0751cb4c98aea50423e25fd.png)

## 2. 내가 생성한 리뷰들 조회하기

내가 작성한 리뷰 목록은 커서 기반으로 조회하도록 구현했습니다.  
정렬 기준에 따라 ID 순 조회와 별점 순 조회를 나누었고, 다음 페이지 조회를 위해 `nextCursor`, `hasNext` 값을 응답에 포함했습니다.

### 1. ID 순 커서 조회

ID 기준 조회에서는 최신 리뷰가 먼저 보이도록 `reviewId` 내림차순으로 정렬했습니다.

![](https://img.boostad.site/2026/05/ac0b33e9d2b22b523986f39c8f0612a7.png)

### 2. 별점 순 커서 조회

별점 기준 조회에서는 `starRating` 내림차순으로 정렬하고, 같은 별점이 있을 경우 `reviewId`를 보조 정렬 기준으로 사용했습니다.  
이를 통해 별점이 같은 리뷰가 있어도 커서 조회에서 중복이나 누락이 생기지 않도록 했습니다.

![](https://img.boostad.site/2026/05/5e93dbef2298c74c395fea8eda868e4e.png)

## 3. Request Body가 있는 API에 검증 어노테이션 붙혀 검증하기

Request Body DTO에 검증 어노테이션을 적용하고, Controller에서 `@Valid`를 사용해 요청값을 검증했습니다.  
검증 실패 시 `GeneralExceptionAdvice`에서 `MethodArgumentNotValidException`을 처리해 공통 응답 형식으로 에러 메시지가 내려가도록 구현했습니다.

![](https://img.boostad.site/2026/05/0cddbb0832c597d665e4e8869c643b95.png)

---
# 피어리뷰

https://github.com/UMC-Inha/10th_Spring_Practice_Mission/pull/41

---

![](https://img.boostad.site/{year}/{month}/{md5}.{extName}/20260518201541402.png)

![](https://img.boostad.site/{year}/{month}/{md5}.{extName}/20260518201605686.png)

![](https://img.boostad.site/{year}/{month}/{md5}.{extName}/20260518201624493.png)

