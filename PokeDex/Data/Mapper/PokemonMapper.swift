import Foundation

struct PokemonMapper {
    static func fromRecord(_ record: PokemonTeamRecord) -> Pokemon {
        Pokemon(
            id: record.idPokemon,
            name: record.name,
            imageUrl: PokemonSprites.artwork(record.idPokemon),
            stats: PokemonStats(
                hp: record.hp,
                attack: record.attack,
                defense: record.defense,
                specialAttack: record.specialAttack,
                specialDefense: record.specialDefense,
                speed: record.speed,
                total: record.total
            ),
            types: TypesCSV.deserialize(record.types),
            generation: record.generation,
            region: record.region,
            habitat: record.habitat,
            color: record.color,
            shape: record.shape
        )
    }
}
