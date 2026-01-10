//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

public protocol DatabaseQuery {

    var sql: String { get }
}

struct DatabaseQueryBind {

    public var sql: String

    /// The list of bound parameter values (if any).
    public var binds: [any Encodable & Sendable]
}
