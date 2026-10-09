import SwiftUI

struct PokemonCard: View {
    let pokemon: Pokemon
    var onTap: () -> Void = {}
    var onFavorite: () -> Void = {}

    private var baseColor: Color {
        TypeColors.color(for: pokemon.types.first).dimmed(0.9)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(baseColor)

                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 160, height: 160)
                    .offset(x: 60, y: -60)

                VStack(spacing: 0) {
                    HStack {
                        Text("#\(pokemon.id)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                    Spacer(minLength: 4)

                    SpriteImageView(url: artworkURL, size: 150)
                        .frame(height: 150)

                    Spacer(minLength: 4)

                    Text(pokemon.name)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)

                    Spacer(minLength: 4)

                    HStack(spacing: 4) {
                        ForEach(pokemon.types, id: \.self) { type in
                            Text(type)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(RoundedRectangle(cornerRadius: 8).fill(TypeColors.color(for: type)))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 12)
                }
            }
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            Button(action: onFavorite) {
                Image(systemName: pokemon.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 26))
                    .foregroundColor(pokemon.isFavorite ? .red : .white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(Color.white.opacity(0.35)))
            }
            .buttonStyle(.plain)
            .padding(8)
        }
        .accessibilityLabel("Favorite")
    }

    private var artworkURL: String? {
        pokemon.imageUrl ?? PokemonSprites.artwork(pokemon.id)
    }
}

private struct VisibleIndexesKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]

    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct PokemonGrid: View {
    let pokemons: [Pokemon]
    var onPokemonTap: (Pokemon) -> Void = { _ in }
    var onFavorite: (Pokemon) -> Void = { _ in }
    @Binding var firstVisibleIndex: Int
    var resetSignal: Int = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                Color.clear
                    .frame(height: 0)
                    .id("grid-top")

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8),
                        GridItem(.flexible(), spacing: 8),
                    ],
                    spacing: 8
                ) {
                    ForEach(Array(pokemons.enumerated()), id: \.element.id) { index, pokemon in
                        PokemonCard(
                            pokemon: pokemon,
                            onTap: { onPokemonTap(pokemon) },
                            onFavorite: { onFavorite(pokemon) }
                        )
                        .id(pokemon.id)
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: VisibleIndexesKey.self,
                                    value: [index: geometry.frame(in: .global).maxY]
                                )
                            }
                        )
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
            .onPreferenceChange(VisibleIndexesKey.self) { rects in
                let visible = rects.filter { $0.value > 8 }.keys
                firstVisibleIndex = visible.min() ?? 0
            }
            .onChange(of: resetSignal) { _, _ in
                withAnimation {
                    proxy.scrollTo("grid-top", anchor: .top)
                }
            }
        }
    }
}
