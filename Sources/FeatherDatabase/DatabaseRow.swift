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
