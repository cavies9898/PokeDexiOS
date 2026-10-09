import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    var onPokemonTap: (Pokemon) -> Void

    @State private var showFilterOptions = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ThemeColors.screenBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                content
            }

            if viewModel.uiState.firstVisibleIndex > 3 {
                Button {
                    viewModel.uiState.scrollResetSignal += 1
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(Color(hex: 0xE53935)))
                        .shadow(radius: 4)
                }
                .accessibilityLabel("Scroll to top")
                .padding(16)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.uiState.firstVisibleIndex > 3)
        .animation(.easeInOut(duration: 0.25), value: showFilterOptions)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.uiState.isLoading {
            LoadingView()
        } else if let error = viewModel.uiState.error {
            ErrorContentView(message: error) {
                viewModel.retry()
            }
        } else {
            ZStack(alignment: .top) {
                PokemonGrid(
                    pokemons: viewModel.uiState.filteredPokemons,
                    onPokemonTap: onPokemonTap,
                    onFavorite: { viewModel.onFavoriteClick($0) },
                    firstVisibleIndex: $viewModel.uiState.firstVisibleIndex,
                    resetSignal: viewModel.uiState.scrollResetSignal
                )
                if !viewModel.uiState.categorySelected.isEmpty {
                    selectedCategoriesBar
                }
            }
        }
    }

    private var selectedCategoriesBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.uiState.categorySelected, id: \.self) { value in
                    Text(value.capitalized)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(ThemeColors.appBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(ThemeColors.appBlue.opacity(0.12)))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(ThemeColors.screenBackground.opacity(0.9))
    }

    private var header: some View {
        GradientHeader(
            gradient: LinearGradient(
                colors: [Color(hex: 0xC62828), .red],
                startPoint: .top,
                endPoint: .bottom
            ),
            padding: EdgeInsets(top: 24, leading: 24, bottom: 24, trailing: 24)
        ) {
            VStack(alignment: .leading, spacing: 20) {
                Text("PokéDex")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 12)

                searchBar

                HStack(spacing: 10) {
                    Button {
                        withAnimation { showFilterOptions.toggle() }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                            Text("Filtrar por tipo")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: showFilterOptions ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.white.opacity(showFilterOptions ? 0.45 : 0.3)))
                    }
                    .accessibilityLabel("Filtros")

                    Spacer()

                    sortButton(icon: "arrow.up", ascending: true, accessibility: "Ascendant")
                    sortButton(icon: "arrow.down", ascending: false, accessibility: "Descendant")
                }

                if showFilterOptions {
                    filterOptionsPanel
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }

    private var filterOptionsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(FilterItem.allCases) { item in
                        filterCategoryChip(item)
                    }
                }
            }

            if let item = viewModel.uiState.currentFilterItem, item.hasOptions {
                if viewModel.uiState.categoryOptions.isEmpty {
                    Text("Cargando opciones…")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    FlowLayout(spacing: 8, lineSpacing: 8) {
                        ForEach(viewModel.uiState.categoryOptions, id: \.self) { option in
                            optionChip(option)
                        }
                    }
                }
            }

            HStack {
                Button {
                    viewModel.onFilterItemSelected(.all)
                } label: {
                    Text("Limpiar")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().stroke(Color.white.opacity(0.6), lineWidth: 1))
                }

                Spacer()

                Button {
                    withAnimation { showFilterOptions = false }
                } label: {
                    Text("Listo")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(ThemeColors.ink)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.white))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private func filterCategoryChip(_ item: FilterItem) -> some View {
        let isSelected = viewModel.uiState.currentFilterItem == item
        return Button {
            viewModel.onFilterItemSelected(item)
            if !item.hasOptions {
                withAnimation { showFilterOptions = false }
            }
        } label: {
            Text(item.displayName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? Color(hex: 0xC62828) : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(isSelected ? .white : Color.white.opacity(0.22)))
        }
        .buttonStyle(.plain)
    }

    private func optionChip(_ option: String) -> some View {
        let isSelected = viewModel.uiState.categorySelected.contains(option)
        return Button {
            var selection = viewModel.uiState.categorySelected
            if isSelected {
                selection.removeAll { $0 == option }
            } else {
                selection.append(option)
            }
            viewModel.filterByCategory(selection)
        } label: {
            Text(option.capitalized)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? Color(hex: 0xC62828) : .white)
                .padding(.horizontal, 11)
                .padding(.vertical, 6)
                .background(Capsule().fill(isSelected ? .white : Color.white.opacity(0.22)))
        }
        .buttonStyle(.plain)
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(ThemeColors.labelGray)
            TextField("Buscar por nombre", text: Binding(
                get: { viewModel.uiState.searchQuery },
                set: { viewModel.onSearchQueryChanged($0) }
            ))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.done)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.9))
        .clipShape(Capsule())
    }

    private func sortButton(icon: String, ascending: Bool, accessibility: String) -> some View {
        Button {
            if ascending { viewModel.sortAscending() } else { viewModel.sortDescending() }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.3)))
        }
        .accessibilityLabel(accessibility)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(size)
            )
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
