import Foundation
import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Codable {
    case traditionalChinese = "zh-Hant"
    case simplifiedChinese = "zh-Hans"
    case english = "en"

    var displayName: String {
        switch self {
        case .traditionalChinese: return "繁體中文"
        case .simplifiedChinese: return "簡體中文"
        case .english: return "English"
        }
    }

    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaultsManager.shared.appLanguage = currentLanguage
        }
    }

    private init() {
        currentLanguage = UserDefaultsManager.shared.appLanguage
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }

    func localizedString(_ key: String) -> String {
        return LocalizationStrings.shared.string(for: key, in: currentLanguage)
    }
}

final class LocalizationStrings {
    static let shared = LocalizationStrings()

    private var translations: [String: [AppLanguage: String]] = [:]

    private init() {
        loadAllTranslations()
    }

    func string(for key: String, in language: AppLanguage) -> String {
        if let translation = translations[key]?[language] {
            return translation
        }
        return key
    }

    private func loadAllTranslations() {
        loadTraditionalChinese()
        loadSimplifiedChinese()
        loadEnglish()
    }

    private func loadTraditionalChinese() {
        translations["app.name"] = [
            .traditionalChinese: "最佳年份規劃師",
            .simplifiedChinese: "最佳年份规划师",
            .english: "Best Year Planner"
        ]

        translations["auth.welcome.title"] = [
            .traditionalChinese: "歡迎來到\n最佳年份規劃師",
            .simplifiedChinese: "欢迎来到\n最佳年份规划师",
            .english: "Welcome to\nBest Year Planner"
        ]

        translations["auth.welcome.subtitle"] = [
            .traditionalChinese: "根據《規劃最好的一年》\n讓你的人生更有方向",
            .simplifiedChinese: "根据《规划最好的一年》\n让你的人生更有方向",
            .english: "Based on 'Best Year Planner'\nMake your life more purposeful"
        ]

        translations["auth.login.title"] = [
            .traditionalChinese: "登入",
            .simplifiedChinese: "登录",
            .english: "Login"
        ]

        translations["auth.register.title"] = [
            .traditionalChinese: "註冊",
            .simplifiedChinese: "注册",
            .english: "Register"
        ]

        translations["auth.forgotPassword.title"] = [
            .traditionalChinese: "忘記密碼",
            .simplifiedChinese: "忘记密码",
            .english: "Forgot Password"
        ]

        translations["auth.account.placeholder"] = [
            .traditionalChinese: "請輸入帳號",
            .simplifiedChinese: "请输入帐号",
            .english: "Enter account"
        ]

        translations["auth.password.placeholder"] = [
            .traditionalChinese: "請輸入密碼",
            .simplifiedChinese: "请输入密码",
            .english: "Enter password"
        ]

        translations["auth.confirmPassword.placeholder"] = [
            .traditionalChinese: "請確認密碼",
            .simplifiedChinese: "请确认密码",
            .english: "Confirm password"
        ]

        translations["auth.nickname.placeholder"] = [
            .traditionalChinese: "請輸入暱稱",
            .simplifiedChinese: "请输入昵称",
            .english: "Enter nickname"
        ]

        translations["auth.email.placeholder"] = [
            .traditionalChinese: "請輸入電子郵箱",
            .simplifiedChinese: "请输入电子邮箱",
            .english: "Enter email"
        ]

        translations["auth.login.button"] = [
            .traditionalChinese: "登入",
            .simplifiedChinese: "登录",
            .english: "Login"
        ]

        translations["auth.register.button"] = [
            .traditionalChinese: "註冊",
            .simplifiedChinese: "注册",
            .english: "Register"
        ]

        translations["auth.forgotPassword.button"] = [
            .traditionalChinese: "忘記密碼？",
            .simplifiedChinese: "忘记密码？",
            .english: "Forgot Password?"
        ]

        translations["auth.noAccount"] = [
            .traditionalChinese: "還沒有帳號？",
            .simplifiedChinese: "还没有帐号？",
            .english: "No account?"
        ]

        translations["auth.hasAccount"] = [
            .traditionalChinese: "已經有帳號？",
            .simplifiedChinese: "已经有帐号？",
            .english: "Already have an account?"
        ]

        translations["auth.signUp"] = [
            .traditionalChinese: "立即註冊",
            .simplifiedChinese: "立即注册",
            .english: "Sign Up"
        ]

        translations["auth.signIn"] = [
            .traditionalChinese: "立即登入",
            .simplifiedChinese: "立即登录",
            .english: "Sign In"
        ]

        translations["auth.welcome.back"] = [
            .traditionalChinese: "歡迎回來！",
            .simplifiedChinese: "欢迎回来！",
            .english: "Welcome back!"
        ]

        translations["auth.createAccount"] = [
            .traditionalChinese: "創建你的帳戶",
            .simplifiedChinese: "创建你的帐户",
            .english: "Create your account"
        ]

        translations["auth.gender.label"] = [
            .traditionalChinese: "性別（選填）",
            .simplifiedChinese: "性别（选填）",
            .english: "Gender (Optional)"
        ]

        translations["auth.birthYear.label"] = [
            .traditionalChinese: "出生年份（選填）",
            .simplifiedChinese: "出生年份（选填）",
            .english: "Birth Year (Optional)"
        ]

        translations["auth.selectGender"] = [
            .traditionalChinese: "請選擇",
            .simplifiedChinese: "请选择",
            .english: "Please select"
        ]

        translations["gender.male"] = [
            .traditionalChinese: "男",
            .simplifiedChinese: "男",
            .english: "Male"
        ]

        translations["gender.female"] = [
            .traditionalChinese: "女",
            .simplifiedChinese: "女",
            .english: "Female"
        ]

        translations["gender.other"] = [
            .traditionalChinese: "其他",
            .simplifiedChinese: "其他",
            .english: "Other"
        ]

        translations["gender.preferNotToSay"] = [
            .traditionalChinese: "不願透露",
            .simplifiedChinese: "不愿透露",
            .english: "Prefer not to say"
        ]

        translations["error.invalidAccount"] = [
            .traditionalChinese: "帳號格式不正確，請至少輸入4個字符",
            .simplifiedChinese: "帐号格式不正确，请至少输入4个字符",
            .english: "Invalid account format, please enter at least 4 characters"
        ]

        translations["error.invalidPassword"] = [
            .traditionalChinese: "密碼格式不正確，請至少輸入6個字符",
            .simplifiedChinese: "密码格式不正确，请至少输入6个字符",
            .english: "Invalid password format, please enter at least 6 characters"
        ]

        translations["error.invalidNickname"] = [
            .traditionalChinese: "暱稱不能為空",
            .simplifiedChinese: "昵称不能为空",
            .english: "Nickname cannot be empty"
        ]

        translations["error.accountAlreadyExists"] = [
            .traditionalChinese: "該帳號已存在",
            .simplifiedChinese: "该帐号已存在",
            .english: "Account already exists"
        ]

        translations["error.userNotFound"] = [
            .traditionalChinese: "用戶不存在",
            .simplifiedChinese: "用户不存在",
            .english: "User not found"
        ]

        translations["error.wrongPassword"] = [
            .traditionalChinese: "密碼錯誤",
            .simplifiedChinese: "密码错误",
            .english: "Wrong password"
        ]

        translations["error.databaseError"] = [
            .traditionalChinese: "資料庫錯誤",
            .simplifiedChinese: "数据库错误",
            .english: "Database error"
        ]

        translations["error.noSavedCredentials"] = [
            .traditionalChinese: "沒有保存的登入資訊",
            .simplifiedChinese: "没有保存的登录信息",
            .english: "No saved login credentials"
        ]

        translations["error.passwordMismatch"] = [
            .traditionalChinese: "兩次輸入的密碼不一致",
            .simplifiedChinese: "两次输入的密码不一致",
            .english: "Passwords do not match"
        ]

        translations["error.fillAllRequired"] = [
            .traditionalChinese: "請填寫所有必填欄位",
            .simplifiedChinese: "请填写所有必填字段",
            .english: "Please fill in all required fields"
        ]

        translations["error.enterValidCredentials"] = [
            .traditionalChinese: "請輸入有效的帳號和密碼",
            .simplifiedChinese: "请输入有效的帐号和密码",
            .english: "Please enter valid account and password"
        ]

        translations["common.confirm"] = [
            .traditionalChinese: "確定",
            .simplifiedChinese: "确定",
            .english: "Confirm"
        ]

        translations["common.cancel"] = [
            .traditionalChinese: "取消",
            .simplifiedChinese: "取消",
            .english: "Cancel"
        ]

        translations["common.error"] = [
            .traditionalChinese: "錯誤",
            .simplifiedChinese: "错误",
            .english: "Error"
        ]

        translations["common.success"] = [
            .traditionalChinese: "成功",
            .simplifiedChinese: "成功",
            .english: "Success"
        ]

        translations["common.save"] = [
            .traditionalChinese: "儲存",
            .simplifiedChinese: "储存",
            .english: "Save"
        ]

        translations["common.delete"] = [
            .traditionalChinese: "刪除",
            .simplifiedChinese: "删除",
            .english: "Delete"
        ]

        translations["common.edit"] = [
            .traditionalChinese: "編輯",
            .simplifiedChinese: "编辑",
            .english: "Edit"
        ]

        translations["onboarding.next"] = [
            .traditionalChinese: "下一步",
            .simplifiedChinese: "下一步",
            .english: "Next"
        ]

        translations["onboarding.previous"] = [
            .traditionalChinese: "上一步",
            .simplifiedChinese: "上一步",
            .english: "Previous"
        ]

        translations["onboarding.skip"] = [
            .traditionalChinese: "跳過",
            .simplifiedChinese: "跳过",
            .english: "Skip"
        ]

        translations["onboarding.start"] = [
            .traditionalChinese: "開始規劃",
            .simplifiedChinese: "开始规划",
            .english: "Start Planning"
        ]

        translations["onboarding.career.title"] = [
            .traditionalChinese: "事業與財富",
            .simplifiedChinese: "事业与财富",
            .english: "Career & Wealth"
        ]

        translations["onboarding.career.subtitle"] = [
            .traditionalChinese: "回答以下問題，了解你在事業和財富方面的現況與願景",
            .simplifiedChinese: "回答以下问题，了解你在事业和财富方面的现况与愿景",
            .english: "Answer the following questions to understand your current situation and vision for career and wealth"
        ]

        translations["onboarding.relationship.title"] = [
            .traditionalChinese: "人際關係",
            .simplifiedChinese: "人际关系",
            .english: "Relationships"
        ]

        translations["onboarding.relationship.subtitle"] = [
            .traditionalChinese: "回答以下問題，了解你在人際關係方面的現況與願景",
            .simplifiedChinese: "回答以下问题，了解你在人际关系方面的现况与愿景",
            .english: "Answer the following questions to understand your current situation and vision for relationships"
        ]

        translations["onboarding.growth.title"] = [
            .traditionalChinese: "自我成長",
            .simplifiedChinese: "自我成长",
            .english: "Self Growth"
        ]

        translations["onboarding.growth.subtitle"] = [
            .traditionalChinese: "回答以下問題，了解你在自我成長方面的現況與願景",
            .simplifiedChinese: "回答以下问题，了解你在自我成长方面的现况与愿景",
            .english: "Answer the following questions to understand your current situation and vision for self growth"
        ]

        translations["dashboard.title"] = [
            .traditionalChinese: "儀表板",
            .simplifiedChinese: "仪表板",
            .english: "Dashboard"
        ]

        translations["dashboard.yearProgress"] = [
            .traditionalChinese: "年度進度",
            .simplifiedChinese: "年度进度",
            .english: "Year Progress"
        ]

        translations["dashboard.thisWeek"] = [
            .traditionalChinese: "本週",
            .simplifiedChinese: "本周",
            .english: "This Week"
        ]

        translations["dashboard.thisMonth"] = [
            .traditionalChinese: "本月",
            .simplifiedChinese: "本月",
            .english: "This Month"
        ]

        translations["dashboard.streakDays"] = [
            .traditionalChinese: "連續打卡",
            .simplifiedChinese: "连续打卡",
            .english: "Streak Days"
        ]

        translations["dashboard.totalCheckIns"] = [
            .traditionalChinese: "總打卡次數",
            .simplifiedChinese: "总打卡次数",
            .english: "Total Check-ins"
        ]

        translations["dashboard.unfinishedTasks"] = [
            .traditionalChinese: "待完成任務",
            .simplifiedChinese: "待完成任务",
            .english: "Pending Tasks"
        ]

        translations["dashboard.todayTasks"] = [
            .traditionalChinese: "今日任務",
            .simplifiedChinese: "今日任务",
            .english: "Today's Tasks"
        ]

        translations["dashboard.noTasksToday"] = [
            .traditionalChinese: "今日無任務",
            .simplifiedChinese: "今日无任务",
            .english: "No Tasks Today"
        ]

        translations["dashboard.career"] = [
            .traditionalChinese: "事業/財富",
            .simplifiedChinese: "事业/财富",
            .english: "Career/Wealth"
        ]

        translations["dashboard.relationship"] = [
            .traditionalChinese: "人際關係",
            .simplifiedChinese: "人际关系",
            .english: "Relationships"
        ]

        translations["dashboard.growth"] = [
            .traditionalChinese: "自我成長",
            .simplifiedChinese: "自我成长",
            .english: "Self Growth"
        ]

        translations["goals.title"] = [
            .traditionalChinese: "目標任務",
            .simplifiedChinese: "目标任务",
            .english: "Goals"
        ]

        translations["goals.add"] = [
            .traditionalChinese: "新增目標",
            .simplifiedChinese: "新增目标",
            .english: "Add Goal"
        ]

        translations["goals.edit"] = [
            .traditionalChinese: "編輯目標",
            .simplifiedChinese: "编辑目标",
            .english: "Edit Goal"
        ]

        translations["goals.delete"] = [
            .traditionalChinese: "刪除目標",
            .simplifiedChinese: "删除目标",
            .english: "Delete Goal"
        ]

        translations["goals.goalTitle"] = [
            .traditionalChinese: "目標標題",
            .simplifiedChinese: "目标标题",
            .english: "Goal Title"
        ]

        translations["goals.goalDescription"] = [
            .traditionalChinese: "目標描述",
            .simplifiedChinese: "目标描述",
            .english: "Goal Description"
        ]

        translations["goals.deadline"] = [
            .traditionalChinese: "截止日期",
            .simplifiedChinese: "截止日期",
            .english: "Deadline"
        ]

        translations["goals.priority"] = [
            .traditionalChinese: "優先級",
            .simplifiedChinese: "优先级",
            .english: "Priority"
        ]

        translations["goals.priority.high"] = [
            .traditionalChinese: "高",
            .simplifiedChinese: "高",
            .english: "High"
        ]

        translations["goals.priority.medium"] = [
            .traditionalChinese: "中",
            .simplifiedChinese: "中",
            .english: "Medium"
        ]

        translations["goals.priority.low"] = [
            .traditionalChinese: "低",
            .simplifiedChinese: "低",
            .english: "Low"
        ]

        translations["goals.level.yearly"] = [
            .traditionalChinese: "年度",
            .simplifiedChinese: "年度",
            .english: "Yearly"
        ]

        translations["goals.level.quarterly"] = [
            .traditionalChinese: "季度",
            .simplifiedChinese: "季度",
            .english: "Quarterly"
        ]

        translations["goals.level.monthly"] = [
            .traditionalChinese: "月度",
            .simplifiedChinese: "月度",
            .english: "Monthly"
        ]

        translations["goals.level.weekly"] = [
            .traditionalChinese: "每週",
            .simplifiedChinese: "每周",
            .english: "Weekly"
        ]

        translations["goals.level.daily"] = [
            .traditionalChinese: "每日",
            .simplifiedChinese: "每日",
            .english: "Daily"
        ]

        translations["goals.dimension.all"] = [
            .traditionalChinese: "全部",
            .simplifiedChinese: "全部",
            .english: "All"
        ]

        translations["checkIn.title"] = [
            .traditionalChinese: "打卡中心",
            .simplifiedChinese: "打卡中心",
            .english: "Check-in Center"
        ]

        translations["checkIn.todayTasks"] = [
            .traditionalChinese: "今日任務",
            .simplifiedChinese: "今日任务",
            .english: "Today's Tasks"
        ]

        translations["checkIn.completed"] = [
            .traditionalChinese: "已完成",
            .simplifiedChinese: "已完成",
            .english: "Completed"
        ]

        translations["checkIn.partial"] = [
            .traditionalChinese: "部分完成",
            .simplifiedChinese: "部分完成",
            .english: "Partially Completed"
        ]

        translations["checkIn.missed"] = [
            .traditionalChinese: "未完成",
            .simplifiedChinese: "未完成",
            .english: "Missed"
        ]

        translations["checkIn.checkIn"] = [
            .traditionalChinese: "打卡",
            .simplifiedChinese: "打卡",
            .english: "Check-in"
        ]

        translations["checkIn.success"] = [
            .traditionalChinese: "打卡成功！",
            .simplifiedChinese: "打卡成功！",
            .english: "Check-in successful!"
        ]

        translations["checkIn.streak"] = [
            .traditionalChinese: "連續打卡",
            .simplifiedChinese: "连续打卡",
            .english: "Streak"
        ]

        translations["checkIn.days"] = [
            .traditionalChinese: "天",
            .simplifiedChinese: "天",
            .english: "days"
        ]

        translations["checkIn.calendar"] = [
            .traditionalChinese: "打卡日曆",
            .simplifiedChinese: "打卡日历",
            .english: "Check-in Calendar"
        ]

        translations["checkIn.history"] = [
            .traditionalChinese: "打卡歷史",
            .simplifiedChinese: "打卡历史",
            .english: "Check-in History"
        ]

        translations["aiCoach.title"] = [
            .traditionalChinese: "AI教練",
            .simplifiedChinese: "AI教练",
            .english: "AI Coach"
        ]

        translations["aiCoach.chatPlaceholder"] = [
            .traditionalChinese: "輸入訊息...",
            .simplifiedChinese: "输入讯息...",
            .english: "Enter message..."
        ]

        translations["aiCoach.send"] = [
            .traditionalChinese: "發送",
            .simplifiedChinese: "发送",
            .english: "Send"
        ]

        translations["aiCoach.reminder"] = [
            .traditionalChinese: "提醒",
            .simplifiedChinese: "提醒",
            .english: "Reminder"
        ]

        translations["aiCoach.weeklyReview"] = [
            .traditionalChinese: "每週復盤",
            .simplifiedChinese: "每周复盘",
            .english: "Weekly Review"
        ]

        translations["aiCoach.monthlyReview"] = [
            .traditionalChinese: "月度復盤",
            .simplifiedChinese: "月度复盘",
            .english: "Monthly Review"
        ]

        translations["aiCoach.trackDeviation"] = [
            .traditionalChinese: "軌道偏離提醒",
            .simplifiedChinese: "轨道偏离提醒",
            .english: "Track Deviation Reminder"
        ]

        translations["aiCoach.howCanIHelp"] = [
            .traditionalChinese: "我是你的AI教練，有什麼可以幫助你？",
            .simplifiedChinese: "我是你的AI教练，有什么可以帮助你？",
            .english: "I'm your AI coach, how can I help you?"
        ]

        translations["community.title"] = [
            .traditionalChinese: "AI夥伴社群",
            .simplifiedChinese: "AI伙伴社群",
            .english: "Community"
        ]

        translations["community.groups"] = [
            .traditionalChinese: "揪團列表",
            .simplifiedChinese: "揪团列表",
            .english: "Group List"
        ]

        translations["community.createGroup"] = [
            .traditionalChinese: "創建揪團",
            .simplifiedChinese: "创建揪团",
            .english: "Create Group"
        ]

        translations["community.joinGroup"] = [
            .traditionalChinese: "加入揪團",
            .simplifiedChinese: "加入揪团",
            .english: "Join Group"
        ]

        translations["community.leaveGroup"] = [
            .traditionalChinese: "離開揪團",
            .simplifiedChinese: "离开揪团",
            .english: "Leave Group"
        ]

        translations["community.leaderboard"] = [
            .traditionalChinese: "排行榜",
            .simplifiedChinese: "排行榜",
            .english: "Leaderboard"
        ]

        translations["settings.title"] = [
            .traditionalChinese: "設定",
            .simplifiedChinese: "设置",
            .english: "Settings"
        ]

        translations["settings.profile"] = [
            .traditionalChinese: "個人資料",
            .simplifiedChinese: "个人资料",
            .english: "Profile"
        ]

        translations["settings.notification"] = [
            .traditionalChinese: "通知",
            .simplifiedChinese: "通知",
            .english: "Notification"
        ]

        translations["settings.checkInReminder"] = [
            .traditionalChinese: "打卡提醒",
            .simplifiedChinese: "打卡提醒",
            .english: "Check-in Reminder"
        ]

        translations["settings.dailyReminderTime"] = [
            .traditionalChinese: "每日提醒時間",
            .simplifiedChinese: "每日提醒时间",
            .english: "Daily Reminder Time"
        ]

        translations["settings.appearance"] = [
            .traditionalChinese: "外觀",
            .simplifiedChinese: "外观",
            .english: "Appearance"
        ]

        translations["settings.themeMode"] = [
            .traditionalChinese: "主題模式",
            .simplifiedChinese: "主题模式",
            .english: "Theme Mode"
        ]

        translations["settings.dataManagement"] = [
            .traditionalChinese: "數據管理",
            .simplifiedChinese: "数据管理",
            .english: "Data Management"
        ]

        translations["settings.syncData"] = [
            .traditionalChinese: "同步數據",
            .simplifiedChinese: "同步数据",
            .english: "Sync Data"
        ]

        translations["settings.exportData"] = [
            .traditionalChinese: "導出數據",
            .simplifiedChinese: "导出数据",
            .english: "Export Data"
        ]

        translations["settings.about"] = [
            .traditionalChinese: "關於",
            .simplifiedChinese: "关于",
            .english: "About"
        ]

        translations["settings.version"] = [
            .traditionalChinese: "版本",
            .simplifiedChinese: "版本",
            .english: "Version"
        ]

        translations["settings.aboutApp"] = [
            .traditionalChinese: "關於App",
            .simplifiedChinese: "关于App",
            .english: "About App"
        ]

        translations["settings.bookCorePrinciples"] = [
            .traditionalChinese: "《規劃最好的一年》核心原則",
            .simplifiedChinese: "《规划最好的一年》核心原则",
            .english: "'Best Year Planner' Core Principles"
        ]

        translations["settings.logout"] = [
            .traditionalChinese: "登出",
            .simplifiedChinese: "登出",
            .english: "Logout"
        ]

        translations["settings.language"] = [
            .traditionalChinese: "語言",
            .simplifiedChinese: "语言",
            .english: "Language"
        ]

        translations["settings.changeLanguage"] = [
            .traditionalChinese: "切換語言",
            .simplifiedChinese: "切换语言",
            .english: "Change Language"
        ]

        translations["theme.system"] = [
            .traditionalChinese: "系統",
            .simplifiedChinese: "系统",
            .english: "System"
        ]

        translations["theme.light"] = [
            .traditionalChinese: "淺色",
            .simplifiedChinese: "浅色",
            .english: "Light"
        ]

        translations["theme.dark"] = [
            .traditionalChinese: "深色",
            .simplifiedChinese: "深色",
            .english: "Dark"
        ]

        translations["task.status.pending"] = [
            .traditionalChinese: "待開始",
            .simplifiedChinese: "待开始",
            .english: "Pending"
        ]

        translations["task.status.inProgress"] = [
            .traditionalChinese: "進行中",
            .simplifiedChinese: "进行中",
            .english: "In Progress"
        ]

        translations["task.status.completed"] = [
            .traditionalChinese: "已完成",
            .simplifiedChinese: "已完成",
            .english: "Completed"
        ]

        translations["task.status.cancelled"] = [
            .traditionalChinese: "已取消",
            .simplifiedChinese: "已取消",
            .english: "Cancelled"
        ]

        translations["dimension.career"] = [
            .traditionalChinese: "事業與財富",
            .simplifiedChinese: "事业与财富",
            .english: "Career & Wealth"
        ]

        translations["dimension.relationship"] = [
            .traditionalChinese: "人際關係",
            .simplifiedChinese: "人际关系",
            .english: "Relationships"
        ]

        translations["dimension.growth"] = [
            .traditionalChinese: "自我成長",
            .simplifiedChinese: "自我成长",
            .english: "Self Growth"
        ]

        translations["welcome.getStarted"] = [
            .traditionalChinese: "開始使用",
            .simplifiedChinese: "开始使用",
            .english: "Get Started"
        ]

        translations["empty.noGoals"] = [
            .traditionalChinese: "還沒有目標",
            .simplifiedChinese: "还没有目标",
            .english: "No Goals Yet"
        ]

        translations["empty.noGoalsDesc"] = [
            .traditionalChinese: "點擊右上角按鈕新增你的第一個目標",
            .simplifiedChinese: "点击右上角按钮新增你的第一个目标",
            .english: "Tap the button in the top right to add your first goal"
        ]

        translations["empty.noCheckIns"] = [
            .traditionalChinese: "今日無打卡記錄",
            .simplifiedChinese: "今日无打卡记录",
            .english: "No check-in records today"
        ]

        translations["empty.noMessages"] = [
            .traditionalChinese: "還沒有訊息",
            .simplifiedChinese: "还没有讯息",
            .english: "No messages yet"
        ]

        translations["loading"] = [
            .traditionalChinese: "載入中...",
            .simplifiedChinese: "载入中...",
            .english: "Loading..."
        ]
    }

    private func loadSimplifiedChinese() {
    }

    private func loadEnglish() {
    }
}

struct StringWrapper: ViewModifier {
    let key: String
    @EnvironmentObject private var localization: LocalizationManager

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func localized(_ key: String) -> some View {
        modifier(LocalizedViewModifier(key: key))
    }
}

struct LocalizedViewModifier: ViewModifier {
    let key: String
    @EnvironmentObject private var localization: LocalizationManager

    func body(content: Content) -> some View {
        Text(localization.localizedString(key))
    }
}

extension LocalizationManager {
    func t(_ key: String) -> String {
        return localizedString(key)
    }
}
