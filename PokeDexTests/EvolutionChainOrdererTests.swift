import Testing
@testable import PokeDex

struct EvolutionChainOrdererTests {
    private func node(speciesId: Int, evolvesFrom: Int?, pokemonId: Int, name: String) -> EvolutionChainOrderer.Node {
        EvolutionChainOrderer.Node(
            speciesId: speciesId,
            evolvesFrom: evolvesFrom,
            pokemonId: pokemonId,
            name: name
        )
    }

    @Test
    func ordersLinearChainFromFirstEvolution() {
        let ordered = EvolutionChainOrderer.order([
            node(speciesId: 3, evolvesFrom: 2, pokemonId: 3, name: "venusaur"),
            node(speciesId: 1, evolvesFrom: nil, pokemonId: 1, name: "bulbasaur"),
            node(speciesId: 2, evolvesFrom: 1, pokemonId: 2, name: "ivysaur"),
        ])

        #expect(ordered.map(\.speciesId) == [1, 2, 3])
    }

    @Test
    func ordersMultipleRootsInBreadthFirstOrder() {
        let ordered = EvolutionChainOrderer.order([
            node(speciesId: 6, evolvesFrom: 5, pokemonId: 6, name: "charizard"),
            node(speciesId: 1, evolvesFrom: nil, pokemonId: 1, name: "bulbasaur"),
            node(speciesId: 5, evolvesFrom: 4, pokemonId: 5, name: "charmeleon"),
            node(speciesId: 2, evolvesFrom: 1, pokemonId: 2, name: "ivysaur"),
            node(speciesId: 4, evolvesFrom: nil, pokemonId: 4, name: "charmander"),
            node(speciesId: 3, evolvesFrom: 2, pokemonId: 3, name: "venusaur"),
        ])

        let ids = ordered.map(\.speciesId)
        #expect(ids.count == 6)
        #expect(ids[0] == 1)
        #expect(ids[1] == 4)
        let position: [Int: Int] = Dictionary(uniqueKeysWithValues: ids.enumerated().map { ($1, $0) })
        #expect(position[1]! < position[2]!)
        #expect(position[2]! < position[3]!)
        #expect(position[4]! < position[5]!)
        #expect(position[5]! < position[6]!)
    }

    @Test
    func brokenChainRootsIncludeNodesWhoseParentIsMissing() {
        let ordered = EvolutionChainOrderer.order([
            node(speciesId: 2, evolvesFrom: 1, pokemonId: 2, name: "ivysaur"),
        ])

        #expect(ordered.map(\.speciesId) == [2])
    }

    @Test
    func cyclicGraphTerminatesAndKeepsEveryNode() {
        let ordered = EvolutionChainOrderer.order([
            node(speciesId: 1, evolvesFrom: 2, pokemonId: 1, name: "a"),
            node(speciesId: 2, evolvesFrom: 1, pokemonId: 2, name: "b"),
        ])

        #expect(Set(ordered.map(\.speciesId)) == [1, 2])
        #expect(ordered.first?.speciesId == 1)
    }

    @Test
    func emptyInputReturnsEmptyOutput() {
        #expect(EvolutionChainOrderer.order([]).isEmpty)
    }

    @Test
    func conditionPrefersMinimumLevel() {
        #expect(EvolutionChainOrderer.condition(minimumLevel: 16, trigger: "level-up") == "Nv. 16")
    }

    @Test
    func conditionMapsKnownTriggers() {
        #expect(EvolutionChainOrderer.condition(minimumLevel: nil, trigger: "level-up") == "Subir de nivel")
        #expect(EvolutionChainOrderer.condition(minimumLevel: nil, trigger: "trade") == "Intercambio")
        #expect(EvolutionChainOrderer.condition(minimumLevel: nil, trigger: "use-item") == "Usar objeto")
        #expect(EvolutionChainOrderer.condition(minimumLevel: nil, trigger: "friendship") == "Friendship")
    }
}
