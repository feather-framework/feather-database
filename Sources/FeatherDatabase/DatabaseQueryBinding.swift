//
//  DatabaseQueryBinding.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 02. 07..
//

#if canImport(FoundationEssentials)
public import FoundationEssentials
#else
public import Foundation
#endif

/// A single bindable value used by a database query.
public enum DatabaseQueryBinding: Sendable, Equatable, Hashable, Codable {
    /// A text value.
    case string(String)
    /// An integer value.
    case int(Int)
    /// A 32-bit integer value.
    case int32(Int32)
    /// A floating-point value.
    case double(Double)
    /// A 32-bit floating-point value.
    case float(Float)
    /// A boolean value.
    case bool(Bool)
    /// A UUID value.
    case uuid(UUID)
    /// A date and time value.
    case date(Date)
    /// A binary value.
    case data(Data)
    /// A JSON document encoded as UTF-8.
    case json(Data)
}
