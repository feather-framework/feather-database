//
//  SQLiteQuery.swift
//  Feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import SQLiteNIO

/// A SQLite query with SQL text and bound parameters.
///
/// Use this type to construct SQLite queries safely.
public struct SQLiteQuery: DatabaseQuery {
    /// The SQL text to execute.
    ///
    /// This is the raw SQL string for the query.
    public var sql: String
    /// The bound parameters for the SQL text.
    ///
    /// These values are passed alongside `sql`.
    public var bindings: [SQLiteData]

    /// Create a query from raw SQL and bindings.
    ///
    /// Prefer string interpolation initializers when possible to bind values.
    /// - Parameters:
    ///   - sql: The raw SQL string to execute.
    ///   - bindings: The bound parameters for the SQL.
    public init(
        unsafeSQL sql: String,
        bindings: [SQLiteData] = []
    ) {
        self.sql = sql
        self.bindings = bindings
    }
}

extension SQLiteQuery: ExpressibleByStringInterpolation {

    /// A string interpolation builder for SQLite queries.
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
        var binds: [SQLiteData]

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
        /// - Returns: Nothing.
        public mutating func appendInterpolation(
            _ value: String?
        ) {
            switch value {
            case .some(let value):
                self.binds.append(.text(value))
                self.sql.append(contentsOf: "?")
            case .none:
                self.sql.append(contentsOf: "NULL")
            }
        }

        @inlinable
        /// Append an interpolated integer value.
        ///
        /// The value is bound as a SQLite integer.
        /// - Parameter value: The integer value to interpolate.
        /// - Returns: Nothing.
        public mutating func appendInterpolation(
            _ value: Int
        ) {
            self.binds.append(.integer(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        /// Append an interpolated floating-point value.
        ///
        /// The value is bound as a SQLite float.
        /// - Parameter value: The double value to interpolate.
        /// - Returns: Nothing.
        public mutating func appendInterpolation(
            _ value: Double
        ) {
            self.binds.append(.float(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        /// Append an interpolated string value.
        ///
        /// The value is bound as a SQLite text value.
        /// - Parameter value: The string value to interpolate.
        /// - Returns: Nothing.
        public mutating func appendInterpolation(
            _ value: String
        ) {
            self.binds.append(.text(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        /// Append an interpolated SQLite data value.
        ///
        /// The value is bound directly as SQLite data.
        /// - Parameter value: The SQLite data value to interpolate.
        /// - Returns: Nothing.
        public mutating func appendInterpolation(
            _ value: SQLiteData
        ) {
            self.binds.append(value)
            self.sql.append(contentsOf: "?")
        }

        //        @inlinable
        //        public mutating func appendInterpolation(_ value: SQLiteData?) throws {
        //            switch value {
        //            case .none:
        //                self.binds.append(.null)
        //            case .some(let value):
        //                self.binds.append(value)
        //            }
        //
        //            self.sql.append(contentsOf: "?")
        //        }

        @inlinable
        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        /// - Returns: Nothing.
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
