import SwiftUI

struct TeamStatsView: View {
    let pokemons: [Pokemon]
    @Bindable var viewModel: TeamStatsViewModel

    var body: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                EmptyStateCard(
                    icon: "chart.bar",
                    iconColor: ThemeColors.appBlue,
                    title: "Sin Pokémon en el equipo",
                    description: "Añade Pokémon desde la pestaña Equipo para ver sus estadísticas."
                )
            case .loaded(let summary):
                content(summary)
            }
        }
        .onChange(of: pokemons) { _, newValue in
            viewModel.submit(newValue)
        }
        .onAppear {
            viewModel.submit(pokemons)
        }
    }

    private func content(_ summary: TeamStatsSummary) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                header(summary)
                profileCard(summary)
                leadersCard(summary)
                rankingCard(summary)
                rolesCard(summary)
            }
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
    }

    private func header(_ summary: TeamStatsSummary) -> some View {
        GradientCardHeader {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Estadísticas del Equipo")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                    Text("Media de \(summary.memberCount) Pokémon · máx. \(maxTeamScore)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(summary.averageTotal)")
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundColor(.white)
                        Text("de \(maxTeamScore)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                Spacer()
                if let best = summary.ranking.first {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle().fill(.white).frame(width: 64, height: 64)
                            SpriteImageView(
                                url: best.imageUrl ?? PokemonSprites.artwork(best.id),
                                size: 56
                            )
                        }
                        Text("\(best.name) · \(best.stats.total)")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 104)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    private func profileCard(_ summary: TeamStatsSummary) -> some View {
        SectionCard(title: "Perfil del equipo", icon: "chart.bar", mainColor: ThemeColors.appBlue) {
            VStack(alignment: .leading, spacing: 12) {
                GroupLabel(text: "Media de \(summary.memberCount) Pokémon", color: ThemeColors.labelGray)
                TeamRadarChart(averages: summary.averages)
                Rectangle().fill(ThemeColors.divider).frame(height: 1)
                ForEach(0..<summary.averages.count, id: \.self) { index in
                    StatBar(
                        label: StatPalette.labels[index],
                        value: summary.averages[index],
                        color: StatPalette.colors[index]
                    )
                }
            }
        }
    }

    private func leadersCard(_ summary: TeamStatsSummary) -> some View {
        SectionCard(
            title: "Mejor de cada stat",
            icon: "trophy",
            mainColor: Color(hex: 0xF9A825),
            trailingText: "máx. \(StatPalette.maxStat)"
        ) {
            VStack(spacing: 10) {
                ForEach(0..<summary.leaders.count, id: \.self) { index in
                    let leader = summary.leaders[index]
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .stroke(StatPalette.colors[index], lineWidth: 2)
                                .frame(width: 36, height: 36)
                            SpriteImageView(
                                url: leader.pokemon.imageUrl ?? PokemonSprites.artwork(leader.pokemon.id),
                                size: 30
                            )
                        }
                        Text(StatPalette.labels[index])
                            .font(.system(size: 12))
                            .foregroundColor(ThemeColors.labelGray)
                        Text(leader.pokemon.name)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(ThemeColors.ink)
                            .lineLimit(1)
                        Spacer()
                        Text("\(leader.value)")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(ThemeColors.ink)
                    }
                }
            }
        }
    }

    private func rankingCard(_ summary: TeamStatsSummary) -> some View {
        SectionCard(
            title: "Ranking del equipo",
            icon: "chart.line.uptrend.xyaxis",
            mainColor: ThemeColors.appBlue,
            trailingText: "\(summary.memberCount)/\(Team.maxPokemon)"
        ) {
            VStack(spacing: 10) {
                ForEach(Array(summary.ranking.enumerated()), id: \.element.id) { index, pokemon in
                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            Text("#\(index + 1)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ThemeColors.appBlue)
                                .frame(width: 26, alignment: .leading)
                            ZStack {
                                Circle()
                                    .stroke(TypeColors.color(for: pokemon.types.first), lineWidth: 2)
                                    .frame(width: 40, height: 40)
                                SpriteImageView(
                                    url: pokemon.imageUrl ?? PokemonSprites.artwork(pokemon.id),
                                    size: 34
                                )
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text(pokemon.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .lineLimit(1)
                                HStack(spacing: 4) {
                                    ForEach(pokemon.types.prefix(2), id: \.self) { type in
                                        Text(type)
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(TypeColors.color(for: type))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 1)
                                            .background(Capsule().fill(TypeColors.color(for: type).opacity(0.18)))
                                            .overlay(Capsule().stroke(TypeColors.color(for: type).opacity(0.45)))
                                    }
                                }
                            }
                            Spacer()
                            Text("\(pokemon.stats.total)")
                                .font(.system(size: 14, weight: .bold))
                        }
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4).fill(ThemeColors.statTrack)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(ThemeColors.appBlue)
                                    .frame(
                                        width: proxy.size.width
                                            * CGFloat(min(pokemon.stats.total, maxTeamScore))
                                            / CGFloat(maxTeamScore)
                                    )
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
    }

    private func rolesCard(_ summary: TeamStatsSummary) -> some View {
        SectionCard(
            title: "Distribución de roles",
            icon: "person.3",
            mainColor: Color(hex: 0x7E57C2),
            trailingText: "\(summary.roles.count)"
        ) {
            VStack(alignment: .leading, spacing: 12) {
                if summary.roles.count <= 1 {
                    Text("Perfil poco definido: casi todo el equipo encaja en un mismo rol")
                        .font(.system(size: 12))
                        .foregroundColor(ThemeColors.labelGray)
                }

                ForEach(summary.roles, id: \.role) { group in
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(RolePalette.color(for: group.role).opacity(0.12))
                                .frame(width: 30, height: 30)
                            Image(systemName: RolePalette.icon(for: group.role))
                                .font(.system(size: 14))
                                .foregroundColor(RolePalette.color(for: group.role))
                        }
                        Text(group.role.label)
                            .font(.system(size: 13, weight: .semibold))
                        AccentPill(text: "\(group.members.count)", color: RolePalette.color(for: group.role))
                        Spacer()
                    }
                    HStack(spacing: -8) {
                        ForEach(group.members) { member in
                            ZStack {
                                Circle()
                                    .stroke(TypeColors.color(for: member.types.first), lineWidth: 2)
                                    .frame(width: 28, height: 28)
                                    .background(Circle().fill(.white))
                                SpriteImageView(
                                    url: member.imageUrl ?? PokemonSprites.artwork(member.id),
                                    size: 24
                                )
                            }
                        }
                        Spacer()
                    }
                    .padding(.leading, 40)
                }

                Text("Roles inferidos de las estadísticas base")
                    .font(.system(size: 11))
                    .foregroundColor(ThemeColors.labelGray)
            }
        }
    }
}
