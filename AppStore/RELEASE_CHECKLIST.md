# App Store 上架前檢查清單

## 📅 檢查日期: 2026-05-04

---

## ✅ 已完成項目

### 代碼與功能
- [x] 所有 Swift 文件已加入 xcodeproj（85個文件）
- [x] 單元測試（7個測試文件，662行）
- [x] UI 測試（13個測試案例）
- [x] Dark Mode 支援
- [x] Widget 擴展（Small + Medium）
- [x] StoreKit IAP 真實接入
- [x] 本地通知提醒
- [x] AI Gateway 整合

### 文案與素材
- [x] App Store 文案（AppStore/README_AppStore.md）
- [x] 10張截圖文案規劃

---

## ⚠️ 待完成項目

### Xcode 編譯驗證
- [ ] 在 Xcode 中打開項目
- [ ] 選擇目標設備（iPhone 15 Pro）
- [ ] Build (⌘B) 確認無編譯錯誤
- [ ] Run (⌘R) 確認模擬器運行正常
- [ ] 測試所有核心功能

### App Store Connect
- [ ] 創建 App ID（com.bestyearplanner）
- [ ] 配置 App Groups（Widget 數據共享）
- [ ] 配置 In-App Purchase（高級版訂閱）
- [ ] 上傳 App Icon（1024x1024）
- [ ] 上傳截圖（6.7" + 6.5" + 5.5"）
- [ ] 填寫年齡分級問卷
- [ ] 上傳構建版本

### 截圖準備
- [ ] 首頁（挑戰卡片）
- [ ] 打卡頁（每日任務）
- [ ] AI 教練對話
- [ ] 7天啟動進度
- [ ] 21天挑戰日曆
- [ ] 訂閱頁面
- [ ] Dark Mode 對比圖

### 測試驗證
- [ ] 在真機上測試（需 Apple Developer 帳號）
- [ ] 測試 IAP 購買流程（Sandbox）
- [ ] 測試 Widget 功能
- [ ] 測試通知提醒
- [ ] 測試深色模式切換

---

## 🔧 技術規格確認

| 項目 | 值 |
|------|-----|
| Bundle ID | com.bestyearplanner |
| 最低版本 | iOS 16.0+ |
| 架構 | MVVM + SwiftUI |
| 數據庫 | SQLite3 |
| AI Gateway | https://www.herelai.fun/ws/05-ai-gateway/api/query |

---

## 📝 App Store 信息

### 名稱
最好的一年 · 7天啟動，21天改變

### 副標題
從相信自己開始，一步步遇見更好的你

### 描述
見 AppStore/README_AppStore.md

### 關鍵詞
習慣養成,目標規劃,21天挑戰,AI教練,自我成長,時間管理,打卡追蹤,年度計劃

### 分類
生產力

### 年齡分級
4+

---

## 🚀 上架步驟

1. **Xcode 驗證**
   ```bash
   # 打開項目
   open "Best Year Planner.xcodeproj"
   # 或
   open "Best Year Planner.xcworkspace"
   ```

2. **Archive 構建**
   - Product → Archive
   - 驗證構建
   - 上傳到 App Store Connect

3. **App Store Connect 配置**
   - 填寫所有必填信息
   - 上傳截圖和圖標
   - 提交審核

---

## ⏰ 預估時間

| 項目 | 時間 |
|------|------|
| Xcode 編譯驗證 | 30 分鐘 |
| 截圖準備 | 1 小時 |
| App Store Connect 配置 | 1 小時 |
| 審核等待 | 1-3 天 |

**總計**: 2.5 小時 + 審核時間

---

## 📞 支援

- GitHub: https://github.com/wilson710808/Best-Year-Planner-ios-app
- AI Gateway: herelai.fun
- 開發者: Wilson Lai

---

**最後更新**: 2026-05-04 17:15 GMT+8
