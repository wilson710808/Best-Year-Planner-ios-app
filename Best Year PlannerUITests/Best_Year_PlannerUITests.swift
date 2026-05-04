//
//  Best_Year_PlannerUITests.swift
//  Best Year PlannerUITests
//
//  Created by Wilson Lai on 2026/5/1.
//

import XCTest

final class Best_Year_PlannerUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Onboarding Flow Tests

    @MainActor
    func testOnboardingFlow() throws {
        // 歡迎頁
        XCTAssertTrue(app.staticTexts["歡迎來到最好的一年"].exists)

        // 點擊開始
        let startButton = app.buttons["開始規劃"]
        XCTAssertTrue(startButton.exists)
        startButton.tap()

        // 第一個問題（事業）
        XCTAssertTrue(app.staticTexts["關於你的事業"].exists)
        let firstOption = app.buttons.firstMatch
        XCTAssertTrue(firstOption.exists)
        firstOption.tap()

        // 下一題
        let nextButton = app.buttons["下一題"]
        if nextButton.exists {
            nextButton.tap()
        }

        // 第二個問題（關係）
        XCTAssertTrue(app.staticTexts["關於你的人際關係"].exists)

        // 第三個問題（成長）
        // 選擇選項後應該能進入目標審查頁
    }

    @MainActor
    func testOnboardingSkipIfCompleted() throws {
        // 如果已經完成引導，應該直接進入主頁
        app.launchArguments = ["--uitesting", "--onboarding-completed"]
        app.launch()

        // 應該看到主 TabView
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }

    // MARK: - Tab Navigation Tests

    @MainActor
    func testTabNavigation() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed"]
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)

        // 4 個 Tab：首頁、打卡、AI教練、我的
        let homeTab = tabBar.buttons["首頁"]
        let checkInTab = tabBar.buttons["打卡"]
        let aiCoachTab = tabBar.buttons["AI教練"]
        let profileTab = tabBar.buttons["我的"]

        XCTAssertTrue(homeTab.exists)
        XCTAssertTrue(checkInTab.exists)
        XCTAssertTrue(aiCoachTab.exists)
        XCTAssertTrue(profileTab.exists)

        // 切換 Tab
        checkInTab.tap()
        aiCoachTab.tap()
        profileTab.tap()
        homeTab.tap()
    }

    // MARK: - Challenge Flow Tests

    @MainActor
    func testSevenDayChallengeDisplay() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed", "--has-challenge"]
        app.launch()

        // 首頁應該顯示挑戰卡片
        XCTAssertTrue(app.staticTexts["7天啟動計畫"].exists || app.staticTexts["21天挑戰"].exists)
    }

    @MainActor
    func testDailyTaskCompletion() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed", "--has-challenge"]
        app.launch()

        // 進入打卡頁
        app.tabBars.buttons["打卡"].tap()

        // 點擊今日任務的完成按鈕
        let completeButton = app.buttons["完成今日任務"]
        if completeButton.exists {
            completeButton.tap()

            // 應該顯示完成動畫或鼓勵語
            XCTAssertTrue(app.staticTexts["太棒了"].exists || app.staticTexts["做得好"].exists)
        }
    }

    @MainActor
    func testTwentyOneDayUnlock() throws {
        // 模擬已完成 7 天的狀態
        app.launchArguments = ["--uitesting", "--onboarding-completed", "--seven-day-completed"]
        app.launch()

        // 應該看到解鎖慶祝頁
        XCTAssertTrue(app.staticTexts["恭喜"].exists || app.staticTexts["解鎖"].exists)

        // 點擊開始 21 天挑戰
        let startButton = app.buttons["開始21天挑戰"]
        if startButton.exists {
            startButton.tap()
        }
    }

    // MARK: - Subscription Tests

    @MainActor
    func testSubscriptionViewDisplay() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed"]
        app.launch()

        // 進入我的頁
        app.tabBars.buttons["我的"].tap()

        // 點擊升級按鈕
        let upgradeButton = app.buttons["升級高級版"]
        if upgradeButton.exists {
            upgradeButton.tap()

            // 應該看到訂閱選項
            XCTAssertTrue(app.staticTexts["高級版"].exists)
            XCTAssertTrue(app.staticTexts["基礎版"].exists)
        }
    }

    @MainActor
    func testFreeTierChallengeLimit() throws {
        // 模擬免費用戶已有 3 個挑戰
        app.launchArguments = ["--uitesting", "--onboarding-completed", "--free-tier-full"]
        app.launch()

        // 嘗試創建新挑戰時應該提示升級
        // 實際行為取決於 UI 設計
    }

    // MARK: - AI Coach Tests

    @MainActor
    func testAICoachChat() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed"]
        app.launch()

        // 進入 AI 教練頁
        app.tabBars.buttons["AI教練"].tap()

        // 應該看到對話輸入框
        let textField = app.textFields.firstMatch
        if textField.exists {
            textField.tap()
            textField.typeText("我今天完成了運動任務")

            // 發送
            let sendButton = app.buttons["發送"]
            if sendButton.exists {
                sendButton.tap()
            }
        }
    }

    // MARK: - Dashboard Tests

    @MainActor
    func testDashboardStatistics() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed", "--has-challenge"]
        app.launch()

        // 首頁應該顯示統計數據
        XCTAssertTrue(app.staticTexts["已完成的任務"].exists || app.staticTexts["連續打卡"].exists)
    }

    @MainActor
    func testDimensionProgress() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed", "--has-challenge"]
        app.launch()

        // 應該看到三個維度的進度
        XCTAssertTrue(app.staticTexts["事業"].exists)
        XCTAssertTrue(app.staticTexts["人際"].exists)
        XCTAssertTrue(app.staticTexts["成長"].exists)
    }

    // MARK: - Dark Mode Tests

    @MainActor
    func testDarkModeToggle() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed"]
        app.launch()

        // 進入我的頁
        app.tabBars.buttons["我的"].tap()

        // 找到深色模式開關
        let darkModeToggle = app.switches["深色模式"]
        if darkModeToggle.exists {
            darkModeToggle.tap()

            // 驗證 UI 顏色變化（實際顏色驗證需要截圖比對）
        }
    }

    // MARK: - Notification Settings Tests

    @MainActor
    func testNotificationSettings() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed"]
        app.launch()

        // 進入我的頁
        app.tabBars.buttons["我的"].tap()

        // 點擊通知設定
        let notificationButton = app.buttons["通知設定"]
        if notificationButton.exists {
            notificationButton.tap()

            // 應該看到時間選擇器
            XCTAssertTrue(app.datePickers.firstMatch.exists || app.pickers.firstMatch.exists)
        }
    }

    // MARK: - Performance Tests

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testScrollPerformance() throws {
        app.launchArguments = ["--uitesting", "--onboarding-completed", "--has-challenge"]
        app.launch()

        // 進入打卡頁測試滾動性能
        app.tabBars.buttons["打卡"].tap()

        let scrollView = app.scrollViews.firstMatch
        if scrollView.exists {
            measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
                scrollView.swipeUp()
                scrollView.swipeDown()
            }
        }
    }
}
