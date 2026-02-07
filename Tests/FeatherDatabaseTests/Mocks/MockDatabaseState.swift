//
//  MockDatabaseState.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 15..
//

import FeatherDatabase

actor MockDatabaseState {

    private var connectionCallCount = 0
    private var executedQueries: [DatabaseQuery] = []

    func recordConnection() {
        connectionCallCount += 1
    }

    func recordExecution(_ query: DatabaseQuery) {
        executedQueries.append(query)
    }

    func connectionCount() -> Int {
        connectionCallCount
    }

    func executedQueryList() -> [DatabaseQuery] {
        executedQueries
    }
}
