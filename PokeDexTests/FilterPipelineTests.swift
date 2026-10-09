import Testing
@testable import PokeDex

struct FilterPipelineTests {
    private let all = [
        Pokemon(id: 25, name: "pikachu", types: ["electric"]),
        Pokemon(id: 6, name: "charizard", types: ["fire", "flying"]),
        Pokemon(id: 1, name: "bulbasaur", types: ["grass", "poison"]),
    ]

    @Test
    func searchFiltersByNameIgnoringCase() {
        let result = FilterPipeline.apply(
            pokemons: all,
            searchQuery: "PIKA",
            filter: nil,
            selectedCategories: [],
            sortAscending: nil
        )

        #expect(result.map(\.id) == [25])
    }

    @Test
    func blankSearchKeepsEveryPokemon() {
        for query in ["", "   "] {
            let result = FilterPipeline.apply(
                pokemons: all,
                searchQuery: query,
                filter: nil,
                selectedCategories: [],
                sortAscending: nil
            )
            #expect(result.count == 3)
        }
    }

    @Test
    func categoryFilterMatchesAnySelectedValue() {
        let result = FilterPipeline.apply(
            pokemons: all,
            searchQuery: "",
            filter: .type,
            selectedCategories: ["flying"],
            sortAscending: nil
        )

        #expect(result.map(\.id) == [6])
    }

    @Test
    func categoryFilterIgnoredWithoutSelection() {
        let result = FilterPipeline.apply(
            pokemons: all,
            searchQuery: "",
            filter: .type,
            selectedCategories: [],
            sortAscending: nil
        )

        #expect(result.count == 3)
    }

    @Test
    func sortsBySelectedStatInBothDirections() {
        let withStats = [
            Pokemon(id: 1, name: "a", stats: PokemonStats(hp: 30, attack: 10, defense: 10, specialAttack: 10, specialDefense: 10, speed: 10, total: 80)),
            Pokemon(id: 2, name: "b", stats: PokemonStats(hp: 55, attack: 40, defense: 30, specialAttack: 30, specialDefense: 30, speed: 45, total: 230)),
        ]

        let ascending = FilterPipeline.apply(
            pokemons: withStats,
            searchQuery: "",
            filter: .hp,
            selectedCategories: [],
            sortAscending: true
        )
        let descending = FilterPipeline.apply(
            pokemons: withStats,
            searchQuery: "",
            filter: .hp,
            selectedCategories: [],
            sortAscending: false
        )

        #expect(ascending.map(\.id) == [1, 2])
        #expect(descending.map(\.id) == [2, 1])
    }

    @Test
    func defaultDirectionMatchesAndroidBehavior() {
        #expect(FilterPipeline.defaultDirection(for: .all, current: nil) == nil)
        #expect(FilterPipeline.defaultDirection(for: .alphabet, current: false) == true)
        #expect(FilterPipeline.defaultDirection(for: .id, current: nil) == true)
        #expect(FilterPipeline.defaultDirection(for: .hp, current: nil) == false)
        #expect(FilterPipeline.defaultDirection(for: .speed, current: true) == false)
        #expect(FilterPipeline.defaultDirection(for: .type, current: true) == true)
    }
}
