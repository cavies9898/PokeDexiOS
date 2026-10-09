import SwiftUI

struct DescriptionSection: View {
    let detail: PokemonDetail
    let mainColor: Color

    var body: some View {
        SectionCard(title: "Descripción", icon: "info.circle", mainColor: mainColor) {
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(mainColor)
                    .frame(width: 4)
                Text(detail.description.isEmpty ? "Sin descripción disponible." : detail.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x444444))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct AboutSection: View {
    let detail: PokemonDetail
    let mainColor: Color

    var body: some View {
        SectionCard(title: "Datos generales", icon: "square.grid.3x3", mainColor: mainColor) {
            let tiles = Self.tiles(for: detail)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(tiles.chunked(size: 2).enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: 8) {
                        ForEach(pair) { tile in
                            InfoTileView(tile: tile, mainColor: mainColor)
                        }
                        if pair.count == 1 {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    static func tiles(for detail: PokemonDetail) -> [InfoTileData] {
        let gender: String
        switch detail.genderRate {
        case PokemonDetail.genderless:
            gender = "Sin género"
        case 0:
            gender = "100% ♀"
        case 8:
            gender = "100% ♂"
        default:
            let female = detail.genderRate * 100 / 8
            gender = "\(female)% ♀ / \(100 - female)% ♂"
        }

        let habitat = (detail.pokemon.habitat ?? "").isEmpty
            ? "Desconocido"
            : (detail.pokemon.habitat ?? "").prefix(1).uppercased() + String((detail.pokemon.habitat ?? "").dropFirst())
        let color = detail.pokemon.color.isEmpty
            ? "Desconocido"
            : detail.pokemon.color.prefix(1).uppercased() + String(detail.pokemon.color.dropFirst())
        let region = detail.pokemon.region.isEmpty ? "Desconocida" : detail.pokemon.region
        let generation = detail.pokemon.generation.isEmpty ? "Desconocida" : detail.pokemon.generation
        let growth = detail.growthRate.isEmpty
            ? "Desconocido"
            : detail.growthRate
                .replacingOccurrences(of: "-", with: " ")
                .prefix(1).uppercased()
                + String(
                    detail.growthRate
                        .replacingOccurrences(of: "-", with: " ")
                        .dropFirst()
                )

        return [
            InfoTileData(label: "Altura", value: "\(detail.heightMeters) m", icon: "ruler"),
            InfoTileData(label: "Peso", value: "\(detail.weightKg) kg", icon: "scalemass"),
            InfoTileData(label: "Captura", value: "\(detail.captureRate) / 255", icon: "target"),
            InfoTileData(label: "Género", value: gender, icon: "person"),
            InfoTileData(label: "Hábitat", value: String(habitat), icon: "tree"),
            InfoTileData(label: "Color", value: color, icon: "paintpalette"),
            InfoTileData(label: "Región", value: region, icon: "globe"),
            InfoTileData(label: "Generación", value: generation, icon: "number"),
            InfoTileData(label: "Crecimiento", value: String(growth), icon: "chart.line.uptrend.xyaxis"),
            InfoTileData(
                label: "Huevos",
                value: detail.hatchSteps > 0 ? "\(detail.hatchSteps) pasos" : "—",
                icon: "oval.portrait"
            ),
        ]
    }
}

struct InfoTileData: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let icon: String
}

struct InfoTileView: View {
    let tile: InfoTileData
    let mainColor: Color

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(mainColor.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: tile.icon)
                    .font(.system(size: 16))
                    .foregroundColor(mainColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(tile.label)
                    .font(.system(size: 11))
                    .foregroundColor(ThemeColors.labelGray)
                Text(tile.value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ThemeColors.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(ThemeColors.tileBackground))
    }
}

struct StatsSection: View {
    let detail: PokemonDetail
    let mainColor: Color

    var body: some View {
        SectionCard(title: "Estadísticas", icon: "chart.bar", mainColor: mainColor) {
            VStack(spacing: 10) {
                ForEach(0..<statCount, id: \.self) { index in
                    StatBar(
                        label: StatPalette.labels[index],
                        value: detail.pokemon.stats.value(at: index),
                        color: StatPalette.colors[index]
                    )
                }

                Rectangle()
                    .fill(ThemeColors.divider)
                    .frame(height: 1)
                    .padding(.vertical, 4)

                HStack {
                    Text("Total")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(ThemeColors.ink)
                    Spacer()
                    Text("\(detail.pokemon.stats.total)")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(mainColor)
                }
            }
        }
    }
}

struct AbilitiesSection: View {
    let detail: PokemonDetail
    let mainColor: Color

    var body: some View {
        SectionCard(
            title: "Habilidades",
            icon: "figure.strengthtraining",
            mainColor: mainColor,
            trailingText: "\(detail.abilities.count)"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(detail.abilities.chunked(size: 2).enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: 8) {
                        ForEach(Array(pair.enumerated()), id: \.offset) { _, ability in
                            abilityTile(ability)
                        }
                        if pair.count == 1 {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    private func abilityTile(_ ability: PokemonAbility) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ability.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ThemeColors.ink)
                    .lineLimit(1)
                if ability.isHidden {
                    AccentPill(text: "Oculta", color: mainColor, fontSize: 10)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(ThemeColors.tileBackground))
    }
}

struct WeaknessSection: View {
    let detail: PokemonDetail
    let mainColor: Color

    private var weak: [TypeEffectiveness] {
        detail.weaknesses.filter { $0.isWeakness }
    }

    private var resistant: [TypeEffectiveness] {
        detail.weaknesses.filter { $0.multiplier < 1.0 && !$0.isImmune }
    }

    private var immune: [TypeEffectiveness] {
        detail.weaknesses.filter { $0.isImmune }
    }

    var body: some View {
        SectionCard(title: "Debilidades y resistencias", icon: "shield.lefthalf.filled", mainColor: mainColor) {
            VStack(alignment: .leading, spacing: 16) {
                if !weak.isEmpty {
                    effectivenessGroup(title: "Débil contra", color: ThemeColors.badRed, items: weak)
                }
                if !resistant.isEmpty {
                    effectivenessGroup(title: "Resistente", color: ThemeColors.goodGreen, items: resistant)
                }
                if !immune.isEmpty {
                    effectivenessGroup(title: "Inmune", color: ThemeColors.appBlue, items: immune)
                }
            }
        }
    }

    private func effectivenessGroup(title: String, color: Color, items: [TypeEffectiveness]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            GroupLabel(text: title, color: color)
            FlowLayout(spacing: 6, lineSpacing: 6) {
                ForEach(items, id: \.type) { effectiveness in
                    HStack(spacing: 6) {
                        Text(effectiveness.type.capitalized)
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.ink)
                        Text(effectiveness.label())
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(color)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(TypeColors.color(for: effectiveness.type).opacity(0.15))
                    )
                    .overlay(
                        Capsule().stroke(TypeColors.color(for: effectiveness.type).opacity(0.5), lineWidth: 1)
                    )
                }
            }
        }
    }
}

struct EvolutionSection: View {
    let detail: PokemonDetail
    let mainColor: Color
    var onPokemonTap: (Int) -> Void

    var body: some View {
        SectionCard(title: "Cadena de evolución", icon: "arrow.left.arrow.right", mainColor: mainColor) {
            let stages = detail.evolutionChain
            if stages.count > 3 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        stageContent(stages)
                    }
                }
            } else {
                HStack(alignment: .top, spacing: 0) {
                    stageContent(stages)
                }
            }
        }
    }

    @ViewBuilder
    private func stageContent(_ stages: [EvolutionStage]) -> some View {
        ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
            if index > 0 {
                evolutionArrow(condition: stage.condition)
            }
            stageView(stage)
                .frame(maxWidth: stages.count > 3 ? 84 : .infinity, alignment: .leading)
        }
    }

    private func evolutionArrow(condition: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: "arrow.right")
                .font(.system(size: 16))
                .foregroundColor(Color(hex: 0xB0B0B0))
            Text(condition.isEmpty ? "Evoluciona" : condition)
                .font(.system(size: 9))
                .foregroundColor(ThemeColors.labelGray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 48)
    }

