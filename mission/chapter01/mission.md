### 워크북 캡쳐 

유리 -> 에반 
![1주차.png](1%EC%A3%BC%EC%B0%A8.png)

### 워크북 리뷰
트랜잭션의 4가지 특징에 대해서 잘 정리하였고 COMMIT이랑 ROLLBACK을 딱 대비시켜서 정리해 주시니까 두 개념 차이가 명확하게 잘 보여요!

### 미션
1. INSERT INTO review (member_id, store_id, score, content, created_at, updated_at)
VALUES (1, 101, 5.0, '음 너무 맛있어요 포인트도 얻고 맛있는 맛집도 알게 된 것 같아 너무나도 행복한 식사였답니다. 다음에 또 올게요!!', NOW(), NOW());

2. SELECT name, email, phone_number, point
FROM member
WHERE member_id = 1; 

3.<진행중>

SELECT
m.reward_point,
[s.name](http://s.name/) AS store_name,
m.conditional,
mm.created_at
FROM member_mission mm
JOIN mission m
ON mm.mission_id = m.mission_id
JOIN store s
ON m.store_id = s.store_id
WHERE mm.member_id = 1
AND mm.status = 'CHALLENGING'
ORDER BY mm.created_at DESC
LIMIT 10 OFFSET 0;

<진행완료>

SELECT
m.reward_point,
[s.name](http://s.name/) AS store_name,
m.conditional,
mm.created_at
FROM member_mission mm
JOIN mission m
ON mm.mission_id = m.mission_id
JOIN store s
ON m.store_id = s.store_id
WHERE mm.member_id = 1
AND mm.status = 'COMPLETE'
ORDER BY mm.created_at DESC
LIMIT 10 OFFSET 0;

4. <유저 미션 현황>

SELECT
COUNT(*) AS total_complete_count,
MOD(COUNT(*), 10) AS current_stamp_count
FROM member_mission mm
JOIN mission m
ON mm.mission_id = m.mission_id
JOIN store s
ON m.store_id = s.store_id
JOIN region r
ON s.region_id = r.region_id
WHERE mm.member_id = 1
AND mm.status = 'COMPLETE'
AND r.region_id = :region_id;

---

<도전 가능한 미션 목록>

SELECT
m.mission_id,
m.store_id,
[s.name](http://s.name/) AS store_name,
s.category AS store_category,
m.reward_point,
m.conditional,
m.deadline,
m.created_at
FROM mission m
JOIN store s
ON m.store_id = s.store_id
WHERE m.mission_id NOT IN (
SELECT mm.mission_id
FROM member_mission mm
WHERE mm.member_id = 1
)
ORDER BY m.created_at DESC
LIMIT 10 OFFSET 0;
