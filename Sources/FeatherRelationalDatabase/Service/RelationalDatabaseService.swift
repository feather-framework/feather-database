//
//  SQLDatabase.swift
//  FeatherServiceTests
//
//  Created by Tibor Bodecs on 18/11/2023.
//

import FeatherService
import SQLKit

/// the sql-database service protocol
public protocol RelationalDatabaseService: Service {
    
    func connection() async throws -> SQLKit.SQLDatabase
}
