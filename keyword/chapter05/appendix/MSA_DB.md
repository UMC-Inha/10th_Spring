## 오케스트레이션 (Orchestration)이란?

**여러 컨테이너화된 애플리케이션의 배포, 관리, 확장, 네트워킹 등을 자동화하는 프로세스**이다. 마이크로서비스 아키텍처에서 수십~수백 개의 서비스를 수동으로 관리하는 것은 불가능하기 때문에 오케스트레이션 도구가 필수적이다.

### 오케스트레이션이 제공하는 기능

**1️⃣ 자동 배포**

- 리소스 상황을 고려하여 컨테이너를 적절한 서버에 자동으로 배치한다.

**2️⃣ 스케일링**

- 트래픽에 따라 자동으로 인스턴트를 증감시킨다.

**3️⃣ 자가 복구**

- 컨테이너에 장애가 발생하거나 헬스체크 실패 시 자동으로 재시작한다.

**4️⃣ 로드밸런싱**

- 여러 인스턴스 간 트래픽을 분산시킨다.

**5️⃣ 롤링 업데이트**

- 무중단으로 배포 가능하며 문제 발생 시 자동으로 롤백한다.

## 쿠버네티스 (Kubernetes)

**컨테이너 오케스트레이션의 사실상 표준 플랫폼**이다. Google이 개발하여 오픈소스로 공개했으며, 현재 CNCF(Cloud Native Computing Foundation)에서 관리한다. 

## 🧩 쿠버네티스의 핵심 구성 요소

### 클러스터 (Cluster)

**쿠버네티스로 관리되는 서버들의 집합**이다.

```
Kubernetes Cluster
├─ Master Node (제어 평면)
│   - API Server
│   - Scheduler
│   - Controller Manager
│   - etcd
│
└─ Worker Nodes (워커 노드)
    ├─ Node 1: Pod 1, Pod 2, Pod 3
    ├─ Node 2: Pod 4, Pod 5
    └─ Node 3: Pod 6, Pod 7, Pod 8
```

### 파드 (Pod)

**쿠버네티스의 가장 작은 배포 단위**이다. 하나 이상의 컨테이너를 포함한다.

같은 Pod 내 컨테이너는 localhost로 통신하며 같은 IP 주소와 네트워크를 공유한다. 

하나의 Pod에 여러개의 컨테이너가 포함될 수 있지만, **보통 1Pod = 1 컨테이너의 원칙을 지킨다고한다 (단일 책임 원칙)**.

```
Pod
├─ Container 1: user-service (메인 애플리케이션)
├─ Container 2: log-collector (사이드카)
└─ 공유: IP, 볼륨, 네트워크
```

### 서비스 (Service)

**Pod에 대한 네트워크 접근을 제공**한다. Pod는 언제든 재생성될 수 있고 IP가 바뀌므로, 고정된 엔드포인트가 필요하다.

**Service 타입:**

**ClusterIP(기본)**: 클러스터 내부에서만 접근하며 마이크로 서비스 간 통신용이다.

**NodePort**: 각 노드의 특정 포트로 외부 접근이 가능하다.

**LoadBalancer**: 클라우드 노드밸런서를 자동으로 생성한다.

### 네임스페이스 (Namespace)

**클러스터를 논리적으로 분리**한다. 환경별, 팀별 리소스 격리에 사용한다.

```
Kubernetes Cluster
├─ Namespace: dev (개발 환경)
│   ├─ user-service
│   └─ order-service
│
├─ Namespace: staging (스테이징 환경)
│   ├─ user-service
│   └─ order-service
│
└─ Namespace: prod (프로덕션 환경)
    ├─ user-service
    └─ order-service
```

## 쿠버네티스 vs 기존 방식

### 기존 방식 (수동 관리)

```
서버 3대에 user-service 배포
    ↓
서버 1번 장애 발생
    ↓
수동으로 감지
    ↓
다른 서버에 수동 재배포
    ↓
로드밸런서 설정 수동 변경
    ↓
30분 소요, 서비스 중단
```

### 쿠버네티스

```
user-service Deployment 배포 (replicas: 3)
    ↓
자동으로 3개 Pod 생성 및 분산
    ↓
Pod 하나 장애 발생
    ↓
즉시 자동 감지
    ↓
새 Pod 자동 생성
    ↓
로드밸런싱 자동 업데이트
    ↓
10초 소요, 무중단
```

