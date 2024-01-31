import Foundation
import SQLite3

public let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
public let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

public func sqlite3Open(_ filename: String) throws -> OpaquePointer {
    var databaseConnection: OpaquePointer!
    let resultCode = sqlite3_open(filename, &databaseConnection)
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
    return databaseConnection
}

public func sqlite3OpenV2(_ filename: String, flags: Int32, zVfs: String?) throws -> OpaquePointer {
    var databaseConnection: OpaquePointer!
    let resultCode = sqlite3_open_v2(filename, &databaseConnection, flags, zVfs)
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
    return databaseConnection
}

public func sqlite3Close(_ databaseConnection: OpaquePointer) throws {
    let resultCode = sqlite3_close(databaseConnection)
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
}

public func sqlite3CloseV2(_ databaseConnection: OpaquePointer) throws {
    let resultCode = sqlite3_close(databaseConnection)
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
}

public func sqlite3PrepareV2(_ databaseConnection: OpaquePointer, _ statement: String) throws -> OpaquePointer {
    let utf8Statement = (statement as NSString).utf8String
    var preparedStatement: OpaquePointer!
    let resultCode = sqlite3_prepare_v2(databaseConnection, utf8Statement, -1, &preparedStatement, nil)
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
    return preparedStatement
}

public func sqlite3StepDone(_ preparedStatement: OpaquePointer) throws {
    let resultCode = sqlite3_step(preparedStatement)
    if resultCode != SQLITE_DONE {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
}

public func sqlite3StepRow(_ preparedStatement: OpaquePointer) throws -> Bool {
    let resultCode = sqlite3_step(preparedStatement)
    if resultCode == SQLITE_ROW {
        return true
    } else if resultCode == SQLITE_DONE {
        return false
    } else {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
}

public func sqlite3Finalize(_ preparedStatement: OpaquePointer) throws {
    let resultCode = sqlite3_finalize(preparedStatement)
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
}

// MARK: - Bind

public func sqlite3BindTextNull(_ preparedStatement: OpaquePointer, _ index: Int32, _ value: String?) throws {
    if let value = value {
        let utf8String = (value as NSString).utf8String
        let resultCode = sqlite3_bind_text(preparedStatement, index, utf8String, -1, SQLITE_TRANSIENT)
        if resultCode != SQLITE_OK {
            let errorCode = resultCode
            let errorMessage = String(cString: sqlite3_errstr(resultCode))
            throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
        }
    } else {
        let resultCode = sqlite3_bind_null(preparedStatement, index)
        if resultCode != SQLITE_OK {
            let errorCode = resultCode
            let errorMessage = String(cString: sqlite3_errstr(resultCode))
            throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
        }
    }
}

public func sqlite3BindText(_ preparedStatement: OpaquePointer, _ index: Int32, _ value: String) throws {
    let utf8String = (value as NSString).utf8String
    let resultCode = sqlite3_bind_text(preparedStatement, index, utf8String, -1, SQLITE_TRANSIENT)
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
}

public func sqlite3BindInt64(_ preparedStatement: OpaquePointer, _ index: Int32, _ value: Int64) throws {
    let resultCode = sqlite3_bind_int64(preparedStatement, index, value)
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
}

public func sqlite3BindDouble(_ preparedStatement: OpaquePointer, _ index: Int32, _ value: Double) throws {
    let resultCode = sqlite3_bind_double(preparedStatement, index, value)
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
}

public func sqlite3BindBlob(_ preparedStatement: OpaquePointer, _ index: Int32, _ value: Data) throws {
    let resultCode = value.withUnsafeBytes({ bufferPointer -> Int32 in
        return sqlite3_bind_blob(preparedStatement, index, bufferPointer.baseAddress, Int32(value.count), SQLITE_TRANSIENT)
    })
    if resultCode != SQLITE_OK {
        let errorCode = resultCode
        let errorMessage = String(cString: sqlite3_errstr(resultCode))
        throw Error("SQLite3 failure: \(errorCode) \(errorMessage)")
    }
}

public struct BoundParameter {
    let index: Int32
    enum Value {
        case textNull(String?)
        case text(String)
        case int64(Int64)
        case double(Double)
        case blob(Data)
    }
    let value: Value
}
public func sqlite3Bind(_ preparedStatement: OpaquePointer, _ parameter: BoundParameter) throws {
    let index = parameter.index
    let value = parameter.value
    switch value {
    case .textNull(let value):
        try sqlite3BindTextNull(preparedStatement, index, value)
    case .text(let value):
        try sqlite3BindText(preparedStatement, index, value)
    case .int64(let value):
        try sqlite3BindInt64(preparedStatement, index, value)
    case .double(let value):
        try sqlite3BindDouble(preparedStatement, index, value)
    case .blob(let value):
        try sqlite3BindBlob(preparedStatement, index, value)
    }
}
public func sqlite3Bind(_ preparedStatement: OpaquePointer, _ parameters: [BoundParameter]) throws {
    for parameter in parameters {
        try sqlite3Bind(preparedStatement, parameter)
    }
}

// MARK: - Column

public func sqlite3ColumnText(_ preparedStatement: OpaquePointer, _ columnIndex: Int32) throws -> String {
    let columnType = sqlite3_column_type(preparedStatement, columnIndex)
    if columnType == SQLITE_TEXT {
        if let value = sqlite3_column_text(preparedStatement, columnIndex) {
            let string = String(cString: value)
            return string
        } else {
            throw Error("Unexpected nil value")
        }
    } else {
        throw Error("Unexpected column type \(columnType)")
    }
}

public func sqlite3ColumnTextNull(_ preparedStatement: OpaquePointer, _ columnIndex: Int32) throws -> String? {
    let columnType = sqlite3_column_type(preparedStatement, columnIndex)
    if columnType == SQLITE_TEXT {
        if let value = sqlite3_column_text(preparedStatement, columnIndex) {
            let string = String(cString: value)
            return string
        } else {
            throw Error("Unexpected nil value")
        }
    } else if columnType == SQLITE_NULL {
        return nil
    } else {
        throw Error("Unexpected column type \(String(reflecting: columnType))")
    }
}

public func sqlite3ColumnInt64(_ preparedStatement: OpaquePointer, _ columnIndex: Int32) throws -> Int64 {
    let columnType = sqlite3_column_type(preparedStatement, columnIndex)
    if columnType == SQLITE_INTEGER {
        let value = sqlite3_column_int64(preparedStatement, columnIndex)
        return value
    } else {
        throw Error("Unexpected column type \(String(reflecting: columnType))")
    }
}

public func sqlite3ColumnInt64Null(_ preparedStatement: OpaquePointer, _ columnIndex: Int32) throws -> Int64? {
    let columnType = sqlite3_column_type(preparedStatement, columnIndex)
    if columnType == SQLITE_INTEGER {
        let value = sqlite3_column_int64(preparedStatement, columnIndex)
        return value
    } else if columnType == SQLITE_NULL {
        return nil
    } else {
        throw Error("Unexpected column type \(String(reflecting: columnType))")
    }
}

public func sqlite3ColumnDouble(_ preparedStatement: OpaquePointer, _ columnIndex: Int32) throws -> Double {
    let columnType = sqlite3_column_type(preparedStatement, columnIndex)
    if columnType == SQLITE_FLOAT {
        let value = sqlite3_column_double(preparedStatement, columnIndex)
        return value
    } else {
        throw Error("Unexpected column type \(String(reflecting: columnType))")
    }
}

public func sqlite3ColumnDoubleNull(_ preparedStatement: OpaquePointer, _ columnIndex: Int32) throws -> Double? {
    let columnType = sqlite3_column_type(preparedStatement, columnIndex)
    if columnType == SQLITE_FLOAT {
        let value = sqlite3_column_double(preparedStatement, columnIndex)
        return value
    } else if columnType == SQLITE_NULL {
        return nil
    } else {
        throw Error("Unexpected column type \(String(reflecting: columnType))")
    }
}

public func sqlite3ColumnBlob(_ preparedStatement: OpaquePointer, _ columnIndex: Int32) throws -> Data {
    let columnType = sqlite3_column_type(preparedStatement, columnIndex)
    if columnType == SQLITE_BLOB {
        let bytesCount = sqlite3_column_bytes(preparedStatement, columnIndex)
        guard bytesCount > 0 else {
            throw Error("Data is empty for \(String(reflecting: columnType))")
        }
        guard let blob = sqlite3_column_blob(preparedStatement, columnIndex) else {
            throw Error("Unable to load blob for \(String(reflecting: columnType))")
        }
        let data = Data(bytes: blob, count: Int(bytesCount))
        return data
    } else {
        throw Error("Unexpected column type \(String(reflecting: columnType))")
    }
}

public func sqlite3ColumnBlobNull(_ preparedStatement: OpaquePointer, _ columnIndex: Int32) throws -> Data? {
    let columnType = sqlite3_column_type(preparedStatement, columnIndex)
    if columnType == SQLITE_BLOB {
        let bytesCount = sqlite3_column_bytes(preparedStatement, columnIndex)
        guard bytesCount > 0 else {
            return nil
        }
        guard let blob = sqlite3_column_blob(preparedStatement, columnIndex) else {
            return nil
        }
        let data = Data(bytes: blob, count: Int(bytesCount))
        return data
    } else if columnType == SQLITE_NULL {
        return nil
    } else {
        throw Error("Unexpected column type \(String(reflecting: columnType))")
    }
}
