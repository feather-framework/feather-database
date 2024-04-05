//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseTableQueryDelete: DatabaseTableQuery {

    func delete(
        filter: QueryFieldFilter<Row.FieldKeys>
    ) async throws
}

extension DatabaseTableQueryDelete {

    public func delete(
        filter: QueryFieldFilter<Row.FieldKeys>
    ) async throws {
        try await db.run { sql in
            try await sql
                .delete(from: Self.name)
                .applyFilter(filter)
                .run()
        }
    }
}
