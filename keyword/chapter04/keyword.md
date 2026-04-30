<aside>
💡 주요 내용들에 대해 조사해보고, 자신만의 생각을 통해 정리해보세요!
레퍼런스를 참고하여 정의, 속성, 장단점 등을 적어주셔도 됩니다.
조사는 공식 홈페이지 **Best**, 블로그(최신 날짜) **Not Bad**

</aside>

- 아키텍처 구조란?

  **아키텍처 구조 :** 시스템 구성 요소와 요소 간의 상호작용, 동작 원리, 구성 환경 등을 설명하는 설계도

  ⇒ 의존성을 줄여 유지 보수, 확장성을 높이기 위해 잘 설계하는 것이 중요함

  **시스템(배포 단위) 기준**

    - **모놀리식 아키텍처(Monolithic Architecture)**

      애플리케이션을 하나의 큰 단위로 구성하는 스타일. 모든 기능이 단일 코드 베이스 내에서 하나의 애플리케이션으로 빌드 및 배포

      장점

        - 단순한 개발, 배포
        - 일관된 성능
        - 쉬운 개발 환경 셋팅, 테스트

      단점

        - 유지보수⬇️

          코드 베이스의 크기가⬆️, 작은 기능 수정 시에도 전체 빌드 및 재배포

        - 확장성 한계

          특정 기능을 독립적으로 확장 불가능

        - 유연성 ⬇️

          특정 기능에 맞춘 기술 변경이 불가능


    - **마이크로 서비스 아키텍처(Microservices Architecture, MSA)**
        
        시스템을 여러 개의 작은 서비스로 나누어 구성하는 스타일. 각 서비스는 기능을 독립적으로 수행하며 개별적으로 배포, 운영, 확장 가능
        
        장점
        
        - 유연한 배포
            
            각 서비스를 독립적으로 배포 가능 → 개발 주기 및 변경 사항 반영이 빨라짐
            
        - 장애 격리
            
            하나의 서비스에 문제가 발생하면 격리 가능 → 가용성⬆️ 
            
        - 수평 확장
            
            확장이 필요한 서비스만 확장 가능
            
        - 개발팀 간의 독립성
            
            여러 팀이 동시에 다양한 기능 개발 용이
            
        
        단점
        
        - 복잡한 운영 및 배포
            
            서비스 분리에 따른 복잡도 증가
            
        - 데이터 일관성 관리⬇️
            
            각 서비스가 독립적인 DB 사용 가능
            
        - 서비스 간 통신 비용
        - 모니터링, 로깅 복잡성⬆️
    
    **코드 구조 기준**
    
    - **계층형 구조(Layered Architecture)**
        
        애플리케이션을 기능 별로 나누는 스타일, 패키지를 나누어 각 기능을 맞는 패키지에 넣는 방식
        ex : Controller는 Controller 패키지에, Repository는 Repository 패키지에
        
        장점
        
        - 코드의 가독성⬆️
        - 동일한 계층에서의 코드 중복⬇️
        - 전체 구조 파악에 용이
        
        단점
        
        - 규모가 커질수록 복잡도⬆️
        - 특정 기능과 관련된 코드 찾기가 어려움
        
    - **도메인형 구조**
        
        밑의 키워드에서 후술
        
    
    https://will-of-rough.tistory.com/64
    
    https://velog.io/@chanmi125/Spring-Boot-%ED%8C%A8%ED%82%A4%EC%A7%80-%EA%B5%AC%EC%A1%B0-%EA%B3%84%EC%B8%B5%ED%98%95-vs-%EB%8F%84%EB%A9%94%EC%9D%B8%ED%98%95

- Swagger란?

  **Swagger :** API의 설계, 문서화, 테스트를 도와주는 오픈소스 프레임워크
  API를 코드가 아닌 명세로 정의하고, 이 명세로 문서 생성, 테스트, 코드 생성까지 가능

  OpenAPI Specification을 표준으로 하여 기능을 제공

  API 명세는 endpoint, request, response, schema로 구성됨

    ```yaml
    openapi: 3.0.0
    info:
      title: User API
      version: 1.0.0
    
    paths:
      /users/{id}: //endpoint
        get:
          summary: 사용자 조회 //request
          parameters:
            - name: id
              in: path
              required: true
              schema:
                type: integer
          responses:
            200:
              description: 성공
              content:
                application/json:
                  schema:
                    $ref: '#/components/schemas/User'
    
    components: //shcema(데이터 구조) 
      schemas:
        User:
          type: object
          properties:
            id:
              type: integer
            name:
              type: string
            email:
              type: string
    ```

  **주요 도구**

    - Swagger UI

      OpenAPI 명세를 기반으로 API 문서를 생성, 웹 화면으로 제공

      요청을 보내 테스트 기능 제공

    - Swagger Editor

      YAML/JSON 형식으로 API 명세를 작성, 바로 UI 형태로 확인 가능

    - Swagger Codegen

      API 명세를 기반으로 클라이언트/서버 코드 자동 생성


    장점
    
    - 쉬운 세팅 및 사용
    - 실제 API 호출 기능 제공
    - 문서의 자동 작성
    
    단점
    
    - 실제 코드와 문서 사이에 불일치 발생 가능
    - 동기화를 위해 추가 작업 필요 가능
    - 명세 관리 필요
    
    https://www.linkedin.com/pulse/what-swagger-how-use-allan-crowley-akmmf/

