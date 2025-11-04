# 포도잇 (Podoit)
🍇 사용자의 시간을 데이터화해 목표 달성과 자기 성장을 돕는 타이머 앱 ⏰

<br>

<p align="left">
    <img width="300" height="300" alt="Image" src="https://github.com/user-attachments/assets/195a5416-1220-4ae3-8e99-697dc364dee0" />
</p>

---

## 📋 프로젝트
- **앱 이름**: **포도잇 (Podoit)**
- **프로젝트 기간**: 2025.08.14(화) ~
- **Figma**: [포도잇, Podoit](https://www.figma.com/design/uBOMlShQ4yaqJMKmdehByc/podoit?node-id=3-1049&t=SW3tHXFIUbBRHUdC-1)
- **최종 발표 자료**: [MVP 발표자료](https://www.figma.com/slides/ecGvZ69FFrHGSWMOyWQPbt/%ED%8F%AC%EB%8F%84%EC%9E%87-%EC%B5%9C%EC%A2%85-%EB%B0%9C%ED%91%9C-PPT?node-id=1-146&t=xep3XhaHeNMTObzU-1)
- **앱스토어 주소**: [포도잇, Podoit](https://apps.apple.com/kr/app/%ED%8F%AC%EB%8F%84%EC%9E%87/id6752013483)

---

## 앱 스크린

<p align="center">
  <img src="https://github.com/user-attachments/assets/6fe8d61c-761e-4762-a89c-aacb27849aa0" width="200" />
  <img src="https://github.com/user-attachments/assets/5221f458-0656-4369-9940-9165b49a6675" width="200" />
  <img src="https://github.com/user-attachments/assets/1604ff4e-e526-41ba-8669-2ea656711c27" width="200" />
  <img src="https://github.com/user-attachments/assets/3818495f-e0d5-47d0-851a-e35cc50df9b9" width="200" />
</p>

---

## 👥 팀 구성

| 이름  | 역할  | 담당기능 |
| :----: | :----: | :---- |
| **🐶 서광용** | iOS 개발 | 타이머 실행, 설정 화면, 사운드 및 알림, Lottie |
| **🐤 노가현** | iOS 개발 | 타이머 목록, 타이머 편집, 커스텀 탭바, 디자인시스템 적용, 런치스크린 |
| **🦊 김이든** | iOS 개발 | 타이머 기록 일간/월간 통계, SwiftData 설정, 앱 기타 설정 |
| **🐱 고채원** | 디자이너 | UX/UI 디자인, 브랜딩, 애니메이션 제작 |
| **🍇 Podoit** | 공통 작업 | 기획 |

---

## 🤝 협업 방식

### 프로젝트 관리
- **GitHub**: 코드 리뷰, 브랜치 전략 수립, 개발 관리 전반
- **Zep, Slack**: 실시간 소통 및 자료 공유
- **Discord**: 봇을 활용하여 github의 `commit`, `push`, `comment`, `merge` 등의 알림 제공

### 작업 프로세스
- **스크럼**: 매일 오전 10:10, 오후 20:10 진행
- **PR 규칙**
  - `develop`, `main` 브랜치 삭제 불가
  - 최소 1명 이상 `approve` 후 `merge` 가능
  - 강제 푸시(`--force push`) 금지

### 컨벤션
- **코딩 컨벤션**: SwiftFormat 적용 및 `MARK` 주석 사용
- **커밋 컨벤션**: 태그(`feat`, `fix`, `chore`, `refactor`, `add`)와 이슈 번호 기반으로 작성. `[태그 타입]: #이슈번호 - 작업 내용`
- **브랜치 전략**: GitHub 이슈 번호 기반 네이밍(`feat/번호-작업명`, `fix/번호-작업명` 등)

---

## 📂 프로젝트 구조
```
🍇 PodoIt
├─ 📁 App             # 앱 실행 및 라이프사이클 관련 (AppDelegate, SceneDelegate 등)
├─ 📁 AppSettings     # 앱 전역 설정 (오디오, 알림 스케줄러 등 공통 설정 관리)
├─ 📁 Data            # 데이터 계층 (의존성, Persistence, SwiftData 관리)
├─ 📁 DesignSystem    # 디자인 시스템
│  ├─ 📁 Color        # 색상 팔레트
│  ├─ 📁 Component    # 공통 UI 컴포넌트
│  └─ 📁 Font         # 폰트 및 폰트 스타일 정의
├─ 📁 Models          # 앱 전반에서 사용하는 데이터/도메인 모델
├─ 📁 Resources       # 전역 리소스 (폰트, 이미지, 컬러, Info 등)
├─ 📁 Scenes          # 화면 모듈
│  ├─ 📁 RootScene    # 루트/탭바 컨트롤러
│  ├─ 📁 Setting      # 설정 화면
│  ├─ 📁 Stats        # 통계 화면
│  ├─ 📁 Timer        # 타이머 화면 (타이머 리스트 및 타이머 관리)
│  └─ 📁 TimerRun     # 타이머 실행 화면 (타이머 실행 공부/휴식 상태 관리)
├─ 📁 Support         # 공통 지원 모듈
│  ├─ 📁 Extensions   # UIKit 확장 (UILabel, UITextField, UIViewController 등)
│  └─ 📁 UI           # 공통 Alert, Toast 등 UI 컴포넌트
└─ 
```

---

## 🛠️ 기술 스택

### Architecture
- MVVM

### Reactive
- RxSwift
- RxCocoa

### UI
- UIKit
- SnapKit
- Then
- Lottie

### Notification
- UserNotificationCenter

### Data
- SwiftData (Dependencies)
- UserDefaults



<!-- ### Network
- CloudKit (예정)

 -->

### Etc
- SafariServices

---

## 📱 MVP(1.0.0)

### ⏳ 타이머 리스트
- **아이템 표시**
  - 이모지 + 타이틀 + 메타 정보 (오늘 집중/누적) + 우측 플레이 버튼
  - 플레이 버튼 탭 시 실행 화면 진입, 햅틱 피드백 제공
  - 셀 5개 도달 시 하단 추가 버튼 비활성화 및 햅틱/토스트로 피드백
- **타이머 편집**
  - 제목, 이모지, 목표 시간 설정 → 신규 생성/기존 수정 모두 처리
  - 중복 방지 : 동일 제목 입력 시 햅틱 + 토스트로 사용자에게 즉시 피드백
  - 이모지 선택 버튼, 텍스트필드, 시간 선택기, 저장 버튼으로 단순 구조


### ⏱️ 타이머 실행
- **공부 중**
  - 목표 시간과 공부 시간 타이머 동작
  - 목표 시간 달성 시 Label 변경 및 ProgressBar 애니메이션 완료
  - ProgressBar는 점진적으로 차오르며, 달성 시 진한 색상으로 표시
  - 목표 시간을 초과해도 타이머는 계속 진행
- **휴식 중**
  - 기본 5분 카운트다운 제공
  - +1분, +5분, +10분 버튼으로 휴식 시간 연장 가능
  - 휴식 진입 시마다 기본 5분으로 초기화
  - 상단 타이머를 통해 이번 휴식 세션에서의 총 휴식 시간 누적 표시
- **공통**
  - 타이머 알림 소리 On/Off 설정 지원
  - 타이머 세션을 종료하는 stop버튼


### 📊 통계
- **캘린더 및 통계**
  - 카테고리별 캘린더 및 통계 필터 제공
  - 날짜별 누적 집중시간에 따라 색상 진하기로 시각적 확인
  - 하루·월간 단위 집중시간 분석 지원
  - 타이머 종료 시 통계 데이터 즉시 갱신
  - 오늘 날짜로 복귀하는 버튼 제공
  - SwiftData를 활용해 기록 불러오기


### ⚙️ 설정
- 타이머 알림 소리 On/Off 설정
- 문의·건의하기 (Google Form 연결)
- 리뷰 남기기 (App Store 연결)

---

## 개발 진행 사항

### ver 1.0.1
- **📊 통계**
  - 오늘 날짜 복귀 버튼 UI수정 및 사용성 개선
  
### ver 1.1.0
- **⏳ 타이머 리스트**
  - 런치스크린 추가
  - 타이머 셀 스와이프로 삭제 기능 추가
  - 저장하기 버튼 → 키보드 위로 올라 오도록 구현
  - 타이머 편집 TextField 최대 글자 수 토스트 알럿 추가
  - 타이머 생성 화면 백 스와이프 제스처 추가
- **⏱️ 타이머 실행**
  - Lottie 애니메이션 적용
  - 음소거 상태에 따른 토스트 알럿 추가
  - 공부 시간에 따라 Alert 2개로 분기
  - UT후 디자인 변경으로 인한 버튼 UI 변경
  - 갱신 주기를 0.1초에서 1초로 변경하여 성능 개선
- **📊 통계**
  - iOS 26 카테고리 선택 시트 버그 수정
  - 손쉬운 사용 볼드체 텍스트 적용 시 버튼 텍스트 잘림 수정
  - 캘린더 달 이동 시 통계 자동 갱신

### ver 1.1.1 이후 
- ver 1.1.1 이후 업데이트 내역은 아래의 Notion 문서에서 확인 가능
  - [Notion 바로가기](https://iris-ceres-022.notion.site/2938f738d002806499e1fade60f57b11?source=copy_link)

---

## 시연 영상
- [Youtube](https://youtube.com/shorts/g1Xb2EwhsMk?feature=shared)
