# Best Year Planner - 技術規格文檔

## 1. 項目概述

### 1.1 基本信息
- **項目名稱**: Best Year Planner (最佳年份規劃師)
- **Bundle Identifier**: com.bestyear.planner
- **最小iOS版本**: iOS 16.0
- **開發語言**: Swift 5.9+
- **UI框架**: SwiftUI

### 1.2 核心定位
一款完全遵循《規劃最好的一年》書籍邏輯、AI引導式問卷生成目標、任務打卡、進度儀表板、AI私人教練實時提醒校正、AI夥伴社群揪團成長的iOS規劃行動工具。

### 1.3 書籍核心原則（App設計根基）
1. **人生均衡三大支柱**: 事業/財富、人際關係、自我成長
2. **目標必須具體、可衡量、可執行**
3. **目標層級拆解**: 年度 → 季度 → 月度 → 每週任務 → 每日打卡行動項
4. **固定週度復盤、月度校正**
5. **行動打卡建立習慣閉環**
6. **同伴社群互相監督**
7. **年度終局復盤**

---

## 2. 技術架構

### 2.1 架構模式
- **MVVM** (Model-View-ViewModel)
- **單一責任原則**: 每個模組獨立運作
- **Protocol-Oriented**: 善用 Protocol 定義介面

### 2.2 技術棧
| 類別 | 技術 |
|------|------|
| 開發語言 | Swift 5.9 |
| UI框架 | SwiftUI |
| 本地存儲 | UserDefaults (輕量數據) + SQLite.swift (結構化數據) |
| 鑰匙串存儲 | KeychainAccess |
| 網絡層 | URLSession |
| AI接入 | 豆包/通義千問 API |
| 推送通知 | Apple APNs |
| 架構 | MVVM + Repository Pattern |

### 2.3 項目目錄結構
```
Best Year Planner/
├── App/
│   ├── Best_Year_PlannerApp.swift
│   └── AppDelegate.swift
├── Core/
│   ├── Constants/
│   │   ├── AppConstants.swift
│   │   ├── ColorConstants.swift
│   │   └── StringConstants.swift
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── View+Extensions.swift
│   │   └── Color+Extensions.swift
│   └── Utilities/
│       ├── KeychainManager.swift
│       └── NotificationManager.swift
├── Models/
│   ├── User.swift
│   ├── Goal.swift
│   ├── Task.swift
│   ├── CheckIn.swift
│   ├── AIConversation.swift
│   ├── Review.swift
│   └── Community.swift
├── Storage/
│   ├── DatabaseManager.swift
│   ├── UserDefaultsManager.swift
│   └── StorageModels/
│       ├── UserStorage.swift
│       ├── GoalStorage.swift
│       └── CheckInStorage.swift
├── Services/
│   ├── AuthService.swift
│   ├── GoalService.swift
│   ├── TaskService.swift
│   ├── CheckInService.swift
│   ├── AIService.swift
│   ├── ReviewService.swift
│   └── CommunityService.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── OnboardingViewModel.swift
│   ├── GoalViewModel.swift
│   ├── DashboardViewModel.swift
│   ├── CheckInViewModel.swift
│   ├── AICoachViewModel.swift
│   ├── CommunityViewModel.swift
│   ├── ReviewViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Auth/
│   │   ├── WelcomeView.swift
│   │   ├── LoginView.swift
│   │   ├── RegisterView.swift
│   │   └── ForgotPasswordView.swift
│   ├── Onboarding/
│   │   ├── OnboardingContainerView.swift
│   │   ├── CareerWealthQuestionnaireView.swift
│   │   ├── RelationshipsQuestionnaireView.swift
│   │   ├── SelfGrowthQuestionnaireView.swift
│   │   └── GoalReviewView.swift
│   ├── MainTab/
│   │   └── MainTabView.swift
│   ├── Dashboard/
│   │   ├── DashboardView.swift
│   │   ├── ProgressRingView.swift
│   │   ├── DimensionProgressView.swift
│   │   └── WeeklySummaryView.swift
│   ├── Goals/
│   │   ├── GoalsListView.swift
│   │   ├── GoalDetailView.swift
│   │   ├── TaskListView.swift
│   │   ├── TaskDetailView.swift
│   │   └── AddGoalView.swift
│   ├── CheckIn/
│   │   ├── CheckInView.swift
│   │   ├── DailyTaskView.swift
│   │   ├── CheckInCalendarView.swift
│   │   └── CheckInRecordView.swift
│   ├── AICoach/
│   │   ├── AICoachView.swift
│   │   ├── ChatBubbleView.swift
│   │   ├── AICoachReminderView.swift
│   │   └── WeeklyReviewView.swift
│   ├── Community/
│   │   ├── CommunityView.swift
│   │   ├── GroupListView.swift
│   │   ├── GroupDetailView.swift
│   │   ├── CreateGroupView.swift
│   │   ├── LeaderboardView.swift
│   │   └── PostDetailView.swift
│   ├── Review/
│   │   ├── WeeklyReviewContainerView.swift
│   │   ├── MonthlyReviewView.swift
│   │   └── YearlyReviewView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ProfileEditView.swift
│   │   ├── NotificationSettingsView.swift
│   │   ├── DataManagementView.swift
│   │   └── AboutView.swift
│   └── Components/
│       ├── PrimaryButton.swift
│       ├── SecondaryButton.swift
│       ├── CustomTextField.swift
│       ├── LoadingView.swift
│       ├── EmptyStateView.swift
│       └── CustomAlert.swift
└── Resources/
    ├── Assets.xcassets/
    └── Localizable.strings
```

