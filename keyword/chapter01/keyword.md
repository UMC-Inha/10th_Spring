- DB Join이란?

  여러 테이블에서 데이터를 가져와서 하나의 테이블이나 집합으로 표현하는 것이다.
  주로 RDB 에서 많이 쓴다.

- Join 종류들
    - Inner join
        - join 이라고 부를 때 보통 inner join을 말한다.
        - 두 테이블을 조인할 때, 두 테이블에 모두 지정한 열의 데이터가 있어야 한다.

        <aside>
        💡

        ```sql
        SELECT <열 목록>
        FROM <첫 번째 테이블>
            INNER JOIN <두 번째 테이블>
            ON <조건>
        [WHERE 검색 조건]
        ```

        </aside>

    - Outer join
        - 두 테이블을 조인할 때, 1개의 테이블에만 데이터가 있어도 결과가 나온다.
        - 조인하는 테이블의 ON절의 조건 중 한 쪽의 데이터를 모두 가져온다는 의미이다.
            - left outer join
                - 왼쪽 테이블의 모든 값이 출력되는 조인
            - right outer join
                - 오른쪽 테이블의 모든 값이 출력되는 조인
            - full outer join
                - 대부분의 DB는 full outer join을 지원하지 않는다.
                - UNION으로 간접적으로 구현하는 방법이 존재한다.

        <aside>
        💡

        ```sql
        SELECT <열 목록>
        FROM <첫 번째 테이블(LEFT 테이블)>
            <LEFT | RIGHT | FULL> OUTER JOIN <두 번째 테이블(RIGHT 테이블)>
             ON <조인 조건>
        [WHERE 검색 조건]
        ```

        </aside>

    - Cross join
        - 한쪽 테이블의 모든 행과 다른 쪽 테이블의 모든 행을 조인시키는 기능이다.
        - 두 테이블 간의 가능한 모든 조합(Cartesian Product)을 생성하는 SQL 조인 방식.

        <aside>
        💡

        ```sql
        SELECT *
        FROM <첫 번째 테이블>
            CROSS JOIN <두 번째 테이블>
        ```

        </aside>

    - Self join
        - 테이블 자기자신을 조인한 것
        - 자기자신을 조인하므로 테이블 1개를 사용한다.

        <aside>
        💡

        ```sql
        SELECT <열 목록>
        FROM <테이블> 별칭A
            INNER JOIN <테이블> 별칭B
        [WHERE 검색 조건]
        ```

        </aside>

- 트랜잭션이란?
    - 트랜잭션은 DB에서 작업을 수행하는 단위이다.
    - **“모 아니면 도”:** 중간에 작업이 실패하면 처음 상태로 돌아간다. 성공하면 계속 진행한다.
      **정상적으로 반영하는 것을 “커밋”
      실패해서 되돌리는 것을 “롤백”**
    - ACID 원칙
        - Atomicity 원자성
            - 모두 성공 시에는 커밋을, 실패 시에는 롤백해야 한다.
            - 마치 하나의 작업 단위로 움직이는 것처럼 동작한다.
        - Consistency 일관성
            - 일관성 있는 데이터베이스 상태를 유지해야 한다.
            - 무결성 제약 조건을 만족하는 경우를 의미한다.
        - Isolatioin 격리성
            - 서로 다른 트랜잭션에 영향을 미치지 않도록 한다.
            - 동시에 같은 데이터를 수정하지 못하게 한다.
        - Durability 영속성
            - 트랜잭션이 성공적으로 끝나면 그 결과가 항상 기록되어야 한다.
            - 로그를 사용해서 복구할 수 있게 하는 것과 같다.
- Join on 과 where의 차이점
    - ON
        - join 전에 조건을 필터링
        - **두 테이블을 합치기 위해 사용하는 규칙**

        <aside>
        💡

      SELECT * FROM 사용자 A
      LEFT JOIN 주문 B ON [A.id](http://a.id/) = B.user_id
      WHERE B.음식 = '치킨';

        - 이런 경우에는 주문이 없는 B 사용자의 데이터는 날아가버린다.
          LEFT JOIN은 한 쪽의 데이터가 모두 필요한데 inner join 과 같아져버린다.
        </aside>

    - WHERE
        - join후에 조건을 필터링
        - **합치고 나서 필터링**

        <aside>
        💡

      SELECT * FROM 사용자 A
      LEFT JOIN 주문 B ON [A.id](http://a.id/) = B.user_id AND B.음식 = '치킨';

        - 필터링 조건을 on 에 넣으면 사용자A 와 치킨 주문은 잘 조인되고
          사용자 B는 주문은 없지만 LEFT JOIN 의 특성 때문에 NULL 결과를 가지고 조인된다.
        </aside>