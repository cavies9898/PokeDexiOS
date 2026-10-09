import SwiftUI

struct TeamBuilderView: View {
    @Bindable var viewModel: TeamBuilderViewModel
    var onPokemonTap: (Int) -> Void

    @State private var showPicker = false

    var body: some View {
        ZStack {
            ThemeColors.screenBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 4) {
                    ForEach(viewModel.uiState.pokemonTeam) { pokemon in
                        memberCard(pokemon)
                    }

                    addButton
                        .padding(.top, 16)
                }
                .padding(16)
            }

            if let error = viewModel.uiState.error {
                feedbackBanner(text: error, color: ThemeColors.badRed)
            } else if let message = viewModel.uiState.message {
                feedbackBanner(text: message, color: ThemeColors.appBlue)
            }
        }
        .sheet(isPresented: $showPicker) {
            pickerSheet
        }
    }

    private func feedbackBanner(text: String, color: Color) -> some View {
        VStack {
            Spacer()
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(color)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(.white))
                .shadow(radius: 3)
                .padding(.bottom, 16)
        }
        .transition(.opacity)
        .onChange(of: text) { _, _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                viewModel.onErrorShown()
            }
        }
    }

    private func memberCard(_ pokemon: Pokemon) -> some View {
        HStack(spacing: 12) {
            SpriteImageView(url: pokemon.imageUrl ?? PokemonSprites.artwork(pokemon.id), size: 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(pokemon.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    ForEach(pokemon.types, id: \.self) { type in
                        Text(type)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(RoundedRectangle(cornerRadius: 8).fill(TypeColors.color(for: type)))
                    }
                }
            }

            Spacer()

            Button {
                viewModel.removePokemon(pokemon)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 20))
                    .foregroundColor(ThemeColors.badRed)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { onPokemonTap(pokemon.id) }
    }

    private var addButton: some View {
        Button {
            showPicker = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                Text("Agregar Pokémon")
                    .font(.system(size: 16))
            }
            .foregroundColor(Color(hex: 0x4285F4))
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [Color(hex: 0x4285F4), Color(hex: 0x4285F4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
            )
        }
    }

    private var pickerSheet: some View {
        VStack(spacing: 16) {
            Text("Selecciona un Pokemon")
                .font(.system(size: 17, weight: .bold))
                .padding(.top, 24)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(ThemeColors.labelGray)
                TextField("Buscar por nombre", text: Binding(
                    get: { viewModel.uiState.searchQuery },
                    set: { viewModel.onSearchQueryChanged($0) }
                ))
                .textInputAutocapitalization(.never)
                if !viewModel.uiState.searchQuery.isEmpty {
                    Button {
                        viewModel.onSearchQueryChanged("")
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ThemeColors.labelGray)
                    }
                    .accessibilityLabel("Borrar texto")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: 0x4285F4), lineWidth: 1)
            )
            .padding(.horizontal, 12)

            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                    ],
                    spacing: 8
                ) {
                    ForEach(viewModel.uiState.filteredPokemons) { pokemon in
                        pickerCard(pokemon)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.large])
    }

    private func pickerCard(_ pokemon: Pokemon) -> some View {
        Button {
            viewModel.addPokemon(pokemon)
        } label: {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(TypeColors.color(for: pokemon.types.first).dimmed(0.9))

                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 160, height: 160)
                    .offset(x: 80, y: -80)

                VStack(spacing: 4) {
                    Text("#\(pokemon.id)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)

                    SpriteImageView(url: PokemonSprites.sprite(pokemon.id), size: 150)
                        .frame(height: 150)

                    Text(pokemon.name)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        ForEach(pokemon.types, id: \.self) { type in
                            Text(type)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(RoundedRectangle(cornerRadius: 8).fill(TypeColors.color(for: type)))
                        }
                    }
                    .padding(.bottom, 12)
                }
            }
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