## 쿠버네티스 사용의 장점과 단점

### 장점

1️⃣ **자동화** : 배포, 스케일링, 복구가 모두 자동이기 때문에 인프라 관리 부담이 감소될 수 있다.

2️⃣ **고가용성**: 자가 복구로 다운 타임을 최소화시킬 수 있다.

3️⃣ **확장성**: 수평 확장(Pod 추가)에 용이하다.

4️⃣ **이식성**: 클라우드 벤더에 독립적이고, 온프레미스에서도 동일하게 동작한다.

5️⃣ **선언적 관리**: YAML로 원하는 상태를 정의할 수 있다.

### 단점

1️⃣ **높은 학습 곡선**: 개념이 많고 복잡하고 운영 노하우가 필요하다.

2️⃣ **리소스 오버헤드**: 다양한 추가 리소스가 필요하기 때문에 작은 규모에서는 과할 수 있다.

3️⃣ **초기 설정 복잡**: 클러스터 구축과 설정이 복잡하다.

# EDA (Event-Driven Architecture): 이벤트 기반 아키텍처

**이벤트 기반 아키텍처**는 **이벤트의 생성, 감지, 소비, 반응을 중심으로 설계된 소프트웨어 아키텍처 패턴**이다.

시스템 내에서 상태 변화나 중요한 사건이 발생했을 때, 이를 이벤트로 발행하고 관심있는 서비스들이 해당 이벤트를 구독하여 비동기적으로 처리하는 방식이다. 

전통적인 요청-응답 방식과 달리, EDA는 이벤트 발행자와 구독자가 서로를 직접 알 필요가 없어 느슨한 결합(Loose Coupling)을 이룬다.

### 핵심 구성 요소

**1️⃣ 이벤트** 

시스템에서 발생한 상태 변화나 의미 있는 사건을 나타내는 불변 객체이다. 

예를 들어, “주문이 생성됨.”, “결제가 완료됨.”, “재고가 부족함”과 같은 과거형으로 표현되며, 이벤트는 발생한 사실이므로 변경되지 않는다.

```java
// "주문이 생성됨" 이벤트 객체의 예시
@Getter
@Builder
public class OrderCreatedEvent {
    private final String eventId;
    private final Long orderId;
    private final Long userId;
    private final BigDecimal amount;
    private final LocalDateTime occurredAt;
}
```

**2️⃣ 이벤트 프로듀서 (Event Producer)**

이벤트를 생성하고 발행하는 주체이다. 비즈니스 로직 수행 후 상태 변화를 이벤트로 발행한다.

```java
@Service
public class OrderService {
		...
    
    @Transactional
    public Order createOrder(CreateOrderRequest request) {
        ...
        
        // 이벤트 발행
        eventPublisher.publish(OrderCreatedEvent.builder()
            .eventId(UUID.randomUUID().toString())
            .orderId(order.getId())
            .userId(order.getUserId())
            .amount(order.getTotalAmount())
            .occurredAt(LocalDateTime.now())
            .build());
        
        return order;
    }
    
    ...
}
```

**3️⃣ 이벤트 컨슈머 (Event Consumer)**

이벤트를 구독하고 처리하는 주체이다. 여러 컨슈머가 동일한 이벤트를 각자의 목적에 맞게 처리할 수 있다.

```java
@Component
public class OrderEventConsumer {
    
    // 재고 서비스
    @EventListener
    public void handleOrderCreated(OrderCreatedEvent event) {
        inventoryService.reserveStock(event.getOrderId());
    }
}

@Component
public class NotificationEventConsumer {
    
    // 알림 서비스
    @EventListener
    public void handleOrderCreated(OrderCreatedEvent event) {
        notificationService.sendOrderConfirmation(event.getUserId());
    }
}
```

4️⃣ 이벤트 채널 / 브로커

이벤트를 프로듀서에서 컨슈머로 전달하는 중간 매개체이다. Kafka, RabbitMQ, AWS SNS/SQS 등이 있다.

### EDA 장점

