import Foundation

/// Decodes flat `Decodable` values from database rows.
public struct DatabaseRowDecoder: Sendable {

    public enum KeyDecodingStrategy: Sendable {
        case useDefaultKeys
        case convertFromSnakeCase
        case custom(@Sendable ([any CodingKey]) -> any CodingKey)
    }

    public var prefix: String?
    public var keyDecodingStrategy: KeyDecodingStrategy
    public var userInfo: [CodingUserInfoKey: any Sendable]

    public init(
        prefix: String? = nil,
        keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: any Sendable] = [:]
    ) {
        self.prefix = prefix
        self.keyDecodingStrategy = keyDecodingStrategy
        self.userInfo = userInfo
    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from row: some DatabaseRow
    ) throws -> T {
        try T(from: RowDecoder(configuration: self, row: row))
    }

    fileprivate func columnName(for key: String) -> String {
        let transformed: String
        switch keyDecodingStrategy {
        case .useDefaultKeys:
            transformed = key
        case .convertFromSnakeCase:
            transformed = key.convertedToSnakeCase
        case .custom(let transform):
            transformed =
                transform([DatabaseCodingKey(stringValue: key)]).stringValue
        }
        return "\(prefix ?? "")\(transformed)"
    }

    fileprivate func keyName(for column: String) -> String {
        let column =
            prefix.flatMap {
                column.hasPrefix($0) ? String(column.dropFirst($0.count)) : nil
            } ?? column
        switch keyDecodingStrategy {
        case .useDefaultKeys, .custom:
            return column
        case .convertFromSnakeCase:
            return column.convertedFromSnakeCase
        }
    }
}

extension String {
    fileprivate var convertedToSnakeCase: String {
        guard !isEmpty else { return self }
        var words: [Range<String.Index>] = []
        var wordStart = startIndex
        var searchIndex = index(after: wordStart)

        while let upperIndex = self[searchIndex...]
            .firstIndex(where: \.isUppercase)
        {
            words.append(wordStart..<upperIndex)
            wordStart = upperIndex
            guard
                let lowerIndex = self[upperIndex...]
                    .firstIndex(where: \.isLowercase)
            else { break }
            searchIndex = lowerIndex
            if lowerIndex != index(after: upperIndex) {
                let beforeLowerIndex = index(before: lowerIndex)
                words.append(upperIndex..<beforeLowerIndex)
                wordStart = beforeLowerIndex
            }
        }
        words.append(wordStart..<endIndex)
        return
            words.map {
                String(self[$0].prefix(1).lowercased() + self[$0].dropFirst())
            }
            .joined(separator: "_")
    }

    fileprivate var convertedFromSnakeCase: String {
        guard !isEmpty, let first = firstIndex(where: { $0 != "_" }) else {
            return self
        }
        var last = endIndex
        repeat { formIndex(before: &last) }
        while last > first && self[last] == "_"
        let leading = self[..<first]
        let trailing = self[index(after: last)...]
        let words = self[first...last].split(separator: "_")
        guard words.count > 1 else {
            return "\(leading)\(self[first...last])\(trailing)"
        }
        return
            "\(leading)\(words[0].lowercased())\(words.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined())\(trailing)"
    }
}

private struct RowDecoder<Row: DatabaseRow>: Decoder {
    let configuration: DatabaseRowDecoder
    let row: Row
    var codingPath: [any CodingKey] = []

