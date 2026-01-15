//
//  MySQLQuery.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import MySQLNIO

/// A MySQL query with SQL text and bound parameters.
///
/// Use this type to construct MySQL queries safely.
public struct MySQLQuery: DatabaseQuery {
    /// The SQL text to execute.
    ///
    /// This is the raw SQL string for the query.
    public var sql: String
    /// The bound parameters for the SQL text.
    ///
    /// These values are passed alongside `sql`.
    public var bindings: [MySQLData]

    /// Create a query from raw SQL and bindings.
    ///
    /// Prefer string interpolation initializers when possible to bind values.
    /// - Parameters:
    ///   - sql: The raw SQL string to execute.
    ///   - bindings: The bound parameters for the SQL.
    public init(
        unsafeSQL sql: String,
        bindings: [MySQLData] = []
    ) {
        self.sql = sql
        self.bindings = bindings
    }
}

extension MySQLQuery: ExpressibleByStringInterpolation {

    /// A string interpolation builder for MySQL queries.
    ///
    /// Use interpolation to bind values safely into SQL text.
    public struct StringInterpolation: StringInterpolationProtocol, Sendable {

        /// The string literal type used by the interpolation.
        ///
        /// This matches the standard `String` literal type.
        public typealias StringLiteralType = String

        @usableFromInline
        var sql: String

        @usableFromInline
        var binds: [MySQLData]

        /// Create a new interpolation buffer.
        ///
        /// Use the provided capacities to preallocate storage.
        /// - Parameters:
        ///   - literalCapacity: The expected literal character count.
        ///   - interpolationCount: The expected number of interpolations.
        public init(
            literalCapacity: Int,
            interpolationCount: Int
        ) {
            self.sql = ""
            self.sql.reserveCapacity(literalCapacity)
            self.binds = []
            self.binds.reserveCapacity(interpolationCount)
        }

        /// Append a literal string segment.
        ///
        /// This adds raw SQL text to the builder.
        /// - Parameter literal: The literal string segment.
        public mutating func appendLiteral(
            _ literal: String
        ) {
            self.sql.append(contentsOf: literal)
        }

        @inlinable
        /// Append an interpolated optional string value.
        ///
        /// Non-nil values are bound, and nil values emit `NULL`.
        /// - Parameter value: The optional string value to interpolate.
        public mutating func appendInterpolation(
            _ value: String?
        ) {
            switch value {
            case .some(let value):
                self.binds.append(.init(string: value))
                self.sql.append(contentsOf: "?")
            case .none:
                self.sql.append(contentsOf: "NULL")
            }
        }

        @inlinable
        /// Append an interpolated integer value.
        ///
        /// The value is bound as a MySQL integer.
        /// - Parameter value: The integer value to interpolate.
        public mutating func appendInterpolation(
            _ value: Int
        ) {
            self.binds.append(.init(int: value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        /// Append an interpolated floating-point value.
        ///
        /// The value is bound as a MySQL double.
        /// - Parameter value: The double value to interpolate.
        public mutating func appendInterpolation(
            _ value: Double
        ) {
            self.binds.append(.init(double: value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        /// Append an interpolated string value.
        ///
        /// The value is bound as a MySQL string.
        /// - Parameter value: The string value to interpolate.
        public mutating func appendInterpolation(
            _ value: String
        ) {
            self.binds.append(.init(string: value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        /// Append an interpolated MySQL data value.
        ///
        /// The value is bound directly as MySQL data.
        /// - Parameter value: The MySQL data value to interpolate.
        public mutating func appendInterpolation(
            _ value: MySQLData
        ) {
            self.binds.append(value)
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        public mutating func appendInterpolation(
            unescaped interpolated: String
        ) {
            self.sql.append(contentsOf: interpolated)
        }
    }

    /// Create a query from a string interpolation builder.
    ///
    /// This initializer is used by Swift string interpolation.
    /// - Parameter stringInterpolation: The interpolation builder.
    public init(
        stringInterpolation: StringInterpolation
    ) {
        self.sql = stringInterpolation.sql
        self.bindings = stringInterpolation.binds
    }

    /// Create a query from a string literal.
    ///
    /// This initializer does not add any bindings.
    /// - Parameter value: The literal SQL string.
    public init(
        stringLiteral value: String
    ) {
        self.sql = value
        self.bindings = []
    }
}
