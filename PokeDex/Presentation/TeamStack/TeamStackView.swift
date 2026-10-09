import SwiftUI

struct TeamStackView: View {
    let idTeam: Int?
    var onBack: () -> Void
    var onPokemonTap: (Int) -> Void

    @Bindable var builderViewModel: TeamBuilderViewModel
    @Bindable var statsViewModel: TeamStatsViewModel
    @Bindable var coverageViewModel: TeamCoverageViewModel
    @Bindable var analysisViewModel: TeamAnalysisViewModel

    @State private var selectedTab: TeamTab = .team

    var body: some View {
        ZStack {
            ThemeColors.screenBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ZStack {
                    tabContent
                        .id(selectedTab)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: selectedTab)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .team:
            TeamBuilderView(viewModel: builderViewModel, onPokemonTap: onPokemonTap)
        case .stats:
            TeamStatsView(pokemons: builderViewModel.uiState.pokemonTeam, viewModel: statsViewModel)
        case .coverage:
            TeamCoverageView(pokemons: builderViewModel.uiState.pokemonTeam, viewModel: coverageViewModel)
        case .analysis:
            TeamAnalysisView(pokemons: builderViewModel.uiState.pokemonTeam, viewModel: analysisViewModel)
        }
    }

    private var header: some View {
        GradientHeader(
            gradient: LinearGradient(
                colors: [ThemeColors.skyBlue, ThemeColors.appBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            padding: EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)
        ) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("back")

                    Text("Equipo")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(builderViewModel.uiState.pokemonTeam.count)/\(Team.maxPokemon)")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                }
                .padding(.top, 12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(TeamTab.allCases) { tab in
                            Button {
                                selectedTab = tab
                            } label: {
                                Text(tab.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(selectedTab == tab ? 0.45 : 0.25))
                                    )
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}
