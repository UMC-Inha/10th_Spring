### 워크북 캡쳐

유리 -> 에반
![2주차.png](2%EC%A3%BC%EC%B0%A8.png)

### 워크북 리뷰
핵심 개념을 정확하게 짚으면서도 불필요한 내용 없이 깔끔하게 정리한 점이 정말 인상적이다. 구조적으로 이해하기 쉽게 정리되어 있어서 REST API의 본질을 복습하기 좋았다

### 미션
- 홈 화면

  **API Endpoint**

    ```json
    GET /home?region=안암동
    ```

  **Request Body (서버에 새 데이터를 보내거나 수정할 때)**

    ```json
    -
    ```

  **Request Header (요청에 대한 부가정보)**

    ```json
    Authorization: Bearer <token>
    ```

  **Query String (URL 뒤에 붙는 추가 조건값)**

    ```json
    {
    	“region” : “안암동”
    }
    ```

  **Path Variable (특정 자원 하나를 식별)**

    ```json
    -
    ```

  **Query Parameter (조회 조건, 필터, 정렬, 페이지 정보 등)**

    ```json
    {
    	“region” : “안암동”
    }
    ```

  **Response body**

    ```json
    {
    	“isSuccess” : true,
    	“code” : “HOME200”,
    	“message” : “홈 화면 조회 성공”,
    	“result” : {
    		"region": "안암동",
    		"userTotalPoint": 999999,
    		"missionCount" : 7, 
    		"missions" : [
    		{
    			"missionId" : 1, 
    			"storeName" : "반이학생마라탕",
    			"storeCategory" : "중식당",
    			"missionDeadline" : 7,
    			"missionContent" : "10,000원 이상의 식사",
    			"missionPoint" : 500
    		}
    		{
    			"missionId" : 2, 
    			"storeName" : "반이학생마라탕",
    			"storeCategory" : "중식당",
    			"missionDeadline" : 7,
    			"missionContent" : "10,000원 이상의 식사",
    			"missionPoint" : 500
    		}
    		]
    	}
    }
    ```

- 마이 페이지 리뷰 작성

  **API Endpoint**

    ```json
    POST /stores/{storeId}/reviews
    ```

  **Request Body (서버에 새 데이터를 보내거나 수정할 때)**

    ```json
    {
    	“reviewComment” : “맛있어요”.
    	“score” : 4,
    	“photoURL” : “https://…”
    }
    ```

  **Request Header (요청에 대한 부가정보)**

    ```json
    Authorization: Bearer <token>
    Content-Type: application/json
    ```

  **Query String (URL 뒤에 붙는 추가 조건값)**

    ```json
    -
    ```

  **Path Variable (특정 자원 하나를 식별)**

    ```json
    {
    
    “storeId” : “1”
    
    }
    ```

  **Query Parameter (조회 조건, 필터, 정렬, 페이지 정보 등)**

    ```json
    -
    ```

  **Response body**

    ```json
    {
    	"isSuccess": true,
    	"code": "REVIEW201",
    	"message": "리뷰 작성 성공",
    	"result": {
    		"reviewId": 10,
    		“storeId” : 1
    		"timestamp" : "2026-3-26T12:00:00"
    	}
    }
    ```

    ```json
    {
    	“isSuccess” : false,
    	“code” : “REVIEW400”,
    	“message” : “리뷰 작성에 실패했습니다.”
    }
    ```

- 미션 목록 조회(진행중, 진행 완료)

  **API Endpoint**

    ```json
    GET /mypages/missions
    ```

  **Request Body (서버에 새 데이터를 보내거나 수정할 때)**

    ```json
    -
    ```

  **Request Header (요청에 대한 부가정보)**

    ```json
    Authorization: Bearer <token>
    ```

  **Query String (URL 뒤에 붙는 추가 조건값)**

    ```json
    -
    ```

  **Path Variable (특정 자원 하나를 식별)**

    ```json
    -
    ```

  **Query Parameter (조회 조건, 필터, 정렬, 페이지 정보 등)**

    ```json
    {
    
    	“region” : “안암동”,
    	“status” : “SUCCESS” or “ONGOING”
    	“page” : 0,
    	“size” : 10
    }
    ```

  **Response body**

    ```json
    {
    	"isSuccess": true,
    	"code": "COMMON200",
    	"message": "미션 목록 조회 성공",
    	"result": {
    	“missions” : [
    		{
    			"missionId": 1,
    			"title": "리뷰 작성",
    			"status": "ONGOING”
    		}
    	]
    	“page” : 0, 
    	“size” : 10,
    	“totalElements” : 25
    	}
    }
    ```

- 미션 성공 누르기

  **API Endpoint**

    ```json
    PATCH /missions/{missionId}/status
    ```

  **Request Body (서버에 새 데이터를 보내거나 수정할 때)**

    ```json
    {
    	“isSuccess” : true,
    	“message” : “성공”,
    	“timestamp” : “2026-03-26T12:00:00”
    }
    ```

  **Request Header (요청에 대한 부가정보)**

    ```json
    Authorization: Bearer <token>
    Content-Type : application/json
    ```

  **Query String (URL 뒤에 붙는 추가 조건값)**

    ```json
    -
    ```

  **Path Variable (특정 자원 하나를 식별)**

    ```json
    {
    	“missionid” : 1
    }
    ```

  **Query Parameter (조회 조건, 필터, 정렬, 페이지 정보 등)**

    ```json
    -
    ```

  **Response body**

    ```json
    {
    	“isSuccess” : true,
    	“code” : “MISSION200”,
    	“message” : “미션 성공 처리 완료”, 
    	“timestamp” : “2026-03-26T12:00:00”
    
    }
    ```

- 회원가입

  **API Endpoint**

    ```json
    POST /users/signup
    ```

  **Request Body (서버에 새 데이터를 보내거나 수정할 때)**

    ```json
    {
    	“name” : “yuri”,
    	“gender” : “female”,
    	“birth” : “2003-05-31”,
    	“address” : “서울특별시”,
    	“email”: “hanaharu1234@naver.com”,
    	“password” :  “abcd1234”,
    	“phoneNumber” : “010-1234-1234”
    }
    ```

  **Request Header (요청에 대한 부가정보)**

    ```json
    Content-Type: application/json
    ```

  **Query String (URL 뒤에 붙는 추가 조건값)**

    ```json
    -
    ```

  **Response body**

    ```json
    {
    	“isSuccess” : true,
    	“code” : “USER201”,
    	“message” : “회원가입에 성공했습니다.”,
    	“result” : {
    		“userId” : 1, 
    		“name” : “yuri”
    		"timestamp" : "2026-03-26T12:00:00"
    	}
    }
    ```

    ```json
    {
    	“isSuccess” : false,
    	“code” : “USER400”,
    	“message” : “이미 가입된 전화번호입니다.”
    }
    ```