    var userInfo: [CodingUserInfoKey: Any] {
        configuration.userInfo
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws
        -> KeyedDecodingContainer<Key>
    {
        guard codingPath.isEmpty else {
            throw DecodingError.typeMismatch(
                KeyedDecodingContainer<Key>.self,
                .init(
                    codingPath: codingPath,
                    debugDescription:
                        "Nested keyed values are not supported when decoding a flat database row."
                )
            )
        }
        return .init(RowKeyedDecodingContainer(decoder: self))
    }

    func unkeyedContainer() throws -> any UnkeyedDecodingContainer {
        throw DecodingError.typeMismatch(
            (any UnkeyedDecodingContainer).self,
            .init(
                codingPath: codingPath,
                debugDescription:
                    "Unkeyed values are not supported when decoding a flat database row."
            )
        )
    }

    func singleValueContainer() throws -> any SingleValueDecodingContainer {
        RowSingleValueDecodingContainer(decoder: self)
    }
}

private struct RowKeyedDecodingContainer<Key: CodingKey, Row: DatabaseRow>:
    KeyedDecodingContainerProtocol
{
    let decoder: RowDecoder<Row>
    var codingPath: [any CodingKey] { decoder.codingPath }

    var allKeys: [Key] {
        decoder.row.columns
            .map { decoder.configuration.keyName(for: $0) }
            .compactMap(Key.init(stringValue:))
    }

    func contains(_ key: Key) -> Bool {
        decoder.row.contains(
            column: decoder.configuration.columnName(for: key.stringValue)
        )
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        let column = decoder.configuration.columnName(for: key.stringValue)
        guard decoder.row.contains(column: column) else { return true }
        do {
            return try decoder.row.decodeNil(column: column)
        }
        catch {
            throw error.withCodingPath(codingPath + [key])
        }
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        let column = decoder.configuration.columnName(for: key.stringValue)
        guard decoder.row.contains(column: column) else {
            throw DecodingError.keyNotFound(
                key,
                .init(
                    codingPath: codingPath,
                    debugDescription:
                        "No value for key \"\(key.stringValue)\" (column \"\(column)\")."
                )
            )
        }
        do {
            return try decoder.row.decode(column: column, as: type)
        }
        catch {
            throw error.withCodingPath(codingPath + [key])
        }
    }

    func nestedContainer<NestedKey: CodingKey>(
        keyedBy type: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        throw DecodingError.typeMismatch(
            KeyedDecodingContainer<NestedKey>.self,
            .init(
                codingPath: codingPath + [key],
                debugDescription:
                    "Nested keyed values are not supported when decoding a flat database row."
            )
        )
    }

    func nestedUnkeyedContainer(forKey key: Key) throws
        -> any UnkeyedDecodingContainer
    {
        throw DecodingError.typeMismatch(
            (any UnkeyedDecodingContainer).self,
            .init(
                codingPath: codingPath + [key],
                debugDescription:
                    "Nested unkeyed values are not supported when decoding a flat database row."
            )
        )
    }

    func superDecoder() throws -> any Decoder {
        throw DecodingError.typeMismatch(
            (any Decoder).self,
            .init(
                codingPath: codingPath,
                debugDescription:
                    "A key is required to decode a flat database row."
            )
        )
    }

    func superDecoder(forKey key: Key) throws -> any Decoder {
        RowDecoder(
            configuration: decoder.configuration,
            row: decoder.row,
            codingPath: codingPath + [key]
        )
    }
}

private struct RowSingleValueDecodingContainer<Row: DatabaseRow>:
    SingleValueDecodingContainer
{
    let decoder: RowDecoder<Row>
    var codingPath: [any CodingKey] { decoder.codingPath }

    func decodeNil() -> Bool {
        guard let key = codingPath.last else { return false }
        return
            (try? decoder.row.decodeNil(
                column: decoder.configuration.columnName(for: key.stringValue)
            )) ?? false
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        guard let key = codingPath.last else {
            throw DecodingError.typeMismatch(
                T.self,
                .init(
                    codingPath: codingPath,
                    debugDescription:
                        "A flat database row cannot be decoded as a single value."
                )
            )
        }
        let column = decoder.configuration.columnName(for: key.stringValue)
        do {
            return try decoder.row.decode(column: column, as: type)
        }
        catch {
            throw error.withCodingPath(codingPath)
        }
    }

    func decode(_: Bool.Type) throws -> Bool {
        throw unsupportedScalar(Bool.self)
    }
    func decode(_: String.Type) throws -> String {
        throw unsupportedScalar(String.self)
    }
    func decode(_: Double.Type) throws -> Double {
        throw unsupportedScalar(Double.self)
    }
    func decode(_: Float.Type) throws -> Float {
        throw unsupportedScalar(Float.self)
    }
    func decode(_: Int.Type) throws -> Int { throw unsupportedScalar(Int.self) }
    func decode(_: Int8.Type) throws -> Int8 {
        throw unsupportedScalar(Int8.self)
    }
    func decode(_: Int16.Type) throws -> Int16 {
        throw unsupportedScalar(Int16.self)
    }
    func decode(_: Int32.Type) throws -> Int32 {
        throw unsupportedScalar(Int32.self)
    }
    func decode(_: Int64.Type) throws -> Int64 {
        throw unsupportedScalar(Int64.self)
    }
    func decode(_: UInt.Type) throws -> UInt {
        throw unsupportedScalar(UInt.self)
    }
    func decode(_: UInt8.Type) throws -> UInt8 {
        throw unsupportedScalar(UInt8.self)
    }
    func decode(_: UInt16.Type) throws -> UInt16 {
        throw unsupportedScalar(UInt16.self)
    }
    func decode(_: UInt32.Type) throws -> UInt32 {
        throw unsupportedScalar(UInt32.self)
    }
    func decode(_: UInt64.Type) throws -> UInt64 {
        throw unsupportedScalar(UInt64.self)
    }

    private func unsupportedScalar<T>(_ type: T.Type) -> DecodingError {
        .typeMismatch(
            type,
            .init(
                codingPath: codingPath,
                debugDescription:
                    "A flat database row must be decoded as a keyed value."
            )
        )
    }
}

private struct DatabaseCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil

    init(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { return nil }
}

extension DecodingError {
    fileprivate func withCodingPath(_ path: [any CodingKey]) -> DecodingError {
        switch self {
        case .typeMismatch(let type, let context):
            .typeMismatch(
                type,
                .init(
                    codingPath: path,
                    debugDescription: context.debugDescription,
                    underlyingError: context.underlyingError
                )
            )
        case .valueNotFound(let type, let context):
            .valueNotFound(
                type,
                .init(
                    codingPath: path,
                    debugDescription: context.debugDescription,
                    underlyingError: context.underlyingError
                )
            )
        case .keyNotFound(let key, let context):
            .keyNotFound(
                key,
                .init(
                    codingPath: path,
                    debugDescription: context.debugDescription,
                    underlyingError: context.underlyingError
                )
            )
        case .dataCorrupted(let context):
            .dataCorrupted(
                .init(
                    codingPath: path,
                    debugDescription: context.debugDescription,
                    underlyingError: context.underlyingError
                )
            )
        @unknown default:
            .dataCorrupted(
                .init(
                    codingPath: path,
                    debugDescription: String(describing: self)
                )
            )
        }
    }
}
