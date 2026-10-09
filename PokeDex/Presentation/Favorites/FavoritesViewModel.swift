import Foundation
import Observation

@MainActor
@Observable
final class FavoritesViewModel {
    struct UiState {
        var isLoading = true
        var favoritePokemons: [Pokemon] = []
        var error: String?
    }

    private let getFavorites: GetFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    var uiState = UiState()

    nonisolated(unsafe) private var observeTask: Task<Void, Never>?

    init(getFavorites: GetFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase) {
        self.getFavorites = getFavorites
        self.toggleFavorite = toggleFavorite
        observeFavorites()
    }

    deinit {
        observeTask?.cancel()
    }

    private func observeFavorites() {
        observeTask = Task { [weak self] in
            guard let stream = await self?.getFavorites() else { return }
            var receivedAny = false
            for await favorites in stream {
                if Task.isCancelled { return }
                receivedAny = true
                self?.uiState.favoritePokemons = favorites
                self?.uiState.isLoading = false
                self?.uiState.error = nil
            }
            if !receivedAny, let self, self.uiState.error == nil {
                self.uiState.isLoading = false
                self.uiState.error = "Error al cargar los favoritos"
            }
        }
    }

    func onFavoriteClick(_ pokemon: Pokemon) {
        Task { await toggleFavorite(pokemon) }
    }

    func retry() {
        uiState.isLoading = true
        uiState.error = nil
        observeFavorites()
    }
}
