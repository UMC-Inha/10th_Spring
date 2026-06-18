- 클라우드 컴퓨팅이란?

  **클라우드 컴퓨팅**

  서버, 저장소, 데이터베이스, 네트워크 같은 IT 자원을 인터넷을 통해 필요한 만큼 빌려 쓰는 방식

  직접 물리 서버를 사고 관리하는 대신, AWS나 GCP 같은 클라우드 제공자가 관리하는 인프라를 서비스처럼 사용하는 것

    ```
    내 컴퓨터 / 회사 서버실에서 직접 운영
    → 서버 구매, 설치, 전원, 네트워크, 장애 대응을 직접 관리
    
    클라우드 사용
    → 필요한 서버/DB/스토리지를 인터넷으로 빌려 쓰고 사용량만큼 비용 지불
    ```

  ⇒ 24/365 서버를 실행 가능

  **주요 특징**

    - 온디맨드 사용

      필요할 때 서버, DB, 스토리지 같은 자원을 바로 생성해서 사용 가능

    - 사용량 기반 과금

      서버를 구매하는 것이 아니라 사용한 시간, 저장 용량, 트래픽 등에 따라 비용이 발생

    - 확장성

      사용자가 늘면 서버 성능을 올리거나 서버 개수 증설 가능

    - 관리 부담 감소

      물리 장비, 데이터센터, 일부 인프라 운영 부담을 클라우드 제공자가 부담

    - 글로벌 배포

      여러 리전에 인프라를 만들어 사용자와 가까운 곳에서 서비스를 제공 가능


    **서비스 모델**
    
    - IaaS
        
        서버, 네트워크, 스토리지 같은 인프라를 빌려 쓰는 방식
        
        Ex) AWS EC2, Google Compute Engine
        
    - PaaS
        
        인프라 관리 부담을 줄이고 애플리케이션 실행 환경을 제공하는 방식
        
        Ex) Google App Engine, AWS Elastic Beanstalk
        
    - SaaS
        
        완성된 소프트웨어를 인터넷으로 사용하는 방식
        
        Ex) Gmail, Notion, Google Docs
        
    
    **주의할 점**
    
    클라우드를 쓴다고 모든 운영 문제가 사라지는 것은 아님
    
    서버 보안 그룹, 비용 관리, 로그, 백업, 장애 대응, 환경 변수 관리 같은 부분은 여전히 신경 써야 함
    
    특히 배포 자동화나 DB 연결 정보를 다룰 때는 민감 정보가 코드나 로그에 노출되지 않도록 관리해야 함

- AWS? GCP?

  **AWS와 GCP**

  둘 다 대표적인 클라우드 서비스 제공자

  서버, 데이터베이스, 스토리지, 네트워크, 인증, 모니터링 같은 인프라를 직접 구축하지 않고 클라우드에서 사용 가능

  **공통점**

  둘 다 클라우드 위에서 애플리케이션을 배포하고 운영하기 위한 서비스를 제공함

    ```
    가상 서버
    AWS EC2        / GCP Compute Engine
    
    객체 스토리지
    AWS S3         / GCP Cloud Storage
    
    관리형 관계형 DB
    AWS RDS        / GCP Cloud SQL
    
    컨테이너 오케스트레이션
    AWS EKS        / GCP GKE
    
    서버리스 함수
    AWS Lambda     / GCP Cloud Functions
    ```

  **AWS**

  가장 널리 사용되는 클라우드 플랫폼 중 하나

  서비스 종류⬆️, 레퍼런스 및 자료⬆️

  EC2, RDS, S3, IAM, VPC 같은 기본 서비스부터 배포, 모니터링, 보안, 머신러닝까지 폭넓게 제공

  장점

    - 서비스 종류와 생태계가 큼
    - 자료와 예제가 많음
    - 기업에서 많이 사용되어 실무 경험으로 이어지기 좋음
    - EC2, RDS, S3 같은 기본 인프라 구성이 익숙해지면 다른 클라우드 이해에도 도움이 됨

  주의할 점

    - 서비스가 많아 처음에는 복잡하게 느껴질 수 있음
    - 사용량 기반 과금이라 리소스를 켜둔 채 방치하면 비용이 발생 가능
    - IAM, 보안 그룹, VPC 같은 네트워크/권한 설정에 대한 이해 필요

  **GCP**

  Google이 운영하는 인프라를 기반으로 제공되는 클라우드 플랫폼

  데이터 분석, 머신러닝, Kubernetes, 네트워크 인프라 쪽에서 강점이 자주 언급됨

  Compute Engine, Cloud SQL, Cloud Storage, Cloud Run, GKE 같은 서비스를 제공함

  장점

    - Google의 인프라와 데이터/AI 서비스와 연결하기 좋음
    - Kubernetes 기반 서비스인 GKE가 강점으로 많이 언급됨
    - Cloud Run처럼 컨테이너 기반 서버리스 배포 경험이 비교적 단순한 편

  주의할 점

    - AWS와 서비스 이름과 설정 방식이 다르므로 별도로 익숙해져야 함
    - 팀이나 회사에서 이미 사용하는 클라우드가 있다면 그 환경을 우선 고려하는 것이 현실적임

  **선택 기준**

    - 팀이나 회사에서 이미 사용하는 클라우드
    - 필요한 서비스가 있는지
    - 비용과 무료 티어
    - 리전 위치와 지연 시간
    - 자료와 커뮤니티
    - 운영 난이도

