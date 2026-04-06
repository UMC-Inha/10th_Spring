클라이언트 요청 

→ 서블릿 컨테이너 영역(톰캣)

- 요청 정보를 담은 객체 생성 (HttpServletRequest/Response)
- DispatcherServlet 호출
    - 스프링의 컨테이너의 DispatcherServlet 호출

→ 스프링 컨테이너 영역

- DispatcherServlet → Handler Mapping
    - URL 처리할 `@controller` 찾기
- Handler Adapter에게 실행 요청
- 컨트롤러가 스프링 컨테이너에 등록된 Service 빈 호출
- 서비스 → Repository 빈 호출하여 DB 통신

→ 로직이 끝나면 컨트롤러가 결과 반환 : 자바 객체→JSON

→ DispatcherServlet가 최종 응답을 다시 서블릿 컨테이너에게 넘기고, 톰캣이 클라이언트에게 전달