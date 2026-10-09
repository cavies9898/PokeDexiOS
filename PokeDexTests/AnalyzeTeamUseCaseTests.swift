import Testing
@testable import PokeDex

struct AnalyzeTeamUseCaseTests {
    private let analyzeTeam = AnalyzeTeamUseCase()

    private func makePokemon(
        id: Int,
        hp: Int = 80,
        attack: Int = 80,
        defense: Int = 80,
        specialAttack: Int = 80,
        specialDefense: Int = 80,
        speed: Int = 80,
        types: [String] = ["normal"]
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
            ),
            types: types
        )
    }

    @Test
    func emptyTeamReturnsDefaultAnalysis() {
        let result = analyzeTeam(pokemons: [])

        #expect(result.memberCount == 0)
        #expect(result.averageScore == 0)
        #expect(result.scoreRatio == 0)
        #expect(result.strengths.isEmpty)
        #expect(result.weaknesses.isEmpty)
    }

    @Test
    func incompleteTeamReportsMissingMembersAsWeakness() {
        let result = analyzeTeam(pokemons: [
            makePokemon(
                id: 1,
                attack: 100,
                defense: 100,
                specialAttack: 50,
                specialDefense: 100,
                types: ["fire", "flying"]
            ),
            makePokemon(id: 2, attack: 50, specialAttack: 100, types: ["water", "grass"]),
        ])

        #expect(result.memberCount == 2)
        #expect(result.weaknesses.contains("Equipo incompleto: 2 de 6 Pokémon"))
    }

    @Test
    func countsPhysicalSpecialAndSpeedBuckets() {
        let result = analyzeTeam(pokemons: [
            makePokemon(id: 1, attack: 120, specialAttack: 60, speed: 110),
            makePokemon(id: 2, attack: 50, specialAttack: 130, speed: 70),
            makePokemon(id: 3, attack: 90, specialAttack: 90, speed: 50),
        ])

        #expect(result.memberCount == 3)
        #expect(result.physicalCount == 2)
        #expect(result.specialCount == 1)
        #expect(result.fastCount == 1)
        #expect(result.mediumCount == 1)
        #expect(result.slowCount == 1)
        #expect(result.defensiveCount == 0)
    }

    @Test
    func averagesAndTypeCountsAreComputedFromTheTeam() {
        let result = analyzeTeam(pokemons: [
            makePokemon(id: 1, types: ["fire"]),
            makePokemon(id: 2, types: ["fire", "flying"]),
        ])

        let expectedAverage = (480 + 480) / 2
        #expect(result.averageScore == expectedAverage)
        #expect(result.scoreRatio == Double(expectedAverage) / 600.0)
        #expect(result.typeCounts.count == 2)
        #expect(result.typeCounts.first == TypeCount(name: "fire", count: 2))
    }

    @Test
    func fastTeamGeneratesRapidityStrength() {
        let result = analyzeTeam(pokemons: [
            makePokemon(id: 1, hp: 100, attack: 110, defense: 100, specialAttack: 60, specialDefense: 100, speed: 100, types: ["fire", "flying"]),
            makePokemon(id: 2, hp: 90, attack: 60, defense: 95, specialAttack: 110, specialDefense: 95, speed: 100, types: ["water", "grass"]),
            makePokemon(id: 3, hp: 80, attack: 100, defense: 90, specialAttack: 70, specialDefense: 90, speed: 110, types: ["electric"]),
        ])

        #expect(result.strengths.contains("3 Pokémon rápidos (Velocidad 100 o superior)"))
        #expect(result.strengths.count <= 3)
    }
}
