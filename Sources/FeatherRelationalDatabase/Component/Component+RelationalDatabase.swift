//
//  Component+Storage.swift
//  FeatherStorage
//
//  Created by Tibor Bodecs on 20/11/2023.
//

import FeatherComponent
import Logging

/// Relational database component identfier.
public enum RelationalDatabaseComponentID: ComponentID {

    /// Default storage component identifier.
    case `default`

    /// Custom storage component identifier.
    case custom(String)

    /// Raw identifier value.
    public var rawId: String {
        switch self {
        case .default:
            return "relational-database-component-id"
        case .custom(let value):
            return "\(value)-relational-database-component-id"
        }
    }
}

extension ComponentRegistry {

    /// Add a new storage component using a context.
    public func addRelationalDatabase(
        _ context: ComponentContext,
        id: RelationalDatabaseComponentID = .default
    ) async throws {
        try await add(context, id: id)
    }

    /// Returns a storage component by a given id.
    public func relationalDatabase(
        _ id: RelationalDatabaseComponentID = .default,
        logger: Logger? = nil
    ) throws -> RelationalDatabaseComponent {
        guard
            let storage = try get(id, logger: logger)
                as? RelationalDatabaseComponent
        else {
            fatalError(
                "Relational database component not found, call `addRelationalDatabase()` to register."
            )
        }
        return storage
    }
}
