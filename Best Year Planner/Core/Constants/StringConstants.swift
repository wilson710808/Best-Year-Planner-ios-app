import Foundation

enum StringConstants {
    enum Auth {
        static let welcomeTitle = "歡迎來到\n最佳年份規劃師"
        static let welcomeSubtitle = "根據《規劃最好的一年》\n讓你的人生更有方向"
        static let loginTitle = "登入"
        static let registerTitle = "註冊"
        static let forgotPasswordTitle = "忘記密碼"
        static let accountPlaceholder = "請輸入帳號"
        static let passwordPlaceholder = "請輸入密碼"
        static let confirmPasswordPlaceholder = "請確認密碼"
        static let nicknamePlaceholder = "請輸入暱稱"
        static let emailPlaceholder = "請輸入電子郵箱"
        static let loginButton = "登入"
        static let registerButton = "註冊"
        static let forgotPasswordButton = "忘記密碼？"
        static let noAccount = "還沒有帳號？"
        static let hasAccount = "已經有帳號？"
        static let signUp = "立即註冊"
        static let signIn = "立即登入"
    }

    enum Onboarding {
        static let nextButton = "下一步"
        static let previousButton = "上一步"
        static let skipButton = "跳過"
        static let startButton = "開始規劃"
        static let careerTitle = "事業與財富"
        static let relationshipTitle = "人際關係"
        static let growthTitle = "自我成長"
        static let careerSubtitle = "回答以下問題，了解你在事業和財富方面的現況與願景"
        static let relationshipSubtitle = "回答以下問題，了解你在人際關係方面的現況與願景"
        static let growthSubtitle = "回答以下問題，了解你在自我成長方面的現況與願景"
    }

    enum Dashboard {
        static let title = "儀表板"
        static let yearProgress = "年度進度"
        static let thisWeek = "本週"
        static let thisMonth = "本月"
        static let streakDays = "連續打卡"
        static let totalCheckIns = "總打卡次數"
        static let unfinishedTasks = "待完成任務"
        static let todayTasks = "今日任務"
        static let career = "事業/財富"
        static let relationship = "人際關係"
        static let growth = "自我成長"
    }

    enum Goals {
        static let title = "目標任務"
        static let addGoal = "新增目標"
        static let editGoal = "編輯目標"
        static let deleteGoal = "刪除目標"
        static let goalTitle = "目標標題"
        static let goalDescription = "目標描述"
        static let deadline = "截止日期"
        static let priority = "優先級"
        static let highPriority = "高"
        static let mediumPriority = "中"
        static let lowPriority = "低"
        static let yearly = "年度"
        static let quarterly = "季度"
        static let monthly = "月度"
        static let weekly = "每週"
        static let daily = "每日"
    }

    enum CheckIn {
        static let title = "打卡中心"
        static let todayTasks = "今日任務"
        static let completed = "已完成"
        static let partial = "部分完成"
        static let missed = "未完成"
        static let checkIn = "打卡"
        static let checkInSuccess = "打卡成功！"
        static let streak = "連續打卡"
        static let streakDays = "連續打卡"
        static let days = "天"
        static let calendar = "打卡日曆"
        static let history = "打卡歷史"
    }

    enum AICoach {
        static let title = "AI教練"
        static let chatPlaceholder = "輸入訊息..."
        static let sendButton = "發送"
        static let reminderTitle = "提醒"
        static let weeklyReviewTitle = "每週復盤"
        static let monthlyReviewTitle = "月度復盤"
        static let trackDeviation = "軌道偏離提醒"
        static let howCanIHelp = "我是你的AI教練，有什麼可以幫助你？"
    }

    enum Community {
        static let title = "AI夥伴社群"
        static let groups = "揪團列表"
        static let createGroup = "創建揪團"
        static let joinGroup = "加入揪團"
        static let leaveGroup = "離開揪團"
        static let leaderboard = "排行榜"
        static let posts = "動態"
        static let createPost = "發布動態"
        static let like = "點讚"
        static let comment = "評論"
    }

    enum Settings {
        static let title = "設置"
        static let profile = "個人資料"
        static let notifications = "通知設定"
        static let appearance = "外觀"
        static let dataManagement = "數據管理"
        static let about = "關於"
        static let logout = "登出"
        static let deleteAccount = "刪除帳號"
        static let editProfile = "編輯資料"
        static let syncData = "同步數據"
        static let exportData = "導出數據"
        static let lightMode = "淺色模式"
        static let darkMode = "深色模式"
        static let systemMode = "跟隨系統"
    }

    enum Common {
        static let save = "儲存"
        static let cancel = "取消"
        static let confirm = "確認"
        static let delete = "刪除"
        static let edit = "編輯"
        static let done = "完成"
        static let loading = "載入中..."
        static let error = "錯誤"
        static let success = "成功"
        static let retry = "重試"
        static let empty = "暫無數據"
    }
}
