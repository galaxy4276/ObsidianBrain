#event-driven #nestjs #nodejs #kafka 

## 마이크로서비스 메스
한 가지 상황을 생각해보자. 당신의 팀은 NestJS를 사용하여 멋진 이커머스 플랫폼을 구축했다. 처음에는 단순했다. 사용자가 제품을 둘러보고, 장바구니에 추가하고, 결제하는 것뿐이었다.
6개월 후, 그 "단순한" 앱은 괴물로 성장했다. 사용자가 주문을 할 때, 다음과 같은 작업들이 필요하다.
- 결제 처리
- 재고 업데이트
- 확인 이메일 발송
- 창고 시스템 알림
- 분석 업데이트
- 로열티 포인트 트리거
- 그리고 아마 내가 잊고 있는 다른 10가지 일들

한때 깔끔했던 컨트롤러는 이제 이렇게 생겼다.
```typescript
@Post('/orders')
async createOrder(@Body() orderData: CreateOrderDto) {
  // 주문 저장
  const order = await this.orderService.create(orderData);
  
  // 결제 처리
  await this.paymentService.processPayment(order);
  
  // 재고 업데이트
  await this.inventoryService.updateStock(order.items);
  
  // 확인 이메일 발송
  await this.emailService.sendOrderConfirmation(order);
  
  // 창고 알림
  await this.warehouseService.notifyNewOrder(order);
  
  // 분석 업데이트
  await this.analyticsService.trackPurchase(order);
  
  // 로열티 포인트 추가
  await this.loyaltyService.addPoints(order.userId, order.total);
  
  return order;
}
```

문제가 보이는가? 하나의 엔드포인트가 너무 많은 작업을 하고 있다. 코드는 밀접하게 결합되어 있고, 테스트하기 어려우며, 확장하기 불가능하다. 이러한 프로세스 중 하나라도 실패하면 전체 요청이 실패한다. 그리고 하나의 서비스가 느리면 모든 것이 느려진다.

친숙한가? 이럴 때 이벤트 기반 아키텍처가 필요하다.
## 왜 이벤트 기반 아키텍처인가
이벤트 기반 아키텍처(EDA)는 애플리케이션 컴포넌트가 직접적인 메서드 호출 대신 이벤트를 통해 통신할 수 있게 한다. 이는 마치 앱을 동기식 오케스트라(모든 사람이 정확히 맞는 시간에 연주해야 하는)에서 비동기식 재즈 밴드(음악가들이 신호에 반응하지만 타이밍에 자유가 있는)로 전환하는 것과 같다.

이점은 다음과 같다.
- 느슨한 결합: 서비스들이 서로에 대해 알 필요가 없다
- 더 나은 복원력: 하나의 서비스 실패가 시스템 전체를 중단시키지 않는다
- 향상된 확장성: 기존 이벤트를 리스닝하는 새 컴포넌트를 쉽게 추가할 수 있다
- 향상된 유지 관리성: 더 작고 집중된 코드 조각
## NestJS + 이벤트 = ❤️
좋은 소식은 NestJS가 이러한 것을 염두에 두고 구축되었다는 것이다. 프레임워크는 써드파티 메시지 브로커 없이도 이벤트 기반 패턴을 구현할 수 있는 내장 도구를 제공한다(물론 필요할 때 그것들을 통합할 수도 있다).

그 복잡한 컨트롤러를 더 깔끔하게 변환해보자!
## NestJS에서 이벤트 설정하기
먼저, 이벤트 시스템을 설정해보자. NestJS는 기본적으로 EventEmitter 인터페이스를 제공하지만, 더 나은 구조를 위해 더 강력한 @nestjs/cqrs 패키지를 사용하는 것이 좋다.
```bash
npm install @nestjs/cqrs
```

```typescript
// events/order-created.event.ts
export class OrderCreatedEvent {
  constructor(public readonly order: Order) {}
}
```

```typescript
// app.module.ts
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { OrdersModule } from './orders/orders.module';
// 다른 임포트들...
@Module({
  imports: [
    CqrsModule,
    OrdersModule,
    // 다른 모듈들...
  ],
})
export class AppModule {}
```

그리고 이벤트 핸들러와 함께 주문 모듈을 설정하자:

```typescript
// orders/orders.module.ts
import { Module } from '@nestjs/common';
import { CqrsModule } from '@nestjs/cqrs';

import { OrdersController } from './orders.controller';
import { OrdersService } from './orders.service';
import { OrderCreatedHandlers } from './events/handlers';
@Module({
  imports: [CqrsModule],
  controllers: [OrdersController],
  providers: [
    OrdersService,
    ...OrderCreatedHandlers,
  ],
})
export class OrdersModule {}
```

