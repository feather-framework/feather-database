import SQLiteNIO

public struct SQLiteQuery: DatabaseQuery {
    public var sql: String
    public var bindings: [SQLiteData]

    public init(
        unsafeSQL sql: String,
        bindings: [SQLiteData] = []
    ) {
        self.sql = sql
        self.bindings = bindings
    }
}

extension SQLiteQuery: ExpressibleByStringInterpolation {

    public struct StringInterpolation: StringInterpolationProtocol, Sendable {

        public typealias StringLiteralType = String

        @usableFromInline
        var sql: String

        @usableFromInline
        var binds: [SQLiteData]

        public init(
            literalCapacity: Int,
            interpolationCount: Int
        ) {
            self.sql = ""
            self.sql.reserveCapacity(literalCapacity)
            self.binds = []
            self.binds.reserveCapacity(interpolationCount)
        }

        public mutating func appendLiteral(
            _ literal: String
        ) {
            self.sql.append(contentsOf: literal)
        }

        @inlinable
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
        public mutating func appendInterpolation(
            _ value: Int
        ) {
            self.binds.append(.integer(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(
            _ value: Double
        ) {
            self.binds.append(.float(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
        public mutating func appendInterpolation(
            _ value: String
        ) {
            self.binds.append(.text(value))
            self.sql.append(contentsOf: "?")
        }

        @inlinable
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
        public mutating func appendInterpolation(
            unescaped interpolated: String
        ) {
            self.sql.append(contentsOf: interpolated)
        }
    }
    
    public init(
        stringInterpolation: StringInterpolation
    ) {
        self.sql = stringInterpolation.sql
        self.bindings = stringInterpolation.binds
    }

    public init(
        stringLiteral value: String
    ) {
        self.sql = value
        self.bindings = []
    }
}
