import Foundation

protocol ThemeRepository: Sendable {
    func darkModeStream() async -> AsyncStream<Bool>
    func setDarkMode(_ enabled: Bool) async
}
