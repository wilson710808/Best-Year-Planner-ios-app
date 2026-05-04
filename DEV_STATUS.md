# DEV_STATUS.md — Best Year Planner 開發狀態

## 版本: v2.0 (7天啟動·21天改變)

### 最近更新: 2026-05-04

---

## ✅ 已完成功能

### 核心模型
- [x] Challenge.swift — 7天啟動 + 21天挑戰模型
- [x] Subscription.swift — 免費/高級訂閱體系
- [x] Goal.swift — 新增 sevenDayLaunch / twentyOneDayChallenge 層級
- [x] Questionnaire.swift — 簡化為3個問題 + OnboardingAnswers

### 常量 & 文案
- [x] AppConstants.swift — 新增 Challenge 常量、訂閱相關鍵值
- [x] StringConstants.swift — 全面更新產品文案（「從相信自己開始」）

### 數據層
- [x] DatabaseManager.swift — 新增 challenges / daily_challenge_tasks 表 + CRUD
- [x] UserDefaultsManager.swift — 新增 subscriptionState / onboardingAnswers

### 服務層
- [x] AIService.swift — 新增 generateSevenDayLaunchPlan / generateTwentyOneDayChallenge / generateDailyTip

### ViewModel 層
- [x] OnboardingViewModel.swift — 3問題 → AI生成7天計畫（含 fallback）
- [x] ChallengeViewModel.swift — 挑戰管理、打卡、解鎖21天
- [x] AppState.swift — 訂閱狀態管理、挑戰計數

### Views
- [x] OnboardingContainerView.swift — 全新4步引導流程
- [x] SevenDayLaunchView.swift — 7天啟動視圖（進度圈+每日任務）
- [x] TwentyOneDayChallengeView.swift — 21天挑戰視圖（週進度+日曆格）
- [x] ChallengeUnlockView.swift — 完成七天後解鎖慶祝頁
- [x] SubscriptionView.swift — 訂閱/升級頁面
- [x] DashboardView.swift — 重新設計（挑戰卡片+統計+快速操作）
- [x] MainTabView.swift — 簡化為4個Tab（首頁/打卡/AI教練/我的）

### 模組管理
- [x] ModuleManager.swift — 更新為4模組（首頁/打卡/AI教練/我的）

---

## ⚠️ 待完成

### 功能
- [x] StoreKit 真實 IAP 接入（StoreKitService.swift）
- [x] 本地通知提醒（ChallengeNotificationManager.swift）
- [x] Dark Mode 自適應（ColorConstants + RootView preferredColorScheme）
- [x] AI Prompt 優化（7天/21天結構化提示詞）
- [x] AI Tip 快取機制（1小時過期）
- [x] Widget 支持（TodayTaskWidget - Small/Medium 尺寸）

### 技術
- [x] Xcode 項目配置（所有80個.swift文件已加入）
- [x] 單元測試（7個測試文件，覆蓋 Challenge/Subscription/Goal/Onboarding/Questionnaire/UserDefaults/ChallengeViewModel）
- [x] UI 測試（13個測試案例，覆蓋引導流程/Tab導航/挑戰流程/訂閱/AI教練/深色模式/性能）
- [x] App Store 截圖和描述文案 (AppStore/README_AppStore.md)

### AI 優化
- [x] AI 生成7天計畫的 prompt 優化（漸進式：認知→行動→錨點）
- [x] AI 生成21天挑戰的 prompt 優化（3循環：基礎→深化→內化）
- [x] 每日 AI tip 快取避免重複請求

---

## 🔧 技術規格

| 項目 | 規格 |
|------|------|
| 架構 | MVVM + SwiftUI |
| 最低版本 | iOS 16.0+ |
| Bundle ID | com.bestyearplanner |
| AI Gateway | https://www.herelai.fun/ws/05-ai-gateway/api/query |
| App ID | bestyearplanner |
| 語言 | 繁體中文 |
| 數據庫 | SQLite3 (本地) |

---

## 📊 訂閱方案

| 功能 | 基礎版 | 高級版 |
|------|--------|--------|
| 7天啟動 | ✅ | ✅ |
| 21天挑戰 | 最多3組 | 無限 |
| AI 教練 | ✅ | ✅ |
| AI 洞察報告 | ❌ | ✅ |
| 進階分析 | ❌ | ✅ |
| 自訂提醒 | ❌ | ✅ |

---

## 📁 最新新增文件 (commit 9230a39)

- AppStore/README_AppStore.md — App Store 完整文案 + 截圖規劃
- TodayTaskWidget/TodayTaskWidget.swift — Widget 主入口
- TodayTaskWidget/TodayTaskWidgetBundle.swift — Widget Bundle
- TodayTaskWidget/WidgetDataProvider.swift — App Group 數據共享
- TodayTaskWidget/SmallWidgetView.swift — Small 尺寸（進度圈+任務）
- TodayTaskWidget/MediumWidgetView.swift — Medium 尺寸（任務+AI Tip+進度）

## 📁 新增文件清單 (v2.0)

- Models/Challenge.swift
- Models/Subscription.swift
- ViewModels/ChallengeViewModel.swift
- Views/Challenge/SevenDayLaunchView.swift
- Views/Challenge/TwentyOneDayChallengeView.swift
- Views/Challenge/ChallengeUnlockView.swift
- Views/Settings/SubscriptionView.swift

## 📁 修改文件清單

- Models/Goal.swift
- Models/Questionnaire.swift
- Core/Constants/AppConstants.swift
- Core/Constants/StringConstants.swift
- Core/Modules/ModuleManager.swift
- Services/AIService.swift
- Storage/DatabaseManager.swift
- Storage/UserDefaultsManager.swift
- ViewModels/AppState.swift
- ViewModels/OnboardingViewModel.swift
- Views/Onboarding/OnboardingContainerView.swift
- Views/Dashboard/DashboardView.swift
- Views/MainTab/MainTabView.swift
