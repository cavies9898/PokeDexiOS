import Foundation

enum SQLiteValue: Sendable, Equatable {
    case integer(Int64)
    case real(Double)
    case text(String)
    case null
}

struct SQLiteRow: Sendable {
    private let values: [String: SQLiteValue]

    init(values: [String: SQLiteValue]) {
        self.values = values
    }

    func int(_ column: String) -> Int {
        if case .integer(let value) = values[column] { return Int(value) }
        return 0
    }

    func optionalInt(_ column: String) -> Int? {
        switch values[column] {
        case .integer(let value): Int(value)
        case .real(let value): Int(value)
        default: nil
        }
    }

    func double(_ column: String) -> Double {
        switch values[column] {
        case .real(let value): value
        case .integer(let value): Double(value)
        default: 0.0
        }
    }

    func text(_ column: String) -> String {
        if case .text(let value) = values[column] { return value }
        return ""
    }

    func optionalText(_ column: String) -> String? {
        if case .text(let value) = values[column] { return value }
        return nil
    }

    func isNull(_ column: String) -> Bool {
        values[column] == nil || values[column] == .null
    }
}

struct SQLiteError: LocalizedError, Equatable {
    let code: Int32
    let message: String

    var errorDescription: String? { message }
}
