# 📱 Best Year Planner — 最好的一年

**從相信自己開始，7天啟動，21天改變，AI夥伴揪團成長。**

基於《規劃最好的一年》五大步驟法則，結合 AI 教練、階梯式習慣養成與 AI 夥伴揪團，幫助你打造最好的一年。

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
- 對話持久化 + 上下文記憶（最近10條歷史）

### 👥 AI 夥伴揪團成長 ⭐ NEW
- **3-5 位 AI 夥伴**陪你走完全程，各有獨特角色：

| 角色 | 定位 | 互動風格 |
|------|------|----------|
| 🧑‍💼 **同行者 ×2** | 和你同時起步，一起摸索 | 「我也是耶！」共情+不確定 |
| ⭐ **過來人 ×1** | 已完成相同任務，分享經驗 | 「我當時也卡在這裡...」溫暖像學長姐 |
| 🌱 **新手 ×1** | 被你影響而開始 | 「你怎麼做到的？」好奇+敬佩 |
| 🧘 **教練** (可選) | 適時引導，全局視角 | 在里程碑/提問時介入 |

- 揪團動態消息流：打卡、分享、鼓勵、里程碑、提問、反思
- 夥伴私聊：點任意夥伴1對1深度對話
- 進度里程碑：第7天/第14天/第21天自動觸發
- AI 角色一致性：每個夥伴有獨立人格 prompt，回覆保持角色特色

### 📊 進度視覺化
- 挑戰進度環形圖
- 三維度追蹤：事業 / 人際 / 成長
- 週進度日曆視圖
- 連續打卡天數統計

### 🔮 AI 洞察報告 ⭐ NEW
- 週洞察：AI 彙整本週數據，生成優勢/改進/聚焦建議
- 月洞察：深度分析月度趨勢、成就、挑戰
- 激勵語句：AI 生成個人化激勵

### 📈 進階數據分析 ⭐ NEW
- 維度趨勢圖：事業/人際/成長 週完成率變化
- 目標完成時間線：從創建到完成的軌跡
- 習慣養成曲線：30天打卡率 + 週幾分佈 + 連續天數

### 🎯 AI 任務生成 ⭐ NEW
- 從目標內容 AI 生成個性化任務（4-6個）
- 每個任務含優先級、截止日期
- Fallback 到規則模板，確保離線可用

### 🎨 現代化體驗
- **Dark Mode** — 自適應深色模式 + 語義顏色
- **Widget 擴展** — 鎖屏顯示今日任務（Small + Medium）
- **本地通知** — 每日挑戰提醒 + 連續打卡提醒
- **數據導出** — JSON 備份 + 系統分享

### 💎 訂閱方案

| 功能 | 基礎版 | 高級版 |
|------|--------|--------|
| 7天啟動計畫 | ✅ | ✅ |
| 21天習慣挑戰 | 最多3組 | 無限 |
| AI 教練對話 | ✅ | ✅ |
| AI 夥伴揪團 | ✅ | ✅ |
| AI 洞察報告 | ❌ | ✅ |
| 進階數據分析 | ❌ | ✅ |
| 自訂提醒時間 | ❌ | ✅ |
| 免費試用期 | — | ✅ |

---

## 🛠️ 技術棧

