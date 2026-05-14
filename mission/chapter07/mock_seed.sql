-- DROP DATABASE IF EXISTS umc10th;
-- CREATE DATABASE umc10th CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE umc10th;
-- 위는 처음 세팅시나 초기화시에 실행해줘야함!

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE review_photo;
TRUNCATE TABLE review_reply;
TRUNCATE TABLE review;
TRUNCATE TABLE inquiry_photo;
TRUNCATE TABLE inquiry_reply;
TRUNCATE TABLE inquiry;
TRUNCATE TABLE notification_setting;
TRUNCATE TABLE notification;
TRUNCATE TABLE point_history;
TRUNCATE TABLE member_mission_verification;
TRUNCATE TABLE member_mission;
TRUNCATE TABLE mission;
TRUNCATE TABLE store_owner;
TRUNCATE TABLE store_business_hour;
TRUNCATE TABLE store_food_category;
TRUNCATE TABLE store;
TRUNCATE TABLE member_food_category;
TRUNCATE TABLE member_region_goal;
TRUNCATE TABLE member_address;
TRUNCATE TABLE region_goal;
TRUNCATE TABLE food_category;
TRUNCATE TABLE member_term_agreement;
TRUNCATE TABLE term;
TRUNCATE TABLE region;
TRUNCATE TABLE member;

SET FOREIGN_KEY_CHECKS = 1;

SET @now = NOW();
SET @started_at = TIMESTAMP('2026-05-01 00:00:00');
SET @ended_at = TIMESTAMP('2026-05-31 23:59:59');

INSERT INTO member (
    member_id,
    name,
    nickname,
    gender,
    birth,
    social_provider,
    point,
    email,
    phone_number,
    profile_image_url,
    created_at,
    updated_at
) VALUES
      (1, '차그린', 'nickname012', 'MALE', '2001-07-10', 'LOCAL', 2500, 'green@example.com', '01011112222', 'https://example.com/profile/green.png', @now, @now),
      (2, '김블루', 'blueuser', 'FEMALE', '2000-03-15', 'LOCAL', 1200, 'blue@example.com', '01033334444', NULL, @now, @now);

INSERT INTO region (
    region_id,
    name,
    created_at,
    updated_at
) VALUES
      (1, '안암동', @now, @now),
      (2, '오금동', @now, @now);

INSERT INTO food_category (
    food_category_id,
    name,
    created_at,
    updated_at
) VALUES
      (1, '중식', @now, @now),
      (2, '한식', @now, @now),
      (3, '일식', @now, @now);

INSERT INTO member_address (
    member_address_id,
    address_name,
    address,
    detail_address,
    is_default,
    is_current,
    last_selected_at,
    member_id,
    region_id,
    created_at,
    updated_at
) VALUES
      (1, '학교 근처', '서울 성북구 안암동 1', '101동 202호', TRUE, TRUE, @now, 1, 1, @now, @now),
      (2, '집', '서울 송파구 오금동 1', '303동 404호', TRUE, TRUE, @now, 2, 2, @now, @now);

INSERT INTO region_goal (
    region_goal_id,
    target_month,
    goal_mission_count,
    reward_point,
    started_at,
    ended_at,
    region_id,
    created_at,
    updated_at
) VALUES
      (1, '2026-05', 10, 1000, @started_at, @ended_at, 1, @now, @now),
      (2, '2026-05', 8, 800, @started_at, @ended_at, 2, @now, @now);

INSERT INTO member_region_goal (
    member_region_goal_id,
    completed_mission_count,
    is_reward_received,
    reward_received_at,
    member_id,
    region_goal_id,
    created_at,
    updated_at
) VALUES
      (1, 7, FALSE, NULL, 1, 1, @now, @now),
      (2, 2, FALSE, NULL, 2, 2, @now, @now);

INSERT INTO member_food_category (
    member_food_category_id,
    member_id,
    food_category_id,
    created_at,
    updated_at
) VALUES
      (1, 1, 1, @now, @now),
      (2, 1, 2, @now, @now),
      (3, 2, 3, @now, @now);

INSERT INTO store (
    store_id,
    name,
    address,
    phone_number,
    average_rating,
    region_id,
    primary_food_category_id,
    created_at,
    updated_at
) VALUES
      (1, '반이학생마라탕', '서울 성북구 안암동 10', '02-111-2222', 4.5, 1, 1, @now, @now),
      (2, '안암김치찌개', '서울 성북구 안암동 20', '02-333-4444', 4.2, 1, 2, @now, @now),
      (3, '오금초밥', '서울 송파구 오금동 30', '02-555-6666', 4.8, 2, 3, @now, @now);

INSERT INTO store_food_category (
    store_food_category_id,
    store_id,
    food_category_id,
    created_at,
    updated_at
) VALUES
      (1, 1, 1, @now, @now),
      (2, 2, 2, @now, @now),
      (3, 3, 3, @now, @now);

INSERT INTO store_owner (
    store_owner_id,
    name,
    login_id,
    password_hash,
    store_id,
    created_at,
    updated_at
) VALUES
      (1, '마라탕사장', 'owner_mara', 'mock-password-hash', 1, @now, @now),
      (2, '김치찌개사장', 'owner_kimchi', 'mock-password-hash', 2, @now, @now);

