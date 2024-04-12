//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseQueryCount: DatabaseQuery {

    static func count(
        filter: QueryFieldFilter<Row.ColumnNames>?,
        on db: Database
    ) async throws -> UInt
}

extension DatabaseQueryCount {

    public static func count(
        filter: QueryFieldFilter<Row.ColumnNames>? = nil,
        on db: Database
    ) async throws -> UInt {
        try await db.run { sql in
            try await sql
                .select()
                .from(Row.tableName)
                .column(SQLFunction("COUNT"), as: "count")
                .applyFilter(filter)
                .first(decoding: RowCount.self)?
                .count ?? 0
        }
    }
}
