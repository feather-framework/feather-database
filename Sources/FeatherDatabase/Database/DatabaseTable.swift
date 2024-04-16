//
//  File.swift
//
//
//  Created by mzperx on 11/04/2024.
//

public protocol DatabaseTable {
    static var tableName: String { get }
    static var columns: [DatabaseColumnInterface] { get }
    static var constraints: [DatabaseConstraintInterface] { get }

    static func create(on db: Database) async throws
    static func drop(on db: Database) async throws
}

extension DatabaseTable {

    public static var constraints: [DatabaseConstraintInterface] {
        []
    }

    public static func create(on db: Database) async throws {
        let sql = db.sqlDatabase.create(table: tableName)
        for constraint in constraints {
            sql.createTable.tableConstraints.append(constraint.sqlConstraint)
        }
        try await sql.build(columns).run()
    }

    public static func drop(on db: Database) async throws {
        try await db.sqlDatabase.drop(table: tableName).run()
    }
}
