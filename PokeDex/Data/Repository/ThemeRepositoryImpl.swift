import Foundation

struct ThemeRepositoryImpl: ThemeRepository {
    private let defaults: UserDefaults
    private let store: DarkModeStore

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        store = DarkModeStore(defaults: defaults)
    }

    func darkModeStream() async -> AsyncStream<Bool> {
        await store.stream()
    }

    func setDarkMode(_ enabled: Bool) async {
        await store.set(enabled)
    }
}

private actor DarkModeStore {
    private let defaults: UserDefaults
    private var observers: [UUID: AsyncStream<Bool>.Continuation] = [:]

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    func stream() -> AsyncStream<Bool> {
        let id = UUID()
        return AsyncStream { continuation in
            observers[id] = continuation
            continuation.yield(defaults.bool(forKey: "dark_mode"))
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeObserver(id) }
            }
        }
    }

    func set(_ enabled: Bool) {
        defaults.set(enabled, forKey: "dark_mode")
        for continuation in observers.values {
            continuation.yield(enabled)
        }
    }

    private func removeObserver(_ id: UUID) {
        observers[id] = nil
    }
}