---

## 3. UI/UX 設計規範

### 3.1 顏色系統
| 顏色名稱 | Hex Code | 用途 |
|----------|----------|------|
| Primary | #4A90D9 | 主色，按鈕、鏈接、重點 |
| Secondary | #7ED321 | 成功、完成打卡 |
| Accent | #F5A623 | 提醒、警告 |
| Background | #F8F9FA | 背景色 |
| Card | #FFFFFF | 卡片背景 |
| TextPrimary | #2C3E50 | 主要文字 |
| TextSecondary | #7F8C8D | 次要文字 |
| Divider | #E0E0E0 | 分隔線 |
| Disabled | #BDC3C7 | 禁用狀態 |
| Career | #3498DB | 事業/財富維度 |
| Relationship | #E74C8C | 人際關係維度 |
| Growth | #27AE60 | 自我成長維度 |

### 3.2 字體系統
| 樣式 | 字體 | 大小 | 權重 |
|------|------|------|------|
| LargeTitle | SF Pro Display | 34pt | Bold |
| Title1 | SF Pro Display | 28pt | Bold |
| Title2 | SF Pro Display | 22pt | Semibold |
| Title3 | SF Pro Display | 20pt | Semibold |
| Headline | SF Pro Text | 17pt | Semibold |
| Body | SF Pro Text | 17pt | Regular |
| Callout | SF Pro Text | 16pt | Regular |
| Subheadline | SF Pro Text | 15pt | Regular |
| Footnote | SF Pro Text | 13pt | Regular |
| Caption | SF Pro Text | 12pt | Regular |

### 3.3 間距系統 (8pt Grid)
- xs: 4pt
- sm: 8pt
- md: 16pt
- lg: 24pt
- xl: 32pt
- xxl: 48pt

### 3.4 組件規範
- 圓角: 12pt (卡片)、8pt (按鈕)、20pt (輸入框)
- 陰影: 0pt 2pt 8pt rgba(0,0,0,0.08)
- 安全區域: 自動適配

### 3.5 導航設計
**底部5大Tab**:
1. 首頁儀表板 (Dashboard)
2. 目標任務 (Goals)
3. 打卡中心 (CheckIn)
4. AI教練 (AICoach)
5. AI夥伴社群 (Community)

---

## 4. 數據模型

### 4.1 User (用戶)
```swift
struct User {
    var id: String
    var account: String
    var passwordHash: String
    var nickname: String
    var avatarURL: String?
    var gender: Gender?
    var birthYear: Int?
    var createdAt: Date
    var personalityTags: [String]
    var isOnboardingCompleted: Bool
}
```

### 4.2 Goal (目標)
```swift
struct Goal {
    var id: String
    var title: String
    var description: String
    var dimension: GoalDimension // career, relationship, growth
    var level: GoalLevel // yearly, quarterly, monthly, weekly, daily
    var parentGoalId: String?
    var priority: Priority // high, medium, low
    var status: GoalStatus // active, paused, completed, cancelled
    var deadline: Date?
    var progress: Double // 0.0 - 1.0
    var createdAt: Date
    var updatedAt: Date
}
```

### 4.3 Task (任務)
```swift
struct Task {
    var id: String
    var goalId: String
    var title: String
    var description: String?
    var checkInCount: Int
    var currentStreak: Int
    var priority: Priority
    var status: TaskStatus
    var deadline: Date?
    var reminderTime: Date?
    var createdAt: Date
    var updatedAt: Date
}
```

### 4.4 CheckIn (打卡記錄)
```swift
struct CheckIn {
    var id: String
    var taskId: String
    var date: Date
    var status: CheckInStatus // completed, partial, missed
    var note: String?
    var streakDay: Int
    var createdAt: Date
}
```

### 4.5 AIConversation (AI對話)
```swift
struct AIConversation {
    var id: String
    var type: ConversationType // coach, communityAssistant
    var messages: [AIMessage]
    var createdAt: Date
}

struct AIMessage {
    var id: String
    var content: String
    var isFromUser: Bool
    var timestamp: Date
}
```

