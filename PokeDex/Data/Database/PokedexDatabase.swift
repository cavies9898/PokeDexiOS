import Foundation

actor PokedexDatabase {
    private let connection: SQLiteConnection
    private var cachedPokemons: [Pokemon]?

    init() throws {
        let url = try DatabaseHelper.pokedexDatabaseURL()
        connection = try SQLiteConnection(path: url.path, readOnly: true)
    }

    func rows(_ sql: String, params: [SQLiteValue] = []) async throws -> [SQLiteRow] {
        try connection.rows(sql, params: params)
    }

    func firstRow(_ sql: String, params: [SQLiteValue] = []) async throws -> SQLiteRow? {
        try connection.firstRow(sql, params: params)
    }

    func loadCachedPokemons() -> [Pokemon]? {
        cachedPokemons
    }

    func storePokemons(_ pokemons: [Pokemon]) {
        cachedPokemons = pokemons
    }
}
