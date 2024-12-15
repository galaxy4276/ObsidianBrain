**구조에 표시되는 모든 내용은 디렉터리임**

├── public - 정적 웹 자원
├── scripts  - 백엔드 코드나 외부환경과 상호작용하는 스크립트 파일 
├── src - 애플리케이션 소스 루트 디렉터리
│   ├── api - 외부 api 와 관련된 소스코드의 루트 디렉터리
│   │   ├── interceptors - api 와 통신하는 클라이언트 객체의 미들웨어
│   │   └── services - api 연동 코드
│   │       ├── @shared - 애플리케이션 공용 타입
│   │       └── admin - 어드민 전용 api 코드
│   ├── assets - 이미지, svg 자원 루트 디렉터리
│   │   ├── icons - 아이콘(svg) 자원 모음
│   │   └── images - 이미지 자원 모음
│   ├── components - UI 를 구성하는 단위(컴포넌트) 소스코드 루트 디렉터리
│   │   ├── @atoms - 버튼, Input, Select 등 공용 컴포넌트
│   │   │   └── __deprecated__ - 더 이상 사용하지 않는 컴포넌트
│   │   ├── @layouts - UI 레이아웃 컴포넌트
│   │   ├── @molecules - 최소 단위 컴포넌트를 조합하여 일부 UI 를 나타내는 컴포넌트
│   │   │   ├── Editor - 텍스트 에디터 관련 
│   │   │   │   ├── images - 에디터 내 이미지 자원
│   │   │   │   │   └── icons - 에디터 내 이미지(svg) 자원
│   │   │   │   ├── nodes - 에디터 구성 요소들
│   │   │   │   ├── plugins - 에디터 플러그인
│   │   │   │   └── themes - 에디터 스타일
│   │   │   └── __deprecated__ - 더 이상 사용되지 않는 파일
│   │   ├── GNB - UI 공용 네이게이션 관련 컴포넌트
│   │   ├── admin - 내부 사용자 페이지 컴포넌트
│   │   ├── contract - 전자 계약 컴포넌트
│   │   ├── file-manage - 파일 관리 컴포넌트
│   │   │   └── FileViewer - 파일 뷰어 관련 컴포넌트
│   │   ├── mypage - 내부사용자, 일반사용자 마이페이지 관련 컴포넌트
│   │   │   ├── profile - 프로필 관련 컴포넌트
│   │   │   └── settlement - 정산 관련 컴포넌트
│   │   ├── project - 프로젝트 관련 컴포넌트 상위 디렉터리
│   │   │   ├── create - 프로젝트 생성 관련 컴포넌트
│   │   │   ├── detail - 프로젝트 상세 관련 컴포넌트
│   │   │   │   ├── collect - 수집관련 컴포넌트
│   │   │   │   ├── info - 프로젝트 상세 정보 관련 컴포넌트 
│   │   │   │   └── schedule - 스케줄 UI 관련 컴포넌트
│   │   │   ├── edit - 프로젝트 수정 관련 컴포넌트
│   │   │   └── participate - 프로젝트 내 참여자 관련 컴포넌트
│   │   └── signup - 회원가입 관련 컴포넌트
│   ├── constants - 애플리케이션에서 관리하는 상수값을 의미하는 루트 디렉터리
│   │   ├── Input - UI 내 Input 요소들의 상수 값
│   │   └── terms_of_use - 회원가입 약관 상수 값
│   ├── hooks - 리액트 커스텀 훅 기능의 루트 디렉터리
│   │   └── dialog - 다이얼로그 관련 훅
│   │       └── auth - 다이얼로그 - 인증 에러 관련 훅
│   ├── pages - 화면단위를 구성하는 컴포넌트(최상위) 루트 디렉터리
│   │   ├── admin - 어드민 관련 화면
│   │   ├── contract - 전자계약 관련 화면
│   │   ├── login - 로그인 관련 화면
│   │   ├── mypage - 마이페이지 관련 화면
│   │   ├── project - 프롤젝트 관련 화면
│   │   │   ├── admin - 프로젝트 - 어드민 관련 화면
│   │   │   │   ├── create - 프로젝트 생성 관련 화면
│   │   │   │   ├── detail - 프로젝트 상세구조 관련 화면
│   │   │   │   ├── edit - 프로젝트 수정 관련 화면
│   │   │   │   ├── file-manage - 내부 사용자 파일 관리 관련 화면
│   │   │   │   └── preview - 프리뷰 관련 화면
│   │   │   └── user - 일반 사용자 관련 화면
│   │   │       ├── detail - 일반사용자 - 프로젝트 상세 정보 관련 화면
│   │   │       │   ├── available - 사용가능한 프로젝트 관련 화면
│   │   │       │   └── ongoing-closed  - 취소된 프로젝트 관련 화면
│   │   │       ├── file-manage - 일반 사용자 파일관리 관련 화면
│   │   │       └── participate - 일반사용자 참여자 관련 화면
│   │   └── signup - 회원가입 관련 화면
│   ├── react-query - Tanstack Query 라이브러리 기능을 포함하는 루트 디렉터리
│   │   ├── contract - 전자계약 관련 TanStack Query 훅
│   │   └── project - 프로젝트 관련 TanStack Query 훅
│   ├── routes - 화면 간 라우팅 기능
│   ├── stories - StoryBook 의 모든 요소를 구성하는 루트 디렉터리
│   │   ├── Atoms - Atom 컴포넌트 스토리
│   │   ├── Molecules - Molecules 컴포넌트 스토리
│   │   └── Theme - Theme 컴포넌트 스토리
│   ├── styles - 공용 스타일 값이나 css 관련 자원
│   └── utils - 애플리케이션 유틸성 기능
└── test - 테스트 목적 파일
