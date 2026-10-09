import Foundation
import Observation

@MainActor
@Observable
final class AppCoordinator {
    enum Stage {
        case splash
        case main
    }

    enum Tab: Hashable {
        case home
        case team
        case favorites
        case settings

        var route: Route {
            switch self {
            case .home: .home
            case .team: .team
            case .favorites: .favorites
            case .settings: .settings
            }
        }
    }

    var stage: Stage = .splash
    var selectedTab: Tab = .home
    var homePath: [Route] = []
    var teamPath: [Route] = []
    var favoritesPath: [Route] = []
    var settingsPath: [Route] = []

    var activePath: [Route] {
        get {
            switch selectedTab {
            case .home: homePath
            case .team: teamPath
            case .favorites: favoritesPath
            case .settings: settingsPath
            }
        }
        set {
            switch selectedTab {
            case .home: homePath = newValue
            case .team: teamPath = newValue
            case .favorites: favoritesPath = newValue
            case .settings: settingsPath = newValue
            }
        }
    }

    var isRootVisible: Bool {
        activePath.isEmpty
    }

    func startMain() {
        stage = .main
        selectedTab = .home
        homePath = []
        teamPath = []
        favoritesPath = []
        settingsPath = []
    }

    func select(_ tab: Tab) {
        selectedTab = tab
    }

    func push(_ route: Route) {
        if let top = activePath.last, top == route {
            return
        }
        activePath.append(route)
    }

    func pop() {
        guard !activePath.isEmpty else { return }
        activePath.removeLast()
    }

    func popToRoot() {
        activePath.removeAll()
    }
}
