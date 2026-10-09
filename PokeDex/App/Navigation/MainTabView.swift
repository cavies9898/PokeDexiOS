import SwiftUI

struct MainTabView: View {
    let environment: AppEnvironment
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch coordinator.selectedTab {
                case .home:
                    homeStack
                case .team:
                    teamStack
                case .favorites:
                    favoritesStack
                case .settings:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if coordinator.isRootVisible {
                bottomBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: coordinator.isRootVisible)
        .background(ThemeColors.screenBackground)
    }

    private var homeStack: some View {
        PushNavigationView(path: $coordinator.homePath) {
            HomeTabView(environment: environment) { pokemon in
                coordinator.push(.detail(id: pokemon.id))
            }
        } routeContent: { route in
            routeView(route)
        }
    }

    private var teamStack: some View {
        PushNavigationView(path: $coordinator.teamPath) {
            TeamsTabView(
                environment: environment,
                onTeamTap: { coordinator.push(.teamStack(idTeam: $0)) },
                onPokemonTap: { coordinator.push(.detail(id: $0)) }
            )
        } routeContent: { route in
            routeView(route)
        }
    }

    private var favoritesStack: some View {
        PushNavigationView(path: $coordinator.favoritesPath) {
            FavoritesTabView(environment: environment) { pokemon in
                coordinator.push(.detail(id: pokemon.id))
            }
        } routeContent: { route in
            routeView(route)
        }
    }

    @ViewBuilder
    private func routeView(_ route: Route) -> some View {
        switch route {
        case .detail(let id):
            DetailRouteView(id: id, environment: environment) {
                coordinator.pop()
            } onPokemonTap: { pokemonId in
                coordinator.push(.detail(id: pokemonId))
            }
        case .teamStack(let idTeam):
            TeamStackRouteView(
                idTeam: idTeam ?? 0,
                environment: environment,
                onBack: { coordinator.pop() },
                onPokemonTap: { coordinator.push(.detail(id: $0)) }
            )
        default:
            EmptyView()
        }
    }

    private var bottomBar: some View {
        HStack {
            bottomBarItem(tab: .home, title: "Inicio", icon: "house", selectedIcon: "house.fill")
            bottomBarItem(tab: .team, title: "Equipo", icon: "person.2", selectedIcon: "person.2.fill")
            bottomBarItem(tab: .favorites, title: "Favoritos", icon: "heart", selectedIcon: "heart.fill")
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Color.white
                .shadow(color: .black.opacity(0.08), radius: 4, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func bottomBarItem(
        tab: AppCoordinator.Tab,
        title: String,
        icon: String,
        selectedIcon: String
    ) -> some View {
        let isSelected = coordinator.selectedTab == tab
        return Button {
            coordinator.select(tab)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? ThemeColors.accentRed : ThemeColors.labelGray)
            .frame(maxWidth: .infinity)
        }
    }
}

struct PushNavigationView<Root: View, RouteContent: View>: View {
    @Binding var path: [Route]
    let root: () -> Root
    let routeContent: (Route) -> RouteContent

    @State private var duration = 0.26

    var body: some View {
        ZStack {
            root()

            if let route = path.last {
                routeContent(route)
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 1.08).combined(with: .opacity)
                    ))
            }
        }
        .onChange(of: path.count) { _, newValue in
            duration = newValue > 0 ? 0.26 : 0.18
        }
        .animation(.easeInOut(duration: duration), value: path.count)
    }
}

struct HomeTabView: View {
    let environment: AppEnvironment
    var onPokemonTap: (Pokemon) -> Void

    @State private var viewModel: HomeViewModel

    init(
        environment: AppEnvironment,
        onPokemonTap: @escaping (Pokemon) -> Void
    ) {
        self.environment = environment
        self.onPokemonTap = onPokemonTap
        _viewModel = State(initialValue: environment.makeHomeViewModel())
    }

    var body: some View {
        HomeView(viewModel: viewModel, onPokemonTap: onPokemonTap)
    }
}

struct FavoritesTabView: View {
    let environment: AppEnvironment
    var onPokemonTap: (Pokemon) -> Void

    @State private var viewModel: FavoritesViewModel

    init(
        environment: AppEnvironment,
        onPokemonTap: @escaping (Pokemon) -> Void
    ) {
        self.environment = environment
        self.onPokemonTap = onPokemonTap
        _viewModel = State(initialValue: environment.makeFavoritesViewModel())
    }

    var body: some View {
        FavoritesView(viewModel: viewModel, onPokemonTap: onPokemonTap)
    }
}

struct DetailRouteView: View {
    let id: Int
    let environment: AppEnvironment
    var onBack: () -> Void
    var onPokemonTap: (Int) -> Void

    @State private var viewModel: PokemonDetailViewModel

    init(
        id: Int,
        environment: AppEnvironment,
        onBack: @escaping () -> Void,
        onPokemonTap: @escaping (Int) -> Void
    ) {
        self.id = id
        self.environment = environment
        self.onBack = onBack
        self.onPokemonTap = onPokemonTap
        _viewModel = State(initialValue: environment.makeDetailViewModel(id: id))
    }

    var body: some View {
        PokemonDetailView(
            viewModel: viewModel,
            onPokemonTap: { onPokemonTap($0) },
            onBack: onBack
        )
    }
}

struct TeamStackRouteView: View {
    let idTeam: Int
    let environment: AppEnvironment
    var onBack: () -> Void
    var onPokemonTap: (Int) -> Void

    @State private var builderViewModel: TeamBuilderViewModel
    @State private var statsViewModel: TeamStatsViewModel
    @State private var coverageViewModel: TeamCoverageViewModel
    @State private var analysisViewModel: TeamAnalysisViewModel

    init(
        idTeam: Int,
        environment: AppEnvironment,
        onBack: @escaping () -> Void,
        onPokemonTap: @escaping (Int) -> Void
    ) {
        self.idTeam = idTeam
        self.environment = environment
        self.onBack = onBack
        self.onPokemonTap = onPokemonTap
        _builderViewModel = State(initialValue: environment.makeTeamBuilderViewModel(idTeam: idTeam))
        _statsViewModel = State(initialValue: environment.makeTeamStatsViewModel())
        _coverageViewModel = State(initialValue: environment.makeTeamCoverageViewModel())
        _analysisViewModel = State(initialValue: environment.makeTeamAnalysisViewModel())
    }

    var body: some View {
        TeamStackView(
            idTeam: idTeam,
            onBack: onBack,
            onPokemonTap: onPokemonTap,
            builderViewModel: builderViewModel,
            statsViewModel: statsViewModel,
            coverageViewModel: coverageViewModel,
            analysisViewModel: analysisViewModel
        )
    }
}

struct TeamsTabView: View {
    let environment: AppEnvironment
    var onTeamTap: (Int) -> Void
    var onPokemonTap: (Int) -> Void

    @State private var viewModel: TeamsViewModel

    init(
        environment: AppEnvironment,
        onTeamTap: @escaping (Int) -> Void,
        onPokemonTap: @escaping (Int) -> Void
    ) {
        self.environment = environment
        self.onTeamTap = onTeamTap
        self.onPokemonTap = onPokemonTap
        _viewModel = State(initialValue: environment.makeTeamsViewModel())
    }

    var body: some View {
        TeamsView(
            viewModel: viewModel,
            onTeamTap: onTeamTap,
            onPokemonTap: onPokemonTap
        )
        .onChange(of: viewModel.uiState.teamCreatedId) { _, id in
            guard let id else { return }
            onTeamTap(id)
            viewModel.onTeamOpened()
        }
    }
}
