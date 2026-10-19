public import FeatherDatabase
#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif

public struct MockDatabaseRow: DatabaseRow {
    public enum Value: Sendable {
        case string(String)
        case int(Int)
        case int32(Int32)
        case double(Double)
        case float(Float)
        case bool(Bool)
        case uuid(UUID)
        case date(Date)
        case data(Data)
        case null
    }

    private struct Key: CodingKey {
        let stringValue: String
        var intValue: Int? { nil }

        init(_ value: String) { stringValue = value }
        init?(stringValue: String) { self.init(stringValue) }
        init?(intValue: Int) { return nil }
    }

    private let values: [String: Value]

    public init(_ values: [String: Value]) {
        self.values = values
    }

    public var columns: [String] { Array(values.keys).sorted() }

    public func contains(column: String) -> Bool {
        values[column] != nil
    }

    public func decodeNil(column: String) throws(DecodingError) -> Bool {
        guard let value = values[column] else {
            throw missingColumn(column)
        }
        if case .null = value { return true }
        return false
    }

    public func decode<T: Decodable>(
        column: String,
        as: T.Type
    ) throws(DecodingError) -> T {
        guard let value = values[column] else {
            throw missingColumn(column)
        }
        if case .null = value {
            do {
                return try JSONDecoder().decode(T.self, from: Data("null".utf8))
            }
            catch {
                throw DecodingError.valueNotFound(
                    T.self,
                    .init(
                        codingPath: [Key(column)],
                        debugDescription: "Mock column is SQL NULL."
                    )
                )
            }
        }
        guard let decoded = value.decode(as: T.self) else {
            throw DecodingError.typeMismatch(
                T.self,
                .init(
                    codingPath: [Key(column)],
                    debugDescription:
                        "Mock value cannot be decoded as the requested type."
                )
            )
        }
        return decoded
    }

    private func missingColumn(_ column: String) -> DecodingError {
        .keyNotFound(
            Key(column),
            .init(
                codingPath: [],
                debugDescription: "Missing mock column: \(column)"
            )
        )
    }
}

extension MockDatabaseRow.Value {
    fileprivate func decode<T>(as type: T.Type) -> T? {
        switch self {
        case .string(let value): value as? T
        case .int(let value): value as? T
        case .int32(let value): value as? T
        case .double(let value): value as? T
        case .float(let value): value as? T
        case .bool(let value): value as? T
        case .uuid(let value): value as? T
        case .date(let value): value as? T
        case .data(let value): value as? T
        case .null: nil
        }
    }
}
