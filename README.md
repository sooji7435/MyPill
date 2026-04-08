# 💊 MyPill - 약 복용 관리 앱

> 매일 먹어야 하는 약과 영양제, 빠뜨리지 않도록 도와드립니다



<프로젝트 개요>

MyPill은 약과 영양제 복용 일정을 관리하고, 복용 여부를 기록하며 통계로 확인할 수 있는 iOS 앱입니다.  
매일 챙겨야 할 약을 잊지 않도록 로컬 알림을 제공하고, 복용 습관을 주간·월간 차트로 시각화합니다.


| 항목 | 내용 |
|------|------|
| 개발 기간 | 2025.06 ~ 2026.03 (약 9개월) |
| 개발 인원 | 1인 (개인 프로젝트) |
| 배포 상태 | AppStore 배포 준비 중 |



<사용 기술>

| 분류 | 기술 |
|------|------|
| Language | Swift |
| UI Framework | SwiftUI |
| 인증 | Google Sign-In, Firebase |
| 차트 | Swift Charts |
| 알림 | UserNotifications (UNUserNotificationCenter) |
| 데이터 저장 | UserDefaults, App Group UserDefaults (위젯 공유) |
| 아키텍처 | MVVM |



<주요 기능>

1. Google 소셜 로그인
- Google OAuth 2.0 기반 로그인 (GoogleSignIn SDK)
- 앱 재시작 시 `restorePreviousSignIn()`으로 세션 자동 복원
- `AuthViewModel`과 `GoogleOAuthViewModel` 역할 분리로 인증 상태 관리

2. 약 복용 일정 관리
- 제목 / 복용 시간 / 메모 / 아이콘을 입력해 일정 추가
- `[String: [Schedule]]` (날짜키: 일정배열) 구조로 날짜별 관리
- `didSet`에서 `UserDefaults` 자동 저장으로 저장 누락 방지

3. 캘린더 뷰
- 월별 캘린더 UI, 이전/다음 달 이동 지원
- 날짜 선택 시 해당 날 일정 타임라인 즉시 반영
- UTC 변환으로 인한 날짜 오류 방지 (정오 고정)

4. 복용 체크 및 자동 missed 감지
- 복용 완료 체크 / 시간 경과 시 missed 자동 전환
- `Timer.publish(every: 60)`으로 1분마다 상태 감지
- missed 상태에서 30분 스누즈 알림 지원

5. 로컬 푸시 알림
- 일정 추가 시 `UNCalendarNotificationTrigger`로 복용 시간 알림 자동 등록
- 일정 삭제 시 해당 알림 자동 취소
- 스누즈: `UNTimeIntervalNotificationTrigger`로 30분 후 재알림

6. 복용 통계
- 전체 복용률 원형 링 애니메이션
- 주간 / 월간 탭 전환 막대 차트 (75% 목표선 포함)
- 복용 완료 · 누락 · 완벽한 날 요약 카드

7. 위젯 지원
- App Group UserDefaults로 앱 ↔ 위젯 간 오늘 일정 공유
- `SharedStore`를 통해 일정 저장 시 위젯 데이터 자동 동기화



<아키텍처>

