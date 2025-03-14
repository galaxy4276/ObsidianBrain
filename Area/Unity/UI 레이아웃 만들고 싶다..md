#unity 

# Canvas 부터 깔고보자.
### Canvas?
`Canvas`는 Unity에서 UI 요소를 렌더링하고 관리하는 데 사용되는 중요한 컴포넌트.
모든 UI 요소(버튼, 텍스트, 이미지 등)는 반드시 `Canvas` 안에 있어야 화면에 표시된다고한다.
UI 요소를 화면에 어떻게 배치하고 렌더링할지 결정하는 역할 수행.

### Canvas 의 세 가지 모드
1. **Screen Space - Overlay**:
    - UI가 화면 위에 오버레이됩니다. 카메라와 무관하게 UI가 항상 화면에 표시됩니다.
    - 주로 HUD(Head-Up Display)나 메뉴 화면에 사용됩니다.
2. **Screen Space - Camera**:
    - UI가 특정 카메라를 기준으로 렌더링됩니다. 카메라의 위치와 설정에 따라 UI가 표시됩니다.
    - 주로 카메라가 움직이는 2D/3D 게임에서 사용됩니다.
3. **World Space**:
    - UI가 3D 세계 공간에 배치됩니다. 이 모드에서는 UI가 다른 3D 객체와 함께 렌더링됩니다.
    - 주로 3D 게임에서 UI가 월드 객체와 상호작용할 때 사용됩니다.

# 처음 만들어본 간단한 UI
![[Pasted image 20250207185217.webp]]
### Button 에 이벤트 할당하기
타 오브젝트에서 작성한 스크립트 파일의 공개 메서드르 참조한다.
### Layout 배치 정렬하기
기본적으로 레이아웃 배치 도구를 지원한다.

# References
