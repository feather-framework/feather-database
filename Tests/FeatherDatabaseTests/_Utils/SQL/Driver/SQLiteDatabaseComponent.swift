//
//  File 2.swift
//
//
//  Created by Tibor Bodecs on 03/12/2023.
//

import FeatherComponent
import FeatherDatabase
import SQLiteKit

@dynamicMemberLookup
struct SQLiteDatabaseComponent: DatabaseComponent {

    public let config: ComponentConfig

    subscript<T>(
        dynamicMember keyPath: KeyPath<
            SQLiteDatabaseComponentContext, T
        >
    ) -> T {
        let context = config.context as! SQLiteDatabaseComponentContext
        return context[keyPath: keyPath]
    }

    public func connection() async throws -> Database {
        .init(self.pool.database(logger: self.logger).sql())
    }
}
