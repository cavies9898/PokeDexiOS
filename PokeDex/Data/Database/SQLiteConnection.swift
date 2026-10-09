import Foundation
import SQLite3

private let sqlTransient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

final class SQLiteConnection: @unchecked Sendable {
    private let db: OpaquePointer

    nonisolated init(path: String, readOnly: Bool) throws {
        var handle: OpaquePointer?
        let flags = readOnly
            ? SQLITE_OPEN_READONLY
            : SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX
        let result = sqlite3_open_v2(path, &handle, flags, nil)
        guard result == SQLITE_OK, let handle else {
            let message = handle.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "Unable to open database"
            if let handle { sqlite3_close(handle) }
            throw SQLiteError(code: result, message: message)
        }
        db = handle
    }

    deinit {
        sqlite3_close_v2(db)
    }

    nonisolated func rows(_ sql: String, params: [SQLiteValue] = []) throws -> [SQLiteRow] {
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        try bind(params, to: statement)

        var result: [SQLiteRow] = []
        while true {
            let step = sqlite3_step(statement)
            if step == SQLITE_ROW {
                result.append(readRow(statement))
            } else if step == SQLITE_DONE {
                break
            } else {
                throw currentError(code: step)
            }
        }
        return result
    }

    nonisolated func firstRow(_ sql: String, params: [SQLiteValue] = []) throws -> SQLiteRow? {
        try rows(sql, params: params).first
    }

    nonisolated func execute(_ sql: String, params: [SQLiteValue] = []) throws {
        let statement = try prepare(sql)
        defer { sqlite3_finalize(statement) }
        try bind(params, to: statement)
        let step = sqlite3_step(statement)
        guard step == SQLITE_DONE || step == SQLITE_ROW else {
            throw currentError(code: step)
        }
    }

    nonisolated func transaction<T>(_ body: () throws -> T) throws -> T {
        try execute("BEGIN IMMEDIATE TRANSACTION;")
        do {
            let value = try body()
            try execute("COMMIT TRANSACTION;")
            return value
        } catch {
            try? execute("ROLLBACK TRANSACTION;")
            throw error
        }
    }

    nonisolated var lastInsertedRowId: Int64 {
        sqlite3_last_insert_rowid(db)
    }

    nonisolated var changes: Int {
        Int(sqlite3_changes(db))
    }

    private nonisolated func prepare(_ sql: String) throws -> OpaquePointer {
        var statement: OpaquePointer?
        let result = sqlite3_prepare_v2(db, sql, -1, &statement, nil)
        guard result == SQLITE_OK, let statement else {
            throw currentError(code: result)
        }
        return statement
    }

    private nonisolated func bind(_ params: [SQLiteValue], to statement: OpaquePointer) throws {
        for (index, value) in params.enumerated() {
            let position = Int32(index + 1)
            let result: Int32
            switch value {
            case .integer(let number):
                result = sqlite3_bind_int64(statement, position, number)
            case .real(let number):
                result = sqlite3_bind_double(statement, position, number)
            case .text(let string):
                result = sqlite3_bind_text(statement, position, string, -1, sqlTransient)
            case .null:
                result = sqlite3_bind_null(statement, position)
            }
            guard result == SQLITE_OK else {
                throw currentError(code: result)
            }
        }
    }

    private nonisolated func readRow(_ statement: OpaquePointer) -> SQLiteRow {
        let columnCount = sqlite3_column_count(statement)
        var values: [String: SQLiteValue] = [:]
        values.reserveCapacity(Int(columnCount))

        for index in 0..<columnCount {
            guard let namePointer = sqlite3_column_name(statement, index) else { continue }
            let name = String(cString: namePointer)
            switch sqlite3_column_type(statement, index) {
            case SQLITE_INTEGER:
                values[name] = .integer(sqlite3_column_int64(statement, index))
            case SQLITE_FLOAT:
                values[name] = .real(sqlite3_column_double(statement, index))
            case SQLITE_TEXT:
                if let text = sqlite3_column_text(statement, index) {
                    values[name] = .text(String(cString: text))
                } else {
                    values[name] = .null
                }
            default:
                values[name] = .null
            }
        }
        return SQLiteRow(values: values)
    }

    private nonisolated func currentError(code: Int32) -> SQLiteError {
        SQLiteError(code: code, message: String(cString: sqlite3_errmsg(db)))
    }
}
