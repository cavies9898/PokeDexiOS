import Foundation

struct PokemonStats: Hashable, Sendable {
    let hp: Int
    let attack: Int
    let defense: Int
    let specialAttack: Int
    let specialDefense: Int
    let speed: Int
    let total: Int

    init(
        hp: Int = 0,
        attack: Int = 0,
        defense: Int = 0,
        specialAttack: Int = 0,
        specialDefense: Int = 0,
        speed: Int = 0,
        total: Int = 0
    ) {
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
        self.total = total
    }

    func value(at index: Int) -> Int {
        switch index {
        case 0: hp
        case 1: attack
        case 2: defense
        case 3: specialAttack
        case 4: specialDefense
        default: speed
        }
    }
}
