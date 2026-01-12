//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

public protocol DatabaseQuery: Sendable {
    associatedtype Bindings: Sendable

    var sql: String { get }
    var bindings: Bindings { get }
}
