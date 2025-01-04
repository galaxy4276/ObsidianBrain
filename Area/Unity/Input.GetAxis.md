#unity 

## 🎮 Input.GetAxis란?
`Input.GetAxis`는 Unity에서 **플레이어의 입력을 감지하고 부드럽게 값을 반환하는 메서드**입니다.  
주로 **캐릭터 이동, 카메라 회전, 점프 등**에 사용되며, **키보드, 마우스, 게임패드** 등 다양한 입력 장치와 연동됩니다.  

---

## 📌 기본 개념
- `Input.GetAxis`는 **-1에서 1 사이의 값**을 반환합니다.  
- 입력이 없으면 **0**을 반환하며, 입력에 따라 서서히 변화하는 **선형 보간된 값**을 제공합니다.  
- `Input.GetAxisRaw`는 즉각적인 값을 반환해 반응이 더 빠릅니다.  
  - 예: `-1`, `0`, `1` (즉시 값 변환, 부드러운 움직임 없음)  

---
## 🛠️ 주요 사용법
### 1. 기본 사용법
```c#
float moveHorizontal = Input.GetAxis("Horizontal");
float moveVertical = Input.GetAxis("Vertical");
```

- **"Horizontal"** – A/D 키, 좌우 방향키, 게임패드의 좌우 스틱
- **"Vertical"** – W/S 키, 상하 방향키, 게임패드의 상하 스틱
- 반환값이 `-1`이면 왼쪽/아래, `1`이면 오른쪽/위 방향을 의미


### 2. Input Manager 설정

Unity에서 `Edit > Project Settings > Input Manager`를 통해 Axis 설정을 확인할 수 있습니다.

**기본적으로 설정된 축(Axis) 목록:**

| 축 이름           | 설명          | 기본 키          |     |
| -------------- | ----------- | ------------- | --- |
| **Horizontal** | 좌우 이동 입력    | A, D, 방향키 좌/우 |     |
| **Vertical**   | 상하 이동 입력    | W, S, 방향키 상/하 |     |
| **Jump**       | 점프 입력       | Spacebar      |     |
| **Mouse X**    | 마우스의 X 축 이동 | 마우스 좌우 이동     |     |
| **Mouse Y**    | 마우스의 Y 축 이동 | 마우스 상하 이동     |     |

## ⚙️ 주요 코드 예시

### 1. 2D 캐릭터 이동 (좌우 이동)

```c#
public float speed = 5f;
void Update() {
    float move = Input.GetAxis("Horizontal");
    transform.Translate(Vector2.right * move * speed * Time.deltaTime);
}
```
- **A/D** 또는 방향키로 캐릭터를 좌우로 이동시킵니다.
- 부드럽게 이동하며, 입력이 서서히 증가/감소합니다.

# References
https://docs.unity3d.com/kr/2020.3/ScriptReference/Input.GetAxis.html
