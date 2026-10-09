import Foundation

struct GetTeamsUseCase: Sendable {
    private let repository: any TeamRepository

    init(repository: any TeamRepository) {
        self.repository = repository
    }

    func callAsFunction() async -> AsyncStream<[Team]> {
        await repository.observeTeams()
    }
}

struct CreateTeamUseCase: Sendable {
    private let repository: any TeamRepository

    init(repository: any TeamRepository) {
        self.repository = repository
    }

    func callAsFunction(name: String) async -> Result<Int, Error> {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .failure(DomainError.emptyTeamName)
        }
        do {
            return .success(try await repository.createTeam(name: trimmed))
        } catch {
            return .failure(error)
        }
    }
}

struct RenameTeamUseCase: Sendable {
    private let repository: any TeamRepository

    init(repository: any TeamRepository) {
        self.repository = repository
    }

    func callAsFunction(id: Int, name: String) async -> Result<Void, Error> {
        do {
            try await repository.renameTeam(id: id, name: name)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

struct DeleteTeamUseCase: Sendable {
    private let repository: any TeamRepository

    init(repository: any TeamRepository) {
        self.repository = repository
    }

    func callAsFunction(id: Int) async -> Result<Void, Error> {
        do {
            try await repository.deleteTeam(id: id)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
