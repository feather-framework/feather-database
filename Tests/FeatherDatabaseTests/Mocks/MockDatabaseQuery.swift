//
//  MockDatabaseQuery.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import FeatherDatabase

struct MockDatabaseQuery: DatabaseQuery {
    let sql: String
    let bindings: [String]
}
