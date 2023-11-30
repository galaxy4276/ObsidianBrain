---
tags: saga-pattern, spring
---
![[Pasted image 20231130102725.png]]
# Saga Pattern
사가 패턴은 마이크로서비스 아키텍처 내에서 분산 트랜잭션을 관리하는데 사용되는 디자인 패턴입니다.
여러 마이크로서비스에서 데이터 일관성을 유지하는 데 따르는 복잡성과 문제를 해결하는 동시에 기존 분산 트랜잭션의 함정을 피할 수 있습니다.

사가 패턴에서는 글로벌 트랜잭션이 일련의 작은 로컬 트랜잭션으로 나뉘며, 각 트랜잭션은 특정 마이크로서비스와 연관이 있습니다.
<mark style="background: #D2B3FFA6;">한 단계에서 트랜잭션 실패가 발생할 경우 이전 단계를 취소하는 보상 작업이 트리거되어 데이터 일관성을 보장합니다.</mark>

# Spring 에서 간단한 Saga Pattern 구현
시나리오는 다음과 같습니다.

**1. 예약 서비스**
	* 호텔 예약을 처리합니다.
**2. 결제 서비스**
	* 결제 프로세스를 처리합니다.
**3. 공유 데이터베이스(PostgreSQL)**
	* 예약 및 결제와 관련된 데이터를 저장합니다.
**4. 메시지 브로커(ActiveMQ)**
	* 마이크로서비스 간의 비동기 통신을 처리합니다.

어느 단계에서 실패가 발생하면 사가 패턴은 적절한 보상 조치를 수행합니다.

### 예약 서비스 코드

```java
@Service
public class BookingService {
    @Autowired
    private JmsTemplate jmsTemplate;
    
    @Autowired
    private BookingRepository bookingRepository;
    
    @Transactional
    public void makeBooking(Booking booking) {
        bookingRepository.save(booking);
        jmsTemplate.convertAndSend("bookingQueue", booking);
    }
    @Transactional
    public void confirmBooking(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId).orElse(null);
        if (booking != null) {
            booking.setConfirmed(true);
            bookingRepository.save(booking);
        }
    }
    @Transactional
    public void cancelBooking(Long bookingId) {
        Booking booking = bookingRepository.findById(bookingId).orElse(null);
        if (booking != null) {
            bookingRepository.delete(booking);
        }
    }
}
```

### 결제 서비스 코드
```java
@Service
public class PaymentService {
    @Autowired
    private JmsTemplate jmsTemplate;
    
    @Autowired
    private PaymentRepository paymentRepository;

    @Transactional
    public void processPayment(Booking booking) {
        Payment payment = new Payment();
        payment.setBookingId(booking.getId());
        payment.setAmount(calculatePaymentAmount(booking));
        paymentRepository.save(payment);
        jmsTemplate.convertAndSend("paymentQueue", payment);
    }
    @Transactional
    public void confirmPayment(Long bookingId) {
        Payment payment = paymentRepository.findByBookingId(bookingId);
        if (payment != null) {
            payment.setPaid(true);
            paymentRepository.save(payment);
        }
    }
    @Transactional
    public void cancelPayment(Long bookingId) {
        Payment payment = paymentRepository.findByBookingId(bookingId);
        if (payment != null) {
            paymentRepository.delete(payment);
        }
    }
    private double calculatePaymentAmount(Booking booking) {
        // Implement your payment calculation logic here
        return booking.getRoomPrice() * booking.getNumNights();
    }
}
```

### 사가 오케스트레이터 코드
```java
@Service
public class SagaOrchestrator {
    @Autowired
    private BookingService bookingService;
    
    @Autowired
    private PaymentService paymentService;

    @JmsListener(destination = "bookingQueue")
    public void handleBooking(Booking booking) {
         
    }
    @JmsListener(destination = "paymentQueue")
    public void handlePayment(Payment payment) {
        try {
      // step 2: confirm payment is success or failed. If it's failed
      // It's failure, throw exception and rollback.  
            paymentService.confirmPayment(payment.getBookingId());
      // Step 3: Mark status is comfirmed in booking.
      bookingService.confirmBooking(payment.getBookingId())
        } catch (Exception e) {
            // Handle exceptions and initiate compensation
		    bookingService.cancelBooking(booking.getId());
            paymentService.cancelPayment(payment.getBookingId());
        }
    }
}
```


# Saga Pattern 의 혜택 및 고려사항

사가 패턴의 장점입니다.
##### 탈중앙화
각 마이크로서비스가 글로벌 트랜잭션의 일부분을 담당하므로 중앙 집중식 코디네이터의 필요성이 줄어듭니다.

##### 확장성
사가의 각 단계가 로컬 트랜잭션이므로 보상 작업을 실행하여 데이터 일관성을 보장함으로써 쉽게 복구할 수 있도록 합니다.

##### 성능
분산 트랜잭션을 피하면 시스템 성능이 향상될 수 있습니다.

그러나 사가를 관리하고 보상 조치를 구현하는데 따르는 복잡성을 고려해야합니다.

# References
[마이크로서비스에서 Spring Boot 및 ActiveMQ로 사가 패턴 구현하기](https://jackynote.medium.com/implementing-the-saga-pattern-with-spring-boot-and-activemq-in-microservice-43742d7ca300)