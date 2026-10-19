//
//  DatabaseRow.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

/// A database row that can decode column values.
///
/// Conforming types provide type-safe decoding for column values.
public protocol DatabaseRow: Sendable {

    /// The names of the columns available in this row.
    var columns: [String] { get }

    /// Returns whether this row contains a column with the given name.
    func contains(column: String) -> Bool

    /// Returns whether the given column is SQL `NULL`.
    ///
    /// Missing columns should throw `DecodingError.keyNotFound`.
    func decodeNil(column: String) throws(DecodingError) -> Bool

    /// Decode a column value as the given type.
    ///
    /// This method converts the column value into a `Decodable` type.
    /// - Parameters:
    ///   - column: The column name to decode.
    ///   - as: The expected type to decode as.
    /// - Throws: A `DecodingError` if the value cannot be decoded.
    /// - Returns: The decoded value.
    func decode<T: Decodable>(
        column: String,
        as: T.Type
    ) throws(DecodingError) -> T
}

extension DatabaseRow {

    /// Decode this row into a flat `Decodable` value.
    public func decode<T: Decodable>(
        model type: T.Type,
        with decoder: DatabaseRowDecoder = .init()
    ) throws -> T {
        try decoder.decode(type, from: self)
    }
}
