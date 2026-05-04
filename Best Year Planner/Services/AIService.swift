import Foundation

final class AIService {
    static let shared = AIService()
    
    private let urlSession: URLSession

    // MARK: - Tip Cache
    private var tipCache: [String: (tip: String, timestamp: Date)] = [:]
    private let tipCacheExpiry: TimeInterval = 3600 // 1 hour

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        urlSession = URLSession(configuration: config)
    }

    // MARK: - AI Gateway API

    private let aiGatewayBaseURL = "https://www.herelai.fun"
    private let appId = "bestyearplanner"

    /// 调用 AI Gateway API 获取 AI 回复
    func queryAIGateway(userId: String, query: String) async -> String {
        let urlString = "\(aiGatewayBaseURL)/ws/05-ai-gateway/api/query"
        print("[AIService] ====== 開始請求 ======")
        print("[AIService] Request URL: \(urlString)")
        print("[AIService] User ID: \(userId)")

        guard let url = URL(string: urlString) else {
            print("[AIService] ❌ Invalid URL: \(urlString)")
            return "抱歉，服務位址配置錯誤。"
        }

        let requestBody: [String: Any] = [
            "app_id": appId,
            "user_id": userId,
            "query_data": query
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("[AIService] ❌ Failed to serialize request body")
            return "抱歉，請求處理失敗。"
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 60

        print("[AIService] Request body: \(String(data: jsonData, encoding: .utf8) ?? "N/A")")
        print("[AIService] Timeout: 60s")

        do {
            print("[AIService] ⏳ 發送請求中...")
            let (data, response) = try await urlSession.data(for: request)
            
            print("[AIService] ✅ 收到響應")

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[AIService] ❌ Invalid response type: \(type(of: response))")
                return "抱歉，服務響應異常。"
            }

            print("[AIService] Status code: \(httpResponse.statusCode)")

            guard httpResponse.statusCode == 200 else {
                if let errorData = String(data: data, encoding: .utf8) {
                    print("[AIService] ❌ Error response body: \(errorData)")
                }
                return "抱歉，服務暫時不可用（錯誤碼: \(httpResponse.statusCode)）。"
            }

            let rawResponse = String(data: data, encoding: .utf8) ?? "N/A"
            print("[AIService] Raw response: \(rawResponse)")

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("[AIService] Parsed JSON: \(json)")
                if let aiResponse = json["response"] as? String {
                    print("[AIService] ✅ Successfully got AI response")
                    return aiResponse
                } else if let errorMsg = json["error"] as? String {
                    print("[AIService] ❌ API returned error: \(errorMsg)")
                    return "抱歉，服務返回錯誤：\(errorMsg)"
                } else {
                    print("[AIService] ⚠️ No response field found in JSON")
                    return "抱歉，服務響應格式異常。"
                }
            } else {
                print("[AIService] ❌ Failed to parse JSON response")
                return "抱歉，無法解析服務響應。"
            }
        } catch let error as URLError {
            print("[AIService] ❌ URL Error: \(error)")
            print("[AIService] Error code: \(error.code.rawValue)")
            print("[AIService] Error description: \(error.localizedDescription)")
            
            switch error.code {
            case .notConnectedToInternet:
                return "抱歉，網路連線失敗。請檢查您的網路連線。"
            case .timedOut:
                return "抱歉，連線超時。請稍後再試。"
            case .cannotConnectToHost:
                return "抱歉，無法連接到服務器。"
            case .cannotFindHost:
                return "抱歉，找不到服務器。"
            case .badServerResponse:
                return "抱歉，服務器響應異常。"
            case .secureConnectionFailed:
                return "抱歉，安全連接失敗。可能是證書問題。"
            case .serverCertificateHasBadDate:
                return "抱歉，服務器證書過期。"
            case .serverCertificateUntrusted:
                return "抱歉，服務器證書不受信任。"
            default:
                return "抱歉，網路連線失敗（錯誤碼: \(error.code.rawValue)）。"
            }
        } catch {
            print("[AIService] ❌ Unknown error: \(error)")
            return "抱歉，發生未知錯誤：\(error.localizedDescription)"
        }
    }

    /// AI 教练：获取个性化欢迎消息
    func getCoachWelcomeMessage(userId: String, userData: [String: Any]) async -> String {
        let welcomeQuery = "請給我一句溫暖的歡迎消息，提及我最近的一個小成就來鼓勵我"
        return await queryAIGateway(userId: userId, query: welcomeQuery)
    }

    /// AI 伙伴：获取个性化欢迎消息
    func getPartnerWelcomeMessage(userId: String, partnerName: String, userData: [String: Any]) async -> String {
        let welcomeQuery = "作為我的夥伴，請給我一句溫暖的歡迎消息，分享你自己的經驗來鼓勵我"
        return await queryAIGateway(userId: userId, query: welcomeQuery)
    }

    /// AI 教练：回复用户问题
    func getCoachResponse(userId: String, query: String, conversationHistory: [AIMessage] = []) async -> String {
        // 添加角色提示
        let coachPrompt = "你是一位專業的AI教練，根據《規劃最好的一年》原則，幫助用戶設定目標、追蹤進度、克服拖延。請以教練的身份回答以下問題：\(query)"
        return await queryAIGateway(userId: userId, query: coachPrompt)
    }

    /// AI 伙伴：回复用户问题
    func getPartnerResponse(userId: String, query: String, partnerName: String, conversationHistory: [AIMessage] = []) async -> String {
        // 添加角色提示
        let partnerPrompt = "你是用戶的AI夥伴\(partnerName)，以夥伴的身份陪伴用戶成長，分享經驗來支持用戶。請回答：\(query)"
        return await queryAIGateway(userId: userId, query: partnerPrompt)
    }

    // MARK: - 原有功能保留

    func generateGoalsFromQuestionnaire(answers: [QuestionnaireAnswer]) -> [Goal] {
        var goals: [Goal] = []

        let careerAnswers = answers.filter { $0.dimension == .career }
        if let mainCareerAnswer = careerAnswers.first {
            let careerGoal = Goal(
                title: generateCareerGoalTitle(from: mainCareerAnswer.answer),
                description: "基於你的現況生成的事業/財富年度目標",
                dimension: .career,
                level: .yearly,
                priority: .high
            )
            goals.append(careerGoal)
        }

        let relationshipAnswers = answers.filter { $0.dimension == .relationship }
        if let mainRelationshipAnswer = relationshipAnswers.first {
            let relationshipGoal = Goal(
                title: generateRelationshipGoalTitle(from: mainRelationshipAnswer.answer),
                description: "基於你的現況生成的人際關係年度目標",
                dimension: .relationship,
                level: .yearly,
                priority: .high
            )
            goals.append(relationshipGoal)
        }

        let growthAnswers = answers.filter { $0.dimension == .growth }
        if let mainGrowthAnswer = growthAnswers.first {
            let growthGoal = Goal(
                title: generateGrowthGoalTitle(from: mainGrowthAnswer.answer),
                description: "基於你的現況生成的自我成長年度目標",
                dimension: .growth,
                level: .yearly,
                priority: .high
            )
            goals.append(growthGoal)
        }

        return goals
    }

    func generateDirectionalSuggestions(from answers: [QuestionnaireAnswer]) -> [DirectionalSuggestion] {
        var suggestions: [DirectionalSuggestion] = []

        let careerAnswers = answers.filter { $0.dimension == .career }
        if let mainCareerAnswer = careerAnswers.first {
            let suggestion = generateCareerSuggestion(from: mainCareerAnswer.answer, allAnswers: careerAnswers)
            suggestions.append(suggestion)
        }

        let relationshipAnswers = answers.filter { $0.dimension == .relationship }
        if let mainRelationshipAnswer = relationshipAnswers.first {
            let suggestion = generateRelationshipSuggestion(from: mainRelationshipAnswer.answer, allAnswers: relationshipAnswers)
            suggestions.append(suggestion)
        }

        let growthAnswers = answers.filter { $0.dimension == .growth }
        if let mainGrowthAnswer = growthAnswers.first {
            let suggestion = generateGrowthSuggestion(from: mainGrowthAnswer.answer, allAnswers: growthAnswers)
            suggestions.append(suggestion)
        }

        return suggestions
    }

    private func generateCareerSuggestion(from answer: String, allAnswers: [QuestionnaireAnswer]) -> DirectionalSuggestion {
        let dimension = GoalDimension.career
        var title = "事業成長方向"
        var description = "根據你的回答，這是你事業發展的建議方向"
        var actionSteps: [String] = []
        var inspiringQuote = ""

        if answer.contains("創業") {
            title = "創業夢想啟航"
            description = "你心中有一個創業的夢想，這是實現自我價值的最高形式"
            actionSteps = [
                "釐清你的創業目標和核心價值",
                "研究市場需求和潛在客戶",
                "制定最小可行性產品計劃",
                "建立早期支持者社群"
            ]
            inspiringQuote = "每一個偉大的企業，都始於一個勇敢的夢想"
        } else if answer.contains("晋升") || answer.contains("加薪") {
            title = "職場晋升之路"
            description = "你渴望在職場上獲得認可和晉升，這是專業能力的證明"
            actionSteps = [
                "識別晋升所需的關鍵技能",
                "主動爭取更具挑戰性的項目",
                "建立良好的職場關係網絡",
                "持續展現你的專業價值"
            ]
            inspiringQuote = "機會永遠留給準備好的人"
        } else if answer.contains("技能") {
            title = "技能精進之路"
            description = "你選擇通過學習來提升自己，這是最有價值的投資"
            actionSteps = [
                "確定最值得投資的核心技能",
                "制定每日學習計劃",
                "尋找導師或學習社群",
                "實際應用所學技能"
            ]
            inspiringQuote = "投資自己，是回報率最高的投資"
        } else if answer.contains("轉行") {
            title = "職涯轉型之路"
            description = "你勇於突破現狀，選擇一條更適合自己的道路"
            actionSteps = [
                "深入了解目標行業的要求",
                "評估需要補充的能力缺口",
                "建立新行業的人脈關係",
                "从小目標開始逐步過渡"
            ]
            inspiringQuote = "改變永遠不會太晚，只要你願意邁出第一步"
        } else if answer.contains("平衡") {
            title = "工作生活平衡"
            description = "你重視生活的平衡，這是可持續發展的關鍵"
            actionSteps = [
                "設定清晰的工作時間界限",
                "學會拒絕過多的工作要求",
                "培養工作之外的興趣愛好",
                "定期安排休閒和放鬆時間"
            ]
            inspiringQuote = "成功不只是事業有成，而是生活各方面都充实美滿"
        } else {
            actionSteps = [
                "設定清晰的職業發展目標",
                "持續學習和提升專業能力",
                "建立有意義的職場關係"
            ]
            inspiringQuote = "最好的職業規劃，是將熱情轉化為使命"
        }

        return DirectionalSuggestion(
            dimension: dimension,
            title: title,
            description: description,
            actionSteps: actionSteps,
            inspiringQuote: inspiringQuote
        )
    }

    private func generateRelationshipSuggestion(from answer: String, allAnswers: [QuestionnaireAnswer]) -> DirectionalSuggestion {
        let dimension = GoalDimension.relationship
        var title = "人際關係成長方向"
        var description = "根據你的回答，這是你人際關係改善的建議方向"
        var actionSteps: [String] = []
        var inspiringQuote = ""

        if answer.contains("家庭") {
            title = "家庭連結重建"
            description = "家是我們最堅強的後盾，經營好家庭關係是幸福的基礎"
            actionSteps = [
                "安排固定的家人相處時間",
                "主動傾聽家人的想法和感受",
                "表達感謝和愛意",
                "解決長期累積的誤解"
            ]
            inspiringQuote = "家人之間，愛要說出口，感謝要表達"
        } else if answer.contains("伴侶") || answer.contains("戀愛") || answer.contains("已婚") {
            title = "伴侶關係深化"
            description = "一段好的感情需要雙方共同經營，持續投資在關係上"
            actionSteps = [
                "安排定期的伴侶相處時間",
                "學習有效的溝通方式",
                "共同設定未來目標",
                "保持浪漫和驚喜"
            ]
            inspiringQuote = "愛情不是一個結果，而是一段持續成長的旅程"
        } else if answer.contains("朋友") {
            title = "友誼網絡拓展"
            description = "朋友是選擇的家人，優質的友誼需要時間和心力培養"
            actionSteps = [
                "主動聯繫老朋友",
                "參與社交活動認識新朋友",
                "成為值得信賴的朋友",
                "學會平衡社交和獨處"
            ]
            inspiringQuote = "朋友的價值，在於彼此生命中的相互扶持"
        } else if answer.contains("職場") || answer.contains("人脈") {
            title = "職場人脈經營"
            description = "在職場中建立良好的人際關係，有助於事業發展"
            actionSteps = [
                "積極參與團隊活動",
                "主動幫助同事",
                "維護重要的職場關係",
                "學會有效的職場溝通"
            ]
            inspiringQuote = "一個人能走多遠，取決於與誰同行"
        } else {
            actionSteps = [
                "提升溝通和傾聽能力",
                "主動關心朋友和家人",
                "學會處理人際衝突",
                "建立健康的界線"
            ]
            inspiringQuote = "人際關係的質量，決定生命的質量"
        }

        return DirectionalSuggestion(
            dimension: dimension,
            title: title,
            description: description,
            actionSteps: actionSteps,
            inspiringQuote: inspiringQuote
        )
    }

    private func generateGrowthSuggestion(from answer: String, allAnswers: [QuestionnaireAnswer]) -> DirectionalSuggestion {
        let dimension = GoalDimension.growth
        var title = "自我成長方向"
        var description = "根據你的回答，這是你個人成長的建議方向"
        var actionSteps: [String] = []
        var inspiringQuote = ""

        if answer.contains("健康") || answer.contains("運動") {
            title = "健康生活養成"
            description = "健康是所有成就的基礎，投資健康就是投資未來"
            actionSteps = [
                "設定每週運動目標",
                "改善飲食習慣",
                "保證充足睡眠",
                "定期健康檢查"
            ]
            inspiringQuote = "健康的身體，是你追夢的最大資本"
        } else if answer.contains("閱讀") || answer.contains("學習") {
            title = "終身學習實踐"
            description = "閱讀和學習是成長的最快途徑，保持好奇心讓生命年輕"
            actionSteps = [
                "設定每年閱讀目標",
                "培養每日閱讀習慣",
                "寫下讀書心得",
                "與他人分享所學"
            ]
            inspiringQuote = "書籍是人類進步的階梯，閱讀讓靈魂豐富"
        } else if answer.contains("心靈") || answer.contains("情緒") {
            title = "內在心靈修養"
            description = "外在的成功源於內在的平靜，修養心靈是最高的智慧"
            actionSteps = [
                "練習冥想或靜心",
                "培養感恩的心態",
                "學會情緒管理",
                "尋找生命的意義和使命"
            ]
            inspiringQuote = "外在的富有，不如內心的平靜"
        } else if answer.contains("興趣") || answer.contains("培養") {
            title = "興趣愛好發展"
            description = "培養興趣愛好可以豐富生活，帶來更多樂趣和滿足感"
            actionSteps = [
                "探索新的興趣領域",
                "每天安排時間做自己喜歡的事",
                "找到可以堅持的愛好",
                "通過興趣認識同好"
            ]
            inspiringQuote = "生活不只有工作，還有詩和遠方"
        } else {
            actionSteps = [
                "設定個人成長目標",
                "培養新的習慣",
                "挑戰舒適區",
                "定期自我反思"
            ]
            inspiringQuote = "成長的痛苦，比後悔的痛苦要好"
        }

        return DirectionalSuggestion(
            dimension: dimension,
            title: title,
            description: description,
            actionSteps: actionSteps,
            inspiringQuote: inspiringQuote
        )
    }

    private func generateCareerGoalTitle(from answer: String) -> String {
        if answer.contains("創業") {
            return "建立並發展自己的事業"
        } else if answer.contains("加薪") || answer.contains("晋升") {
            return "提升收入達到目標水平"
        } else if answer.contains("升職") {
            return "在職場上獲得晋升機會"
        } else if answer.contains("技能") {
            return "掌握關鍵專業技能"
        } else if answer.contains("轉行") {
            return "順利轉換到理想職業"
        }
        return "事業發展與財富增长"
    }

    private func generateRelationshipGoalTitle(from answer: String) -> String {
        if answer.contains("家庭") {
            return "增進家庭成員間的情感連結"
        } else if answer.contains("伴侶") || answer.contains("戀愛") {
            return "建立更深入的情感關係"
        } else if answer.contains("朋友") {
            return "擴展並深化友誼關係"
        } else if answer.contains("職場") || answer.contains("人脈") {
            return "建立有價值的職場人脈網絡"
        }
        return "建立和諧的人際關係網絡"
    }

    private func generateGrowthGoalTitle(from answer: String) -> String {
        if answer.contains("健康") {
            return "養成健康的生活習慣"
        } else if answer.contains("閱讀") {
            return "建立持續學習的習慣"
        } else if answer.contains("心靈") {
            return "提升心靈修養與內在平靜"
        } else if answer.contains("情緒") {
            return "提升情緒管理能力"
        }
        return "全面提升自我，成為更好的自己"
    }

    func generateTasksFromGoal(_ goal: Goal) -> [Task] {
        var tasks: [Task] = []

        let quarterlyTask1 = Task(
            goalId: goal.id,
            title: "制定\(Date().adding(months: 3).formatted("yyyy年QQQ"))季度計劃",
            description: "將年度目標細化為季度里程碑",
            priority: .high,
            deadline: Date().adding(months: 3)
        )
        tasks.append(quarterlyTask1)

        let quarterlyTask2 = Task(
            goalId: goal.id,
            title: "制定\(Date().adding(months: 6).formatted("yyyy年QQQ"))季度計劃",
            description: "持續追蹤並調整目標方向",
            priority: .medium,
            deadline: Date().adding(months: 6)
        )
        tasks.append(quarterlyTask2)

        let monthlyTask = Task(
            goalId: goal.id,
            title: "制定月度行動計劃",
            description: "設定每月具體任務與時間表",
            priority: .high,
            deadline: Date().adding(months: 1)
        )
        tasks.append(monthlyTask)

        let weeklyTask = Task(
            goalId: goal.id,
            title: "每週回顧與計劃",
            description: "每週日進行目標進度回顧",
            priority: .medium
        )
        tasks.append(weeklyTask)

        return tasks
    }

    func generateWeeklyReviewSummary(checkIns: [CheckIn], tasks: [Task]) -> String {
        let completedTasks = tasks.filter { $0.status == .completed }.count
        let totalTasks = tasks.count
        let completionRate = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) * 100 : 0

        let completedCheckIns = checkIns.filter { $0.status == .completed }.count
        let longestStreak = checkIns.map { $0.streakDay }.max() ?? 0

        var summary = "本週你完成了 \(completedTasks) 個任務，完成率達到 \(String(format: "%.0f", completionRate))%。"
        summary += " 總共打卡 \(completedCheckIns) 次，最長連續打卡 \(longestStreak) 天。"

        if completionRate >= 80 {
            summary += " 表現非常出色！"
        } else if completionRate >= 60 {
            summary += " 做得不錯，還有進步空間。"
        } else {
            summary += " 需要調整計劃或增加動力。"
        }

        return summary
    }

    func generateAISuggestion(forType type: ReviewType, data: [String: Any]) -> String {
        switch type {
        case .weekly:
            return generateWeeklySuggestions(data: data)
        case .monthly:
            return generateMonthlySuggestions(data: data)
        case .yearly:
            return generateYearlySuggestions(data: data)
        }
    }

    private func generateWeeklySuggestions(data: [String: Any]) -> String {
        guard let completionRate = data["completionRate"] as? Double else {
            return "建議你設定更具體的每週小目標，這樣更容易堅持下去。"
        }

        if completionRate < 0.5 {
            return "這週的進度有些落後，建議你將大型任務拆分為更小的每日行動，並設定固定時間專注執行。"
        } else if completionRate < 0.8 {
            return "還有進步空間！試著找出影響效率的原因，可能是時間管理或任務優先級設定需要調整。"
        } else {
            return "這週執行得很順利！建議你保持這個節奏，並考慮適度挑戰自己，設定更高一點的目標。"
        }
    }

    private func generateMonthlySuggestions(data: [String: Any]) -> String {
        guard let monthProgress = data["monthProgress"] as? Double else {
            return "建議你回顧這個月的目標設定是否合理，並為下月做更精準的規劃。"
        }

        if monthProgress < 0.5 {
            return "這個月的進度低於預期，建議重新評估目標難度，確保設定的目標既有挑戰性又可實現。"
        } else if monthProgress < 0.8 {
            return "這月進度不錯！建議持續追蹤並記錄哪些策略有效，哪些需要改進。"
        } else {
            return "這月表現優異！建議總結成功經驗，並將有效的方法複製到下個月的規劃中。"
        }
    }

    private func generateYearlySuggestions(data: [String: Any]) -> String {
        return "年度復盤是迭代改進的關鍵。建議你詳細記錄今年的成就與不足，並將學到的經驗應用到下一年規劃中。記住《規劃最好的一年》的核心：目標要具體、執行要持續、复盘要定期。"
    }

    func generateCoachMessage(forSituation situation: String, userData: [String: Any]) -> String {
        switch situation {
        case "trackDeviation":
            guard let missedDays = userData["missedDays"] as? Int else {
                return "我注意到你的進度有些落後了。不用擔心，讓我們一起找出原因並調整計劃。"
            }
            return "你已經連續 \(missedDays) 天沒有打卡了。這是完全正常的！讓我們重新調整目標和節奏，確保計劃切實可行。"

        case "streakMaintenance":
            guard let streak = userData["streak"] as? Int else {
                return "保持這個勢頭！你做得很好。"
            }
            if streak >= 7 {
                return "太棒了！你已經連續打卡 \(streak) 天了。這種持續性正是成功習慣的關鍵。建議設定下一個里程碑來維持動力！"
            } else {
                return "你已經連續打卡 \(streak) 天了！保持這個好習慣，每天進步一點點。"
            }

        case "goalCompleted":
            return "恭喜你完成了一個目標！這證明你的努力正在產生結果。現在讓我們設定下一個挑戰，或者鞏固剛剛建立的習慣。"

        default:
            return "有什麼我可以幫助你的嗎？無論是目標設定、克服拖延還是時間管理，我都在這裡支持你。"
        }
    }

    func generateCommunityEncouragement(memberData: [String: Any]) -> String {
        guard let nickname = memberData["nickname"] as? String,
              let streak = memberData["streak"] as? Int else {
            return "今天也要加油喔！"
        }

        if streak >= 7 {
            return "\(nickname) 已經連續打卡 \(streak) 天了！簡直太厲害了！大家快來學習一下吧！💪"
        } else if streak >= 3 {
            return "\(nickname) 連續打卡 \(streak) 天了！保持這個勢頭！🔥"
        } else {
            return "歡迎 \(nickname) 加入我們的行列！每天進步一點點，你也可以做到的！🌟"
        }
    }

    // MARK: - Challenge Generation

    /// Generate a 7-day launch plan based on user's 3 answers
    func generateSevenDayLaunchPlan(answers: [String], userId: String) async -> SevenDayLaunchPlan? {
        let prompt = """
        你是一位專業的習慣養成教練，精通《原子習慣》和《規劃最好的一年》方法論。

        用戶回答了三個問題：
        1. 今年最想提升的是：\(answers.count > 0 ? answers[0] : "成為更好的自己")
        2. 願意從小事開始：\(answers.count > 1 ? answers[1] : "每天進步一點點")
        3. 一年後想成為：\(answers.count > 2 ? answers[2] : "更有自信的人")

        請根據以上回答，設計一個7天啟動計畫。

        核心原則：
        - 每天只需5分鐘，降低啟動阻力
        - 任務必須具體可行（如「寫下3個你想改變的原因」，而非「思考改變」）
        - 漸進式：前2天認知覺察 → 中間3天小行動 → 最後2天建立錨點
        - 每個tip用一句話給予鼓勵或洞見
        - 標題要有感染力，讓用戶一看就想做

        請嚴格按JSON格式返回，不要包含其他文字：
        {"title":"計畫標題","tasks":[{"day":1,"title":"任務標題","description":"任務描述","tip":"AI小建議"}]}
        """

        let response = await queryAIGateway(userId: userId, query: prompt)
        return parseLaunchPlanFromResponse(response)
    }

    /// Generate a 21-day challenge based on completed 7-day launch
    func generateTwentyOneDayChallenge(goalId: String, completedLaunch: Challenge, userId: String) async -> [DailyChallengeTask]? {
        let completedTasks = completedLaunch.dailyTasks.map { "第\($0.dayNumber)天: \($0.title) - \($0.isCompleted ? "✅" : "❌")" }.joined(separator: "\n")

        let prompt = """
        你是一位專業的習慣養成教練。用戶已成功完成7天啟動，現在要進入21天習慣養成階段。

        7天啟動完成情況：
        \(completedTasks)

        請設計21天習慣養成計畫，遵循以下原則：
        - 3個7天循環，每個循環有明確主題：
          第1週（Day 1-7）：建立基礎 — 固定行動時間和觸發信號
          第2週（Day 8-14）：深化習慣 — 增加難度和深度
          第3週（Day 15-21）：內化整合 — 習慣成為自然
        - 時間遞增：5分鐘 → 10分鐘 → 15分鐘
        - 每週第7天設為「反思日」而非行動日
        - 任務具體可行，避免模糊指令
        - tip要結合《規劃最好的一年》理念給予鼓勵

        請嚴格按JSON格式返回，不要包含其他文字：
        {"title":"計畫標題","tasks":[{"day":1,"title":"任務標題","description":"任務描述","tip":"AI小建議"}]}
        """

        let response = await queryAIGateway(userId: userId, query: prompt)
        return parseChallengeTasksFromResponse(response, challengeId: goalId)
    }

    /// Generate a daily AI tip for a specific challenge day
    func generateDailyTip(challengeId: String, dayNumber: Int, previousDays: [DailyChallengeTask], userId: String) async -> String {
        let cacheKey = "\(challengeId)_\(dayNumber)"
        if let cached = tipCache[cacheKey], Date().timeIntervalSince(cached.timestamp) < tipCacheExpiry {
            return cached.tip
        }

        let completedCount = previousDays.filter { $0.isCompleted }.count
        let prompt = "用戶正在進行\(dayNumber <= 7 ? "7天啟動" : "21天挑戰")第\(dayNumber)天，已連續完成\(completedCount)天。請給一句簡短鼓勵（20字以內），幫助用戶堅持下去。"
        let tip = await queryAIGateway(userId: userId, query: prompt)

        tipCache[cacheKey] = (tip: tip, timestamp: Date())
        return tip
    }

    // MARK: - JSON Parsing Helpers

    private func parseLaunchPlanFromResponse(_ response: String) -> SevenDayLaunchPlan? {
        var jsonString = extractJSON(from: response)

        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let title = json["title"] as? String,
              let tasksArray = json["tasks"] as? [[String: Any]] else {
            return nil
        }

        var tasks: [DailyChallengeTask] = []
        for taskDict in tasksArray {
            let day = taskDict["day"] as? Int ?? (tasks.count + 1)
            let title = taskDict["title"] as? String ?? "第\(day)天任務"
            let desc = taskDict["description"] as? String ?? ""
            let tip = taskDict["tip"] as? String

            tasks.append(DailyChallengeTask(
                dayNumber: day,
                title: title,
                description: desc,
                estimatedMinutes: AppConstants.Challenge.defaultTaskMinutes,
                aiTip: tip
            ))
        }

        return SevenDayLaunchPlan(title: title, tasks: tasks)
    }

    private func parseChallengeTasksFromResponse(_ response: String, challengeId: String) -> [DailyChallengeTask]? {
        var jsonString = extractJSON(from: response)

        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let tasksArray = json["tasks"] as? [[String: Any]] else {
            return nil
        }

        var tasks: [DailyChallengeTask] = []
        for taskDict in tasksArray {
            let day = taskDict["day"] as? Int ?? (tasks.count + 1)
            let title = taskDict["title"] as? String ?? "第\(day)天任務"
            let desc = taskDict["description"] as? String ?? ""
            let tip = taskDict["tip"] as? String

            tasks.append(DailyChallengeTask(
                challengeId: challengeId,
                dayNumber: day,
                title: title,
                description: desc,
                estimatedMinutes: min(5 + (day / 3) * 2, 15),
                aiTip: tip
            ))
        }

        return tasks
    }

    private func extractJSON(from response: String) -> String {
        var jsonString = response

        // Try to extract JSON from markdown code block
        if let range = response.range(of: "```json") {
            let start = response.index(range.upperBound, offsetBy: 0)
            if let endRange = response[start...].range(of: "```") {
                jsonString = String(response[start..<endRange.lowerBound])
            }
        } else if let range = response.range(of: "```") {
            let start = response.index(range.upperBound, offsetBy: 0)
            if let endRange = response[start...].range(of: "```") {
                jsonString = String(response[start..<endRange.lowerBound])
            }
        }

        return jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