1. **느슨한 결합 (Loose Coupling)**
    
    서비스들이 직접 통신하지 않고 이벤트를 통해 간접적으로 통신한다. 프로듀서는 컨슈머가 누구인지, 몇 개인지 알 필요가 없다.
    
2. **확장성** 
    
    컨슈머를 독립적으로 확장할 수 있다. 특정 서비스의 부하가 높아지면 해당 컨슈머만 확장하면 된다.
    
3. **유연성**
    
    새로운 기능 추가 시 기존 서비스를 수정하지 않고 새로운 컨슈머만 추가하면 된다.

# Apache Kafka (아파치 카프카)란?

**Apache Kafka**는 **분산 이벤트 스트리밍 플랫폼**으로, EDA에서 이벤트 채널 / 브로커 역할을 담당한다. 링크드인에서 개발하여 오픈소스로 공개되었으며, 현재는 **대용량 실시간 데이터 파이프라인과 스트리밍 애플리케이션 구축을 위한 표준**이 되었다.

## 🧩 카프카 핵심 개념

### 토픽 (Topic)

**메시지가 발생되는 논리적인 채널**이다. 데이터베이스의 테이블과 유사한 개념으로, 특정 주제나 카테고리 별로 메시지를 분류한다.

```java
// 주문 관련 이벤트는 order-events 토픽
kafkaTemplate.send("order-events", orderCreatedEvent);

// 결제 관련 이벤트는 payment-events 토픽으로
kafkaTemplate.send("payment-events", paymentCompletedEvent);

// 사용자 관련 이벤트는 user-events 토픽으로
kafkaTemplate.send("user-events", userRegisteredEvent);
```

### 파티션 (Partition)

**토픽을 물리적으로 나눈 단위**다. 하나의 토픽은 여러 파티션으로 구성되며, 각 파티션은 순서가 보장되는 불변의 메시지 시퀀스이다. 파티션을 통해 병렬 처리와 확장성을 보장할 수 있다.

```
order-events 토픽
├─ Partition 0: [msg1, msg2, msg3, ...]
├─ Partition 1: [msg4, msg5, msg6, ...]
└─ Partition 2: [msg7, msg8, msg9, ...]
```

메시지는 키값의 해시를 기반으로 특정 파티션이 할당되며, 같은 키를 가진 메시지는 항상 같은 파티션으로 가기 때문에 순서가 보장된다.

### 프로듀서 (Producer)

토픽에 메시지를 발행하는 애플리케이션이다. EDA의 이벤트 프로듀서와 비슷한 개념이다.

### 컨슈머 (Consumer)

토픽에서 메시지를 읽어오는 애플리케이션이다. EDA의 이벤트 컨슈머와 비슷한 개념이다.

### 브로커

카프카 서버 인스턴스이다. 각 프로커는 일부 파티션을 담당하며, 프로듀서로부터 메시지를 받아 저장하고 컨슈머에게 전달한다.

이 외에도 **컨슈머 그룹, 오프셋, 브로커, 레플리케이션** 등 다양한 개념이 존재한다. 이런 구성요소들을 활용해 서비스 규모에 알맞게 구상하여 대용량 데이터 파이프라인을 안정적이고 확장성 높게 운영할 수 있다.

## 아파치 카프카의 장점

### 높은 처리량

많은 양의 데이터를 송수신할 때 맺어지는 네트워크 비용은 크다. 따라서 동일한 양의 데이터를 보낼 때 네트워크 통신 횟수를 최소한으로 줄이면 동일 시간 내 더 많은 데이터를 전송할 수 있다.

카프카는 데이터를 모두 묶어서 전송하기 때문에 많은 양의 데이터를 묶음 단위로 빠르게 처리할 수 있다.

파티션 단위를 통해 동일 목적의 데이터를 여러 파티션에 분배하고 데이터를 병렬 처리할 수 있다.

### 확장성

데이터 파이프라인에서 데이터의 양을 예측하기 어렵지만 카프카는 이런 가변적인 환경에서 안정적으로 확장 가능하도록 설계되었다.

클러스터의 브로커 개수를 조절함으로써 상황에 따라 스케일 아웃, 스케일 인을 하여 안정적으로 운영이 가능하다.

### 영속성

카프카는 다른 메시징 플랫폼과 다르게 **전송받은 데이터를 메모리가 아닌 파일 시스템에 저장**한다.

