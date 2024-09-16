#spring #asynchronous 

스프링 부트에서 일반적으로 동기 호출이 사용되며 비동기 호출이 적합한 사례의 예시를 들어보자.
![[Spring 에서의 Asynchronous-20240916204031288.webp|605]]

예를 들어, 새로운 사용자가 등록되면 이메일 알림이 전송되며 나중에 회원으로 업그레이드 시 1000 포인트가 제공된다.

### 내결함성 및 견고성 (Fault Tolerance, Robustness)
이메일 전송에 예외가 발생하더라도 전송 실패로 인해 사용자 등록이 실패할 수는 없다.
사용자 등록이 주요 기능이고, 이메일 전송은 부차적인 기능이기 때문이다.
> 사용자가 이메일을 받을 수는 없게되지만 시스템에 로그인을 할 수 있는 경우에 이메일은 신경쓰지 않을 것이다.

### 인터페이스 성능 개선
예를 들어 사용자를 등록하는 데 `20ms`, 이메일을 보내는데 `2000ms` 가 소요된다면 동기 모드에서 총 `2020`ms 가 소요되며 사용자는 느리다고 느낄 수 있다.
여기서 비동기 모드를 사용할 경우 수십 밀리초 안에 사용자 등록을 성공할 수 있게된다.


아래부터는 코드 예시에 대해서 소개한다.
# Spring Asynchronous Programming
```java
@Component  
public class AsyncTask {  
  
	@Async  
	public void sendEmail() {  
		long t1 = System.currentTimeMillis();  
		Thread.sleep(2000);  
		long t2 = System.currentTimeMillis();  
		System.out.println("Sending an email took " + (t2-t1) + " ms");  
	}  
}
...
@RestController  
@RequestMapping("/user")  
public class AsyncController {  
	  
	@Autowired  
	private AsyncTask asyncTask;  
	  
	@RequestMapping("/register")  
	public void register() throws InterruptedException {  
		long t1 = System.currentTimeMillis();  
		// Simulate the time required for user registration.  
		Thread.sleep(20);  
		// Registration is successful. Send an email.  
		asyncTask.sendEmail();  
		long t2 = System.currentTimeMillis();  
		System.out.println("Registering a user took " + (t2-t1) + " ms");  
	}  
}

```


위 예제 코드에서 `/user/register` 를 호출하고 난 경우 출력은 다음과 같다.
```bash
Registering a user took 29 ms  
Sending an email took 2006 ms
```

이러한 방식으로 Spring 에서 async call 을 사용해야할 때 스레드 풀을 지정해주어야 한다.

# Thread Pool for Async
`@Async` 를 사용할 때 기본적으로 `SimpleAsyncTaskExecutor` 스레드 풀이 사용되며 해당 객체는 진정한 스레드 풀이 아니다.
#### SimpleAsyncTaskExecutor
해당 스레드 풀은 스레드 재사용이 불가능하다.
호출될 때마다 새로운 스레드가 생성되며 스레드가 지속적으로 생성된다면 결국 시스템에서 과도한 메모리 사용으로 `OutOfMemoryError` 가 발생하게 된다.

아래 코드는 해당 객체의 구현부인데,

```java
public void execute(Runnable task, long startTimeout) {  
	Assert.notNull(task, "Runnable must not be null");  
	Runnable taskToUse = this.taskDecorator != null ? this.taskDecorator.decorate(task) : task;  
	// Determine whether rate limiting is enabled. By default, it is not enabled.  
	if (this.isThrottleActive() && startTimeout > 0L) {  
	// Perform pre-operations and implement rate limiting.  
		this.concurrencyThrottle.beforeAccess();  
		this.doExecute(new SimpleAsyncTaskExecutor.ConcurrencyThrottlingRunnable(taskToUse));  
	} else {  
		// In the case of no rate limiting, execute thread tasks.  
		this.doExecute(taskToUse);  
	}  
}  
	  
	protected void doExecute(Runnable task) {  
		// Continuously create threads.  
		Thread thread = this.threadFactory != null ? this.threadFactory.newThread(task) : this.createThread(task);  
		thread.start();  
	}  
	  
	public Thread createThread(Runnable runnable) {  
		//Specify the thread name, task-1, task-2, task-3...  
		Thread thread = new Thread(this.getThreadGroup(), runnable, this.nextThreadName());  
		thread.setPriority(this.getThreadPriority());  
		thread.setDaemon(this.isDaemon());  
		return thread;  
	}
```

