import Foundation

struct ObserveDarkModeUseCase: Sendable {
    private let repository: any ThemeRepository

    init(repository: any ThemeRepository) {
        self.repository = repository
    }

    func callAsFunction() async -> AsyncStream<Bool> {
        await repository.darkModeStream()
    }
}

struct SetDarkModeUseCase: Sendable {
    private let repository: any ThemeRepository

    init(repository: any ThemeRepository) {
        self.repository = repository
    }

    func callAsFunction(_ enabled: Bool) async {
        await repository.setDarkMode(enabled)
    }
}
