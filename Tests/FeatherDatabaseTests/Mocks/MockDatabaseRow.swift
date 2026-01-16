//
//  MockDatabaseRow.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import FeatherDatabase

struct MockDatabaseRow: DatabaseRow {

    private struct ColumnKey: CodingKey {
        let stringValue: String
        let intValue: Int? = nil

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }
    }

    enum Value: Sendable {
        case int(Int)
        case string(String)
    }

    let storage: [String: Value]

    func decode<T: Decodable>(
        column: String,
        as: T.Type
    ) throws(DecodingError) -> T {
        let key = ColumnKey(stringValue: column)

        guard let value = storage[column] else {
            throw DecodingError.keyNotFound(
                key,
                .init(
                    codingPath: [key],
                    debugDescription: "Missing column value."
                )
            )
        }

        switch value {
        case .int(let value):
            guard let typed = value as? T else {
                throw DecodingError.typeMismatch(
                    T.self,
                    .init(
                        codingPath: [ColumnKey(stringValue: column)],
                        debugDescription: "Type mismatch for column value."
                    )
                )
            }
            return typed
        case .string(let value):
            guard let typed = value as? T else {
                throw DecodingError.typeMismatch(
                    T.self,
                    .init(
                        codingPath: [ColumnKey(stringValue: column)],
                        debugDescription: "Type mismatch for column value."
                    )
                )
            }
            return typed
        }
    }
}
