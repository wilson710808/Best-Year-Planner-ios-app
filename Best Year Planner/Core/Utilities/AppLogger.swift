import Foundation
import os

/// 統一日誌系統 — 使用 OSLog 替代 print()
enum AppLogger {
    // MARK: - Category Definitions
    private static let app = "BestYearPlanner"

    static let auth     = Logger(subsystem: app, category: "Auth")
    static let database = Logger(subsystem: app, category: "Database")
    static let ai       = Logger(subsystem: app, category: "AI")
    static let network  = Logger(subsystem: app, category: "Network")
    static let widget   = Logger(subsystem: app, category: "Widget")
    static let checkout = Logger(subsystem: app, category: "CheckIn")
    static let community = Logger(subsystem: app, category: "Community")
    static let review   = Logger(subsystem: app, category: "Review")
    static let subscription = Logger(subsystem: app, category: "Subscription")
    static let ui       = Logger(subsystem: app, category: "UI")

    // MARK: - Convenience Methods

    /// 記錄重要業務事件（默認 info 級別）
    static func log(_ message: String, category: Logger = .default, level: LogLevel = .info) {
        switch level {
        case .debug:
            category.debug("📋 \(message, privacy: .auto)")
        case .info:
            category.info("ℹ️ \(message, privacy: .auto)")
        case .warning:
            category.warning("⚠️ \(message, privacy: .auto)")
        case .error:
            category.error("❌ \(message, privacy: .auto)")
        case .critical:
            category.critical("🚨 \(message, privacy: .auto)")
        }
    }

    enum LogLevel {
        case debug, info, warning, error, critical
    }
}
