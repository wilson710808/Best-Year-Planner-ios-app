import Foundation

/// 輕量級服務定位器，實現依賴注入
/// 支持懶加載、單例、協議替換
public final class ServiceLocator: @unchecked Sendable {
    
    public static let shared = ServiceLocator()
    
    // 防止多線程問題
    private let lock = NSLock()
    
    // 服務註冊表
    private var services: [String: Any] = [:]
    private var singletons: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    
    private init() {}
    
    // MARK: - 註冊服務
    
    /// 註冊單例服務
    public func registerSingleton<T>(_ service: T) {
        lock.lock()
        defer { lock.unlock() }
        let key = typeKey(T.self)
        singletons[key] = service
    }
    
    /// 註冊工廠方法（每次resolve時創建新實例）
    public func registerFactory<T>(_ factory: @escaping () -> T) {
        lock.lock()
        defer { lock.unlock() }
        let key = typeKey(T.self)
        factories[key] = { factory() }
    }
    
    /// 註冊已創建的實例
    public func register<T>(_ service: T) {
        lock.lock()
        defer { lock.unlock() }
        let key = typeKey(T.self)
        services[key] = service
    }
    
    // MARK: - 解析服務
    
    /// 解析服務實例（自動選擇單例或新建）
    public func resolve<T>() -> T? {
        lock.lock()
        defer { lock.unlock() }
        let key = typeKey(T.self)
        
        // 1. 先查單例
        if let singleton = singletons[key] as? T {
            return singleton
        }
        
        // 2. 查已註冊實例
        if let service = services[key] as? T {
            // 如果是 Sendable，自動提升為單例
            if let sendable = service as? any Sendable {
                singletons[key] = sendable
                services.removeValue(forKey: key)
            }
            return service
        }
        
        // 3. 查工廠
        if let factory = factories[key] {
            let instance = factory()
            // 工廠默認創建單例
            singletons[key] = instance
            factories.removeValue(forKey: key)
            return instance as? T
        }
        
        return nil
    }
    
    /// 解析協議（帶默認工廠）
    public func resolve<T>(_ type: T.Type, defaultFactory: @escaping () -> T) -> T {
        if let existing = resolve(T.self) {
            return existing
        }
        let instance = defaultFactory()
        register(instance)
        return instance
    }
    
    // MARK: - 替換服務（熱插拔核心）
    
    /// 替換現有服務實現（熱插拔）
    public func replace<T>(_ service: T) {
        lock.lock()
        defer { lock.unlock() }
        let key = typeKey(T.self)
        services[key] = service
        singletons.removeValue(forKey: key)
    }
    
    /// 清除特定類型的所有實例
    public func clear<T>(_ type: T.Type) {
        lock.lock()
        defer { lock.unlock() }
        let key = typeKey(T.self)
        services.removeValue(forKey: key)
        singletons.removeValue(forKey: key)
        factories.removeValue(forKey: key)
    }
    
    /// 清除所有服務（測試用）
    public func resetAll() {
        lock.lock()
        defer { lock.unlock() }
        services.removeAll()
        singletons.removeAll()
        factories.removeAll()
    }
    
    // MARK: - 快捷方法
    
    /// 解析 AI Provider
    public var aiProvider: any AIProvider {
        resolve() ?? ProviderFactory.makeAIProvider()
    }
    
    /// 解析 Auth Provider
    public var authProvider: any AuthProvider {
        resolve() ?? ProviderFactory.makeAuthProvider()
    }
    
    /// 解析 Storage Provider
    public var storageProvider: any StorageProvider {
        resolve() ?? ProviderFactory.makeStorageProvider()
    }
    
    // MARK: - 私有方法
    
    private func typeKey<T>(_ type: T.Type) -> String {
        // 使用 ObjectIdentifier 確保類型唯一性
        return String(ObjectIdentifier(T.self))
    }
}

// MARK: - 快捷擴展

public extension ServiceLocator {
    /// 解析可選協議
    func resolveProtocol<P>(_ type: P.Type) -> P? {
        return resolve(P.self)
    }
    
    /// 檢查是否已註冊
    func isRegistered<T>(_ type: T.Type) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        let key = typeKey(T.self)
        return services[key] != nil || singletons[key] != nil
    }
}
