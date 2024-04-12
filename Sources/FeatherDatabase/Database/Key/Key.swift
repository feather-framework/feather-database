//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/02/2024.
//

public struct Key<T>:
    Sendable,
    Codable,
    Equatable,
    Hashable,
    RawRepresentable
{
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
