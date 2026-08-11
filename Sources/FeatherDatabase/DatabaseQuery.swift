//
//  DatabaseQuery.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 02. 07..
//

/// A database query with SQL text and bound parameters.
///
/// Use this type to construct database queries safely.
public struct DatabaseQuery: Sendable, Equatable, Hashable, Codable {

    /// The SQL text to execute.
    ///
    /// This is the raw SQL string for the query.
    public var sql: String

    /// The bound parameters for the SQL text.
    ///
    /// These values are passed alongside `sql`.
    public var bindings: [DatabaseQueryBindings]

    /// Create a query from raw SQL and bindings.
    ///
    /// Prefer string interpolation initializers when possible to bind values.
    /// - Parameters:
    ///   - sql: The raw SQL string to execute.
    ///   - bindings: The bound parameters for the SQL.
    public init(
        unsafeSQL sql: String,
        bindings: [DatabaseQueryBindings] = []
    ) {
        self.sql = sql
        self.bindings = bindings
    }
}

extension DatabaseQuery: ExpressibleByStringInterpolation {

    /// A string interpolation builder for database queries.
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
        var binds: [DatabaseQueryBindings]

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
            sql.append(contentsOf: literal)
        }

        @usableFromInline
        mutating func appendBound(
            _ binding: DatabaseQueryBinding
        ) {
            binds.append(
                .init(
                    index: binds.count,
                    binding: binding
                )
            )
            sql.append(contentsOf: "{{\(binds.count)}}")
        }

        @usableFromInline
        mutating func appendOptionalBound(
            _ binding: DatabaseQueryBinding?
        ) {
            if let binding {
                appendBound(binding)
            }
            else {
                sql.append(contentsOf: "NULL")
            }
        }

        @usableFromInline
        mutating func appendOptionalSQL<Value>(
            _ value: Value?,
            _ render: (Value) -> String
        ) {
            if let value {
                sql.append(contentsOf: render(value))
            }
            else {
                sql.append(contentsOf: "NULL")
            }
        }

        @usableFromInline
        static func appendSeparatedList<Element>(
            _ values: [Element],
            sql: inout String,
            binds: inout [DatabaseQueryBindings],
            _ appendElement: (
                Element, inout String, inout [DatabaseQueryBindings]
            ) -> Void
        ) {
            for (index, value) in values.enumerated() {
                if index > 0 {
                    sql.append(contentsOf: ", ")
                }
                appendElement(value, &sql, &binds)
            }
        }

        @usableFromInline
        static func appendBound(
            _ binding: DatabaseQueryBinding,
            sql: inout String,
            binds: inout [DatabaseQueryBindings]
        ) {
            binds.append(
                .init(
                    index: binds.count,
                    binding: binding
                )
            )
            sql.append(contentsOf: "{{\(binds.count)}}")
        }

        @usableFromInline
        static func appendOptionalBound(
            _ binding: DatabaseQueryBinding?,
            sql: inout String,
            binds: inout [DatabaseQueryBindings]
        ) {
            if let binding {
                appendBound(binding, sql: &sql, binds: &binds)
            }
            else {
                sql.append(contentsOf: "NULL")
            }
        }

        @usableFromInline
        static func appendOptionalSQL<Value>(
            _ value: Value?,
            sql: inout String,
            _ render: (Value) -> String
        ) {
            if let value {
                sql.append(contentsOf: render(value))
            }
            else {
                sql.append(contentsOf: "NULL")
            }
        }

        @usableFromInline
        mutating func appendBoundList<Element>(
            _ values: [Element],
            _ binding: (Element) -> DatabaseQueryBinding
        ) {
            Self.appendSeparatedList(values, sql: &sql, binds: &binds) {
                value,
                sql,
                binds in
                Self.appendBound(binding(value), sql: &sql, binds: &binds)
            }
        }

        @usableFromInline
        mutating func appendOptionalBoundList<Element>(
            _ values: [Element?],
            _ binding: (Element) -> DatabaseQueryBinding
        ) {
            Self.appendSeparatedList(values, sql: &sql, binds: &binds) {
                value,
                sql,
                binds in
                Self.appendOptionalBound(
                    value.map(binding),
                    sql: &sql,
                    binds: &binds
                )
            }
        }

        @usableFromInline
        mutating func appendUnescapedOptional(
            _ value: String?
        ) {
            Self.appendOptionalSQL(value, sql: &sql) { $0 }
        }

        @usableFromInline
        mutating func appendUnescapedOptional(
            _ value: Int?
        ) {
            Self.appendOptionalSQL(value, sql: &sql, String.init)
        }

        @usableFromInline
        mutating func appendUnescapedOptional(
            _ value: Float?
        ) {
            Self.appendOptionalSQL(value, sql: &sql) { String($0) }
        }

        @usableFromInline
        mutating func appendUnescapedOptional(
            _ value: Double?
        ) {
            Self.appendOptionalSQL(value, sql: &sql) { String($0) }
        }

        @usableFromInline
        mutating func appendUnescapedOptional(
            _ value: Bool?
        ) {
            Self.appendOptionalSQL(value, sql: &sql, String.init)
        }

        /// Append an interpolated optional string value.
        ///
        /// Non-nil values are bound, and nil values emit `NULL`.
        /// - Parameter value: The optional string value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: String?
        ) {
            appendOptionalBound(value.map(DatabaseQueryBinding.string))
        }

        /// Append an interpolated integer value.
        ///
        /// The value is bound as an integer.
        /// - Parameter value: The integer value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: Int
        ) {
            appendBound(.int(value))
        }

        /// Append an interpolated optional integer value.
        ///
        /// Non-nil values are bound, and nil values emit `NULL`.
        /// - Parameter value: The optional integer value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: Int?
        ) {
            appendOptionalBound(value.map(DatabaseQueryBinding.int))
        }

        /// Append an interpolated floating-point value.
        ///
        /// The value is bound as a floating-point value.
        /// - Parameter value: The float value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: Float
        ) {
            appendBound(.double(Double(value)))
        }

        /// Append an interpolated optional floating-point value.
        ///
        /// Non-nil values are bound, and nil values emit `NULL`.
        /// - Parameter value: The optional float value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: Float?
        ) {
            appendOptionalBound(value.map { .double(Double($0)) })
        }

        /// Append an interpolated floating-point value.
        ///
        /// The value is bound as a floating-point value.
        /// - Parameter value: The double value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: Double
        ) {
            appendBound(.double(value))
        }

        /// Append an interpolated optional floating-point value.
        ///
        /// Non-nil values are bound, and nil values emit `NULL`.
        /// - Parameter value: The optional double value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: Double?
        ) {
            appendOptionalBound(value.map(DatabaseQueryBinding.double))
        }

        /// Append an interpolated boolean value.
        ///
        /// The value is bound as a boolean value.
        /// - Parameter value: The boolean value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: Bool
        ) {
            appendBound(.bool(value))
        }

        /// Append an interpolated optional boolean value.
        ///
        /// Non-nil values are bound, and nil values emit `NULL`.
        /// - Parameter value: The optional boolean value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: Bool?
        ) {
            appendOptionalBound(value.map(DatabaseQueryBinding.bool))
        }

        /// Append an interpolated string value.
        ///
        /// The value is bound as a text value.
        /// - Parameter value: The string value to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ value: String
        ) {
            appendBound(.string(value))
        }

        /// Append a comma-separated list of interpolated string values.
        ///
        /// This is useful for `IN (...)` clauses.
        /// - Parameter values: The string values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [String]
        ) {
            appendBoundList(values, DatabaseQueryBinding.string)
        }

        /// Append a comma-separated list of optional string values.
        ///
        /// Nil values are emitted as `NULL`.
        /// - Parameter values: The optional string values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [String?]
        ) {
            appendOptionalBoundList(values, DatabaseQueryBinding.string)
        }

        /// Append a comma-separated list of interpolated integer values.
        ///
        /// This is useful for `IN (...)` clauses.
        /// - Parameter values: The integer values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [Int]
        ) {
            appendBoundList(values, DatabaseQueryBinding.int)
        }

        /// Append a comma-separated list of optional integer values.
        ///
        /// Nil values are emitted as `NULL`.
        /// - Parameter values: The optional integer values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [Int?]
        ) {
            appendOptionalBoundList(values, DatabaseQueryBinding.int)
        }

        /// Append a comma-separated list of interpolated floating-point values.
        ///
        /// This is useful for `IN (...)` clauses.
        /// - Parameter values: The float values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [Float]
        ) {
            appendBoundList(values) { .double(Double($0)) }
        }

        /// Append a comma-separated list of optional floating-point values.
        ///
        /// Nil values are emitted as `NULL`.
        /// - Parameter values: The optional float values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [Float?]
        ) {
            appendOptionalBoundList(values) { .double(Double($0)) }
        }

        /// Append a comma-separated list of interpolated floating-point values.
        ///
        /// This is useful for `IN (...)` clauses.
        /// - Parameter values: The double values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [Double]
        ) {
            appendBoundList(values, DatabaseQueryBinding.double)
        }

        /// Append a comma-separated list of optional floating-point values.
        ///
        /// Nil values are emitted as `NULL`.
        /// - Parameter values: The optional double values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [Double?]
        ) {
            appendOptionalBoundList(values, DatabaseQueryBinding.double)
        }

        /// Append a comma-separated list of interpolated boolean values.
        ///
        /// This is useful for `IN (...)` clauses.
        /// - Parameter values: The boolean values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [Bool]
        ) {
            appendBoundList(values, DatabaseQueryBinding.bool)
        }

        /// Append a comma-separated list of optional boolean values.
        ///
        /// Nil values are emitted as `NULL`.
        /// - Parameter values: The optional boolean values to interpolate.
        @inlinable
        public mutating func appendInterpolation(
            _ values: [Bool?]
        ) {
            appendOptionalBoundList(values, DatabaseQueryBinding.bool)
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: String
        ) {
            self.sql.append(contentsOf: interpolated)
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: String?
        ) {
            appendUnescapedOptional(interpolated)
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: Int
        ) {
            self.sql.append(contentsOf: String(interpolated))
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: Int?
        ) {
            appendUnescapedOptional(interpolated)
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: Float
        ) {
            self.sql.append(contentsOf: String(interpolated))
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: Float?
        ) {
            appendUnescapedOptional(interpolated)
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: Double
        ) {
            self.sql.append(contentsOf: String(interpolated))
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: Double?
        ) {
            appendUnescapedOptional(interpolated)
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: Bool
        ) {
            self.sql.append(contentsOf: String(interpolated))
        }

        /// Append an unescaped SQL fragment.
        ///
        /// Use this only for trusted identifiers or SQL keywords.
        /// - Parameter interpolated: The raw SQL fragment to insert.
        @inlinable
        public mutating func appendInterpolation(
            unescaped interpolated: Bool?
        ) {
            appendUnescapedOptional(interpolated)
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
