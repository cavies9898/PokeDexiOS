import SwiftUI

struct PokemonDetailView: View {
    @Bindable var viewModel: PokemonDetailViewModel
    var onPokemonTap: (Int) -> Void
    var onBack: () -> Void

    var body: some View {
        ZStack {
            ThemeColors.screenBackground.ignoresSafeArea()

            if viewModel.uiState.isLoading {
                LoadingView()
            } else if let detail = viewModel.uiState.detail {
                content(detail)
            } else {
                ErrorContentView(
                    message: viewModel.uiState.error ?? "Pokémon no encontrado",
                    onRetry: viewModel.uiState.detail == nil ? { viewModel.onRetry() } : nil,
                    onBack: onBack
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func content(_ detail: PokemonDetail) -> some View {
        let mainColor = TypeColors.color(for: detail.pokemon.types.first)

        return ScrollView {
            VStack(spacing: 0) {
                header(detail, mainColor: mainColor)

                DescriptionSection(detail: detail, mainColor: mainColor)
                AboutSection(detail: detail, mainColor: mainColor)
                StatsSection(detail: detail, mainColor: mainColor)

                if !detail.abilities.isEmpty {
                    AbilitiesSection(detail: detail, mainColor: mainColor)
                }
                if !detail.weaknesses.isEmpty {
                    WeaknessSection(detail: detail, mainColor: mainColor)
                }
                if detail.evolutionChain.count > 1 {
                    EvolutionSection(detail: detail, mainColor: mainColor, onPokemonTap: onPokemonTap)
                }
                if !detail.moves.isEmpty {
                    MovesSection(detail: detail, mainColor: mainColor)
                }
            }
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .background(mainColor.ignoresSafeArea(edges: .top))
    }

    private func header(_ detail: PokemonDetail, mainColor: Color) -> some View {
        GradientHeader(
            gradient: LinearGradient(
                colors: [mainColor, mainColor.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            ),
            padding: EdgeInsets(top: 16, leading: 20, bottom: 20, trailing: 20)
        ) {
            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel("Atrás")

                    Text("#\(detail.pokemon.id)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { viewModel.onFavoriteClick() }) {
                        Image(systemName: viewModel.uiState.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(viewModel.uiState.isFavorite ? 1 : 0.85))
                    }
                    .accessibilityLabel("Favorito")
                }

                SpriteImageView(url: detail.pokemon.imageUrl ?? PokemonSprites.artwork(detail.pokemon.id), size: 160)

                Text(detail.pokemon.name.prefix(1).uppercased() + String(detail.pokemon.name.dropFirst()))
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(.white)

                Spacer(minLength: 12)

                HStack(spacing: 8) {
                    ForEach(detail.pokemon.types, id: \.self) { type in
                        Text(type.capitalized)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.25))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                    }
                }

                Spacer(minLength: 20)
            }
        }
    }
}