INSERT INTO mission (
    mission_id,
    title,
    content,
    reward_point,
    verification_type,
    is_active,
    started_at,
    ended_at,
    store_id,
    created_at,
    updated_at
) VALUES
      (1, '마라탕 식사 미션', '10,000원 이상의 식사 시', 500, 'OWNER_CONFIRM', TRUE, @started_at, @ended_at, 1, @now, @now),
      (2, '김치찌개 식사 미션', '8,000원 이상의 식사 시', 300, 'OWNER_CONFIRM', TRUE, @started_at, @ended_at, 2, @now, @now),
      (3, '꿔바로우 추가 미션', '15,000원 이상의 식사 시', 700, 'OWNER_CONFIRM', TRUE, @started_at, @ended_at, 1, @now, @now),
      (4, '초밥 식사 미션', '12,000원 이상의 식사 시', 600, 'OWNER_CONFIRM', TRUE, @started_at, @ended_at, 3, @now, @now),
      (5, '진행 가능한 추가 미션', '20,000원 이상의 식사 시', 900, 'OWNER_CONFIRM', TRUE, @started_at, @ended_at, 2, @now, @now);

INSERT INTO member_mission (
    member_mission_id,
    status,
    started_at,
    success_requested_at,
    completed_at,
    rejected_at,
    canceled_at,
    mission_id,
    member_id,
    created_at,
    updated_at
) VALUES
      (1, 'IN_PROGRESS', '2026-05-02 10:00:00', NULL, NULL, NULL, NULL, 1, 1, @now, @now),
      (2, 'SUCCESS_REQUESTED', '2026-05-03 11:00:00', '2026-05-03 12:00:00', NULL, NULL, NULL, 2, 1, @now, @now),
      (3, 'COMPLETED', '2026-05-04 12:00:00', '2026-05-04 13:00:00', '2026-05-04 14:00:00', NULL, NULL, 3, 1, @now, @now),
      (4, 'COMPLETED', '2026-05-05 12:00:00', '2026-05-05 13:00:00', '2026-05-05 14:00:00', NULL, NULL, 4, 1, @now, @now),
      (6, 'COMPLETED', '2026-05-07 12:00:00', '2026-05-07 13:00:00', '2026-05-07 14:00:00', NULL, NULL, 5, 1, @now, @now),
      (7, 'COMPLETED', '2026-05-08 12:00:00', '2026-05-08 13:00:00', '2026-05-08 14:00:00', NULL, NULL, 1, 1, @now, @now),
      (8, 'COMPLETED', '2026-05-09 12:00:00', '2026-05-09 13:00:00', '2026-05-09 14:00:00', NULL, NULL, 2, 1, @now, @now),
      (9, 'COMPLETED', '2026-05-10 12:00:00', '2026-05-10 13:00:00', '2026-05-10 14:00:00', NULL, NULL, 3, 1, @now, @now),
      (5, 'IN_PROGRESS', '2026-05-06 10:00:00', NULL, NULL, NULL, NULL, 4, 2, @now, @now);

INSERT INTO member_mission_verification (
    verification_id,
    verification_code,
    status,
    expires_at,
    requested_at,
    verified_at,
    rejected_at,
    member_mission_id,
    verified_by_store_owner_id,
    created_at,
    updated_at
) VALUES
      (1, '920394810', 'REQUESTED', '2026-05-03 12:10:00', '2026-05-03 12:00:00', NULL, NULL, 2, 1, @now, @now),
      (2, '123456789', 'VERIFIED', '2026-05-04 13:10:00', '2026-05-04 13:00:00', '2026-05-04 14:00:00', NULL, 3, 1, @now, @now);

INSERT INTO review (
    review_id,
    content,
    rating,
    store_id,
    member_id,
    member_mission_id,
    created_at,
    updated_at
) VALUES
      (1, '마라탕 국물이 진하고 맛있었습니다.', 4.5, 1, 1, 3, '2026-05-04 15:00:00', '2026-05-04 15:00:00'),
      (2, '초밥이 신선하고 포인트도 받아서 좋았습니다.', 5.0, 3, 1, 4, '2026-05-05 15:00:00', '2026-05-05 15:00:00'),
      (3, '무난했지만 다음에는 다른 메뉴를 먹어볼 것 같습니다.', 3.0, 1, 1, 7, '2026-05-08 15:00:00', '2026-05-08 15:00:00'),
      (4, '김치찌개가 깔끔하고 양도 충분했습니다.', 4.8, 2, 1, 8, '2026-05-09 15:00:00', '2026-05-09 15:00:00'),
      (5, '꿔바로우가 바삭해서 만족스러웠습니다.', 4.8, 1, 1, 9, '2026-05-10 15:00:00', '2026-05-10 15:00:00');

INSERT INTO review_photo (
    review_photo_id,
    photo_url,
    review_id,
    created_at,
    updated_at
) VALUES
      (1, 'https://example.com/reviews/1-1.png', 1, @now, @now),
      (2, 'https://example.com/reviews/1-2.png', 1, @now, @now),
      (3, 'https://example.com/reviews/2-1.png', 2, @now, @now),
      (4, 'https://example.com/reviews/4-1.png', 4, @now, @now),
      (5, 'https://example.com/reviews/5-1.png', 5, @now, @now);

INSERT INTO review_reply (
    review_reply_id,
    content,
    review_id,
    store_owner_id,
    created_at,
    updated_at
) VALUES
    (1, '방문해주셔서 감사합니다!', 1, 1, @now, @now);