매 호출마다 새로운 스레드를 생성하는 것을 볼 수 있다.
이것이 Spring 에서 `@Async` 를 사용할 때 `SimpleAsyncTaskExecutor` 를 대체해야하는 이유이다.
가장 일반적으로 `ThreadPoolTaskExecutor` 객체를 사용하며 `java.util.concurrent.ThreadPoolExecutor` 의 래퍼이다.

소개한 객체들의 구현 경로는 다음과 같다.
![[Spring 에서의 Asynchronous-20240916205643884.webp]]

## Custom Thread Pool 구현해보기
```java
@Configuration  
@EnableAsync  
public class SyncConfiguration {  
@Bean(name = "asyncPoolTaskExecutor")  
		public ThreadPoolTaskExecutor executor() {  
		ThreadPoolTaskExecutor taskExecutor = new ThreadPoolTaskExecutor();  
		// Core thread count.
		taskExecutor.setCorePoolSize(10);  
		// 스레드 풀이 유지되는 최대 스레드 수, 버퍼 대기열이 가득 찬 경우에만 코어 스레드 수를 초과하는 스레드가 요청 된다.
		taskExecutor.setMaxPoolSize(100);  
		// Cache queue.  
		taskExecutor.setQueueCapacity(50);  
		// 허용된 유휴 시간, 코어 스레드 이외의 스레드는 유휴 시간이 지나면 소멸된다.
		taskExecutor.setKeepAliveSeconds(200);  
		// Thread name prefix for asynchronous methods.  
		taskExecutor.setThreadNamePrefix("async-");  
		/**  
* 스레드 풀의 작업 캐시 큐가 가득 차고 스레드 풀의 스레드 수가 최대PoolSize에 도달한 후에도 계속 들어오는 작업이 있으면 작업 거부 정책이 채택됩니다.
* 일반적으로 다음과 같은 네 가지 정책이 있습니다:
* ThreadPoolExecutor.AbortPolicy: 태스크를 폐기하고 RejectedExecutionException을 던집니다. 
* ThreadPoolExecutor.DiscardPolicy: 또한 작업을 폐기하되 예외를 던지지 않습니다. 
* ThreadPoolExecutor.DiscardOldestPolicy: 대기열 맨 앞에 있는 작업을 삭제한 다음 작업을 다시 실행하려고 시도합니다(이 과정을 반복).
* ThreadPoolExecutor.CallerRunsPolicy: 현재 작업 추가를 다시 시도하고 성공할 때까지 자동으로 execute() 메서드를 반복적으로 호출합니다.
		*/  
		taskExecutor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());  
		taskExecutor.initialize();  
		return taskExecutor;  
	}  
}
```


## 스레드 풀의 격리 사용
시스템에 여러 개의 스레드 풀이 존재하는 경우 기본 스레드 풀을 구성할 수도 있다.
```java
@Configuration  
@EnableAsync  
@Slf4j  
public class AsyncConfiguration implements AsyncConfigurer {  
	  
	@Bean(name = "myAsyncPoolTaskExecutor")  
	public ThreadPoolTaskExecutor executor() {  
	// Initialization code for thread pool configuration as above.  
	}  
	  
	@Bean(name = "otherTaskExecutor")  
	public ThreadPoolTaskExecutor otherExecutor() {  
	// Initialization code for thread pool configuration as above.  
	}  
	  
	/**  
	* Specify the default thread pool.  
	*/  
	@Override  
	public Executor getAsyncExecutor() {  
	return executor();  
	}  
	  
	@Override  
	public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {  
		return (ex, method, params) ->  
		log.error("An unknown error occurred while executing tasks in the thread pool. Executing method: {}", method.getName(), ex);  
	}  
}

```

위와 같이 다른 스레드 풀 빈 객체를 구성하고 다음과 같이 사용할 수도 있다.
```java
@Async("myAsyncPoolTaskExecutor")  
public void sendEmail() {  
	long t1 = System.currentTimeMillis();  
	Thread.sleep(2000);  
	long t2 = System.currentTimeMillis();  
	System.out.println("Sending an email took " + (t2-t1) + " ms");  
}  
  
@Async("otherTaskExecutor")  
public void otherTask() {  
//...  
}
```

# References
https://medium.com/javarevisited/how-does-spring-boot-implement-asynchronous-programming-this-is-how-masters-do-it-e89fc9245928