import Foundation
import SQLite3

/// SQLite3 輔助工具，封裝常用 binding 邏輯
final class SQLiteHelper {
    
    // MARK: - String Binding
    
    /// Bind required string value
    static func bindString(_ statement: OpaquePointer?, _ index: Int32, _ value: String) {
        sqlite3_bind_text(statement, index, (value as NSString).utf8String, -1, nil)
    }
    
    /// Bind optional string value
    static func bindOptionalString(_ statement: OpaquePointer?, _ index: Int32, _ value: String?) {
        if let value = value {
            sqlite3_bind_text(statement, index, (value as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, index)
        }
    }
    
    // MARK: - Int Binding
    
    /// Bind Int value
    static func bindInt(_ statement: OpaquePointer?, _ index: Int32, _ value: Int) {
        sqlite3_bind_int(statement, index, Int32(value))
    }
    
    /// Bind optional Int value
    static func bindOptionalInt(_ statement: OpaquePointer?, _ index: Int32, _ value: Int?) {
        if let value = value {
            sqlite3_bind_int(statement, index, Int32(value))
        } else {
            sqlite3_bind_null(statement, index)
        }
    }
    
    // MARK: - Double Binding
    
    /// Bind Double value
    static func bindDouble(_ statement: OpaquePointer?, _ index: Int32, _ value: Double) {
        sqlite3_bind_double(statement, index, value)
    }
    
    // MARK: - Date Binding
    
    /// Bind required Date value (as Unix timestamp)
    static func bindDate(_ statement: OpaquePointer?, _ index: Int32, _ value: Date) {
        sqlite3_bind_double(statement, index, value.timeIntervalSince1970)
    }
    
    /// Bind optional Date value
    static func bindOptionalDate(_ statement: OpaquePointer?, _ index: Int32, _ value: Date?) {
        if let value = value {
            sqlite3_bind_double(statement, index, value.timeIntervalSince1970)
        } else {
            sqlite3_bind_null(statement, index)
        }
    }
    
    // MARK: - Bool Binding
    
    /// Bind Bool value as integer (0 or 1)
    static func bindBool(_ statement: OpaquePointer?, _ index: Int32, _ value: Bool) {
        sqlite3_bind_int(statement, index, value ? 1 : 0)
    }
    
    // MARK: - Enum Binding (RawValue as String)
    
    /// Bind RawRepresentable enum as string
    static func bindEnum<T: RawRepresentable>(_ statement: OpaquePointer?, _ index: Int32, _ value: T) where T.RawValue == String {
        sqlite3_bind_text(statement, index, (value.rawValue as NSString).utf8String, -1, nil)
    }
    
    /// Bind optional RawRepresentable enum as string
    static func bindOptionalEnum<T: RawRepresentable>(_ statement: OpaquePointer?, _ index: Int32, _ value: T?) where T.RawValue == String {
        if let value = value {
            sqlite3_bind_text(statement, index, (value.rawValue as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, index)
        }
    }
    
    // MARK: - JSON String Binding
    
    /// Encode and bind Codable object as JSON string
    static func bindJSON<T: Encodable>(_ statement: OpaquePointer?, _ index: Int32, _ value: T?) {
        if let value = value,
           let data = try? JSONEncoder().encode(value),
           let string = String(data: data, encoding: .utf8) {
            sqlite3_bind_text(statement, index, (string as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, index)
        }
    }
    
    /// Encode and bind Array as JSON string
    static func bindJSONArray<T: Encodable>(_ statement: OpaquePointer?, _ index: Int32, _ value: [T]) {
        if let data = try? JSONEncoder().encode(value),
           let string = String(data: data, encoding: .utf8) {
            sqlite3_bind_text(statement, index, (string as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_text(statement, index, ("[]" as NSString).utf8String, -1, nil)
        }
    }
    
    // MARK: - Reading Helpers
    
    /// Read string from statement at column
    static func readString(_ statement: OpaquePointer?, _ column: Int32) -> String {
        guard let text = sqlite3_column_text(statement, column) else { return "" }
        return String(cString: text)
    }
    
    /// Read optional string from statement at column
    static func readOptionalString(_ statement: OpaquePointer?, _ column: Int32) -> String? {
        guard sqlite3_column_type(statement, column) != SQLITE_NULL,
              let text = sqlite3_column_text(statement, column) else { return nil }
        return String(cString: text)
    }
    
    /// Read Int from statement at column
    static func readInt(_ statement: OpaquePointer?, _ column: Int32) -> Int {
        return Int(sqlite3_column_int(statement, column))
    }
    
    /// Read optional Int from statement at column
    static func readOptionalInt(_ statement: OpaquePointer?, _ column: Int32) -> Int? {
        guard sqlite3_column_type(statement, column) != SQLITE_NULL else { return nil }
        return Int(sqlite3_column_int(statement, column))
    }
    
    /// Read Double from statement at column
    static func readDouble(_ statement: OpaquePointer?, _ column: Int32) -> Double {
        return sqlite3_column_double(statement, column)
    }
    
    /// Read Bool from statement at column (stored as Int)
    static func readBool(_ statement: OpaquePointer?, _ column: Int32) -> Bool {
        return sqlite3_column_int(statement, column) == 1
    }
    
    /// Read Date from statement at column (stored as Unix timestamp)
    static func readDate(_ statement: OpaquePointer?, _ column: Int32) -> Date {
        return Date(timeIntervalSince1970: sqlite3_column_double(statement, column))
    }
    
    /// Read optional Date from statement at column
    static func readOptionalDate(_ statement: OpaquePointer?, _ column: Int32) -> Date? {
        guard sqlite3_column_type(statement, column) != SQLITE_NULL else { return nil }
        return Date(timeIntervalSince1970: sqlite3_column_double(statement, column))
    }
    
    /// Read JSON decoded array from statement at column
    static func readJSONArray<T: Decodable>(_ statement: OpaquePointer?, _ column: Int32, as type: [T].Type) -> [T] {
        guard let text = sqlite3_column_text(statement, column),
              let data = String(cString: text).data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([T].self, from: data)) ?? []
    }
}