### 4.6 Review (復盤)
```swift
struct Review {
    var id: String
    var type: ReviewType // weekly, monthly, yearly
    var period: String // e.g., "2026-W05", "2026-04"
    var summary: String
    var achievements: [String]
    var improvements: [String]
    var nextWeekFocus: [String]?
    var aiSuggestions: String
    var createdAt: Date
}
```

### 4.7 CommunityGroup (社群群組)
```swift
struct CommunityGroup {
    var id: String
    var name: String
    var theme: String
    var description: String
    var memberIds: [String]
    var adminId: String
    var createdAt: Date
    var dailyCheckInGoal: Int
}
```

---

## 5. 功能模組詳細設計

### 5.1 認證模組 (Auth)
**頁面流程**: Welcome → Login → Register → ForgotPassword

**功能點**:
- 註冊: 帳號、密碼、暱稱、性別、出生年份
- 登入: 自動Keychain記住密碼
- 忘記密碼: 郵箱驗證
- 社交登入: (預留) Apple Sign-In

**數據存儲**:
- 雲端: 後台MySQL
- 本地: Keychain + UserDefaults

### 5.2 新手引導問卷 (Onboarding)
**問卷結構**:
1. 事業/財富維度 (8題)
2. 人際關係維度 (8題)
3. 自我成長維度 (8題)

**AI生成**:
- 根據問卷答案生成年度三大核心目標
- 自動拆解為季度、月度、週、日任務

### 5.3 目標管理 (Goals)
**功能點**:
- 查看三大維度目標列表
- 添加/編輯/刪除/暫停目標
- 設定截止日期、優先級、提醒
- 查看目標完成進度

### 5.4 打卡機制 (CheckIn)
**功能點**:
- 每日任務打卡 (完成/部分/未完成)
- 習慣型任務連續打卡
- 補卡機制
- 歷史打卡日曆
- 完成率統計

### 5.5 儀表板 (Dashboard)
**佈局**:
1. 年度進度圓環圖
2. 三大維度進度條
3. 本週/本月完成數
4. 連續打卡天數
5. 未完成任務提醒

### 5.6 AI教練 (AICoach)
**功能點**:
- 智能定時提醒 (打卡、復盤)
- 軌道偏離校正對話
- 一對一教練諮詢
- 每週自動復盤總結

### 5.7 AI夥伴社群 (Community)
**功能點**:
- AI匹配同頻夥伴
- 揪團打卡房
- 排行榜
- 社群動態牆

### 5.8 復盤 (Review)
**類型**:
- 每週復盤 (每週日)
- 月度復盤 (每月最後一天)
- 年度復盤 (每年12月31日)

### 5.9 設置 (Settings)
**功能點**:
- 個人資料編輯
- 通知設定
- 深色/淺色模式
- 數據管理 (同步、導出)
- 關於App

---

## 6. API 接口設計 (預留)

### 6.1 認證接口
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/forgotPassword

### 6.2 數據同步接口
- GET /api/sync/pull
- POST /api/sync/push

### 6.3 AI接口
- POST /api/ai/generateGoals
- POST /api/ai/chat
- POST /api/ai/weeklyReview

---

## 7. 本地存儲策略

### 7.1 UserDefaults (輕量)
- isFirstLaunch
- isOnboardingCompleted
- lastSyncDate
- notificationSettings
- themeMode

### 7.2 SQLite (結構化數據)
- Users
- Goals
- Tasks
- CheckIns
- AIConversations
- Reviews
- CommunityGroups

### 7.3 Keychain (敏感數據)
- account
- password (encrypted)

---

## 8. 狀態管理

### 8.1 全局狀態 (AppState)
```swift
class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var isOnboardingCompleted: Bool = false
    @Published var themeMode: ThemeMode = .system
}
```

### 8.2 業務狀態 (ViewModel)
每個主要模組有對應的ViewModel管理業務邏輯和狀態。

---

## 9. 錯誤處理

### 9.1 錯誤類型
- NetworkError (網絡錯誤)
- AuthError (認證錯誤)
- DatabaseError (數據庫錯誤)
- ValidationError (驗證錯誤)
- UnknownError (未知錯誤)

### 9.2 處理方式
- 網絡錯誤: 顯示重試選項，緩存數據
- 驗證錯誤: 即時表單提示
- 系統錯誤: 顯示友好提示，日誌記錄

---

## 10. 性能優化

### 10.1 列表優化
- LazyVStack/LazyHStack
- 圖片緩存
- 分頁加載

### 10.2 數據加載
- 背景線程處理
- 主線程更新UI
- 離線優先策略

---

## 11. 安全考量

- 密碼: SHA256 hash
- Keychain: 加密存儲
- 網絡: HTTPS only
- 敏感操作: 二次驗證 (預留)
