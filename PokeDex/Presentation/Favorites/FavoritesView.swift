import SwiftUI

struct FavoritesView: View {
    @Bindable var viewModel: FavoritesViewModel
    var onPokemonTap: (Pokemon) -> Void

    @State private var firstVisibleIndex = 0

    var body: some View {
        ZStack {
            ThemeColors.screenBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                content
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.uiState.isLoading {
            LoadingView()
        } else if let error = viewModel.uiState.error {
            ErrorContentView(message: error) {
                viewModel.retry()
            }
        } else {
            PokemonGrid(
                pokemons: viewModel.uiState.favoritePokemons,
                onPokemonTap: onPokemonTap,
                onFavorite: { viewModel.onFavoriteClick($0) },
                firstVisibleIndex: $firstVisibleIndex
            )
        }
    }

    private var header: some View {
        GradientHeader(
            gradient: LinearGradient(
                colors: [Color(hex: 0xFF4B5C), Color(hex: 0xFF6DAF)],
                startPoint: .top,
                endPoint: .bottom
            ),
            padding: EdgeInsets(top: 36, leading: 24, bottom: 36, trailing: 24)
        ) {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    Text("Favoritos")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("\(viewModel.uiState.favoritePokemons.count) Pokémon guardados")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
        }
    }
}
