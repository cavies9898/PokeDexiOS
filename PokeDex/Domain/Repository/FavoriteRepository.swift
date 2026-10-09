import Foundation

protocol FavoriteRepository: Sendable {
    func favoriteIdsStream() async -> AsyncStream<[Int]>
    func addFavorite(id: Int, name: String) async throws
    func removeFavorite(id: Int) async throws
}