| 技術 | 說明 |
|------|------|
| **Swift / SwiftUI** | 原生 iOS 開發框架 |
| **MVVM + ServiceLocator** | 架構模式 + Protocol 熱插拔 |
| **SQLite3** | 本地數據持久化（含索引+遷移機制） |
| **StoreKit 2** | 應用內購買（含過期降級+試用期） |
| **UNUserNotificationCenter** | 本地推送通知 |
| **WidgetKit** | iOS 鎖屏小工具 |
| **OSLog** | 統一日誌系統 |
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
│   ├── Protocols/                    # AIProvider, StorageProvider, AuthProvider
│   ├── ServiceContainer.swift        # ServiceLocator 依賴注入
│   ├── Modules/                      # ModuleManager（4模組）
│   └── Utilities/
│       ├── KeychainManager.swift     # Keychain 存取
│       └── AppLogger.swift           # OSLog 統一日誌
├── Models/
│   ├── Goal.swift                    # 目標（維度/層級/優先級）
│   ├── Challenge.swift               # 7天+21天挑戰
│   ├── GrowthGroup.swift             # AI夥伴揪團 + 角色定義 ⭐
│   ├── AIConversation.swift          # AI 對話模型
│   ├── Community.swift               # 社群模型
│   ├── Task.swift / CheckIn.swift / User.swift
│   └── Subscription.swift / Questionnaire.swift
├── Services/
│   ├── AIService.swift               # AI Gateway 整合（async + 個性化）
│   ├── AIService+TaskGeneration.swift # AI 任務生成 ⭐
│   ├── AIInsightService.swift        # AI 洞察報告 ⭐
│   ├── AnalyticsService.swift        # 進階數據分析 ⭐
│   ├── GrowthGroupService.swift      # 揪團成長服務 ⭐
│   ├── AuthService.swift             # 認證（SHA256+salt+session token）
│   ├── StoreKitService.swift         # IAP（含過期降級+試用期）
│   ├── CommunityService.swift        # 社群服務
│   ├── ReviewService.swift           # 週/月復盤（async AI）
│   └── GoalService / TaskService / CheckInService / ChallengeNotification
├── ViewModels/
│   ├── ChallengeViewModel.swift      # 挑戰管理
│   ├── AICoachViewModel.swift        # AI 教練（持久化+上下文）
│   ├── GrowthGroupViewModel.swift    # 揪團成長 VM ⭐
│   ├── AIInsightViewModel.swift      # 洞察報告 VM ⭐
│   ├── AdvancedAnalyticsViewModel.swift # 數據分析 VM ⭐
│   ├── OnboardingViewModel.swift     # 引導流程
│   └── AppState / Dashboard / Review / Community / CheckIn / Settings
├── Views/
│   ├── Onboarding/                   # 4步引導流程
│   ├── Challenge/                    # 7天啟動/21天挑戰
│   ├── Dashboard/                    # 儀表板 + 慶祝頁面
│   ├── CheckIn/                      # 打卡中心 + 日曆
│   ├── AICoach/                      # AI 教練
│   ├── Community/
│   │   ├── GrowthGroupListView.swift # 揪團列表 ⭐
│   │   ├── GrowthGroupDetailView.swift # 揪團詳情+動態流 ⭐
│   │   └── CommunityView.swift       # 社群首頁
│   ├── Insights/                     # AI 洞察報告頁面 ⭐
│   ├── Analytics/                    # 進階數據分析頁面 ⭐
│   ├── Goals/                        # 目標 + 任務管理
│   ├── Review/                       # 週/月復盤
│   └── Settings/                     # 設定 + 訂閱 + 導出
├── Storage/
│   ├── DatabaseManager.swift         # SQLite3 CRUD（含索引+遷移）
│   └── UserDefaultsManager.swift     # 偏好設定 + Widget 同步
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
| Swift 檔案 | **102+** |
| 程式碼行數 | ~17,000+ |
| 數據表 | **9**（users, goals, tasks, check_ins, conversations, reviews, community_groups/posts, growth_groups, group_activities） |
| DB 索引 | **21** |
| 功能模組 | 4（首頁/打卡/AI教練/我的） |
| 單元測試 | 7 文件 |
| UI 測試 | 13 測試案例 |
| Widget 尺寸 | 2（Small + Medium） |
| AI 夥伴角色 | 4（同行者/過來人/新手/教練） |

---

## 🔒 安全設計

