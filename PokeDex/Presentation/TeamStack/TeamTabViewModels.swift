import Foundation
import Observation

@MainActor
@Observable
final class TeamStatsViewModel {
    enum UiState {
        case loading
        case loaded(TeamStatsSummary)
    }

    private let getTeamStats: GetTeamStatsUseCase

    var uiState: UiState = .loading

    init(getTeamStats: GetTeamStatsUseCase) {
        self.getTeamStats = getTeamStats
    }

    func submit(_ pokemons: [Pokemon]) {
        guard !pokemons.isEmpty else { return }
        uiState = .loaded(getTeamStats(pokemons: pokemons))
    }
}

@MainActor
@Observable
final class TeamAnalysisViewModel {
    enum UiState {
        case loading
        case loaded(TeamAnalysis)
    }

    private let analyzeTeam: AnalyzeTeamUseCase

    var uiState: UiState = .loading

    init(analyzeTeam: AnalyzeTeamUseCase) {
        self.analyzeTeam = analyzeTeam
    }

    func submit(_ pokemons: [Pokemon]) {
        guard !pokemons.isEmpty else { return }
        uiState = .loaded(analyzeTeam(pokemons: pokemons))
    }
}

@MainActor
@Observable
final class TeamCoverageViewModel {
    enum UiState {
        case loading
        case empty
        case loaded(TeamCoverage)
        case error(String)
    }

    private let getTeamCoverage: GetTeamCoverageUseCase

    var uiState: UiState = .loading

    private var lastIds: [Int]?

    init(getTeamCoverage: GetTeamCoverageUseCase) {
        self.getTeamCoverage = getTeamCoverage
    }

    func submit(_ ids: [Int]) {
        guard ids != lastIds else { return }
        lastIds = ids
        uiState = .loading
        Task {
            do {
                let coverage = try await getTeamCoverage(ids: ids)
                guard lastIds == ids else { return }
                uiState = coverage.isEmpty ? .empty : .loaded(coverage)
            } catch {
                guard lastIds == ids else { return }
                uiState = .error(error.localizedDescription)
            }
        }
    }
}
