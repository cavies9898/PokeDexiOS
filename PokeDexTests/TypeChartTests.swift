import Testing
@testable import PokeDex

struct TypeChartTests {
    private let chart = TypeChart(
        attackers: [
            .init(id: 1, name: "fire"),
            .init(id: 2, name: "water"),
            .init(id: 3, name: "grass"),
            .init(id: 5, name: "rock"),
            .init(id: 10, name: "normal"),
        ],
        factors: [
            "1-1": 50, "1-2": 100, "1-3": 200, "1-5": 100, "1-10": 100,
            "2-1": 200, "2-2": 50, "2-3": 50, "2-5": 100, "2-10": 100,
            "3-1": 50, "3-2": 200, "3-3": 50, "3-5": 100, "3-10": 100,
            "5-1": 100, "5-2": 100, "5-3": 50, "5-5": 50, "5-10": 100,
            "10-1": 100, "10-2": 100, "10-3": 100, "10-5": 100, "10-10": 100,
        ]
    )

    @Test
    func multiplierMultipliesEveryTargetTypeFactor() {
        #expect(chart.multiplier(attackingTypeId: 1, ownTypeIds: [3, 1]) == 1.0)
        #expect(chart.multiplier(attackingTypeId: 1, ownTypeIds: [3]) == 2.0)
        #expect(chart.multiplier(attackingTypeId: 2, ownTypeIds: [1, 3]) == 1.0)
    }

    @Test
    func weaknessesExcludeNeutralEntriesAndSortDescending() {
        let result = chart.weaknesses(ownTypes: [(id: 3, name: "grass")])

        #expect(result.count == 4)
        #expect(result[0] == TypeEffectiveness(type: "fire", multiplier: 2.0))
        #expect(result[1] == TypeEffectiveness(type: "grass", multiplier: 0.5))
        #expect(result[2] == TypeEffectiveness(type: "rock", multiplier: 0.5))
        #expect(result[3] == TypeEffectiveness(type: "water", multiplier: 0.5))
    }

    @Test
    func dualTypeWeaknessesCombineBothFactors() {
        let result = chart.weaknesses(ownTypes: [(id: 3, name: "grass"), (id: 1, name: "fire")])

        #expect(result == [
            TypeEffectiveness(type: "rock", multiplier: 0.5),
            TypeEffectiveness(type: "grass", multiplier: 0.25),
        ])
    }

    @Test
    func emptyTypesProduceNoWeaknesses() {
        #expect(chart.weaknesses(ownTypes: []).isEmpty)
    }

    @Test
    func coverageSortsByScoreThenName() {
        let coverage = chart.coverage(
            ownTypesByPokemon: [1: [3], 2: [1]],
            ids: [1, 2]
        )

        #expect(coverage.memberCount == 2)
        #expect(coverage.rows.map(\.type) == ["grass", "rock", "fire", "normal", "water"])
        #expect(coverage.rows[0] == TypeCoverageRow(type: "grass", resistant: 2, weak: 0, neutral: 0))
        #expect(coverage.rows[1] == TypeCoverageRow(type: "rock", resistant: 1, weak: 0, neutral: 1))
        #expect(coverage.resistedCount == 2)
        #expect(coverage.weakCount == 0)
    }

    @Test
    func coverageOfEmptyIdsReturnsDefault() {
        let coverage = chart.coverage(ownTypesByPokemon: [:], ids: [])

        #expect(coverage.isEmpty)
        #expect(coverage.memberCount == 0)
        #expect(coverage.rows.isEmpty)
    }
}
