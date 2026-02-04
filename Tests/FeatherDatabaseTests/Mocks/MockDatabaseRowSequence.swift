//
//  MockDatabaseRowSequence.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import FeatherDatabase

struct MockDatabaseRowSequence: DatabaseRowSequence {

    let rows: [MockDatabaseRow]

    struct Iterator: AsyncIteratorProtocol, Sendable {
        private let rows: [MockDatabaseRow]
        private var index: Int

        init(rows: [MockDatabaseRow], index: Int = 0) {
            self.rows = rows
            self.index = index
        }

        mutating func next() async throws -> MockDatabaseRow? {
            guard index < rows.count else {
                return nil
            }
            defer { index += 1 }
            return rows[index]
        }
    }

    func collect() async throws(DatabaseError) -> [Element] {
        rows
    }

    func makeAsyncIterator() -> Iterator {
        Iterator(rows: rows)
    }
}
