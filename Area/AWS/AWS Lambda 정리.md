# AWS Lambda 정리

태그: Lambda, Serveless
Date: September 7, 2023 12:25 AM
공개 여부: 공개
설명: 지갑을 아껴주는 람다서비스
카테고리: AWS

<aside>
💡 해당 글은 AWS Lambda 에 대해 단순한 이해 뿐만 아닌, 적절한 사용사례또한 첨부하여 AWs Lambda 서비스 활용에 대한 시야를 넓히기 위해 작성하였습니다.

</aside>

![Untitled](Untitled%2031.png)

## AWS Lambda 란?

AWS Lambda 는 Serverless Computing Service 이다.

<aside>
💡 **Serverless Computing Service**
애플리케이션을 실행하는 데 있어 별도의 서버 세팅없이 곧바로 코드를 실행해주는 서비스를 의미한다.

</aside>

EC2 인스턴스는 초 단위로 비용을 계산하는 반면 Lambda 는 1ms 당 요금을 정확히 계산하여 사용한만큼 비용이 발생한다.

이러한 서비스 유형을 FaaS(Function as a  Server) 라고 부른다.

### Lambda 의 Runtime 지원 여부

Lambda 는 C#, Powershell, Go, Java, NodeJS, Python, Ruby 를 공식적으로 지원하며, 공식 런타임이 없더라도 커스텀 런타임을 통해 지원하지 않는 언어를 사용할  수 있도록 확장할 수 있다.

또한 **리눅스에서 실행가능한 임의의 바이너리**를 포함하여 실행도 가능하다.

## 람다 함수 트리거

람다는 특정 이벤트를 기반으로 요청받은 즉시 실행된다.

API 게이트웨이나 로드밸런서가 받은 요청을 기반으로 실행할 수도 있으며, AWS의 다양한 서비스와 연동할 수 있다.

### 트리거 사례들

- **CloudWatch Events**
    
    크론잡과 같이 실행 스케줄을 지정하여 람다함수를 실행할 수 있다.
    
    이벤트 기반으로 소스를 받는 경우 AWS의 다른 서비스들과 느슨하게 결합해서 람다를 실행할 수 있다.
    
- **S3 Events**
    
    S3 버킷의 특정한 이벤트를 소스로 받아 람다 함수를 실행하는 것이 가능하다.
    
    예를 들어 사용자가 파일을 추가하거나 변경하면 자동적으로 메타데이터를 추출하는 람다 함수를 실행하 수 있다.
    
    이미지가 업로드되면 특정 크기로 리사이즈하는 람다를 실행하면 유용하다.
    

### 서비스 활용 사례들

람다를 활용하는 몇 가지 유용한 사례를 레퍼런스로 남긴다.

> AWS API Gateway 와 Lambda 를 활용하여 Serverless REST API 환경을 구축할 수 있습니다.
> 

**[Lambda 프록시 통합을 사용하여 Hello World REST API 빌드](https://docs.aws.amazon.com/ko_kr/apigateway/latest/developerguide/api-gateway-create-api-as-simple-proxy-for-lambda.html)**

> Serverless Framework 를 활용하여 200만뷰 트래픽 처리를 적은 비용으로 처리합니다.
> 

****[300원에 200만뷰 소화하기 – 서버리스 아키텍처 AWS 람다(Lambda) 활용 사례](https://blog.rocketpunch.com/2017/07/02/2-million-pv-with-300-krw/)****

****[[AWS] 📚 람다(Lambda) 개념 & 사용법 💯 총정리](https://inpa.tistory.com/entry/AWS-%F0%9F%93%9A-%EB%9E%8C%EB%8B%A4Lambda-%EA%B0%9C%EB%85%90-%EC%9B%90%EB%A6%AC#operation_automation_%EC%8B%9C%EC%8A%A4%ED%85%9C_%EC%9A%B4%EC%98%81_%EC%9E%90%EB%8F%99%ED%99%94)****

**[AWS Lambda 제대로 활용하기 – 모범 사례 소개](https://www.megazone.com/techblog_190809_-architecture-best-practices-for-developing-on-aws-lambda/)**

### 개인적인 생각

AWS Lambda 처럼 Serveless Computing 자원을 적절하게 활용하면 기존에 운영해오던 항시 운영(Warm Start) 서비스와 대비해 비교할 수 없을 정도로 효율적인 서비스 운영을 진행할 수 있다.

하지만 이러한 운영방식은 Stateless, Cold Start 와 같은 서버리스의 특징(단점이라 하기엔 조금 뭣하다..) 을 고려하여 설계해야하며 처음부터 염두해두고 설계하기엔 개인적으로 애매한 부분이 있는거 같다. ( 경험부족도 동반하여..)

앞으로 자기개발을 위한 프로젝트를 진행할 때 FaaS 를 활용할 수 없는 지 염두해두고 특정 도메인을 교체해보는 시도는 개발자 경험과 성장에 있어서 꽤나 중요한 포인트가 될 것 같다.

그럼 글을 마친다.