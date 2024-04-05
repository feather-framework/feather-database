//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseTableQueryCount: DatabaseTableQuery {

    func count(
        filter: QueryFieldFilter<Row.FieldKeys>?
    ) async throws -> UInt
}

extension DatabaseTableQueryCount {

    public func count(
        filter: QueryFieldFilter<Row.FieldKeys>? = nil
    ) async throws -> UInt {
        try await db.run { sql in
            try await sql
                .select()
                .from(Self.name)
                .column(SQLFunction("COUNT"), as: "count")
                .applyFilter(filter)
                .first(decoding: RowCount.self)?
                .count ?? 0
        }
    }
}
