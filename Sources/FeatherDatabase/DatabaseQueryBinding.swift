//
//  DatabaseQueryBinding.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 02. 07..
//

/// A single bindable value used by a database query.
public enum DatabaseQueryBinding: Sendable, Equatable, Hashable, Codable {
    /// A text value.
    case string(String)
    /// An integer value.
    case int(Int)
    /// A floating-point value.
    case double(Double)
    /// A boolean value.
    case bool(Bool)
}