- 환경변수 처리 방법과 왜 환경변수로 민감 정보를 가려야 하는가?

  **환경변수**

  애플리케이션 코드 밖에서 주입하는 설정값

  DB 비밀번호, JWT secret, OAuth client secret, AWS 키, SSH 키처럼 환경마다 달라지거나 외부에 공개되면 안 되는 값을 코드에 직접 쓰지 않기 위해 사용함

    ```yaml
    spring:
      datasource:
        url: ${DB_URL}
        username: ${DB_USERNAME}
        password: ${DB_PASSWORD}
    ```

  위처럼 작성하면 실제 값은 코드에 들어가지 않고, 실행 환경에서 `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`를 주입받음

  **민감 정보를 가려야 하는 이유**

  민감 정보가 GitHub 같은 원격 저장소에 올라가면 누구나 그 값으로 DB나 외부 서비스에 접근 가능

  특히 DB 비밀번호, JWT secret, SSH private key, API key 유출 → 보안 사고

  예시

    - DB 비밀번호 유출

      외부에서 DB 접속 시도 가능

    - JWT secret 유출

      공격자가 임의의 JWT를 만들어낼 수 있음

    - SSH private key 유출

      서버 접속 권한이 노출될 수 있음

    - OAuth client secret 유출

      외부 서비스 인증 흐름이 악용될 수 있음


    ⇒ 환경변수나 Secret 저장소로 분리
    
    **처리 방법**
    
    - 로컬 개발 환경
        
        `.env` 파일이나 IDE 실행 설정에 환경변수 등록
        
        단, `.env`는 `.gitignore`에 포함
        
    - 배포 서버
        
        서버의 환경변수, `.env`, systemd 환경 설정, Docker env 옵션 등을 사용
        
    - GitHub Actions
        
        Repository Secrets 또는 Environment Secrets에 값을 저장하고 `${{ secrets.NAME }}` 형태로 사용
        
    - 클라우드 환경
        
        AWS Secrets Manager, SSM Parameter Store 같은 Secret 관리 서비스를 사용 가능
        
    
    **Spring Boot에서 환경변수 사용**
    
    Spring Boot는 환경변수, 시스템 프로퍼티, 설정 파일 등 여러 위치에서 설정값을 읽어온다.
    
    ex) `application.yml`에서 `${ENV_NAME}` 형태로 환경변수를 참조
    
    ```yaml
    jwt:
      secret: ${JWT_SECRET}
    ```
    
    **주의할 점**
    
    - `.env` 파일은 Git에 올리지 않기
    - 로그에 secret 값 출력하지 않기
    - GitHub Actions에서 `echo`로 secret을 출력하지 않기
    - SSH key는 사용 후 삭제하거나 권한을 제한하기
    - 로컬/개발/운영 환경의 값을 섞지 않기

