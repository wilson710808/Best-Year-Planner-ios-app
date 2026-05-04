import Foundation
import SwiftUI
import Combine

protocol AppModule: Identifiable {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    var isEnabled: Bool { get set }
    var order: Int { get }

    func configure()
    func enable()
    func disable()
}

final class ModuleManager: ObservableObject {
    static let shared = ModuleManager()
    
    let objectWillChange = ObservableObjectPublisher()
    private var _modules: [String: any AppModule] = [:]
    private let userDefaults = UserDefaultsManager.shared

    private init() {
        registerDefaultModules()
    }

    private func registerDefaultModules() {
        let home = HomeModule()
        let checkIn = CheckInModule()
        let aiCoach = AICoachModule()
        let settings = SettingsModule()

        _modules[home.id] = home
        _modules[checkIn.id] = checkIn
        _modules[aiCoach.id] = aiCoach
        _modules[settings.id] = settings

        for (id, _) in _modules {
            loadModuleState(id)
        }
    }

    func registerModule(_ module: any AppModule) {
        _modules[module.id] = module
        loadModuleState(module.id)
        objectWillChange.send()
    }

    func unregisterModule(_ moduleId: String) {
        _modules.removeValue(forKey: moduleId)
        objectWillChange.send()
    }

    func getModule(_ moduleId: String) -> (any AppModule)? {
        return _modules[moduleId]
    }

    func getAllModules() -> [any AppModule] {
        return Array(_modules.values).sorted { $0.order < $1.order }
    }

    func getEnabledModules() -> [any AppModule] {
        return getAllModules().filter { $0.isEnabled }
    }

    func enableModule(_ moduleId: String) {
        guard let module = _modules[moduleId] else { return }
        module.enable()
        saveModuleState(moduleId, isEnabled: true)
        objectWillChange.send()
    }

    func disableModule(_ moduleId: String) {
        guard let module = _modules[moduleId] else { return }
        module.disable()
        saveModuleState(moduleId, isEnabled: false)
        objectWillChange.send()
    }

    func toggleModule(_ moduleId: String) {
        guard let module = _modules[moduleId] else { return }
        if module.isEnabled {
            disableModule(moduleId)
        } else {
            enableModule(moduleId)
        }
    }

    private func saveModuleState(_ moduleId: String, isEnabled: Bool) {
        let key = "module_\(moduleId)_enabled"
        UserDefaults.standard.set(isEnabled, forKey: key)
    }

    private func loadModuleState(_ moduleId: String) {
        let key = "module_\(moduleId)_enabled"
        if UserDefaults.standard.object(forKey: key) != nil {
            let isEnabled = UserDefaults.standard.bool(forKey: key)
            _modules[moduleId]?.isEnabled = isEnabled
        }
    }
}

class HomeModule: AppModule {
    let id = "home"
    var name = "首頁"
    var icon = "house.fill"
    var isEnabled: Bool = true
    let order = 0

    func configure() {}
    func enable() { isEnabled = true }
    func disable() { isEnabled = false }
}

class CheckInModule: AppModule {
    let id = "checkin"
    var name = "打卡"
    var icon = "checkmark.circle.fill"
    var isEnabled: Bool = true
    let order = 1

    func configure() {}
    func enable() { isEnabled = true }
    func disable() { isEnabled = false }
}

class AICoachModule: AppModule {
    let id = "aicoach"
    var name = "AI教練"
    var icon = "bubble.left.and.bubble.right.fill"
    var isEnabled: Bool = true
    let order = 2

    func configure() {}
    func enable() { isEnabled = true }
    func disable() { isEnabled = false }
}

class SettingsModule: AppModule {
    let id = "settings"
    var name = "我的"
    var icon = "person.fill"
    var isEnabled: Bool = true
    let order = 3

    func configure() {}
    func enable() { isEnabled = true }
    func disable() { isEnabled = false }
}

struct ModuleSettingsView: View {
    @ObservedObject private var moduleManager = ModuleManager.shared

    var body: some View {
        NavigationStack {
            List {
                ForEach(moduleManager.getAllModules(), id: \.id) { module in
                    HStack {
                        Image(systemName: module.icon)
                            .foregroundColor(AppColors.primary)
                            .frame(width: 30)

                        Text(module.name)
                            .foregroundColor(AppColors.textPrimary)

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { module.isEnabled },
                            set: { _ in moduleManager.toggleModule(module.id) }
                        ))
                        .labelsHidden()
                    }
                }
            }
            .navigationTitle("模組設定")
        }
    }
}
