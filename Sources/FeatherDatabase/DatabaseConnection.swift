//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Logging


public protocol DatabaseConnection {
    
    associatedtype Query: DatabaseQuery
    associatedtype Result: DatabaseResult

    var logger: Logger { get }

    func execute(
        query: Query
    ) async throws -> Result

    func close() async throws
}