디스크 기반의 파일 시스템 덕분에 브로커 앱이 장애 발생으로 종료되더라도 데이터 손실 없이 안전하게 데이터를 처리할 수 있다. 

이런 점이 같은 메시지큐인 RabbitMQ와 다른 점이다.

## Kafka 사용 사례

1. **로그 수집**
    
    여러 서버의 로그를 실시간으로 수집하고 중앙화할 수 있다.
    
2. **실시간 분석**
    
    클릭 스트림, 센서 데이터 등을 실시간으로 분석한다.
    
3. **마이크로서비스 간 이벤트 통신**
    
    서비스 간 비동기 통신과 이벤트 기반 아키텍처를 구현한다.
    
4. **데이터 파이프라인**
    
    다양한 소스에서 데이터를 수집하여 목적지로 전달한다.

## 메시지 큐 (Message Queue)

비동기 통신을 위한 중간 매개체로, **서비스 간 직접 통신 대신 메시지를 큐에 넣어 전달하는 방식**이다. Producer와 Consumer를 분리하여 느슨한 결합을 이룬다.

**주요 메시지 큐**

1. RabbitMQ
2. Kafka
3. AWS SQS
4. Redis

### 메시지 큐의 동작 방식

```
Producer → [Message Queue] → Consumer

주문 서비스 → [order-queue] → 재고 서비스
                           → 알림 서비스
                           → 분석 서비스
```

### 메시지 큐 사용의 장점

- **비동기 처리**
    
    요청과 응답을 분리하여 시스템 응답 속도를 향상시킨다.
    
- **부하 분산**
    
    여러 컨슈머가 큐에서 메시지를 가져가 병렬로 처리할 수 있다.
    
- **장애 격리**
    
    한 서비스 장애가 다른 서비스에 즉시 전파되지 않고, 메시지는 큐에 보관되기 때문에 서비스 복구 후 처리할 수 있다.
    
- **확장성**
    
    컨슈머 수를 조절하여 처리량을 조절할 수 있다.
    

## 이벤트 소싱 (Event Sourcing)

**시스템에서 발생한 모든 사실을 발생 순서대로 불변 이벤트로 저장하는 방식**이다.

현재 상태를 직접 저장하는 대신, 상태를 변경시킨 모든 이벤트를 순서대로 저장한다. 현재 상태는 이벤드들을 순차적으로 재생하여 복원한다.

### 전통적인 CRUD 방식 vs 이벤트 소싱

**전통적인 CRUD 방식**

```java
// 계좌 잔액만 저장
@Entity
public class Account {
    private Long id;
    private BigDecimal balance;  // 현재 잔액만 저장
}

// UPDATE 쿼리로 상태 덮어쓰기
account.setBalance(newBalance);
accountRepository.save(account);
// 이전 상태는 사라짐
```

**이벤트 소싱 방식**

```java
// 모든 변경 이력을 이벤트로 저장
@Entity
public class AccountEvent {
    private Long eventId;
    private Long accountId;
    private String eventType;  // DEPOSIT, WITHDRAW
    private BigDecimal amount;
    private LocalDateTime occurredAt;
}

// 이벤트 저장
public class Account {
    private List<AccountEvent> events = new ArrayList<>();
    
    public void deposit(BigDecimal amount) {
        AccountEvent event = new AccountEvent(
            accountId, "DEPOSIT", amount, LocalDateTime.now()
        );
        events.add(event);
        eventStore.save(event);
    }
    
    public void withdraw(BigDecimal amount) {
        AccountEvent event = new AccountEvent(
            accountId, "WITHDRAW", amount, LocalDateTime.now()
        );
        events.add(event);
        eventStore.save(event);
    }
    
    // 현재 잔액은 이벤트를 재생해서 계산
    public BigDecimal getBalance() {
        return events.stream()
            .map(e -> e.getEventType().equals("DEPOSIT") 
                ? e.getAmount() 
                : e.getAmount().negate())
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
```

→ 이전의 기록들이 사라지지 않고 모두 events 컬렉션이 저장되고 있는 것을 확인할 수 있다.