    private func stageView(_ stage: EvolutionStage) -> some View {
        Button {
            onPokemonTap(stage.pokemonId)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(stage.isCurrent ? mainColor.opacity(0.12) : ThemeColors.tileBackground)
                        .frame(width: 60, height: 60)
                    Circle()
                        .stroke(
                            stage.isCurrent ? mainColor : Color(hex: 0xE0E0E0),
                            lineWidth: stage.isCurrent ? 2 : 1
                        )
                        .frame(width: 60, height: 60)
                    SpriteImageView(url: stage.spriteUrl, size: 50)
                }
                Text(stage.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(stage.isCurrent ? mainColor : ThemeColors.ink)
                    .lineLimit(1)
                if stage.isCurrent {
                    AccentPill(text: "Actual", color: mainColor, fontSize: 9)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct MovesSection: View {
    let detail: PokemonDetail
    let mainColor: Color

    @State private var expanded = false

    private var visibleMoves: [PokemonMove] {
        expanded ? detail.moves : Array(detail.moves.prefix(10))
    }

    var body: some View {
        SectionCard(
            title: "Movimientos por nivel",
            icon: "list.number",
            mainColor: mainColor,
            trailingText: "\(detail.moves.count)"
        ) {
            VStack(spacing: 0) {
                HStack {
                    Text("Nv.")
                        .frame(width: 32, alignment: .leading)
                    Text("Movimiento")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Tipo")
                        .frame(width: 64, alignment: .leading)
                    Color.clear.frame(width: 4)
                    Text("Pot.")
                        .frame(width: 44, alignment: .leading)
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(ThemeColors.labelGray)
                .padding(.bottom, 6)

                Rectangle()
                    .fill(Color(hex: 0xEAEAEA))
                    .frame(height: 1)

                ForEach(Array(visibleMoves.enumerated()), id: \.offset) { index, move in
                    moveRow(move)
                    if index < visibleMoves.count - 1 {
                        Rectangle()
                            .fill(ThemeColors.divider)
                            .frame(height: 1)
                    }
                }

                if detail.moves.count > 10 {
                    Button {
                        withAnimation { expanded.toggle() }
                    } label: {
                        Text(expanded ? "Ver menos" : "Ver todos los \(detail.moves.count) movimientos")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(mainColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                }
            }
        }
    }

    private func moveRow(_ move: PokemonMove) -> some View {
        HStack {
            Text("\(move.level)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(mainColor)
                .frame(width: 32, alignment: .leading)

            VStack(alignment: .leading, spacing: 1) {
                Text(move.name)
                    .font(.system(size: 13))
                    .foregroundColor(ThemeColors.ink)
                    .lineLimit(1)
                Text(move.damageClass)
                    .font(.system(size: 10))
                    .foregroundColor(ThemeColors.labelGray)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(String(move.type.prefix(3)).uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(TypeColors.color(for: move.type).readableOn())
                .frame(width: 64)
                .padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 6).fill(TypeColors.color(for: move.type)))

            Color.clear.frame(width: 4)

            Text(move.power.map(String.init) ?? "—")
                .font(.system(size: 12))
                .foregroundColor(ThemeColors.ink)
                .frame(width: 44, alignment: .leading)
        }
        .padding(.vertical, 7)
    }
}

private extension Array {
    func chunked(size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
