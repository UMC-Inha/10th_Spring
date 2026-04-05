![alt text](../assets/servlet_handler.png)
→ Json을 반환하는 컨트롤러와 마찬가지로 RequestMappingHandlerAdapter가 선택된다.
![alt text](../assets/servlet_handler1.png)
→ 마찬가지로 returnValueHandlers의 종류들을 볼 수 있다.
![alt text](../assets/servlet_handler2.png)
![alt text](../assets/servlet_handler3.png)
→ `ViewNameMethodReturnValueHandler`가 선택되었다.
![alt text](../assets/servlet_handler4.png)
![alt text](../assets/servlet_handler5.png)
![alt text](../assets/servlet_handler6.png)
→ ModelAndView 생성
![alt text](../assets/servlet_handler7.png)
![alt text](../assets/servlet_handler8.png)
→ resolveViewName을 통해 ThymleafView객체 만들어진다.
![alt text](../assets/servlet_handler9.png)
→ ThymeleafView의 render함수 실행
![alt text](../assets/servlet_handler10.png)
→ 랜더링 기초 작업. 템플릿 이름: “hello”, 템플릿 처리 엔진: “SpringTemplateEngine”

![alt text](../assets/servlet_handler11.png)
![alt text](../assets/servlet_handler12.png)
→ process함수를 통해 html응답을 만들고, write()를 통해 완성된 html을 http응답으로 내보낸다.
![alt text](../assets/servlet_handler13.png)
→ process함수가 실행된 뒤, `template.toString()`의 값