import Foundation

struct GetPokemonsUseCase: Sendable {
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
        do {
            let baseList = try await pokemonRepository.pokemons()
            let favoriteIdsStream = await favoriteRepository.favoriteIdsStream()
            return AsyncStream { continuation in
                continuation.yield(baseList)
                let task = Task {
                    for await ids in favoriteIdsStream {
                        let favorites = Set(ids)
                        continuation.yield(
                            baseList.map { pokemon in
                                var copy = pokemon
                                copy.isFavorite = favorites.contains(pokemon.id)
                                return copy
                            }
                        )
                    }
                    continuation.finish()
                }
                continuation.onTermination = { _ in task.cancel() }
            }
        } catch {
            return AsyncStream { continuation in
                continuation.finish()
            }
        }
    }
}

struct GetPokemonDetailUseCase: Sendable {
    private let repository: any PokemonRepository

    init(repository: any PokemonRepository) {
        self.repository = repository
    }

    func callAsFunction(id: Int) async -> Result<PokemonDetail, Error> {
        do {
            guard let detail = try await repository.pokemonDetail(id: id) else {
                return .failure(DomainError.pokemonNotFound)
            }
            return .success(detail)
        } catch {
            return .failure(error)
        }
    }
}

struct GetCategoriesUseCase: Sendable {
    private let repository: any CategoriesRepository

    init(repository: any CategoriesRepository) {
        self.repository = repository
    }

    func callAsFunction() async throws -> Categories {
        try await repository.categories()
    }
}
