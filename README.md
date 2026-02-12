# Savvy WebApp (Flutter)

Figma 기반 React 프로토타입을 Flutter Web에 맞게 재구성한 프로젝트입니다.

## 구성

- `Landing` 랜딩 페이지
- `Onboarding` 3단계 사용자 입력
- `Dashboard` 환급 요약 + 절세 항목 카드
- `Card Analysis` 카드 사용 최적화
- `Report` 종합 계산 리포트
- `My Page` 프로필/설정/데이터 초기화

## 실행

```bash
flutter pub get
flutter run -d chrome
```

## 핵심 구현

- 상태관리: `ChangeNotifier` 기반 `AppState`
- 로컬 저장: `shared_preferences`
- 금액 포맷: `intl`
- 세금 계산 로직: `lib/app/tax_calculator.dart`

## 디렉터리

- `lib/app`: 상태, 모델, 계산기, 테마
- `lib/screens`: 화면 위젯
- `lib/widgets`: 공통 UI 컴포넌트
