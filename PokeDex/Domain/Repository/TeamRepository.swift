import Foundation

protocol TeamRepository: Sendable {
    func observeTeams() async -> AsyncStream<[Team]>
    func createTeam(name: String) async throws -> Int
    func renameTeam(id: Int, name: String) async throws
    func deleteTeam(id: Int) async throws
}