- yml 환경 분리 방법

  **yml 환경 분리**

  개발, 테스트, 운영 환경마다 다른 설정을 분리해서 관리하는 것

  같은 애플리케이션이라도 로컬 개발 환경과 실제 배포 환경은 DB 주소, 포트, 외부 API 키 등이 달라질 수 있음

  ex) 로컬 → 내 컴퓨터의 DB,  운영 → AWS RDS 같은 외부 DB

  설정을 하나의 파일에 섞어두면 운영 설정을 로컬에서 쓰거나, 민감 정보가 코드에 섞이는 문제 발생 가능

  **기본 구조**

  Spring Boot에서는 보통 공통 설정은 `application.yml`에 두고, 환경별 설정은 별도 파일로 분리함

    ```
    application.yml
    application-local.yml
    application-dev.yml
    application-prod.yml
    ```

    - `application.yml`

      모든 환경에서 공통으로 쓰는 설정

    - `application-local.yml`

      개발자 로컬 환경 설정

    - `application-dev.yml`

      개발 서버 설정

    - `application-prod.yml`

      운영 서버 설정


    **프로필 활성화 방법**
    
    실행할 때 어떤 설정 파일을 사용할지 프로필을 지정할 수 있음
    
    ```bash
    java -jar app.jar --spring.profiles.active=prod
    ```
    
    또는 환경변수로 지정할 수도 있음
    
    ```bash
    SPRING_PROFILES_ACTIVE=prod
    ```
    
    이렇게 하면 `application.yml`의 공통 설정과 `application-prod.yml`의 운영 설정이 함께 적용됨
    
    **왜 분리하는가?**
    
    - 환경마다 다른 DB, Redis, 외부 API 주소를 분리하기 위해
    - 운영용 민감 정보를 코드에 직접 넣지 않기 위해
    - 로컬 설정과 운영 설정이 섞이는 실수를 줄이기 위해
    - 같은 코드로 여러 환경에 배포하기 위해
    
    **주의할 점**
    
    프로필 파일을 분리한다고 해서 민감 정보가 자동으로 안전해지는 것은 X
    
    환경 분리는 “설정 구조를 나누는 것”이고, 민감 정보 보호는 환경변수나 Secret 관리가 필수
    
    배포 환경에서는 GitHub Actions, 서버 환경변수, 실행 옵션 등에서 명시적으로 `prod` 프로필을 주입하는 것을 권장

- Docker와 .jar vs Docker 이미지

  **Docker, .jar, Docker 이미지**

  Spring 프로젝트를 배포할 때 자주 비교되는 개념

  `.jar` - Java 애플리케이션을 실행 가능한 파일로 묶은 결과물

  Docker 이미지 - 애플리케이션 실행에 필요한 환경까지 함께 포장한 배포 단위

  **.jar**

  Java 애플리케이션을 빌드해서 만든 실행 파일

  Spring Boot 프로젝트에서는 Gradle/Maven으로 빌드 → `build/libs/*.jar` 파일 생성

    ```bash
    ./gradlew build
    java -jar build/libs/app.jar
    ```

  `.jar` 방식은 서버에 Java가 설치되어 있고, 필요한 환경변수가 준비되어 있어야 실행 가능함

  자료의 GitHub Actions 예시처럼 빌드된 `.jar`를 EC2로 복사한 뒤 `java -jar`로 실행하는 방식이 여기에 해당함

  장점

    - 구조가 단순함
    - 처음 배포를 배우기 쉬움
    - EC2에 바로 올려 실행하기 좋음

  단점

    - 서버에 Java 버전과 실행 환경을 직접 맞춰야 함
    - 서버마다 환경 차이가 생길 수 있음
    - 배포 스크립트에서 프로세스 종료, 재실행, 로그 관리 등을 직접 다뤄야 함

  **Docker**

  애플리케이션을 컨테이너라는 격리된 실행 환경에서 실행할 수 있게 해주는 도구

  Docker를 사용하면 애플리케이션과 실행 환경을 이미지로 묶고, 그 이미지를 기반으로 컨테이너를 실행함

    ```
    Dockerfile
    → Docker Image
    → Docker Container
    ```

  **Docker 이미지**

  컨테이너를 실행하기 위한 템플릿 같은 것

  애플리케이션 파일뿐 아니라 실행에 필요한 런타임, 설정, 의존성 정보가 함께 들어감

  예를 들어 Spring Boot 애플리케이션을 Docker 이미지로 만들면 대략 이런 구성이 됨

    ```docker
    FROM eclipse-temurin:21-jre
    COPY build/libs/app.jar app.jar
    ENTRYPOINT ["java", "-jar", "/app.jar"]
    ```

  이 이미지를 빌드하면 어느 서버에서든 Docker만 설치되어 있으면 비슷한 방식으로 실행할 수 있음

    ```bash
    docker build -t my-app .
    docker run -p 8080:8080 my-app
    ```

  **Docker 이미지와 컨테이너의 차이**

    - 이미지

      실행 가능한 애플리케이션 환경을 담은 불변 템플릿

    - 컨테이너

      이미지를 실제로 실행한 프로세스


    비유하면 이미지는 클래스, 컨테이너는 객체에 가까움
    
    하나의 이미지로 여러 개의 컨테이너를 실행할 수 있음
    
    **.jar 배포 vs Docker 이미지 배포**
    
    - .jar 배포
        
        서버에 Java 런타임을 직접 준비하고 `.jar` 파일을 복사해서 실행
        
        간단하지만 서버 환경에 영향을 많이 받음
        
    - Docker 이미지 배포
        
        애플리케이션과 실행 환경을 이미지로 묶어 배포
        
        환경 일관성이 높고, 컨테이너 기반 배포/스케일링에 유리함