# 📱 Best Year Planner — iOS 年度目標規劃助手

基於《規劃最好的一年》五大步驟法則，結合 AI 教練與社群互助，幫助你設定目標、每日打卡、定期複盤，打造最好的一年。

> **「最好的規劃，是付諸行動的規劃。」**

---

## ✨ 核心功能

### 🎯 智能目標設定
- 基於《規劃最好的一年》問卷系統，AI 自動生成個人化年度目標
- 三大維度：**事業/財富**、**人際關係**、**自我成長**
- 多層級目標體系：年度 → 季度 → 月度 → 週 → 日
- 目標狀態追蹤：進行中 / 已暫停 / 已完成 / 已取消
- 優先級管理：高 / 中 / 低

### ✅ 每日打卡中心
- 任務打卡追蹤（完成/未完成/跳過）
- 連續打卡天數統計與最長紀錄
- 打卡狀態即時更新，養成持續習慣

### 📊 進度儀表板
- 整體年度進度環形圖
- 三維度進度分別展示（事業 / 人際 / 成長）
- 本週摘要：完成率、打卡數、連續天數
- 今日待辦任務一覽

### 🤖 AI 教練 & AI 夥伴
- **AI 教練**：根據《規劃最好的一年》原則，幫助你設定目標、追蹤進度、克服拖延
- **AI 夥伴**：以陪伴者身份分享經驗，溫暖鼓勵你前行
- 通過 AI Gateway 接入大語言模型，支援多輪對話
- 個人化歡迎消息，根據你的成就動態生成

### 📝 定期複盤
- 週覆盤：本週完成率、連續打卡、任務統計 + AI 建議
- 月覆盤：月度進度評估與策略調整
- 年覆盤：年度回顧與下年規劃

### 👥 社群互助
- 揪團功能：創建或加入成長小組
- AI 夥伴聊天室：一對一 AI 陪伴
- 成員鼓勵系統：連續打卡激勵

### 🌐 多語言支持
- 繁體中文
- 簡體中文
- English

### 🔔 通知提醒
- 每日打卡提醒（自訂提醒時間）
- 週覆盤提醒
- 連續打卡中斷提醒

---

## 🏗️ 架構設計

採用 **MVVM (Model-View-ViewModel)** 架構，模組化設計：

```
Best Year Planner/
├── App Entry
│   ├── Best_Year_PlannerApp.swift    # @main 入口
│   └── ContentView.swift
├── Core/
│   ├── Constants/                    # 應用常量、顏色、字串
│   ├── Extensions/                   # Date、View 擴展
│   ├── Localization/                 # 多語言管理器
│   ├── Modules/                      # 模組管理器（可啟用/禁用）
│   └── Utilities/                    # Keychain、通知工具
├── Models/                           # 數據模型
│   ├── Goal.swift                    # 目標（維度/層級/優先級/狀態）
│   ├── Task.swift                    # 任務
│   ├── CheckIn.swift                 # 打卡記錄
│   ├── Review.swift                  # 覆盤（週/月/年）
│   ├── AIConversation.swift          # AI 對話
│   ├── Community.swift               # 社群
│   ├── Questionnaire.swift           # 問卷
│   ├── DirectionalSuggestion.swift   # 方向性建議
│   └── User.swift                    # 用戶
├── Services/                         # 業務邏輯服務層
│   ├── AIService.swift               # AI Gateway API 對接
│   ├── AuthService.swift             # 認證服務
│   ├── GoalService.swift             # 目標服務
│   ├── TaskService.swift             # 任務服務
│   ├── CheckInService.swift          # 打卡服務
│   ├── ReviewService.swift           # 覆盤服務
│   └── CommunityService.swift        # 社群服務
├── ViewModels/                       # 視圖模型
├── Views/                            # SwiftUI 視圖
│   ├── Auth/                         # 登入/註冊/忘記密碼
│   ├── Onboarding/                   # 新手引導問卷
│   ├── Dashboard/                    # 儀表板
│   ├── Goals/                        # 目標列表
│   ├── CheckIn/                      # 打卡中心
│   ├── AICoach/                      # AI 教練聊天
│   ├── Community/                    # 社群 & AI 夥伴
│   ├── Settings/                     # 設定
│   ├── Components/                   # 共用組件
│   └── MainTab/                      # 主標籤頁
└── Storage/                          # 數據持久層
    ├── DatabaseManager.swift         # SQLite3 本地數據庫
    └── UserDefaultsManager.swift     # UserDefaults 管理
```

---

## 🛠️ 技術棧

| 技術 | 說明 |
|------|------|
| **Swift / SwiftUI** | 原生 iOS 開發框架 |
| **MVVM** | Model-View-ViewModel 架構模式 |
| **SQLite3** | 本地數據持久化（7 張數據表） |
| **Keychain** | 安全存儲帳戶密碼 |
| **AI Gateway** | 自建 AI 網關，統一管理 API Key 池與多輪對話 |
| **UserDefaults** | 輕量偏好設定存儲 |
| **Xcode** | 開發環境 |

---

## 🔗 AI Gateway 整合

本應用通過 [AI Gateway](https://github.com/wilson710808/ai-gateway) 接入大語言模型：

- **App ID**：`bestyearplanner`
- **功能**：AI 教練對話、AI 夥伴對話、智能目標生成
- **通訊協議**：HTTPS POST → `/ws/05-ai-gateway/api/query`
- **多輪記憶**：支援上下文連續對話
- **API Key 池化**：Gateway 統一管理多組 API Key，自動輪詢與限流

---

## 📊 項目規模

| 指標 | 數量 |
|------|------|
| Swift 檔案 | 59 |
| 程式碼行數 | ~9,000 |
| 數據表 | 7 |
| 功能模組 | 5（儀表板/目標/打卡/AI教練/社群） |
| ViewModels | 11 |
| Views | 17 |
| Services | 7 |

---

## 🚀 開發指南

### 環境需求
- Xcode 15+
- iOS 17+
- Swift 5.9+

### 編譯運行
1. Clone 此倉庫
2. 打開 `Best Year Planner.xcodeproj`
3. 配置 AI Gateway 端點（`AIService.swift` 中修改 `aiGatewayBaseURL`）
4. Build & Run

---

## 📖 設計理念

基於 Michael Hyatt《規劃最好的一年》（*Your Best Year Ever*）五大步驟法則：

1. **相信可能** — 打破限制性信念
2. **總結過去** — 回顧經驗、汲取教訓
3. **設計未來** — 設定 SMART 目標
4. **找到為什麼** — 發掘內在動機
5. **付諸行動** — 制定執行計劃

本應用將這五大步驟融入問卷引導、目標設定、每日打卡、定期複盤的完整流程中，並以 AI 教練提供個性化指導，以社群互助維持動力。

---

## 📄 License

MIT License

---

**相關項目：**
- [plan-best-year-app](https://github.com/wilson710808/plan-best-year-app) — Web 版（Vite + React SPA）
- [ai-gateway](https://github.com/wilson710808/ai-gateway) — AI Gateway 多應用 API 網關
- [family_website](https://github.com/wilson710808/family_website) — 家族門戶網站
