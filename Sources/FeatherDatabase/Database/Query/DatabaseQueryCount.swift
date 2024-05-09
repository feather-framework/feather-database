//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseQueryCount: DatabaseQueryInterface {

    static func count(
        filter: DatabaseFilter<Row.ColumnNames>?,
        on db: Database
    ) async throws -> UInt

    static func count(
        filter: DatabaseTableFilter<Row.ColumnNames>,
        on db: Database
    ) async throws -> UInt
}

extension DatabaseQueryCount {

    public static func count(
        filter: DatabaseFilter<Row.ColumnNames>? = nil,
        on db: Database
    ) async throws -> UInt {
        if let filter {
            return try await count(
                filter: .init(groups: [.init(columns: [filter])]),
                on: db
            )
        }

        return try await count(filter: .init(groups: []), on: db)
    }

    public static func count(
        filter: DatabaseTableFilter<Row.ColumnNames>,
        on db: Database
    ) async throws -> UInt {
        try await db.run { sql in
            let value =
                try await sql
                .select()
                .from(Row.tableName)
                .column(
                    SQLFunction("COUNT", args: SQLLiteral.all),
                    as: "count"
                )
                .applyFilter(filter)
                .first(decodingColumn: "count", as: Int.self) ?? 0
            return UInt(value)
        }
    }
}
