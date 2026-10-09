import SwiftUI

struct TeamCoverageView: View {
    let pokemons: [Pokemon]
    @Bindable var viewModel: TeamCoverageViewModel

    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                loadingCard
            case .empty:
                EmptyStateCard(
                    icon: "cube.transparent",
                    iconColor: ThemeColors.appBlue,
                    title: "Sin Pokémon en el equipo",
                    description: "Añade Pokémon desde la pestaña Equipo para ver su cobertura defensiva."
                )
            case .error(let message):
                EmptyStateCard(
                    icon: "checkmark.circle",
                    iconColor: ThemeColors.badRed,
                    title: "No se pudo calcular la cobertura",
                    description: message
                )
            case .loaded(let coverage):
                content(coverage)
            }
        }
        .onAppear {
            viewModel.submit(pokemons.map(\.id))
        }
        .onChange(of: pokemons) { _, newValue in
            viewModel.submit(newValue.map(\.id))
        }
    }

    private var loadingCard: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
                .tint(ThemeColors.appBlue)
            Text("Calculando cobertura…")
                .font(.system(size: 13))
                .foregroundColor(ThemeColors.labelGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    private func content(_ coverage: TeamCoverage) -> some View {
        let resisted = coverage.rows.filter { $0.score > 0 }
        let weak = coverage.rows.filter { $0.score < 0 }.sorted { $0.score < $1.score }

        return ScrollView {
            VStack(spacing: 0) {
                header(coverage)
                typeListCard(
                    title: "Fuerte contra",
                    subtitle: "Tipos que el equipo resiste",
                    icon: "shield",
                    color: ThemeColors.goodGreen,
                    count: resisted.count,
                    rows: Array(resisted.prefix(5)),
                    topFive: resisted.count > 5,
                    emptyText: "El equipo no domina ningún tipo de ataque"
                )
                typeListCard(
                    title: "Débil contra",
                    subtitle: "Tipos que superan al equipo",
                    icon: "exclamationmark.triangle",
                    color: ThemeColors.badRed,
                    count: weak.count,
                    rows: Array(weak.prefix(5)),
                    topFive: weak.count > 5,
                    emptyText: "El equipo no comparte debilidades relevantes"
                )
                fullTableCard(coverage)
            }
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
    }

    private func header(_ coverage: TeamCoverage) -> some View {
        GradientCardHeader {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cobertura del Equipo")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(.white)
                        Text("Defensa frente a los 18 tipos atacantes")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Text("\(coverage.memberCount)/\(Team.maxPokemon)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.2)))
                }

                HStack(spacing: 12) {
                    counterBox(label: "Tipos resistidos", value: coverage.resistedCount, color: Color(hex: 0x69F0AE))
                    counterBox(label: "Tipos débiles", value: coverage.weakCount, color: Color(hex: 0xFF8A80))
                }

                HStack(spacing: 8) {
                    Text("Balance defensivo")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.85))
                    Text(coverage.globalScore >= 0 ? "+\(coverage.globalScore)" : "\(coverage.globalScore)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.2)))
                }
            }
        }
    }

    private func counterBox(label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(color)
                Text("de 18")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.16)))
    }

    private func typeListCard(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        count: Int,
        rows: [TypeCoverageRow],
        topFive: Bool,
        emptyText: String
    ) -> some View {
        SectionCard(title: title, icon: icon, mainColor: color, trailingText: "\(count)") {
            VStack(alignment: .leading, spacing: 6) {
                GroupLabel(text: topFive ? "\(subtitle) · top 5" : subtitle, color: ThemeColors.labelGray)

                if rows.isEmpty {
                    Text(emptyText)
                        .font(.system(size: 13))
                        .foregroundColor(ThemeColors.labelGray)
                        .padding(.vertical, 8)
                } else {
                    ForEach(Array(rows.enumerated()), id: \.element.type) { index, row in
                        coverageRow(row)
                        if index < rows.count - 1 {
                            Rectangle().fill(ThemeColors.divider).frame(height: 1)
                        }
                    }
                }
            }
        }
    }

    private func coverageRow(_ row: TypeCoverageRow) -> some View {
        HStack(spacing: 8) {
            Text(row.type.capitalized)
                .font(.system(size: 11))
                .foregroundColor(TypeColors.color(for: row.type).readableOn())
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 76)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(RoundedRectangle(cornerRadius: 8).fill(TypeColors.color(for: row.type).opacity(0.15)))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(TypeColors.color(for: row.type).opacity(0.5), lineWidth: 1))

            SegmentedBar(
                segments: [
                    (row.resistant, ThemeColors.goodGreen),
                    (row.neutral, ThemeColors.statTrack),
                    (row.weak, ThemeColors.badRed),
                ],
                height: 10
            )

            Text("\(row.resistant)R \(row.neutral)N \(row.weak)D")
                .font(.system(size: 10))
                .foregroundColor(ThemeColors.labelGray)
                .frame(width: 56)

            Text(row.score >= 0 ? "+\(row.score)" : "\(row.score)")
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(scoreColor(row.score))
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.vertical, 6)
    }

    private func scoreColor(_ score: Int) -> Color {
        if score > 0 { return ThemeColors.goodGreen }
        if score < 0 { return ThemeColors.badRed }
        return ThemeColors.labelGray
    }

    private func fullTableCard(_ coverage: TeamCoverage) -> some View {
        SectionCard(
            title: "Tabla completa de tipos",
            icon: "tablecells",
            mainColor: ThemeColors.appBlue,
            trailingText: "\(coverage.rows.count)/18"
        ) {
            VStack(alignment: .leading, spacing: 5) {
                GroupLabel(text: "Ordenada por balance defensivo", color: ThemeColors.labelGray)

                ForEach(Array(coverage.rows.enumerated()), id: \.element.type) { index, row in
                    coverageRow(row)
                    if index < coverage.rows.count - 1 {
                        Rectangle().fill(ThemeColors.divider).frame(height: 1)
                    }
                }

                Rectangle().fill(ThemeColors.divider).frame(height: 1)
                    .padding(.vertical, 6)

                HStack(spacing: 10) {
                    legendDot(color: ThemeColors.goodGreen, label: "Resistente")
                    legendDot(color: ThemeColors.statTrack, label: "Neutral")
                    legendDot(color: ThemeColors.badRed, label: "Débil")
                    AccentPill(text: "R / N / D", color: ThemeColors.appBlue, fontSize: 10)
                }
            }
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(ThemeColors.labelGray)
        }
    }
}