| 措施 | 說明 |
|------|------|
| **密碼存儲** | SHA256 + 帳號 salt，不存明文 |
| **Session Token** | 32字符隨機 token，取代明文密碼 autoLogin |
| **密碼強度** | ≥8字符 + 字母 + 數字 |
| **DB 遷移** | PRAGMA user_version + migrateToV2() |
| **Test User** | `#if DEBUG` 包裹，生產環境不創建 |
| **訂閱驗證** | 過期自動降級，免費試用期追蹤 |

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
  - AI 教練多輪對話（含歷史上下文）
  - AI 夥伴角色化回覆（4種人格 prompt）
  - AI 洞察報告（週/月數據彙整）
  - AI 個性化任務生成
  - 週/月復盤 AI 建議（async + fallback）

---

## 🚀 開發狀態

### ✅ 已完成
- [x] 核心功能：7天啟動 + 21天挑戰
- [x] AI Gateway 整合
- [x] 訂閱體系 + StoreKit IAP（含過期降級+試用期）
- [x] Widget 擴展（Small + Medium）
- [x] Dark Mode 自適應 + 語義顏色
- [x] 本地通知提醒
- [x] 單元測試 + UI 測試
- [x] App Store 文案 + 截圖規劃
- [x] **P0 安全修復**：密碼 SHA256+salt + Session Token + 8字元強度
- [x] **P0 DB 基礎**：21索引 + PRAGMA遷移機制
- [x] **P1 AI 對話**：持久化 + 10條上下文記憶
- [x] **P1 Goal/Task CRUD**：刪除+完成+暫停操作
- [x] **P1 社群功能**：DB CRUD → Service → ViewModel 完整實現
- [x] **P1 導航修復**：Dashboard 快速操作綁定
- [x] **AI 夥伴揪團成長**：4角色AI夥伴 + 動態消息 + 私聊
- [x] **AI 洞察報告**：週/月數據彙整 + AI 生成
- [x] **進階數據分析**：維度趨勢 + 目標時間線 + 習慣曲線
- [x] **AI 任務生成**：個性化任務 + fallback
- [x] **訂閱管理完善**：過期降級 + 試用期 + 剩餘天數
- [x] **OSLog 日誌**：10 Category 統一日誌系統
- [x] **數據導出**：JSON 備份 + UIActivityViewController

### 📝 待完成
- [ ] DatabaseManager 拆分 Repository（架構優化）
- [ ] LocalizationManager 按模組拆分
- [ ] iCloud 同步（CloudKit）
- [ ] Xcode 實際編譯驗證
- [ ] App Store 截圖製作
- [ ] App Store Connect 上架提交

---

## 🚀 開發指南

### 環境需求
- Xcode 15+
- iOS 16.0+
- Swift 5.9+

### App Group 配置（Widget 數據共享）
1. 在 Xcode 中選擇主 App Target → Signing & Capabilities → 點擊 "+ Capability" → 添加 "App Groups"
2. 添加 App Group ID：`group.com.bestyearplanner`
3. 對 Widget Extension Target 重複上述步驟，使用**相同**的 App Group ID
4. 確認兩個 Target 的 App Group ID 完全一致，否則 Widget 無法讀取主 App 數據

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

**創新點**：
- 將五大步驟濃縮為「3問題 → 7天啟動 → 21天挑戰」的階梯式流程
- AI 教練提供個性化指導，持續維持動力
- **AI 夥伴揪團**：社交化成長，不再一個人堅持
  - 同行者一起摸索、過來人分享經驗、新手帶來成就感
  - 角色化 AI 讓互動有溫度，不是冷冰冰的問答

---

## 📄 License

MIT License

---

## 🔗 相關項目

- [plan-best-year-app](https://github.com/wilson710808/plan-best-year-app) — Web 版（Vite + React SPA）
- [ai-gateway](https://github.com/wilson710808/ai-gateway) — AI Gateway 多應用 API 網關
- [ai-gateway-client](https://github.com/wilson710808/ai-gateway-client) — AI Chat 聊天客戶端
- [stock_ai](https://github.com/wilson710808/stock_ai) — AI 股票助手
- [family_website](https://github.com/wilson710808/family_website) — 家族門戶網站

---

**GitHub**: https://github.com/wilson710808/Best-Year-Planner-ios-app  
**最後更新**: 2026-05-05
