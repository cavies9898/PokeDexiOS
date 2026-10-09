import Foundation

enum TypesCSV {
    static func serialize(_ types: [String]) -> String {
        types.joined(separator: ",")
    }

    static func deserialize(_ csv: String) -> [String] {
        csv.components(separatedBy: ",")
    }
}
