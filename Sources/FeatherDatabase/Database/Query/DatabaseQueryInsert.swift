//
//  File.swift
//
//
//  Created by Tibor Bodecs on 06/01/2024.
//

import Algorithms
import SQLKit

public protocol DatabaseQueryInsert: DatabaseQueryInterface {

    static func insert(
        _ row: Row,
        on db: Database
    ) async throws

    static func insert(
        _ rows: [Row],
        chunkSize: Int,
        on db: Database
    ) async throws
}

extension DatabaseQueryInsert {

    public static func insert(
        _ row: Row,
        on db: Database
    ) async throws {
        try await insert([row], on: db)
    }

    public static func insert(
        _ rows: [Row],
        chunkSize: Int = 100,
        on db: Database
    ) async throws {
        try await db.run { sql in
            for items in rows.chunks(ofCount: chunkSize) {
                try await sql
                    .insert(into: Row.tableName)
                    .models(Array(items), nilEncodingStrategy: .asNil)
                    .run()
            }
        }
    }
}
