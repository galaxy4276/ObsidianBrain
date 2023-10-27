---
tags: authenication, http
---
![Untitled](Untitled%2043.png)

# API Authentication(인증) 이란?

- API의 보호된 리소스에 대한 액세스를 허용하기 전에 사용자 또는 디바이스의 신원을 확인하는 프로세스
- 인증은 권한이 부여된 사용자만이 API에 액세스할 수 있도록 하고 무단 액세스를 방지함.

# 인증과 인가 테이블 정리

| API Authentication(인증) | API Authorization(인가) |
| --- | --- |
| 클라이언트의 신원을 확인 | API 내에서 특정 리소스나 작업에 대한 액세스를 제어 |
| 권한이 부여된 사용자에게만 API에 액세스할 수 있게 함 | 클라이언트가 API를 통해 수행할 수 있는 작업을 결정 |
| 무단 액세스를 방지합니다.
 예: 토큰 기반 인증, OAuth, API 키 | 사용자 역할 또는 권한을 기반으로 다음을 수행할 수 있음. 
예: 역할 기반 액세스 제어, 속성 기반 액세스 제어 |

# 흔하게 사용되는 4가지 인증 방법

1. Basic Authentication
2. Token Authentication
3. OAuth Authentication
4. API Key Authentication

## Basic Authentication

가장 간단한 형태의 인증 방식으로 매 HTTP 요청마다 서버로 사용자의 이름과 비밀번호 정보를 송신한다.

HTTP 인증은 헤더에 저장되며 자격 증명은 Base64 로 인코딩되어 수행된다.

****************************************************************해당 방식은 사용자를 빠르고 쉽게 인증해야 할 때 유용하다.****************************************************************

**다만 해당 방식은 기본 인증 정보가 평문으로 전달되기 때문에 운용 환경에 적합하지 않다.**

다음은 이해를 돕기 위한 간단한 Python 코드이다.

```python
import requests

url = "https://example.com"

# Use the following format for the username and password: "username:password"
credentials = "user:pass"

headers = {
    "Authorization": f"Basic {credentials}"
}

response = requests.get(url, headers=headers)

print(response.status_code)
```

## Token Authentication

각 사용자에 대해 생성된 고유한 토큰을 이용하는 방법이며 매 HTTP 요청마다 헤더에 토큰 값을 저장한다.

빈번한 인증이 필요한 애플리케이션에서 적합한 방법이며, 각 사용자 자격증명 토큰에 지정된 세션 시간 동안 인증 및 인가 절차가 수행된다.

<aside>
💡 시간이 된다면, JWT 의 Bearer 방식에 대한 정리 및 JWT 를 사용함으로써 얻는 이득에 대해 정리하자.

</aside>

## OAuth Authentication

사용자가 비밀번호를 공유하지 않고도 데이터에 대한 액세스 권한을 부여할 수 있는 방법을 제공하는 인증용 개방형 표준이다.

해당 인증 방식은 사용자를 인증하고 시스템 또는 서비스에 대한 액세스를 승인하는 데 사용된다.

Twitter, Facebook, Google 과 같은 외부 서비스에서 사용자 데이터에 액세스 해야 하는 서비스에 적합하다.

<aside>
💡 해당 외부서비스의 OAuth 인증을 이용해 사용자의 아이디, 비밀번호를 공유받지 않고도 데이터에 대한 액세스 권한을 부여할 수 있다.

</aside>

## API Key Authentication

API 키는 사용자를 인증하고 API에 액세스 할 수 있도록 허용하는데 사용되는 고유한 문자열 키다.

해당 키는 서버에서 생성되어 사용자에게 제공된다.

클라이언트는 각 요청에 대해 전달받은 키를 포함하여 요청을 수행하고, 서버는 해당 키를 받아 사용자를 식별하고 리소스에 대한 액세스를 승인한다.

# 각 인증 방식에 대한 단점

- Basic Authentication 은 다른 방식 대비 안전하지 않으며 공격에 취약하다.
- 토큰 방식은 Basic 대비 안전하지만 구현하기 어렵다.
- OAuth 는 각 사용자 계정에 대해 서비스 공급자가 필요로 하다.
- API 키는 안전하지만 관리하기가 어렵다.

# REST API 인증을 구현하기 위한 최선의 전략

1. **Access Control Lists (ACLs) 구현하기**
    - ACL은 특정 사용자 또는 애플리케이션에 대한 액세스를 제한하는 데 사용된다.
        
          이를 통해 권한이 부여된 사용자와 애플리케이션만 API에 액세스할 수 있도록 할 수 있음
        
2. **안전한 인증 프로토콜 사용하기**
    - OAuth 및 OpenID Connect 같은 보안 프로토콜을 사용하여 추가적인 보안 계층을 제공하고 권한이 부여된 사용자 또는 애플리케이션만 API 액세스 할 수 있도록 보장하자.
3. **강력한 비밀번호 사용**
4. **암호화 기능 사용**
5. **액세스 모니터링 수행**
    - API 에 대한 액세스를 모니터링 할 수 있는 시스템을 구축하여 **무단 액세스 시도를 감지**하는 것이 중요하다.
    - 무단 액세스 시도 감지를 통해 잠재적 보안 문제를 식별하여 취약점을 해결해야 한다.

[Most Used REST API Authentication Methods & Strategies  | MojoAuth Blog](https://mojoauth.com/blog/rest-api-authentication/)