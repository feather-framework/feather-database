//
//  Component+Storage.swift
//  FeatherStorage
//
//  Created by Tibor Bodecs on 20/11/2023.
//

import FeatherComponent
import Logging

///  database component identfier.
public enum DatabaseComponentID: ComponentID {

    /// Default storage component identifier.
    case `default`

    /// Custom storage component identifier.
    case custom(String)

    /// Raw identifier value.
    public var rawId: String {
        switch self {
        case .default:
            return "database-component-id"
        case .custom(let value):
            return "\(value)-database-component-id"
        }
    }
}

extension ComponentRegistry {

    /// Add a new storage component using a context.
    public func addDatabase(
        _ context: ComponentContext,
        id: DatabaseComponentID = .default
    ) async throws {
        try await add(context, id: id)
    }

    /// Returns a storage component by a given id.
    public func database(
        _ id: DatabaseComponentID = .default,
        logger: Logger? = nil
    ) throws -> DatabaseComponent {
        guard
            let database = try get(id, logger: logger) as? DatabaseComponent
        else {
            fatalError(
                "Database component not found, call `addDatabase()` to register."
            )
        }
        return database
    }
}
