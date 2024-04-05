//
//  File.swift
//
//
//  Created by Tibor Bodecs on 06/01/2024.
//

import SQLKit

extension Array {

    fileprivate func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size)
            .map {
                Array(self[$0..<Swift.min($0 + size, count)])
            }
    }
}

public protocol DatabaseTableQueryInsert: DatabaseTableQuery {

    func insert(_ row: Row) async throws
    func insert(_ rows: [Row], chunkSize: Int) async throws
}

extension DatabaseTableQueryInsert {

    public func insert(_ row: Row) async throws {
        try await insert([row])
    }

    public func insert(_ rows: [Row], chunkSize: Int = 100) async throws {
        try await db.run { sql in
            for items in rows.chunked(into: chunkSize) {
                try await sql
                    .insert(into: Self.name)
                    .models(items, nilEncodingStrategy: .asNil)
                    .run()
            }
        }
    }
}
