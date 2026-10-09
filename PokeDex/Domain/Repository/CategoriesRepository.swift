import Foundation

protocol CategoriesRepository: Sendable {
    func categories() async throws -> Categories
}