## 컨트롤러 정리하기
이제, 그 복잡한 컨트롤러를 정리해보자.
```typescript
// orders/orders.controller.ts
import { Controller, Post, Body } from '@nestjs/common';
import { EventBus } from '@nestjs/cqrs';

import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { OrderCreatedEvent } from './events/order-created.event';
@Controller('orders')
export class OrdersController {
  constructor(
    private readonly ordersService: OrdersService,
    private readonly eventBus: EventBus,
  ) {}
  @Post()
  async createOrder(@Body() createOrderDto: CreateOrderDto) {
    // 주문만 생성
    const order = await this.ordersService.create(createOrderDto);
    
    // 주문이 생성되었다는 이벤트 발행
    this.eventBus.publish(new OrderCreatedEvent(order));
    
    // 클라이언트에게 즉시 반환
    return order;
  }
}
```

봐라! 이제 우리의 컨트롤러는 주문 생성이라는 주요 책임에만 집중하고 있다. 다른 모든 것은 OrderCreatedEvent에 대한 응답으로 발생한다.

## 이벤트 핸들러 만들기
이제, 이벤트에 대한 핸들러를 구현해보자.
```typescript
// orders/events/handlers/process-payment.handler.ts
import { EventsHandler, IEventHandler } from '@nestjs/cqrs';
import { OrderCreatedEvent } from '../order-created.event';
import { PaymentService } from '../../../payment/payment.service';

@EventsHandler(OrderCreatedEvent)
export class ProcessPaymentHandler implements IEventHandler<OrderCreatedEvent> {
  constructor(private paymentService: PaymentService) {}
  async handle(event: OrderCreatedEvent) {
    const { order } = event;
    await this.paymentService.processPayment(order);
  }
}
```

또 다른 핸들러를 만들어보자.

```typescript
// orders/events/handlers/update-inventory.handler.ts
import { EventsHandler, IEventHandler } from '@nestjs/cqrs';
import { OrderCreatedEvent } from '../order-created.event';
import { InventoryService } from '../../../inventory/inventory.service';

@EventsHandler(OrderCreatedEvent)
export class UpdateInventoryHandler implements IEventHandler<OrderCreatedEvent> {
  constructor(private inventoryService: InventoryService) {}
  async handle(event: OrderCreatedEvent) {
    const { order } = event;
    await this.inventoryService.updateStock(order.items);
  }
}
```

그리고 모든 핸들러를 수집하는 인덱스 파일을 만들자.

```typescript
// orders/events/handlers/index.ts
import { ProcessPaymentHandler } from './process-payment.handler';
import { UpdateInventoryHandler } from './update-inventory.handler';
import { SendOrderConfirmationHandler } from './send-order-confirmation.handler';
// 다른 핸들러들 임포트...

export const OrderCreatedHandlers = [
  ProcessPaymentHandler,
  UpdateInventoryHandler,
  SendOrderConfirmationHandler,
  // 다른 핸들러들 추가...
];
```

## 실제 세계에서의 장점
이것이 왜 게임 체인저인지 내 프로젝트 중 하나의 실제 예를 통해 보여주겠다.
우리는 사용자 가입이 다음과 같은 7가지 다른 프로세스를 트리거하는 SaaS 플랫폼을 구축하고 있었다.
- Stripe 고객 생성
- 기본 워크스페이스 설정
- 환영 이메일 발송
- 분석 추적 구성
- 리소스 프로비저닝

기능을 추가하면서 코드가 복잡해졌다. 이벤트 기반 아키텍처로 전환함으로써, 가입 컨트롤러는 간소화되었고, 각 프로세스는 우리가 독립적으로 테스트할 수 있는 전용 핸들러를 갖게 되었다.
새로운 기능(SMS 인증 발송)을 추가해야 했을 때, 우리는 단지
- 새 이벤트 핸들러를 만들고
- 모듈에 등록했다
- 기존 코드에 변경사항 없음!

이것이 이벤트 기반 아키텍처의 아름다움이다. 애플리케이션이 변화에 더 유연해진다.

## 고급 패턴: 다단계 프로세스를 위한 사가(Saga)
때로는 특히 후반 단계가 이전 단계의 완료에 의존할 때 이벤트 시퀀스를 조정해야 한다. NestJS CQRS는 이를 위한 "사가"를 제공한다.

```typescript
// orders/sagas/orders.saga.ts
import { Injectable } from '@nestjs/common';
import { Saga, ofType } from '@nestjs/cqrs';
import { Observable, map } from 'rxjs';

import { OrderCreatedEvent } from '../events/order-created.event';
import { PaymentProcessedEvent } from '../events/payment-processed.event';
import { ShipOrderCommand } from '../commands/ship-order.command';
@Injectable()
export class OrdersSaga {
  @Saga()
  orderCreated = (events$: Observable<any>): Observable<any> => {
    return events$.pipe(
      ofType(PaymentProcessedEvent),
      map(event => {
        console.log('결제 처리됨, 배송 트리거 중');
        return new ShipOrderCommand(event.orderId);
      }),
    );
  }
}
```

그런 다음 모듈에 사가를 등록하자.