이러한 이벤트들을 저장하려면 먼저 사실을 나타내는 불변 객체인 **이벤트 객체(Event)**가 필요하고, 이런 이벤트를 영구적으로 저장하는 **이벤트 스토어(Event Stroe)**가 필요하다. 또한 이런 이벤트를 적용하여 현재 상태를 재구성하는 도메인 객체인 **에그리게이트(Aggregate)**를 구현해야한다.

### 이벤트 소싱의 장점

- **완벽한 감사 추적**
    
    모든 변경 이력이 보존되기 때문에 누가, 언제, 무엇을, 왜 변경했는지 추적할 수 있다. 금융이나 의료와 같은 규제가 엄격한 도메인에 필수이다.
    
- **시간 여행**
    
    과거 특정 시점의 상태를 재구성할 수 있다. 디버깅과 분석에 유용하다.
    
- **이벤트 재생**
    
    과거 이벤트를 다시 재생하여 새로운 뷰를 생성할 수 있다. 버그 수정 후 데이터 재처리가 가능하다.
    
- **자연스러운 이벤트 기반 아키텍처 연동**
    
    이벤트 스토어의 이벤트를 그대로 **메시지 큐**로 발행 가능하며, EDA와 결합할 수 있다.
    

## 메시지 큐 + 이벤트 소싱

```java
@Service
public class OrderService {
    
    @Transactional
    public void createOrder(CreateOrderCommand command) {
        // 1. 이벤트 소싱: 이벤트 저장
        OrderCreatedEvent event = new OrderCreatedEvent(command);
        eventStore.append(event);
        
        // 2. 메시지큐: 다른 서비스에 알림
        kafkaTemplate.send("order-events", event);
    }
}

// 다른 서비스들이 메시지큐를 통해 이벤트 수신
@KafkaListener(topics = "order-events")
public class InventoryService {
    public void handleOrderCreated(OrderCreatedEvent event) {
        reserveStock(event.getItems());
    }
}
```

이벤트 소싱 방식이 EDA와 완벽하게 결합되는 점을 이용해 **메시지 큐와 이벤트 소싱을 조합한 방식이 실무에서 많이 사용된다.** 이벤트 소싱을 이용해 과거 이력을 추적할 수 있으며, 메시지 큐를 이용해 서비스 간 느슨한 결합을 이룰 수 있다.

## 2PC 패턴과 SAGA 패턴

분산 환경에서 여러 서비스에 걸친 트랜잭션을 처리하는 두 가지 방식이다. 마이크로 서비스 아키텍처에서는 각 서비스가 독립적인 데이터베이스를 사용하기 때문에, 전통적인 단일 DB 트랜잭션으로는 데이터 일관성을 보장할 수 없다.

### 분산 트랜잭션 문제

**모놀리식 아키텍처**

```java
@Transactional  // 하나의 DB 트랜잭션으로 해결
public void createOrder(Order order) {
    orderRepository.save(order);           // 주문 저장
    inventoryRepository.decrease(items);   // 재고 감소
    paymentRepository.charge(amount);      // 결제 처리
    // 하나라도 실패하면 전부 롤백
}
```

**마이크로서비스 아키텍처**

```java
// 각 서비스가 독립적인 DB 사용
public void createOrder(Order order) {
    orderService.create(order);           // Order DB
    inventoryService.decrease(items);     // Inventory DB
    paymentService.charge(amount);        // Payment DB
    // 어떻게 일관성을 보장?
}
```

위와 같은 상황에서 결제는 성공했는데 재고 감소가 실패하는 경우가 생기거나, 주문은 생성됐지만 결제가 실패하는 문제 등 다양한 문제가 생길 수 있다. 이런 문제를 해결할 수 있는 패턴이 2PC와 SAGA이다.

## 2PC (Two-Phase Commit)

2단계 커밋 프로토콜로, **모든 참여자가 커밋할 준비가 되었는지 확인한 후 일괄 커밋하는 방식**이다. 중앙 조정자(Coordinator)가 전체 프로세스를 관리한다. 

### 동작 방식:

**Phase 1: Prepare (준비 단계)**

1. 조정자가 모든 참여자에게 “커밋 준비됨?” 요청
2. 각 참여자는 로컬 트랜잭션을 실행하고 성공 여부 응답
3. 아직 커밋하지 않고 대기

**Phase 2: Commit/Rollback (완료 단계)**

