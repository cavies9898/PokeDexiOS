import Testing
@testable import PokeDex

struct DisplayNameFormatterTests {
    @Test
    func hyphenatedIdentifiersAreSplitAndCapitalized() {
        #expect(DisplayNameFormatter.displayName(identifier: "mr-mime", speciesName: "mr.mime") == "Mr Mime")
        #expect(DisplayNameFormatter.displayName(identifier: "ho-oh", speciesName: "ho-oh") == "Ho Oh")
        #expect(
            DisplayNameFormatter.displayName(identifier: "charizard-mega-x", speciesName: "charizard")
                == "Charizard Mega X"
        )
        #expect(DisplayNameFormatter.displayName(identifier: "nidoran-f", speciesName: "nidoran♀") == "Nidoran F")
    }

    @Test
    func nonHyphenatedIdentifiersUseSpeciesName() {
        #expect(DisplayNameFormatter.displayName(identifier: "pikachu", speciesName: "pikachu") == "pikachu")
        #expect(DisplayNameFormatter.displayName(identifier: "bulbasaur", speciesName: "bulbasaur") == "bulbasaur")
    }

    @Test
    func missingSpeciesNameFallsBackToEmptyString() {
        #expect(DisplayNameFormatter.displayName(identifier: "pidgey", speciesName: nil) == "")
    }

    @Test
    func emptyPartsProduceEmptySegments() {
        #expect(DisplayNameFormatter.displayName(identifier: "-mime-", speciesName: nil) == "Mime")
    }
}

struct TypesCSVTests {
    @Test
    func roundTripsMultipleTypes() {
        let types = ["fire", "flying"]
        #expect(TypesCSV.deserialize(TypesCSV.serialize(types)) == types)
    }

    @Test
    func roundTripsSingleType() {
        #expect(TypesCSV.deserialize(TypesCSV.serialize(["water"])) == ["water"])
    }

    @Test
    func emptySerializationMatchesKotlinSplitBehavior() {
        #expect(TypesCSV.serialize([]) == "")
        #expect(TypesCSV.deserialize("") == [""])
    }

    @Test
    func tripleTypeRoundTrip() {
        let types = ["a", "b", "c"]
        #expect(TypesCSV.deserialize(TypesCSV.serialize(types)) == types)
    }
}
