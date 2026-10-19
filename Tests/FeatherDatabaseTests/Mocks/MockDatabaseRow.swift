//
//  MockDatabaseRow.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import FeatherDatabase
import Foundation

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
        case bool(Bool)
        case double(Double)
        case date(Date)
        case data(Data)
        case null
    }

    let storage: [String: Value]

    var columns: [String] { Array(storage.keys) }

    func contains(column: String) -> Bool {
        storage[column] != nil
    }

    func decodeNil(column: String) throws(DecodingError) -> Bool {
        guard let value = storage[column] else {
            throw DecodingError.keyNotFound(
                ColumnKey(stringValue: column),
                .init(codingPath: [], debugDescription: "Missing column value.")
            )
        }
        if case .null = value { return true }
        return false
    }

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
        case .bool(let value):
            guard let typed = value as? T else {
                throw DecodingError.typeMismatch(
                    T.self,
                    .init(
                        codingPath: [key],
                        debugDescription: "Type mismatch for column value."
                    )
                )
            }
            return typed
        case .double(let value):
            guard let typed = value as? T else {
                throw DecodingError.typeMismatch(
                    T.self,
                    .init(
                        codingPath: [key],
                        debugDescription: "Type mismatch for column value."
                    )
                )
            }
            return typed
        case .date(let value):
            guard let typed = value as? T else {
                throw DecodingError.typeMismatch(
                    T.self,
                    .init(
                        codingPath: [key],
                        debugDescription: "Type mismatch for column value."
                    )
                )
            }
            return typed
        case .data(let value):
            guard let typed = value as? T else {
                throw DecodingError.typeMismatch(
                    T.self,
                    .init(
                        codingPath: [key],
                        debugDescription: "Type mismatch for column value."
                    )
                )
            }
            return typed
        case .null:
            throw DecodingError.valueNotFound(
                T.self,
                .init(
                    codingPath: [key],
                    debugDescription: "Column value is SQL NULL."
                )
            )
        }
    }
}
