import Foundation

enum DatabaseHelper {
    private static let databaseFileName = "pokedex.db"

    nonisolated static func pokedexDatabaseURL() throws -> URL {
        let fileManager = FileManager.default
        let supportDirectory = fileManager
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PokeDex", isDirectory: true)
        let databaseURL = supportDirectory.appendingPathComponent(databaseFileName)

        if !fileManager.fileExists(atPath: databaseURL.path) {
            try fileManager.createDirectory(at: supportDirectory, withIntermediateDirectories: true)
            guard let bundled = Bundle.main.url(
                forResource: "pokedex",
                withExtension: "db"
            ) else {
                throw DomainError.databaseUnavailable
            }
            try fileManager.copyItem(at: bundled, to: databaseURL)
        }

        return databaseURL
    }

    nonisolated static func userDatabaseURL() throws -> URL {
        let fileManager = FileManager.default
        let supportDirectory = fileManager
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PokeDex", isDirectory: true)
        try fileManager.createDirectory(at: supportDirectory, withIntermediateDirectories: true)
        return supportDirectory.appendingPathComponent("pokedex_user.db")
    }
}
