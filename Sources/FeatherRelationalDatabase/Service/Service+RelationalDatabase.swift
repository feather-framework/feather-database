//
//  Service+Storage.swift
//  FeatherStorage
//
//  Created by Tibor Bodecs on 20/11/2023.
//

import FeatherService
import Logging

public enum RelationalDatabaseServiceID: ServiceID {

    /// default storage service identifier
    case `default`
    
    /// custom storage service identifier
    case custom(String)
    
    public var rawId: String {
        switch self {
        case .default:
            return "relational-database-id"
        case .custom(let value):
            return "\(value)-relational-database-id"
        }
    }
}

public extension ServiceRegistry {

    /// add a new storage service using a context
    func addRelationalDatabase(
        _ context: ServiceContext,
        id: RelationalDatabaseServiceID = .default
    ) async throws {
        try await add(context, id: id)
    }

    /// returns a storage service by a given id
    func relationalDatabase(
        _ id: RelationalDatabaseServiceID = .default,
        logger: Logger? = nil
    ) throws -> RelationalDatabaseService {
        guard let storage = try get(id, logger: logger) as? RelationalDatabaseService
        else {
            fatalError("Relational database service not found, use `add` to register.")
        }
        return storage
    }
}