1. 모든 참여자가 OK → 조정자가 전체 커밋 명령
2. 하나라도 실패 → 조정자가 전체 롤백 명령

```
[Coordinator]
    │ Prepare?
    ├─→ [Order Service]    → OK
    ├─→ [Payment Service]  → OK
    └─→ [Inventory Service] → OK
    
[Coordinator]
    │ Commit!
    ├─→ [Order Service]    → Committed
    ├─→ [Payment Service]  → Committed
    └─→ [Inventory Service] → Committed
```

2PC 방식은 모두 성공하거나 모두 실패하기 때문에 **강한 일관성이 보장**된다. 또한, 성공 / 실패가 명확하게 구분되기 때문에 **구현이 명확하다.** 

반면 강한 일관성이 보장되는 만큼 모든 참여자가 응답할 때까지 대기해야하기 때문에 **성능이 저하되고**, 참여자 중 하나라도 장애 발생 시 **전체가 블로킹되는 문제점**이 있으며 참여자 증가 시 성능이 저하되기 때문에 **확장성이 떨어진다.**

## SAGA 패턴

보상 트랜잭션을 통한 분산 트랜잭션 관리 패턴이다. **각 서비스의 로컬 트랜잭션을 순차적으로 실행하고, 실패 시 이미 완료된 트랜잭션을 보상 트랜잭션으로 되돌린다.**

### SAGA 구현 방식

1. **Orchestration (오케스트레이션)**
    
    **중앙 조정자가 전체 흐름을 제어하는 방식**이다. 조정자가 각 서비스를 순차적으로 호출하고, 실패시 보상 트랜잭션을 실행한다.
    
    오케스트레이션 방식은 **전체 흐름이 명확**하게 보이며 **중앙에서 관리하기 쉽다**는 장점이 있다.
    
    하지만 조정자가 각 서비스를 지휘하는 만큼 조정자에 장애가 발생하면 트랜잭션 실행이 불가능하기 때문에 **단일 장애점**이 될 수 있다.
    
2. **Choreography (코레오그래피)**
    
    각 서비스가 독립적으로 이벤트를 발행하고 구독하는 방식이다. 중앙 조정자 없이 서비스들이 이벤트르 주고받으며 협력한다.
    
    **흐름 예시:**
    
    ```
    정상 흐름:
    OrderCreatedEvent → PaymentSuccessEvent → InventoryReservedEvent → DeliveryStartedEvent
    
    재고 부족 시:
    OrderCreatedEvent → PaymentSuccessEvent → InventoryFailedEvent 
        → PaymentRefundedEvent → OrderCancelledEvent
    ```
    
    Choreography 방식은 서비스 간 **결합도가 낮으며 단일 장애점이 존재하지 않는다**. 하지만 전체 **흐름을 파악하기 어렵고 디버깅이 어려울 수 있다.**
    

## 2PC vs SAGA

**2PC 패턴**은 금융 거래 등 **강한 일관성이 필요한 경우**, **참여 서비스가 소수이고 안정적인 경우**, **모놀리식 → 마이크로서비스로의 전환 초기**에 사용하기 좋다.

**SAGA 패턴**은 **확장성과 가용성이 중요하고 최종 일관성으로 충분한 경우**, **마이크로 서비스 환경**, 서**비스 간 독립성이 중요한 경우**에 사용하기 좋다.

→ **실무에서는 대부분 SAGA 패턴**을 사용한다고 한다. 마이크로 서비스의 핵심 가치인 확장성과 장애 격리를 유지하면서 분산 트랜잭션을 처리할 수 있기 때문이다.

## 서비스 레지스트리와 서비스 디스커버리

**마이크로 서비스 아키텍처에서 서비스 관리와 운영을 위한 패턴**이다. 서비스 간 통신 시 **서비스 위치가 정적이던 전통적인 어플리케이션과는 달리 주소가 동적으로 변화하고 서비스의 수가 많아지는 상황**에서 여러 서비스를 관리하기 위해 서비스 레지스트리 패턴과 서비스 디스커버리 패턴이 등장하게 되었다.

