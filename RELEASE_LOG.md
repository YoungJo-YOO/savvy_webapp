# Release Log

Firebase Hosting 배포 이력을 기록합니다.

| Deployed At (KST) | Commit | Project | URL | Notes |
|---|---|---|---|---|
| 2026-02-13 08:59:15 +09:00 | `c50c5ba` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 뒤로/앞으로 시 해시 라우트를 우선 해석해 landing으로 튀는 현상 개선 |
| 2026-02-13 08:47:48 +09:00 | `bf6ee66` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 결정세액 하한 0원 적용, 관련 안내 문구 및 테스트/리포트 반영, landing 경로 fresh-start 해제 |
| 2026-02-13 08:18:04 +09:00 | `1c85e78` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 브라우저 일반 히스토리 방식(push/replace/popstate 정합)으로 뒤로/앞으로 동작 개선 |
| 2026-02-12 16:57:33 +09:00 | `95b1d5b` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 온보딩 단계별 URL/내비게이션 개선 버전 재배포 |
| 2026-02-12 16:46:26 +09:00 | `d219ab9` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 해시 URL에서 경로 기반 URL(`/dashboard` 등)로 전환, 브라우저 뒤/앞으로 연동 강화 |
| 2026-02-12 16:37:50 +09:00 | `f3ccdf1` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 브라우저 뒤로/앞으로 버튼과 앱 화면 동기화(해시 라우트 연동) |
| 2026-02-12 16:09:44 +09:00 | `4bbe7af` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 온보딩 Step1에서도 이전 버튼 제공, 대시보드 Savvy 로고 클릭 시 랜딩 이동 |
| 2026-02-12 15:27:08 +09:00 | `2f6e6fc` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 기본 URL 접속 시 항상 초기 상태(랜딩)로 시작, `?user=` 있을 때만 기록 유지 |
| 2026-02-12 15:21:54 +09:00 | `953ecce` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 해시 기반 URL에서도 `?user=`, `?fresh=` 파라미터 인식 |
| 2026-02-12 15:15:59 +09:00 | `b20afca` | `savvy-webapp-youngjo` | https://savvy-webapp-youngjo.web.app | 사용자별 세션 분리(`?user=`), 초기 진입 옵션(`?fresh=1`) |
