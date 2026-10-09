import Foundation
import Observation

@MainActor
@Observable
final class TeamsViewModel {
    struct TeamNameDialog {
        var title: String
        var value: String
        var teamId: Int?
        var error: String?
    }

    struct UiState {
        var teams: [Team] = []
        var isLoading = true
        var error: String?
        var nameDialog: TeamNameDialog?
        var teamToDelete: Team?
        var isSaving = false
        var teamCreatedId: Int?
    }

    private let getTeams: GetTeamsUseCase
    private let createTeam: CreateTeamUseCase
    private let renameTeam: RenameTeamUseCase
    private let deleteTeam: DeleteTeamUseCase

    var uiState = UiState()

    nonisolated(unsafe) private var observeTask: Task<Void, Never>?

    init(
        getTeams: GetTeamsUseCase,
        createTeam: CreateTeamUseCase,
        renameTeam: RenameTeamUseCase,
        deleteTeam: DeleteTeamUseCase
    ) {
        self.getTeams = getTeams
        self.createTeam = createTeam
        self.renameTeam = renameTeam
        self.deleteTeam = deleteTeam
        observeTeams()
    }

    deinit {
        observeTask?.cancel()
    }

    private func observeTeams() {
        observeTask = Task { [weak self] in
            guard let stream = await self?.getTeams() else { return }
            for await teams in stream {
                if Task.isCancelled { return }
                self?.uiState.teams = teams
                self?.uiState.isLoading = false
            }
        }
    }

    func onCreateTeamClick() {
        uiState.nameDialog = TeamNameDialog(title: "Crear equipo", value: "", teamId: nil)
        uiState.error = nil
    }

    func onEditClick(_ team: Team) {
        uiState.nameDialog = TeamNameDialog(title: "Editar equipo", value: team.name, teamId: team.id)
        uiState.error = nil
    }

    func onDeleteClick(_ team: Team) {
        guard !uiState.isSaving else { return }
        uiState.teamToDelete = team
        uiState.error = nil
    }

    func onNameChanged(_ value: String) {
        uiState.nameDialog?.value = value
        uiState.nameDialog?.error = nil
    }

    func onNameConfirm() {
        guard var dialog = uiState.nameDialog else { return }
        let name = dialog.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            dialog.error = "El nombre no puede estar vacío"
            uiState.nameDialog = dialog
            return
        }
        if dialog.teamId == nil {
            performCreate(name)
        } else {
            performRename(dialog.teamId ?? 0, name)
        }
    }

    func onDeleteConfirm() {
        guard let team = uiState.teamToDelete, !uiState.isSaving else { return }

        uiState.isSaving = true
        uiState.error = nil
        Task {
            let result = await deleteTeam(id: team.id)
            uiState.isSaving = false
            switch result {
            case .success:
                uiState.teamToDelete = nil
                uiState.error = nil
            case .failure(let error):
                uiState.teamToDelete = nil
                uiState.error = error.localizedDescription
            }
        }
    }

    func onDismissDialogs() {
        guard !uiState.isSaving else { return }
        uiState.nameDialog = nil
        uiState.teamToDelete = nil
    }

    func onTeamOpened() {
        uiState.teamCreatedId = nil
    }

    func onErrorShown() {
        uiState.error = nil
    }

    private func performCreate(_ name: String) {
        uiState.isSaving = true
        uiState.error = nil
        Task {
            let result = await createTeam(name: name)
            uiState.isSaving = false
            switch result {
            case .success(let id):
                uiState.nameDialog = nil
                uiState.teamCreatedId = id
            case .failure(let error):
                uiState.nameDialog?.error = error.localizedDescription
            }
        }
    }

    private func performRename(_ idTeam: Int, _ name: String) {
        uiState.isSaving = true
        uiState.error = nil
        Task {
            let result = await renameTeam(id: idTeam, name: name)
            uiState.isSaving = false
            switch result {
            case .success:
                uiState.nameDialog = nil
            case .failure(let error):
                uiState.nameDialog?.error = error.localizedDescription
            }
        }
    }
}