- **서비스 레지스트리**: 많은 마이크로 서비스들을 관리 및 운영하기 위해 서비스의 조서와 유동적인 IP를 매핑하여 저장하는 저장소이다.
- **서비스 디스커버리**: 클라이언트가 통신하고자 하는 대상 서비스의 위치를 서비스 레지스트리에서 찾아내는 과정이다.

## Spring Cloud Eureka

**서비스 디스커버리 패턴을 구현한 Netflix OSS의 핵심 컴포넌트**이다. 마이크로 서비스 아키텍처에서 각 서비스 인스턴스의 위치(IP, Port)를 자동으로 등록하고 관리하는 역할을 한다.

### 서비스 디스커버리가 필요한 이유

**전통적인 방식의 문제점**

```java
// 하드코딩된 서비스 주소
@Service
public class OrderService {
    
    public User getUser(Long userId) {
        RestTemplate restTemplate = new RestTemplate();
        String url = "http://192.168.1.100:8081/users/" + userId;  // 고정 IP
        return restTemplate.getForObject(url, User.class);
    }
}
```

- 서비스 인스턴스가 추가 및 제거되면 코드 수정이 필요하다.
- IP / Port 가 변경되면 설정 파일 수정 필요
- 로드밸런싱을 수동으로 구현해야 한다.
- 장애가 발생한 인스턴스를 자동으로 제외할 수 없다.

### Eureka를 사용한 방식

```java
@Service
public class OrderService {
    
    @Autowired
    private RestTemplate restTemplate;
    
    public User getUser(Long userId) {
        // 서비스 이름으로 호출 (IP 몰라도 됨)
        String url = "http://user-service/users/" + userId;
        return restTemplate.getForObject(url, User.class);
    }
}
```

**Eureka가 자동으로**

- 살아있는 user-service 인스턴스 찾기
- 여러 인스턴스 중 하나를 선택 (로드 밸런싱)
- 장애 인스턴스 자동 제외

## Eureka 구성 요소

### Eureka Server (레지스트리)

마이크로 서비스들의 정보를 저장하고 관리하는 중앙 서버다.

```java
@SpringBootApplication
@EnableEurekaServer  // Eureka Server 활성화
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```

`@EnableEurekaServer` 어노테이션을 통해 Eureka Server를 활성화 시킬 수 있다.

### Eureka Client (서비스)

Eureka Server에 자신을 등록하고 다른 서비스 정보를 조회하는 마이크로 서비스이다.

```java
@SpringBootApplication
@EnableEurekaClient  // Eureka Client 활성화
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
```

`@EnableEurekaClient` 어노테이션을 통해 **Eureka Server**에 등록할 수 있다.

### Eureka 동작 방식

1. **서비스 등록**
    
    서비스가 시작되면 자동으로 Eureka Server에 등록된다.
    
    ```
    User Service 시작
        ↓
    Eureka Server에 등록 요청
        - 서비스 이름: user-service
        - IP: 192.168.1.100
        - Port: 8081
        - 상태: UP
        ↓
    등록 완료
    ```
    
2. **하트비트**
    
    등록된 서비스는 주기적으로 Eureka Server에 하트비트를 전송하여 살아있음을 알린다.
    
    ```
    User Service → (30초마다) → Eureka Server: "나 살아있어요!"
    ```
    
3. **서비스 발견**
    
    다른 서비스 정보를 Eureka Server에서 조회한다.
    
    ```java
    @Service
    public class OrderService {
        
        @Autowired
        private DiscoveryClient discoveryClient;
        
        public void printUserServiceInstances() {
            // user-service의 모든 인스턴스 조회
            List<ServiceInstance> instances = 
                discoveryClient.getInstances("user-service");
            
            instances.forEach(instance -> {
                System.out.println("Host: " + instance.getHost());
                System.out.println("Port: " + instance.getPort());
                System.out.println("URI: " + instance.getUri());
            });
        }
    }
    ```
    
4. **레지스트리 캐싱**
    
    각 클라이언트는 레지스트리 정보를 로컬에 캐시하고 주기적으로 갱신한다.
    
    ```
    Order Service
        ↓ (30초마다)
    Eureka Server에서 레지스트리 가져오기
        ↓
    로컬 캐시 업데이트
        - user-service: [192.168.1.100:8081, 192.168.1.101:8081]
        - payment-service: [192.168.1.200:8082]
    ```