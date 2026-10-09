import Testing
@testable import PokeDex

struct GetTeamStatsUseCaseTests {
    private let getTeamStats = GetTeamStatsUseCase()

    private func makePokemon(
        id: Int,
        hp: Int = 80,
        attack: Int = 80,
        defense: Int = 80,
        specialAttack: Int = 80,
        specialDefense: Int = 80,
        speed: Int = 80
    ) -> Pokemon {
        Pokemon(
            id: id,
            name: "pokemon\(id)",
            stats: PokemonStats(
                hp: hp,
                attack: attack,
                defense: defense,
                specialAttack: specialAttack,
                specialDefense: specialDefense,
                speed: speed,
                total: hp + attack + defense + specialAttack + specialDefense + speed
            )
        )
    }

    @Test
    func emptyTeamReturnsDefaultSummary() {
        let result = getTeamStats(pokemons: [])

        #expect(result.memberCount == 0)
        #expect(result.averages.isEmpty)
        #expect(result.leaders.isEmpty)
        #expect(result.ranking.isEmpty)
        #expect(result.roles.isEmpty)
    }

    @Test
    func computesAveragesAndRanking() {
        let weak = makePokemon(id: 1, hp: 50, attack: 50, defense: 50, specialAttack: 50, specialDefense: 50, speed: 50)
        let strong = makePokemon(id: 2, hp: 100, attack: 100, defense: 100, specialAttack: 100, specialDefense: 100, speed: 100)

        let result = getTeamStats(pokemons: [weak, strong])

        #expect(result.memberCount == 2)
        #expect(result.averages[0] == 75)
        #expect(result.averageTotal == 450)
        #expect(result.ranking.map(\.id) == [2, 1])
    }

    @Test
    func leadersPickTheBestPokemonPerStat() {
        let fastest = makePokemon(id: 1, speed: 150)
        let strongest = makePokemon(id: 2, attack: 140)

        let result = getTeamStats(pokemons: [fastest, strongest])

        #expect(result.leaders.count == 6)
        #expect(result.leaders[5].pokemon.id == 1)
        #expect(result.leaders[5].value == 150)
        #expect(result.leaders[1].pokemon.id == 2)
        #expect(result.leaders[1].value == 140)
    }

    @Test
    func classifiesRolesAndOmitsEmptyGroups() {
        let tank = makePokemon(id: 1, hp: 80, defense: 120, specialDefense: 100, speed: 30)
        let fast = makePokemon(id: 2, speed: 120)
        let balanced = makePokemon(id: 3)

        let result = getTeamStats(pokemons: [tank, fast, balanced])

        #expect(result.roles.map(\.role) == [.tank, .fast, .balanced])
        #expect(result.roles[0].members.map(\.id) == [1])
        #expect(result.roles.contains { $0.role == .special } == false)
    }

    @Test
    func physicalAndSpecialRolesAreClassifiedByPriority() {
        let physical = makePokemon(id: 1, attack: 120, specialAttack: 80, speed: 80)
        let special = makePokemon(id: 2, attack: 70, specialAttack: 120, speed: 80)

        let result = getTeamStats(pokemons: [physical, special])

        #expect(result.roles.map(\.role) == [.physical, .special])
    }
}
