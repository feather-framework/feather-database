//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

import Logging

public protocol DatabaseConnection {

    var logger: Logger { get }

    @discardableResult
    func run<T: DatabaseResult>(
        query: DatabaseQuery
    ) async throws -> T

    func close() async throws
}
