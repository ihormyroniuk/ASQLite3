import XCTest
import SQLite3
@testable import ASQLite3

class ASQLite3UnitTesting: XCTestCase {
    
    func testExample() throws {
        let sqliteDatabaseUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("hhhhh.sqlite")
        print("fdf \(sqliteDatabaseUrl)")
        try FileManager.default.removeItem(at: sqliteDatabaseUrl)
        let databaseConnection = try sqlite3Open(sqliteDatabaseUrl.path)
        
        let statementCreate =
            """
            CREATE TABLE
            category(
                id TEXT PRIMARY KEY,
                name TEXT
            );
            """
        let preparedStatementCreate = try sqlite3PrepareV2(databaseConnection, statementCreate)
        try sqlite3StepDone(preparedStatementCreate)
        try sqlite3Finalize(preparedStatementCreate)
        
        let statement =
            """
            INSERT INTO category(id, name)
            VALUES (?, ?);
            """
        let preparedStatement = try sqlite3PrepareV2(databaseConnection, statement)
        try sqlite3Bind(databaseConnection, [.text("2"), .text("name2")])
        try sqlite3StepDone(preparedStatement)
        try sqlite3Finalize(preparedStatement)
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
