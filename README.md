# 📱 Best Year Planner — 最好的一年

**從相信自己開始，7天啟動，21天改變。**

基於《規劃最好的一年》五大步驟法則，結合 AI 教練與階梯式習慣養成，幫助你打造最好的一年。

> **「最好的規劃，是付諸行動的規劃。」**

---

## ✨ 產品特色

### 🚀 階梯式習慣養成
- **7天啟動計畫** — 回答3個簡單問題，AI 生成個人化啟動任務
- **21天習慣挑戰** — 完成7天後解鎖，3循環設計（基礎→深化→內化）
- **每日任務打卡** — 簡單追蹤，持續前進

### 🤖 AI 教練
- 個性化目標生成與方向建議
- 每日啟發式 Tip（智慧快取）
- 多輪對話支援，根據你的進度調整建議

### 📊 進度視覺化
- 挑戰進度環形圖
- 三維度追蹤：事業 / 人際 / 成長
- 週進度日曆視圖
- 連續打卡天數統計

### 🎨 現代化體驗
- **Dark Mode** — 自適應深色模式
- **Widget 擴展** — 鎖屏顯示今日任務（Small + Medium）
- **本地通知** — 每日挑戰提醒

### 💎 訂閱方案

| 功能 | 基礎版 | 高級版 |
|------|--------|--------|
| 7天啟動計畫 | ✅ | ✅ |
| 21天習慣挑戰 | 最多3組 | 無限 |
| AI 教練對話 | ✅ | ✅ |
| AI 洞察報告 | ❌ | ✅ |
| 進階數據分析 | ❌ | ✅ |
| 自訂提醒時間 | ❌ | ✅ |

---

## 🛠️ 技術棧

| 技術 | 說明 |
|------|------|
| **Swift / SwiftUI** | 原生 iOS 開發框架 |
| **MVVM** | Model-View-ViewModel 架構 |
| **SQLite3** | 本地數據持久化 |
| **StoreKit 2** | 應用內購買 |
| **UNUserNotificationCenter** | 本地推送通知 |
| **WidgetKit** | iOS 鎖屏小工具 |
| **AI Gateway** | 自建 AI 網關，統一 API 管理 |

---

## 🏗️ 專案結構

```
Best Year Planner/
├── App Entry
│   ├── Best_Year_PlannerApp.swift    # @main 入口 + Dark Mode
│   └── RootView.swift                # 根視圖
├── Core/
│   ├── Constants/                    # AppConstants, StringConstants, ColorConstants
│   ├── Extensions/                   # Date+, View+ 擴展
│   └── Modules/                      # ModuleManager（4模組）
├── Models/                           # 數據模型
│   ├── Goal.swift                    # 目標（維度/層級/優先級）
│   ├── Challenge.swift               # 7天+21天挑戰
│   ├── Subscription.swift            # 訂閱方案
│   ├── Questionnaire.swift           # 問卷答案
│   ├── Task.swift                    # 任務
│   ├── CheckIn.swift                 # 打卡記錄
│   └── User.swift                    # 用戶
├── Services/                         # 業務邏輯
│   ├── AIService.swift               # AI Gateway 整合
│   ├── StoreKitService.swift         # IAP 購買管理
│   ├── ChallengeNotificationManager.swift
│   └── GoalService.swift
├── ViewModels/                       # 視圖模型
│   ├── ChallengeViewModel.swift      # 挑戰管理
│   ├── OnboardingViewModel.swift     # 引導流程
│   ├── AppState.swift                # 全局狀態
│   └── DashboardViewModel.swift
├── Views/                            # SwiftUI 視圖
│   ├── Onboarding/                   # 4步引導流程
│   ├── Challenge/                    # 7天啟動/21天挑戰
│   ├── Dashboard/                    # 儀表板
│   ├── CheckIn/                      # 打卡中心
│   ├── AICoach/                      # AI 教練
│   ├── Settings/                     # 設定 + 訂閱
│   └── MainTab/                      # 4標籤頁
├── Storage/                          # 數據持久層
│   ├── DatabaseManager.swift         # SQLite3 CRUD
│   └── UserDefaultsManager.swift     # 偏好設定 + Widget 同步
├── Tests/                            # 測試
│   ├── Best Year PlannerTests/       # 單元測試（7文件）
│   └── Best_Year_PlannerUITests/     # UI 測試（13案例）
└── TodayTaskWidget/                  # Widget 擴展
    ├── TodayTaskWidget.swift
    ├── SmallWidgetView.swift
    ├── MediumWidgetView.swift
    └── WidgetDataProvider.swift
```

