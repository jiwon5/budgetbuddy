# BudgetBuddy — 개인 예산 관리 & 가계부 iOS 앱

수입과 지출을 한눈에 정리하고, 월별 예산과 저축 목표까지 함께 관리하는 개인 가계부 앱

## 프로젝트 개요

BudgetBuddy는 매일의 소비 내역을 기록하고 월별 예산 흐름을 확인할 수 있도록 만든 iOS 가계부 앱이에요.

사용자는 수입과 지출을 날짜, 카테고리, 결제 수단, 메모와 함께 저장할 수 있고, 대시보드에서 이번 달 수입·지출·잔고를 바로 확인할 수 있어요. 캘린더 화면에서는 날짜별 지출 여부와 무지출 목표 달성 현황을 볼 수 있으며, 저축 목표 슬롯을 통해 원하는 목표 금액까지의 진행률도 관리할 수 있어요.

외부 서버나 별도 API 없이 `UserDefaults`와 `Codable` 기반 로컬 저장 방식으로 동작하기 때문에, 프로젝트를 실행하면 바로 사용할 수 있어요.

## 주요 기능

| 기능 | 설명 |
| --- | --- |
| 수입·지출 기록 | 금액, 날짜, 카테고리, 결제 수단, 메모를 입력해 거래 내역 저장 |
| 월별 대시보드 | 이번 달 수입, 지출, 잔고를 카드 형태로 요약 |
| 예산 진행률 | 월 목표 지출액 대비 현재 지출 비율을 게이지로 표시 |
| 카테고리 분석 | 식비, 쇼핑, 교통, 주거, 문화 등 카테고리별 지출 비중 확인 |
| 장부 검색·필터 | 거래 내역을 검색하고 전체/수입/지출 및 카테고리별로 필터링 |
| 월간 캘린더 | 날짜별 지출 현황을 달력 형태로 표시 |
| 무지출 목표 | 월별 무지출 목표 일수를 설정하고 달성률 확인 |
| 저축 목표 | 여행, 비상금, 구매 목표 등 저축 슬롯별 진행률 관리 |
| 프로필 요약 | 저장된 저축 목표 개수와 무지출 목표 일수 확인 |

## 기술 스택

| 항목 | 내용 |
| --- | --- |
| 언어 | Swift 5 |
| UI 프레임워크 | UIKit |
| 데이터 저장 | UserDefaults + Codable |
| 아키텍처 | MVC 기반 화면 분리 |
| 주요 컴포넌트 | UITabBarController, UINavigationController, UITableView, UICollectionView |
| 개발 환경 | Xcode |

## 프로젝트 구조

```text
BudgetBuddy/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Config/
│   └── AppConfig.swift
├── Models/
│   ├── Category.swift
│   ├── LedgerStore.swift
│   ├── PaymentMethod.swift
│   ├── SavingsGoal.swift
│   └── Transaction.swift
├── Theme/
│   └── AppTheme.swift
├── Views/
│   ├── Dashboard/
│   │   ├── BudgetProgressView.swift
│   │   └── SavingsSlotCell.swift
│   └── Shared/
│       └── MonthNavigationView.swift
└── controllers/
    ├── AddTransactionViewController.swift
    ├── CalendarViewController.swift
    ├── DashboardViewController.swift
    ├── LedgerViewController.swift
    ├── MainTabBarController.swift
    ├── ProfileViewController.swift
    └── SplashViewController.swift
```

## 핵심 로직 — 로컬 가계부 저장소

앱의 거래 내역, 저축 목표, 월 예산, 무지출 목표는 `LedgerStore`에서 관리해요. `Codable`로 모델을 인코딩해 `UserDefaults`에 저장하고, 저장된 값이 없을 때는 샘플 데이터를 보여주는 방식이에요.

```swift
var transactions: [Transaction] {
    get { load([Transaction].self, forKey: AppConfig.StorageKey.transactions) ?? Transaction.sampleData }
    set { save(newValue, forKey: AppConfig.StorageKey.transactions) }
}

func addTransaction(_ transaction: Transaction) {
    var current = transactions
    current.append(transaction)
    transactions = current
}
```

## 실행 방법

1. 프로젝트를 클론하거나 압축을 해제합니다.
2. `BudgetBuddy.xcodeproj` 파일을 Xcode에서 엽니다.
3. 원하는 iPhone 시뮬레이터 또는 실기기를 선택합니다.
4. `Cmd + R`로 빌드 및 실행합니다.

별도 API 키나 외부 서버 설정은 필요 없어요.

## 화면 구성

| 화면 | 설명 |
| --- | --- |
| 스플래시 | 앱 진입 전 브랜드 화면 표시 |
| 대시보드 | 월별 수입, 지출, 잔고, 예산 진행률, 카테고리 지출 요약 |
| 장부 | 거래 내역 목록, 검색, 수입·지출 필터, 카테고리 필터 |
| 내역 추가 | 수입·지출 선택, 금액, 날짜, 카테고리, 결제 수단, 메모 입력 |
| 캘린더 | 월간 지출 현황, 무지출 목표 달성률, 저축 목표 슬롯 |
| 프로필 | 사용자 요약, 저축 목표 수, 무지출 목표, 설정 메뉴 |

## 데이터 모델

| 모델 | 설명 |
| --- | --- |
| `Transaction` | 수입·지출 타입, 금액, 날짜, 카테고리, 결제 수단, 메모 |
| `Category` | 식비, 쇼핑, 교통, 주거, 문화, 건강, 교육, 급여 등 분류 |
| `PaymentMethod` | 신용카드, 체크카드, 계좌이체, 간편결제 등 결제 수단 |
| `SavingsGoal` | 목표명, 목표 금액, 적립 금액, 이모지, 달성률 |
| `LedgerStore` | 앱 전체 가계부 데이터를 저장하고 불러오는 싱글톤 저장소 |

## 개발자

| 항목 | 내용 |
| --- | --- |
| 이름 | jiwon5 |
| 개발 기간 | 2026년 6월 |
| 유형 | iOS 개인 토이 프로젝트 |
