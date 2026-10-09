import Foundation

struct GetFavoritesUseCase: Sendable {
    private let pokemonRepository: any PokemonRepository
    private let favoriteRepository: any FavoriteRepository

    init(
        pokemonRepository: any PokemonRepository,
        favoriteRepository: any FavoriteRepository
    ) {
        self.pokemonRepository = pokemonRepository
        self.favoriteRepository = favoriteRepository
    }

    func callAsFunction() async -> AsyncStream<[Pokemon]> {
        let favoriteIdsStream = await favoriteRepository.favoriteIdsStream()
        let pokemonRepository = self.pokemonRepository
        return AsyncStream { continuation in
            let task = Task {
                for await ids in favoriteIdsStream {
                    var favorites: [Pokemon] = []
                    for id in ids {
                        guard let pokemon = try? await pokemonRepository.pokemon(byId: id) else {
                            continue
                        }
                        var copy = pokemon
                        copy.isFavorite = true
                        favorites.append(copy)
                    }
                    continuation.yield(favorites)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

struct ToggleFavoriteUseCase: Sendable {
    private let repository: any FavoriteRepository

    init(repository: any FavoriteRepository) {
        self.repository = repository
    }

    func callAsFunction(_ pokemon: Pokemon) async {
        if pokemon.isFavorite {
            try? await repository.removeFavorite(id: pokemon.id)
        } else {
            try? await repository.addFavorite(id: pokemon.id, name: pokemon.name)
        }
    }
}
