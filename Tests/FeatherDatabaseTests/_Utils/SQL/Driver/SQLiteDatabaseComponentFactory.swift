//
//  SQLDatabaseDriver.swift
//  FeatherComponentTests
//
//  Created by Tibor Bodecs on 18/11/2023.
//

import FeatherComponent
import SQLiteKit

struct SQLiteDatabaseComponentFactory: ComponentFactory {

    let context: SQLiteDatabaseComponentContext

    func build(using config: ComponentConfig) throws -> Component {
        SQLiteDatabaseComponent(config: config)
    }

}
