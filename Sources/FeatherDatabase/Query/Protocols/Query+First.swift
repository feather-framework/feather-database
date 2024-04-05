//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseTableQueryFirst: DatabaseTableQuery {

    func first(
        filter: QueryFieldFilter<Row.FieldKeys>,
        order: QueryOrder<Row.FieldKeys>?
    ) async throws -> Row?
}

extension DatabaseTableQueryFirst {

    public func first(
        filter: QueryFieldFilter<Row.FieldKeys>,
        order: QueryOrder<Row.FieldKeys>? = nil
    ) async throws -> Row? {
        try await db.run { sql in
            try await sql
                .select()
                .from(Self.name)
                .column("*")
                .applyFilter(filter)
                .applyOrder(order)
                .limit(1)
                .offset(0)
                .first(decoding: Row.self)
        }
    }
}
