- 클라우드 컴퓨팅이란?
    
    직접 서버나 저장장치를 사서 설치하는 대신, 인터넷을 통해 원격으로 컴퓨팅 자원(서버, 데이터 스토리지 등)을 대여하여 사용하고, 쓴 만큼만 요금을 지불하는 방식
    
    3가지 서비스 형태
    
    - IaaS (Infrastructure as a Service) : 서버, 네트워크, 스토리지를 인프라 단위로 빌려줌(AWS, EC2 등)
    - PaaS (Platform as a Service) : 인프라를 직접 관리할 필요 없이, 앱을 실행할 수 있는 환경만 빌려줌. 개발자는 코드 작성에만 집중 (Google  App Engine 등)
    - SaaS (Software as a Service) : 설치할 필요 없이 웹 브라우저에서 바로 사용하는 소프트웨어 ( Gmail, 노션 등)
    
    장점
    
    - 배포가 빠름
    - 안정적임
    - 글로벌 확장이 쉬움
    
- AWS? GCP?
    
    
    **AWS (Amazon Web Services)**
    
    가장 큰 시장 점유율
    
    EC2, S2, RDS 등 폭 넓은 클라우드 서비스.
    
    **GCP (Google Cloud Platform)**
    
    데이터 분석 및 머신 러닝에 강점
    
    빅데이터 서비스와 Google의 기술, AI 및 네트워크 인프라 가짐
    
    컨테이너 기반의 MSA 환경을 구축할 때 선호도가 높다
    
- 환경변수 처리 방법과 왜 환경변수로 민감 정보를 가려야 하는가?
    
    대부분 `.env`  파일에 키-값 쌍을 저장하고, `.gitignore` 설정을 통해 원결 저장소에 올라가지 않게 관리한다.
    
    - GitHub 같은 공개 저장소에 올라가게 되면 비밀번호, 키 등 주요 정보를 봇들이 털어가 서버를 해킹하거나, 비용을 발생시킨다.
    - 유지보수 측면에서도 이득
    
- yml 환경 분리 방법
    
    
    기본 `application.yml` 외에 환경별로 파일을 생성한다.
    
    `application.yml`: 공통 설정 (서버 포트, 로깅 설정 등)
    `application-dev.yml`: 개발 환경 설정 (H2 DB, 개발용 API 키)
    `application-prod.yml`: 운영 환경 설정 (실제 RDS 주소, 보안 API 키)
    
    ```jsx
    spring:
    	profiles:
    		include: secret
    		active: dev // 개발환경 dev 파일
    ```
    
    이런식으로 application.yml 파일에서 활성 프로파일을 설정
    
    혹은 서버에서 실행할 때 직접 지정
    

- Docker와 .jar vs Docker 이미지
    
    
    **.jar**
    
    Java 애플리케이션을 실행하기 위해 필요한 모든 클래스 파일과 리소스를 하나로 묶은 압축 파일
    
    **Docker 이미지**
    
    애플리케이션을 실행하는 데 필요한 OS 설정, 자바, 라이브러리, .jar 파일까지 모두 포함한 읽기 전용 스냅샷
    
    실행환경까지 들어 있어 어디서 실행하든 똑같은 환경을 보장한다.
    
    코드를 작성해서 `.jar` 파일을 생성한 뒤, Dockerfile 이라는 설정 파일을 작성하여 Docker 이미지를 완성한다.