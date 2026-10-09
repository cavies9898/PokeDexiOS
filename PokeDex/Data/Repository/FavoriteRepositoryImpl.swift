import Foundation

struct FavoriteRepositoryImpl: FavoriteRepository {
    private let database: UserDatabase

    init(database: UserDatabase) {
        self.database = database
    }

    func favoriteIdsStream() async -> AsyncStream<[Int]> {
        let database = self.database
        return AsyncStream { continuation in
            let task = Task {
                let changes = await database.changesStream()
                for await _ in changes {
                    if Task.isCancelled { break }
                    do {
                        let ids = try await database.favoriteIds()
                        continuation.yield(ids)
                    } catch {
                        continuation.finish()
                        return
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func addFavorite(id: Int, name: String) async throws {
        try await database.insertFavorite(id: id, name: name)
    }

    func removeFavorite(id: Int) async throws {
        try await database.deleteFavorite(id: id)
    }
}
