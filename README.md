# Savvy WebApp (Flutter)

Savvy는 연말정산 항목을 시뮬레이션하고 최적화 전략을 확인할 수 있는 Flutter Web 서비스입니다.  
AI 활용 전략을 구상하여 기획안 및 프로토타입을 제작하였으며 Flutter 구조로 설계 구현했습니다.

## 배포

- 서비스 URL: `https://savvy-webapp-youngjo.web.app`

## 주요 기능

- `Landing` 메인 진입 페이지
- `Onboarding` 3단계 입력
  - 기본정보(나이/연봉/부양가족)
  - 중도입사/이직 분기(전직장 소득/기납부세액 반영)
  - 특수상황(중소기업 감면, 기부금, 월세 등)
- `Dashboard`
  - 환급/추가납부 요약
  - 항목별 공제 카드 및 상세 편집
- `Card Analysis`
  - 총급여 25% 기준 사용액 진행률
  - 신용/체크/현금영수증 사용 가이드
- `Report`
  - 공제 내역 breakdown
  - 계산 과정 요약
  - PDF 다운로드
- `My Page`
  - 프로필/특수상황 확인
  - 기본 정보 수정 진입
  - 데이터 초기화

## 계산 정책 (현재 구현)

- 총급여: 현재 회사 급여 + (이직 시) 전직장 급여 합산
- 과세표준: 근로소득공제, 인적공제, 소득공제 반영
- 세액 계산: 누진세율 기반 산출세액
- 중소기업 청년 감면: 적격 시 산출세액 90% 감면
- 세액공제: 연금, 기부금, 의료/교육비 반영
- 결정세액: `max(산출세액 - 세액공제합계, 0)`
  - 공제액이 커도 결정세액은 0원 미만으로 내려가지 않음
- 기납부세액(추정): 현재 회사 급여 반영분의 5% + 전직장 기납부세액(입력값)

## 웹 라우팅/히스토리

- 페이지별 경로 기반 라우팅(`landing`, `onboarding/1`, `dashboard`, `report` 등)
- 브라우저 뒤로/앞으로 버튼과 앱 화면 상태 연동
- 온보딩 Step 전환도 URL/히스토리로 추적

## 기술 스택

- Flutter 3 / Dart 3
- 상태관리: `ChangeNotifier` 단일 `AppState`
- 저장소: `shared_preferences`
- PDF: `pdf`, `printing`
- 포맷: `intl`
- 호스팅: Firebase Hosting

## 로컬 실행

```bash
flutter pub get
flutter run -d chrome
```

## 검증

```bash
flutter analyze
flutter test
```

## 배포

```bash
flutter build web --release
firebase deploy --only hosting --project savvy-webapp-youngjo
```

## 디렉터리

- `lib/app`: 상태, 모델, 계산기, 라우팅 동기화, PDF 서비스
- `lib/screens`: 화면 위젯
- `lib/widgets`: 공통 UI 컴포넌트
- `test`: 계산 로직 및 기본 위젯 테스트

## 문서

- 기획 대비 점검: `PLANNING_GAP_CHECK.md`
- 배포 이력: `RELEASE_LOG.md`
