## 🛠️ RigidBody2D란?
`RigidBody2D`는 Unity 2D 물리 엔진에서 객체에 물리적인 움직임을 부여하는 컴포넌트입니다.  
2D 게임에서 **중력, 힘, 충돌** 등을 통해 현실감 있는 물리 효과를 구현할 때 사용됩니다.  

---

## 📌 RigidBody2D 주요 속성

| 속성                      | 설명                                     |
| ----------------------- | -------------------------------------- |
| **Body Type**           | Rigidbody2D의 동작 방식을 결정합니다.             |
| - Dynamic               | 물리 법칙에 따라 자유롭게 움직임                     |
| - Kinematic             | 직접 이동을 설정해야 하며, 충돌은 발생하지만 힘의 영향을 받지 않음 |
| - Static                | 움직이지 않으며 충돌은 감지됨                       |
| **Mass**                | 오브젝트의 질량. 가속도 및 힘에 영향을 줌               |
| **Linear Drag**         | 선형 감속. 공기 저항처럼 작용해 속도를 늦춤              |
| **Angular Drag**        | 회전 감속. 회전 속도를 점진적으로 줄임                 |
| **Gravity Scale**       | 중력의 크기. 0이면 중력의 영향을 받지 않음              |
| **Is Kinematic**        | 체크 시 물리 엔진이 아닌 코드로만 움직임                |
| **Interpolate**         | 프레임 간 물리 보간. 부드러운 움직임을 제공              |
| **Collision Detection** | 충돌 감지 방식 (Discrete, Continuous 등)      |
| **Constraints**         | 특정 축의 이동 및 회전을 고정시킴                    |

---

## ⚙️ 주요 메서드 및 사용법

### 1. AddForce(Vector2 force, ForceMode2D mode)
- 오브젝트에 힘을 가합니다.  
- `ForceMode2D.Force`와 `ForceMode2D.Impulse`로 힘의 적용 방식을 결정합니다.  
```c#
Rigidbody2D rb;
rb.AddForce(new Vector2(10, 0), ForceMode2D.Impulse);  // 즉시 속도 변화
```

