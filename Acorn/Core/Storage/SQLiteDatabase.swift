import Foundation
import SQLite3

final class SQLiteDatabase {
    private var database: OpaquePointer?
    private let dateFormatter = ISO8601DateFormatter()

    init(url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        guard sqlite3_open(url.path, &database) == SQLITE_OK else {
            throw StorageError.openFailed(message: errorMessage)
        }

        try execute("PRAGMA foreign_keys = ON;")
    }

    deinit {
        sqlite3_close(database)
    }

    func migrate() throws {
        try execute(
            """
            CREATE TABLE IF NOT EXISTS installed_apps (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL UNIQUE,
              template_id TEXT NOT NULL,
              status TEXT NOT NULL,
              manifest_id TEXT NOT NULL,
              created_at DATETIME NOT NULL,
              updated_at DATETIME NOT NULL
            );
            """
        )

        // Non-destructive column addition for existing databases
        try? execute("ALTER TABLE installed_apps ADD COLUMN error_message TEXT;")

        try execute(
            """
            CREATE TABLE IF NOT EXISTS manifests (
              id TEXT PRIMARY KEY,
              app_id TEXT NOT NULL,
              schema_version TEXT NOT NULL,
              manifest_yaml TEXT NOT NULL,
              created_at DATETIME NOT NULL,
              updated_at DATETIME NOT NULL
            );
            """
        )
    }

    func execute(_ sql: String) throws {
        guard sqlite3_exec(database, sql, nil, nil, nil) == SQLITE_OK else {
            throw StorageError.executionFailed(message: errorMessage)
        }
    }

    func prepare(_ sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK else {
            throw StorageError.executionFailed(message: errorMessage)
        }
        return statement
    }

    func bind(_ text: String, to statement: OpaquePointer?, at index: Int32) {
        sqlite3_bind_text(statement, index, text, -1, SQLITE_TRANSIENT)
    }

    func bind(_ date: Date, to statement: OpaquePointer?, at index: Int32) {
        bind(dateFormatter.string(from: date), to: statement, at: index)
    }

    func text(from statement: OpaquePointer?, at index: Int32) -> String {
        guard let value = sqlite3_column_text(statement, index) else {
            return ""
        }

        return String(cString: value)
    }

    func date(from statement: OpaquePointer?, at index: Int32) -> Date {
        dateFormatter.date(from: text(from: statement, at: index)) ?? Date(timeIntervalSince1970: 0)
    }

    var errorMessage: String {
        guard let message = sqlite3_errmsg(database) else {
            return "Unknown SQLite error"
        }

        return String(cString: message)
    }
}

enum StorageError: LocalizedError {
    case openFailed(message: String)
    case executionFailed(message: String)
    case stepFailed(message: String)

    var errorDescription: String? {
        switch self {
        case .openFailed(let message), .executionFailed(let message), .stepFailed(let message):
            message
        }
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
