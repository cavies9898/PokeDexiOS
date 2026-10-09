import SwiftUI

struct TeamsView: View {
    @Bindable var viewModel: TeamsViewModel
    var onTeamTap: (Int) -> Void
    var onPokemonTap: (Int) -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if viewModel.uiState.isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .tint(ThemeColors.appBlue)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.uiState.teams.isEmpty {
                    emptyState
                } else {
                    teamsList
                }
            }
        }
        .overlay(alignment: .bottom) {
            if !viewModel.uiState.teams.isEmpty {
                createButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .alert(
            viewModel.uiState.nameDialog?.title ?? "",
            isPresented: Binding(
                get: { viewModel.uiState.nameDialog != nil },
                set: { if !$0 { viewModel.onDismissDialogs() } }
            )
        ) {
            TextField("Nombre del equipo", text: Binding(
                get: { viewModel.uiState.nameDialog?.value ?? "" },
                set: { viewModel.onNameChanged($0) }
            ))
            Button("Guardar") { viewModel.onNameConfirm() }
            Button("Cancelar", role: .cancel) { viewModel.onDismissDialogs() }
        } message: {
            if let error = viewModel.uiState.nameDialog?.error {
                Text(error)
            }
        }
        .alert(
            "Eliminar equipo",
            isPresented: Binding(
                get: { viewModel.uiState.teamToDelete != nil },
                set: { if !$0 { viewModel.onDismissDialogs() } }
            )
        ) {
            Button("Eliminar", role: .destructive) { viewModel.onDeleteConfirm() }
            Button("Cancelar", role: .cancel) { viewModel.onDismissDialogs() }
        } message: {
            if let team = viewModel.uiState.teamToDelete {
                Text("¿Eliminar \"\(team.name)\"? Se borrarán sus \(team.pokemonCount) Pokémon.")
            }
        }
        .alert(
            "Aviso",
            isPresented: Binding(
                get: { viewModel.uiState.error != nil },
                set: { if !$0 { viewModel.onErrorShown() } }
            )
        ) {
            Button("Aceptar") { viewModel.onErrorShown() }
        } message: {
            Text(viewModel.uiState.error ?? "")
        }
    }

    private var header: some View {
        GradientHeader(
            gradient: LinearGradient(
                colors: [ThemeColors.appBlue, ThemeColors.skyBlue],
                startPoint: .top,
                endPoint: .bottom
            ),
            padding: EdgeInsets(top: 36, leading: 24, bottom: 36, trailing: 24)
        ) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                    Text("Mis Equipos Pokémon")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Crea y gestiona tus equipos competitivos")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("Aún no tienes equipos")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            Text("Crea uno para empezar a armar tu equipo ideal")
                .font(.system(size: 14))
                .foregroundColor(ThemeColors.labelGray)
                .multilineTextAlignment(.center)
            createButton
                .padding(.top, 12)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var teamsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(viewModel.uiState.teams) { team in
                    teamCard(team)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 120)
        }
    }

    private func teamCard(_ team: Team) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.system(size: 18, weight: .bold))
                    Text("\(team.pokemonCount)/\(Team.maxPokemon) Pokémon")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.labelGray)
                }
                Spacer()
                Button {
                    viewModel.onEditClick(team)
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                        .foregroundColor(ThemeColors.appBlue)
                }
                .accessibilityLabel("Editar Equipo")
                Button(role: .destructive) {
                    viewModel.onDeleteClick(team)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
                .accessibilityLabel("Eliminar Equipo")
            }

            HStack(spacing: 8) {
                ForEach(0..<Team.maxPokemon, id: \.self) { index in
                    if index < team.sprites.count {
                        SpriteImageView(url: team.sprites[index], size: 50)
                            .frame(width: 50, height: 50)
                            .background(RoundedRectangle(cornerRadius: 8).fill(ThemeColors.tileBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(ThemeColors.appBlue, lineWidth: 2)
                            )
                            .onTapGesture { onPokemonTap(team.pokemonIds[index]) }
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ThemeColors.screenBackground)
                            .frame(width: 50, height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: 0xC7C7CC), lineWidth: 1)
                            )
                    }
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ThemeColors.screenBackground)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ThemeColors.appBlue)
                        .frame(
                            width: proxy.size.width * CGFloat(team.pokemonCount) / CGFloat(Team.maxPokemon)
                        )
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture { onTeamTap(team.id) }
    }

    private var createButton: some View {
        Button {
            viewModel.onCreateTeamClick()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                Text("Crear Nuevo Equipo")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.red))
        }
        .disabled(viewModel.uiState.isSaving)
    }
}
