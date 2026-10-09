import Foundation

struct PokemonDetail: Hashable, Sendable {
    static let genderless = -1

    let pokemon: Pokemon
    let description: String
    let heightMeters: Double
    let weightKg: Double
    let captureRate: Int
    let growthRate: String
    let genderRate: Int
    let hatchSteps: Int
    let abilities: [PokemonAbility]
    let moves: [PokemonMove]
    let evolutionChain: [EvolutionStage]
    let weaknesses: [TypeEffectiveness]

    init(
        pokemon: Pokemon = Pokemon(),
        description: String = "",
        heightMeters: Double = 0.0,
        weightKg: Double = 0.0,
        captureRate: Int = 0,
        growthRate: String = "",
        genderRate: Int = PokemonDetail.genderless,
        hatchSteps: Int = 0,
        abilities: [PokemonAbility] = [],
        moves: [PokemonMove] = [],
        evolutionChain: [EvolutionStage] = [],
        weaknesses: [TypeEffectiveness] = []
    ) {
        self.pokemon = pokemon
        self.description = description
        self.heightMeters = heightMeters
        self.weightKg = weightKg
        self.captureRate = captureRate
        self.growthRate = growthRate
        self.genderRate = genderRate
        self.hatchSteps = hatchSteps
        self.abilities = abilities
        self.moves = moves
        self.evolutionChain = evolutionChain
        self.weaknesses = weaknesses
    }
}

struct PokemonAbility: Hashable, Sendable {
    let name: String
    let isHidden: Bool

    init(name: String = "", isHidden: Bool = false) {
        self.name = name
        self.isHidden = isHidden
    }
}

struct PokemonMove: Hashable, Sendable {
    let name: String
    let level: Int
    let type: String
    let damageClass: String
    let power: Int?
    let accuracy: Int?
    let pp: Int?

    init(
        name: String = "",
        level: Int = 0,
        type: String = "",
        damageClass: String = "",
        power: Int? = nil,
        accuracy: Int? = nil,
        pp: Int? = nil
    ) {
        self.name = name
        self.level = level
        self.type = type
        self.damageClass = damageClass
        self.power = power
        self.accuracy = accuracy
        self.pp = pp
    }
}

struct EvolutionStage: Hashable, Sendable {
    let id: Int
    let pokemonId: Int
    let name: String
    let spriteUrl: String
    let condition: String
    let isCurrent: Bool

    init(
        id: Int = 0,
        pokemonId: Int = 0,
        name: String = "",
        spriteUrl: String = "",
        condition: String = "",
        isCurrent: Bool = false
    ) {
        self.id = id
        self.pokemonId = pokemonId
        self.name = name
        self.spriteUrl = spriteUrl
        self.condition = condition
        self.isCurrent = isCurrent
    }
}

struct TypeEffectiveness: Hashable, Sendable {
    let type: String
    let multiplier: Double

    init(type: String = "", multiplier: Double = 1.0) {
        self.type = type
        self.multiplier = multiplier
    }

    var isWeakness: Bool { multiplier > 1.0 }
    var isImmune: Bool { multiplier == 0.0 }

    func label() -> String {
        switch multiplier {
        case 0.0: "0x"
        case 0.25: "¼x"
        case 0.5: "½x"
        case 1.0: "1x"
        case 2.0: "2x"
        case 4.0: "4x"
        default: "\(multiplier)x"
        }
    }
}
