import Foundation

enum DisplayNameFormatter {
    static func displayName(identifier: String, speciesName: String?) -> String {
        guard identifier.contains("-") else {
            return speciesName ?? ""
        }
        return identifier
            .split(separator: "-")
            .map { part -> String in
                guard let first = part.first else { return "" }
                return first.uppercased() + String(part.dropFirst())
            }
            .joined(separator: " ")
    }
}