```typescript
// orders/orders.module.ts
import { OrdersSaga } from './sagas/orders.saga';

@Module({
  // ...
  providers: [
    OrdersService,
    OrdersSaga,
    ...OrderCreatedHandlers,
  ],
})
export class OrdersModule {}
```
## 이벤트 기반 아키텍처에서의 오류 처리
이벤트 기반 시스템의 한 가지 과제는 오류 처리다. 이벤트 핸들러가 실패하면 어떻게 될까?
다음은 내가 추천하는 패턴이다.

```typescript
// orders/events/handlers/process-payment.handler.ts
import { EventsHandler, IEventHandler } from '@nestjs/cqrs';
import { Logger } from '@nestjs/common';
import { OrderCreatedEvent } from '../order-created.event';
import { PaymentService } from '../../../payment/payment.service';
import { EventBus } from '@nestjs/cqrs';
import { PaymentFailedEvent } from '../payment-failed.event';

@EventsHandler(OrderCreatedEvent)
export class ProcessPaymentHandler implements IEventHandler<OrderCreatedEvent> {
  private readonly logger = new Logger(ProcessPaymentHandler.name);
  constructor(
    private paymentService: PaymentService,
    private eventBus: EventBus,
  ) {}
  async handle(event: OrderCreatedEvent) {
    const { order } = event;
    try {
      await this.paymentService.processPayment(order);
      // 성공 이벤트 발행
      this.eventBus.publish(new PaymentSucceededEvent(order));
    } catch (error) {
      this.logger.error(`주문 ${order.id}에 대한 결제 처리 실패`, error.stack);
      // 실패 이벤트 발행
      this.eventBus.publish(new PaymentFailedEvent(order, error));
    }
  }
}
```

이렇게 하면 시스템의 다른 부분이 실패에 적절하게 반응할 수 있다.
## NestJS 이벤트를 넘어: 외부 메시지 브로커
애플리케이션이 커지면서, RabbitMQ, Kafka 또는 Redis pub/sub과 같은 외부 메시지 브로커로 이동하고 싶을 수 있다. NestJS는 마이크로서비스 패키지를 통해 이를 쉽게 만든다.

```bash
npm install @nestjs/microservices
```

Redis와 함께 사용하는 방법은 다음과 같다.

```typescript
// main.ts
import { NestFactory } from '@nestjs/core';
import { MicroserviceOptions, Transport } from '@nestjs/microservices';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.connectMicroservice<MicroserviceOptions>({
    transport: Transport.REDIS,
    options: {
      url: 'redis://localhost:6379',
    },
  });
  await app.startAllMicroservices();
  await app.listen(3000);
}
bootstrap();
```

그리고 이벤트를 발행하려면...

```typescript
// ClientProxy 사용
import { Controller, Post, Body, Inject } from '@nestjs/common';
import { ClientProxy } from '@nestjs/microservices';
import { CreateOrderDto } from './dto/create-order.dto';

@Controller('orders')
export class OrdersController {
  constructor(
    @Inject('ORDERS_SERVICE') private client: ClientProxy,
    private readonly ordersService: OrdersService,
  ) {}
  @Post()
  async createOrder(@Body() createOrderDto: CreateOrderDto) {
    const order = await this.ordersService.create(createOrderDto);
    this.client.emit('order_created', order);
    return order;
  }
}
```

## 마치며
이벤트 기반 아키텍처는 단지 멋진 아키텍처 패턴이 아니다. 이는 NestJS 애플리케이션이 성장함에 따라 발생하는 실제 문제에 대한 실용적인 솔루션이다. 이벤트를 통해 시스템 컴포넌트를 분리함으로써, 다음과 같은 이점을 얻을 수 있다.
- 이해하기 쉬운 더 깔끔한 코드베이스
- 실패가 격리된 더 복원력 있는 시스템
- 컴포넌트가 독립적으로 확장할 수 있는 더 나은 확장성
- 기존 코드를 건드리지 않고 새 기능을 추가할 수 있는 향상된 유연성

💡 가장 좋은 점은 점진적으로 이 아키텍처를 채택할 수 있다는 것이다. 복잡한 워크플로우에 대해 몇 가지 이벤트부터 시작하고 거기서부터 확장하자.

좋은 아키텍처는 트렌드를 따르는 것이 아니라 실제 문제를 해결하는 것이다. NestJS 애플리케이션의 복잡성이 증가하고 있다면, 이벤트 기반 아키텍처가 바로 관리하기 쉽게 유지하는 데 필요한 것일 수 있다.

# References
- NestJS 공식 문서: [https://docs.nestjs.com/](https://docs.nestjs.com/)
- NestJS CQRS 패키지: [https://docs.nestjs.com/recipes/cqrs](https://docs.nestjs.com/recipes/cqrs)
- NestJS 마이크로서비스: [https://docs.nestjs.com/microservices/basics](https://docs.nestjs.com/microservices/basics)
https://medium.com/@mohantaankit2002/how-to-implement-event-driven-architecture-in-nestjs-without-complicating-the-codebase-6314fb0df524
