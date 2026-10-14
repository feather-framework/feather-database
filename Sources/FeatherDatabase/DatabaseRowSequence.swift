//
//  DatabaseRowSequence.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

/// A sequence returned from a database query.
///
/// Use this protocol to iterate rows asynchronously or collect them eagerly.
public protocol DatabaseRowSequence:
    AsyncSequence,
    Sendable
where
    Element == Row
{
    /// A row type produced by the query.
    ///
    /// This row must conform to `DatabaseRow` for decoding support.
    associatedtype Row: DatabaseRow

    /// Collect all rows from the sequence.
    ///
    /// This method consumes the sequence and returns all elements.
    /// - Throws: An error if iteration fails.
    /// - Returns: An array of all rows produced by the query.
    func collect() async throws -> [Element]
}

extension DatabaseRowSequence {

    /// Returns the first row without collecting the rest of the result sequence.
    public func first() async throws -> Element? {
        for try await row in self {
            return row
        }
        return nil
    }

    /// Decodes the first row without collecting the rest of the result sequence.
    public func first<T: Decodable>(
        decoding type: T.Type,
        with decoder: DatabaseRowDecoder = .init()
    ) async throws -> T? {
        guard let row = try await first() else { return nil }
        return try row.decode(model: type, with: decoder)
    }

    /// Decodes each row as a flat `Decodable` value while consuming the sequence.
    public func decode<T: Decodable>(
        model type: T.Type,
        with decoder: DatabaseRowDecoder = .init()
    ) async throws -> [T] {
        var result: [T] = []
        for try await row in self {
            result.append(try row.decode(model: type, with: decoder))
        }
        return result
    }
}
