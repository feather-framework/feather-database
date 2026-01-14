//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Logging


public protocol DatabaseConnection {
    
    associatedtype Query: DatabaseQuery
    associatedtype Result: DatabaseQueryResult

    var logger: Logger { get }

    @discardableResult
    func execute(
        query: Query
    ) async throws(DatabaseError) -> Result

    func close() async throws
}