---

## 📊 項目規模

| 指標 | 數量 |
|------|------|
| Swift 檔案 | **85** |
| 程式碼行數 | ~12,000+ |
| 數據表 | 7 |
| 功能模組 | 4（首頁/打卡/AI教練/我的） |
| 單元測試 | 7 文件，662 行 |
| UI 測試 | 13 測試案例 |
| Widget 尺寸 | 2（Small + Medium） |

---

## 🔗 AI Gateway 整合

本應用通過 [AI Gateway](https://github.com/wilson710808/ai-gateway) 接入大語言模型：

- **App ID**：`bestyearplanner`
- **端點**：`https://www.herelai.fun/ws/05-ai-gateway/api/query`
- **功能**：
  - 從問卷答案生成目標與方向建議
  - 生成7天啟動計畫（漸進式：認知覺察→小行動→建立錨點）
  - 生成21天習慣挑戰（3循環：基礎→深化→內化）
  - 每日 AI Tip（1小時快取）
  - AI 教練多輪對話

---

## 🚀 開發狀態

### ✅ 已完成 (2026-05-04)

- [x] 核心功能：7天啟動 + 21天挑戰
- [x] AI Gateway 整合
- [x] 訂閱體系 + StoreKit IAP
- [x] Widget 擴展（Small + Medium）
- [x] Dark Mode 自適應
- [x] 本地通知提醒
- [x] 單元測試（7文件）
- [x] UI 測試（13案例）
- [x] App Store 文案 + 截圖規劃
- [x] xcodeproj 配置（85文件）

### 📝 待完成

- [ ] Xcode 實際編譯驗證
- [ ] App Store 截圖製作
- [ ] App Store Connect 上架提交

---

## 🚀 開發指南

### 環境需求
- Xcode 15+
- iOS 16.0+
- Swift 5.9+

### 編譯運行
1. Clone 此倉庫
2. 打開 `Best Year Planner.xcodeproj`
3. Build (⌘B) 確認無編譯錯誤
4. Run (⌘R) 在模擬器中測試

---

## 📖 設計理念

基於 Michael Hyatt《規劃最好的一年》（*Your Best Year Ever*）五大步驟法則：

1. **相信可能** — 打破限制性信念
2. **總結過去** — 回顧經驗、汲取教訓
3. **設計未來** — 設定 SMART 目標
4. **找到為什麼** — 發掘內在動機
5. **付諸行動** — 制定執行計劃

**創新點**：將五大步驟濃縮為「3問題 → 7天啟動 → 21天挑戰」的階梯式流程，降低啟動門檻，以 AI 教練提供個性化指導，持續維持動力。

---

## 📄 License

MIT License

---

## 🔗 相關項目

- [plan-best-year-app](https://github.com/wilson710808/plan-best-year-app) — Web 版（Vite + React SPA）
- [ai-gateway](https://github.com/wilson710808/ai-gateway) — AI Gateway 多應用 API 網關
- [family_website](https://github.com/wilson710808/family_website) — 家族門戶網站

---

**GitHub**: https://github.com/wilson710808/Best-Year-Planner-ios-app

**最後更新**: 2026-05-04


## App Group 配置（Widget 數據共享）

1. 在 Xcode 中選擇主 App Target → Signing & Capabilities → 點擊 "+ Capability" → 添加 "App Groups"
2. 添加 App Group ID：`group.com.bestyearplanner`
3. 對 Widget Extension Target 重複上述步驟，使用**相同**的 App Group ID
4. 確認兩個 Target 的 App Group ID 完全一致，否則 Widget 無法讀取主 App 數據
