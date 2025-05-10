#terraform #cloud
Terraform은 인프라스트럭처 코드(IaC)의 표준이 되었으며, 팀이 클라우드 리소스를 효율적으로 정의, 프로비저닝 및 관리할 수 있게 해준다. 
많은 엔지니어들이 기본 사항에 익숙하지만, 시니어 엔지니어는 확장성, 보안 및 유지보수성을 보장하기 위해 고급 기술을 숙달해야 한다. 
이 글에서는 모든 경험 있는 전문가가 알아야 할 Terraform의 필수 비밀과 모범 사례를 공개한다.

## 워크스페이스를 활용한 환경 관리
워크스페이스를 사용하면 동일한 Terraform 구성 내에서 여러 환경(개발, 스테이징, 프로덕션)을 관리할 수 있다. 코드를 복제하는 대신 워크스페이스를 사용하여 환경에 따라 변수를 동적으로 조정할 수 있다.

```hcl
locals {  
  environment = terraform.workspace  
}  
resource "aws_instance" "example" {  
  ami           = var.amis[local.environment]  
  instance_type = var.instance_types[local.environment]  
}
```

그러나 워크스페이스는 동일한 백엔드를 공유하므로, 엄격한 격리를 위해서는 별도의 상태 파일이나 환경별 루트 모듈을 고려해야 한다.

## 유연한 구성을 위한 동적 블록 활용
동적 블록을 사용하면 중첩된 구성을 동적으로 생성하여 반복적인 코드를 줄일 수 있다. 이는 보안 그룹, IAM 정책 및 다양한 규칙이 필요한 기타 리소스에 특히 유용하다.

```hcl
variable "ingress_rules" {  
  type = list(object({  
    from_port   = number  
    to_port     = number  
    protocol    = string  
    cidr_blocks = list(string)  
  }))  
  default = [  
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },  
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }  
  ]  
}  
resource "aws_security_group" "example" {  
  name = "dynamic_block_example"  
  dynamic "ingress" {  
    for_each = var.ingress_rules  
    content {  
      from_port   = ingress.value.from_port  
      to_port     = ingress.value.to_port  
      protocol    = ingress.value.protocol  
      cidr_blocks = ingress.value.cidr_blocks  
    }  
  }  
}
```
## 상태 관리 최적화
Terraform 상태 파일에는 민감한 정보가 포함되어 있으므로 주의해서 다루어야 한다. 다음과 같은 모범 사례를 따르자.
- 원격 백엔드 사용 암호화가 포함된 AWS S3, Terraform Cloud 또는 HashiCorp Consul과 같은 안전한 백엔드에 상태를 저장한다.
- 상태 잠금 활성화 DynamoDB가 있는 S3, Azure Blob Storage 등에서 지원하는 잠금을 활성화하여 상태를 손상시킬 수 있는 동시 작업을 방지한다.
- 상태 확장 최소화 -target을 적게 사용하고 큰 구성을 작은 모듈로 리팩토링하여 상태 파일 크기를 줄이자.
## 세밀한 IAM 정책 구현
너무 허용적인 IAM 정책을 피하고 최소 권한 원칙을 동적으로 생성하자. Terraform의 aws_iam_policy_document를 사용하여 프로그래밍 방식으로 정책을 구성한다.

```hcl
data "aws_iam_policy_document" "example" {  
  statement {  
    actions   = ["s3:GetObject"]  
    resources = ["arn:aws:s3:::example-bucket/*"]  
    condition {  
      test     = "IpAddress"  
      variable = "aws:SourceIp"  
      values   = ["192.0.2.0/24"]  
    }  
  }  
}  
resource "aws_iam_policy" "example" {  
  name   = "least_privilege_policy"  
  policy = data.aws_iam_policy_document.example.json  
}
```

## 안정성을 위해 count 대신 for_each 사용
count는 여러 인스턴스를 생성하는 데 유용하지만, 목록 순서가 변경될 때 리소스가 다시 생성될 수 있다. for_each는 인덱스 대신 키를 사용하므로 더 안정적이다.

```hcl
variable "instances" {  
  type = map(object({  
    ami        = string  
    instance_type = string  
  }))  
  default = {  
    "web1" = { ami = "ami-123456", instance_type = "t3.micro" },  
    "web2" = { ami = "ami-789012", instance_type = "t3.small" }  
  }  
}  
resource "aws_instance" "example" {  
  for_each      = var.instances  
  ami           = each.value.ami  
  instance_type = each.value.instance_type  
  tags = {  
    Name = each.key  
  }  
}
```

## Vault 통합으로 민감한 데이터 보호
Terraform에 비밀을 하드코딩하는 것은 보안 위험이다. 대신 HashiCorp Vault와 통합하거나 환경 변수를 사용하자.

```hcl
data "vault_generic_secret" "db_creds" {  
  path = "secret/database"  
}  
resource "aws_db_instance" "example" {  
  username = data.vault_generic_secret.db_creds.data["username"]  
  password = data.vault_generic_secret.db_creds.data["password"]  
}
```

또는 Terraform 0.14+ 에서는 `sensitive = true`를 사용하여 비밀이 로깅되지 않도록 할 수 있다.

## 사용자 정의 유효성 검사 규칙 구현
Terraform은 비즈니스 규칙을 적용하기 위해 변수에 사용자 정의 유효성 검사를 허용한다.

```hcl
variable "instance_size" {  
  type        = string  
  description = "유효한 인스턴스 타입이어야 함"  
  default     = "t3.micro"  
  validation {  
    condition     = can(regex("^t3\\.", var.instance_size))  
    error_message = "인스턴스 타입은 't3.'로 시작해야 합니다."  
  }  
}
```

## 모듈 캐싱으로 성능 최적화
대규모 Terraform 구성은 초기화 속도를 늦출 수 있다. 모듈 캐싱을 사용하여 워크플로우 속도를 높이자.

```bash
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
```

## 드리프트 감지 계획
인프라 드리프트는 Terraform 외부에서 변경이 이루어질 때 발생한다. `terraform plan -refresh-only` 또는 서드파티 솔루션(예: driftctl)을 사용하여 드리프트를 감지하고 해결하자.

## Sentinel/OPA로 정책 코드화 도입
HashiCorp Sentinel 또는 Open Policy Agent(OPA)와 같은 정책 코드화 도구를 사용하여 거버넌스를 적용하자. 리소스 유형, 리전 또는 인스턴스 크기를 제한하는 규칙을 정의할 수 있다.

💡 이러한 도구들은 조직의 클라우드 리소스 사용에 대한 제어를 강화하고 비용과 보안을 모두 관리하는 데 효과적이다.

## 마치며
이러한 고급 Terraform 기술을 마스터하면 IaC 기술이 향상되어 인프라를 더 안전하고 확장 가능하며 유지 관리하기 쉽게 만들 수 있다. 동적 블록과 세밀한 IAM 정책부터 드리프트 감지 및 정책 적용에 이르기까지, 이러한 모범 사례는 Terraform을 최대한 활용하고 있는지 확인하는 데 도움이 된다.

오늘 이러한 전략을 구현하면 워크플로우를 최적화할 뿐만 아니라 복잡성과 규모에 대비하여 인프라를 미래에 대비할 수 있다.

# References
https://medium.com/@letsCodeDevelopers/terraform-secrets-every-senior-engineer-must-know-advanced-best-practices-9bbe48521fea
