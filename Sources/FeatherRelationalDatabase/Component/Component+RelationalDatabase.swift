//
//  Component+Storage.swift
//  FeatherStorage
//
//  Created by Tibor Bodecs on 20/11/2023.
//

import FeatherComponent
import Logging

public enum RelationalDatabaseComponentID: ComponentID {

    /// default storage component identifier
    case `default`
    
    /// custom storage component identifier
    case custom(String)
    
    public var rawId: String {
        switch self {
        case .default:
            return "relational-database-component-id"
        case .custom(let value):
            return "\(value)-relational-database-component-id"
        }
    }
}

public extension ComponentRegistry {

    /// add a new storage component using a context
    func addRelationalDatabase(
        _ context: ComponentContext,
        id: RelationalDatabaseComponentID = .default
    ) async throws {
        try await add(context, id: id)
    }

    /// returns a storage component by a given id
    func relationalDatabase(
        _ id: RelationalDatabaseComponentID = .default,
        logger: Logger? = nil
    ) throws -> RelationalDatabaseComponent {
        guard 
            let storage = try get(id, logger: logger) as? RelationalDatabaseComponent
        else {
            fatalError("Relational database component not found, call `addRelationalDatabase()` to register.")
        }
        return storage
    }
}
