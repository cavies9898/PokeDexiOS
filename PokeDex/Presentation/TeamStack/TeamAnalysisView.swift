import SwiftUI

struct TeamAnalysisView: View {
    let pokemons: [Pokemon]
    @Bindable var viewModel: TeamAnalysisViewModel

    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                EmptyStateCard(
                    icon: "person.3",
                    iconColor: ThemeColors.appBlue,
                    title: "Sin Pokémon en el equipo",
                    description: "Añade Pokémon desde la pestaña Equipo para ver el análisis."
                )
            case .loaded(let analysis):
                content(analysis)
            }
        }
        .onAppear {
            viewModel.submit(pokemons)
        }
        .onChange(of: pokemons) { _, newValue in
            viewModel.submit(newValue)
        }
    }

    private func content(_ analysis: TeamAnalysis) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                header(analysis)
                spriteRow(analysis)

                SectionCard(
                    title: "Fortalezas",
                    icon: "checkmark.circle",
                    mainColor: ThemeColors.goodGreen,
                    trailingText: "\(analysis.strengths.count)"
                ) {
                    insightList(analysis.strengths, color: ThemeColors.goodGreen)
                }

                SectionCard(
                    title: "Debilidades",
                    icon: "exclamationmark.circle",
                    mainColor: ThemeColors.badRed,
                    trailingText: "\(analysis.weaknesses.count)"
                ) {
                    if analysis.weaknesses.isEmpty {
                        insightItem(
                            text: "Sin debilidades destacables en el análisis",
                            color: ThemeColors.goodGreen
                        )
                    } else {
                        insightList(analysis.weaknesses, color: ThemeColors.badRed)
                    }
                }

                compositionCard(analysis)
            }
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
    }

    private func header(_ analysis: TeamAnalysis) -> some View {
        GradientCardHeader {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Análisis del Equipo")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                    Text("Evaluación automática basada en \(analysis.memberCount) Pokémon")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                ScoreRing(ratio: analysis.scoreRatio, score: analysis.averageScore)
            }
        }
    }

    private func spriteRow(_ analysis: TeamAnalysis) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<Team.maxPokemon, id: \.self) { index in
                if index < pokemons.count {
                    let pokemon = pokemons[index]
                    ZStack {
                        Circle().fill(.white).frame(width: 46, height: 46)
                        Circle()
                            .stroke(TypeColors.color(for: pokemon.types.first), lineWidth: 2.5)
                            .frame(width: 46, height: 46)
                        SpriteImageView(
                            url: pokemon.imageUrl ?? PokemonSprites.artwork(pokemon.id),
                            size: 40
                        )
                    }
                } else {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.18)).frame(width: 46, height: 46)
                        Circle()
                            .stroke(Color.white.opacity(0.45), lineWidth: 2)
                            .frame(width: 46, height: 46)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func insightList(_ items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                insightItem(text: item, color: color)
                if index < items.count - 1 {
                    HStack {
                        Rectangle().fill(ThemeColors.divider).frame(height: 1)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private func insightItem(text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 20, height: 20)
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundColor(color)
            }
            .padding(.top, 2)
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: 0x444444))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func compositionCard(_ analysis: TeamAnalysis) -> some View {
        SectionCard(
            title: "Composición del Equipo",
            icon: "square.grid.3x3",
            mainColor: ThemeColors.appBlue,
            trailingText: "\(analysis.memberCount)/\(Team.maxPokemon)"
        ) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    GroupLabel(text: "Tipos del equipo", color: ThemeColors.labelGray)
                    FlowLayout(spacing: 6, lineSpacing: 6) {
                        ForEach(analysis.typeCounts, id: \.name) { entry in
                            typeCountChip(entry)
                        }
                    }
                }

                countRow(
                    title: "Tipo de ataque",
                    trailing: "\(analysis.physicalCount)F / \(analysis.specialCount)E",
                    segments: [
                        (analysis.physicalCount, Color(hex: 0xEF5350)),
                        (analysis.specialCount, Color(hex: 0x42A5F5)),
                    ],
                    legends: [
                        (label: "Físico", count: analysis.physicalCount, color: Color(hex: 0xEF5350)),
                        (label: "Especial", count: analysis.specialCount, color: Color(hex: 0x42A5F5)),
                    ]
                )

                countRow(
                    title: "Niveles de velocidad",
                    trailing: "\(analysis.fastCount)R / \(analysis.mediumCount)M / \(analysis.slowCount)L",
                    segments: [
                        (analysis.fastCount, ThemeColors.goodGreen),
                        (analysis.mediumCount, Color(hex: 0xFF9800)),
                        (analysis.slowCount, ThemeColors.badRed),
                    ],
                    legends: [
                        (label: "Rápido (100+)", count: analysis.fastCount, color: ThemeColors.goodGreen),
                        (label: "Medio (60-99)", count: analysis.mediumCount, color: Color(hex: 0xFF9800)),
                        (label: "Lento (<60)", count: analysis.slowCount, color: ThemeColors.badRed),
                    ]
                )

                detailRow(label: "Tipos únicos", value: "\(analysis.typeCounts.count)/18")
                Rectangle().fill(ThemeColors.divider).frame(height: 1)
                detailRow(label: "Pokémon defensivos", value: "\(analysis.defensiveCount)/\(analysis.memberCount)")
            }
        }
    }

    private func typeCountChip(_ entry: TypeCount) -> some View {
        HStack(spacing: 6) {
            Text(entry.name.capitalized)
                .font(.system(size: 12))
                .foregroundColor(TypeColors.color(for: entry.name).readableOn())
            Text("\(entry.count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(TypeColors.color(for: entry.name).readableOn())
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .background(Capsule().fill(TypeColors.color(for: entry.name)))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(TypeColors.color(for: entry.name).opacity(0.15)))
        .overlay(Capsule().stroke(TypeColors.color(for: entry.name).opacity(0.5), lineWidth: 1))
    }

    private func countRow(
        title: String,
        trailing: String,
        segments: [(Int, Color)],
        legends: [(label: String, count: Int, color: Color)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                GroupLabel(text: title, color: ThemeColors.labelGray)
                Spacer()
                Text(trailing)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(ThemeColors.labelGray)
            }
            SegmentedBar(segments: segments.map { (weight: $0.0, color: $0.1) })
            HStack(spacing: 16) {
                ForEach(legends, id: \.label) { legend in
                    HStack(spacing: 6) {
                        Circle().fill(legend.color).frame(width: 8, height: 8)
                        Text(legend.label)
                            .font(.system(size: 10))
                            .foregroundColor(ThemeColors.labelGray)
                        Text("\(legend.count) Pokémon")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(ThemeColors.ink)
                    }
                }
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(ThemeColors.ink)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(ThemeColors.appBlue)
        }
    }
}

private struct ScoreRing: View {
    let ratio: Double
    let score: Int

    @State private var animatedRatio: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 7)
            Circle()
                .trim(from: 0, to: max(0, min(animatedRatio, 1)))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 0) {
                Text("\(score)")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(.white)
                Text("pts")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(width: 86, height: 86)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9)) {
                animatedRatio = ratio
            }
        }
        .onChange(of: ratio) { _, newValue in
            withAnimation(.easeInOut(duration: 0.9)) {
                animatedRatio = newValue
            }
        }
    }
}