```
MyPill/
├── App/
│   ├── MyPillApp.swift          # 앱 진입점, Firebase 초기화, ViewModel 주입
│   └── ContentView.swift        # 로그인 상태 분기 (LoginView / MainTabView)
│
├── Model/
│   ├── Schedule.swift           # Schedule, ScheduleStatus 모델 (앱+위젯 공유)
│   └── User.swift               # User 모델
│
├── ViewModel/
│   ├── AuthViewModel.swift      # 로그인 상태 관리 (isLoggedIn, isLoading)
│   ├── GoogleOAuthViewModel.swift # Google 로그인/로그아웃/세션 복원
│   ├── SchedulesViewModel.swift # 일정 CRUD, 알림 연동, 저장
│   ├── CalendarViewModel.swift  # 캘린더 날짜 계산, 월 탐색
│   └── StatsViewModel.swift     # 주간/월간/전체 복용률 통계 계산
│
├── View/
│   ├── MainTabView.swift        # 탭 네비게이션 (일정 / 통계 / 설정)
│   ├── HomeView.swift           # 홈 (캘린더 + 약 목록 + 타임라인)
│   ├── LoginView.swift          # 로그인
│   ├── SettingsView.swift       # 설정 (계정, 로그아웃)
│   ├── StatsView.swift          # 복용 통계
│   ├── Calendar/
│   │   ├── CalendarView.swift
│   │   ├── CalendarYearMonth.swift
│   │   ├── CalendarHeader.swift
│   │   └── CalendarBody.swift
│   └── Schedule/
│       ├── TimelineView.swift
│       ├── ScheduleDetailView.swift
│       ├── ScheduleAddView.swift
│       ├── MyMedicine.swift
│       └── SchedulesIconView.swift
│
└── Utility/
    ├── NotificationManager.swift  # 알림 싱글톤
    ├── SharedStore.swift          # App Group 위젯 공유
    ├── ColorManager.swift         # 앱 컬러 정의
    └── MyDisclosureStyle.swift    # 커스텀 DisclosureGroupStyle
```



<기술적 도전 및 트러블슈팅>

1. GoogleOAuthViewModel → AuthViewModel 순환 참조 문제

- 문제  
`GoogleOAuthViewModel`이 로그인 성공 시 `AuthViewModel.isLoggedIn`을 직접 변경해야 하는데,  
두 ViewModel이 모두 `@StateObject`로 앱 루트에서 생성되어 강한 참조 시 순환 참조 위험이 있었습니다.

- 해결  
`GoogleOAuthViewModel`에서 `AuthViewModel`을 `weak var`로 선언해 참조 사이클을 방지했습니다.

```swift
// GoogleOAuthViewModel.swift
weak var authViewModel: AuthViewModel?
```

```swift
// MyPillApp.swift - 앱 시작 시 연결
.onAppear {
    googleViewModel.authViewModel = authViewModel
    googleViewModel.restoreSession()
}
```

---

2. UserDefaults 저장 누락 문제

- 문제  
`schedules` 딕셔너리를 여러 경로에서 변경하다 보니 일부 경우에 `persistSchedules()` 호출이 빠져  
앱 재시작 시 데이터가 유실되는 버그가 있었습니다.

- 해결  
`@Published private(set) var schedules`의 `didSet`에 저장 로직을 위치시켜  
값이 변경될 때마다 자동으로 저장되도록 수정했습니다.

```swift
@Published private(set) var schedules: [String: [Schedule]] = [:] {
    didSet { persistSchedules() }
}
```

---

3. UTC 오프셋으로 인한 날짜 변경 문제

- 문제  
`allDatesInMonth()`에서 각 날짜를 자정(00:00)으로 생성하면  
한국 시간(UTC+9) 환경에서 UTC 변환 시 전날 날짜로 밀리는 버그가 발생했습니다.

- 해결  
날짜 생성 시 정오(12:00)로 고정해 타임존 오프셋에 의한 날짜 변경을 방지했습니다.

```swift
// 정오로 고정하여 UTC 변환 시 날짜 변경 방지
return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: date)
```

---

4. missed 상태 실시간 감지 문제

- 문제  
`ScheduleDetailView`가 처음 렌더링될 때만 `isMissed` 여부를 체크해  
이후 시간이 지나도 상태가 자동으로 전환되지 않는 문제가 있었습니다.

- 해결  
`Timer.publish`로 1분 간격으로 상태를 재확인하도록 수정했습니다.

```swift
private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

.onAppear { checkMissed() }
.onReceive(timer) { _ in checkMissed() }

private func checkMissed() {
    guard !schedule.isTaken, Date() > schedule.takeTime else { return }
    schedule.isMissed = true
    onUpdate?(schedule)
}
```



<참여도>

| 항목 | 내용 |
|------|------|
| 개발 인원 | 1인 (개인 프로젝트) |
| 기여도 | 기획 / 설계 / 개발 100% |
