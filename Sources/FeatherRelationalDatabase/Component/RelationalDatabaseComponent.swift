//
//  SQLDatabase.swift
//  FeatherComponentTests
//
//  Created by Tibor Bodecs on 18/11/2023.
//

import FeatherComponent
import SQLKit

/// The sql-database component protocol.
public protocol RelationalDatabaseComponent: Component {

    func connection() async throws -> SQLKit.SQLDatabase
}