- 도메인형 아키텍처란?

  **도메인형 아키텍처**

  애플리케이션을 도메인에 맞춰 나누는 스타일, 각 기능을 도메인 단위로 그룹화해서 구성
  ex : 사용자 관련 클래스는 User 패키지에, 제품 관련 클래스는 Product 패키지에

  장점

    - 코드 탐색이 용이
    - 도메인 단위의 개발
    - 각 도메인의 독립성 보장

  단점

    - 도메인 간의 의존성 관리가 어려움
    - 도메인 간 코드 중복 발생⬆️

    ```json
    com.example.projectname
    ├── user //user domain
    │   ├── controller
    │   ├── service
    │   ├── repository
    │   ├── domain
    │   ├── dto
    │   └── exception
    ├── product //product domain
    │   ├── controller
    │   ├── service
    │   ├── repository
    │   ├── domain
    │   ├── dto
    │   └── exception
    └── config
    ```

- DDD vs 도메인형 아키텍처

  **DDD(Domain Driven Design, 도메인 주도 설계) :** SW를 비즈니스 도메인 중심으로 설계하는 방법론

  도메인 전문가와 개발자가 협력하여 도메인 모델을 정의, 이를 기반으로 SW 설계

  **핵심 개념**

    - 도메인

      해결하려는 문제 영역(ex : 주문, 사용자, 결제, etc)

    - 도메인 모델

      도메인의 규칙과 상태를 코드로 표현한 것

    - 유비쿼터스 언어(Ubiquitous Language)

      도메인 전문가와 개발자가 공통으로 사용하는 언어, 도메인 모델을 설명할 때 사용


    **구성 요소**
    
    - Entity
        
        식별자로 구분되는 객체, 상태와 행동을 가짐  
        
    - Value Obejct
        
        식별자X, 값 자체가 의미를 가지는 객체, 불변성을 가짐
        
    - Aggregate
        
        관련 객체를 묶어 관리하는 단위(for 도메인 모델 일관성 유지)
        
    - Repository
        
        도메인 객체를 저장/조회
        
    
    장점
    
    - 복잡한 비즈니스 로직 표현⬆️
    - 업무와의 연관성⬆️ → 코드 이해도⬆️
    - 유지보수성⬆️
    
    단점
    
    - 설계 난이도⬆️
    - 학습 비용⬆️
    - 단순한 프로젝트에는 적용하기 적합하지 않음(과함)
    
    ⇒ **DDD vs 도메인형 아키텍처**
    
    **도메인형 아키텍처** : 코드를 도메인 기준으로 나누는 구조(패키지/디렉토리) → 코드 구성 방식
    
    **DDD** : 도메인 중심으로 시스템을 설계하는 방법론 → 시스템 설계 기법
    
    https://tech.kakaopay.com/post/backend-domain-driven-design/
    
    https://strong-park.tistory.com/entry/DDD-%EC%9E%85%EB%AC%B8%EC%84%9C%EB%A5%BC-%EC%9D%BD%EA%B3%A0-%EB%82%98%EC%84%9C-%EB%8A%90%EB%82%80-DDD%EB%9E%80-%EB%AC%B4%EC%97%87%EC%9D%B8%EA%B0%80

- 왜 DTO를 사용하는가?

  **DTO(Data Transfer Object, 데이터 전송 객체)**

  계층간 데이터 전송을 위해 사용되는 객체, 부가적인 로직 없이 데이터만 담고 있으며 Entity와 분리해서 사용

    ```java
    class UserDTO {
        Long id;
        String name;
    }
    ```

  **사용 이유**

    - 계층 간 데이터 전달

      Controller, service, Repository 등 계층 구조를 분리하고 그 사이에서 데이터를 전달

    - Entity 노출 방지

      Entity를 드러내면 내부 구조(DB 구조)가 그대로 외부에 드러남 → DTO로 필요한 값만 골라서 전달 가능

    - 데이터 가공

      클라이언트가 원하는 형태로 데이터를 변환해서 전달 가능(여러 Entity의 데이터를 취합하는 등)

      → 여러 번의 API 호출을 한 번으로 줄이기도 가능(호출 비용 최소화)

    - 유연성

      DB 구조 변경 시에도 DTO만 수정하면 API 변경 최소화 가능


    https://bnzn2426.tistory.com/137

- 컨버터는 왜 사용하는가?

  **컨버터(Converter) :** 객체를 다른 형태의 객체로 변환해주는 클래스, spring 프레임워크에서 기본으로 제공하는 인터페이스를 구현해서 사용 (ex : Entity ↔ DTO)

    ```java
    public interface Converter<S, T> { // Converter 기본 형태
        T convert(S source);
    }
    
    class StringToIntegerConverter implements Converter<String, Integer> { // 구현 예시
        @Override
        public Integer convert(String source) {
            return Integer.parseInt(source);
        }
    }
    ```

  Spring에 컨버터를 등록해두면 변환이 필요한 순간 자동으로 호출

  +ConversionService : 컨버터를 관리하고 적절한 컨버터를 찾아 실제 변환을 수행(기본 + 등록)

  **사용 이유**

    - 역할 분리

      객체의 변환 로직을 분리

    - 재사용성

      여러 곳에서 같은 변환이 필요한 경우

    - 유지 보수

      변환 방식이 바뀌면 컨버터만 수정해서 해결 가능