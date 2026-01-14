//
//  PostgresQuery.swift
//  Feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import PostgresNIO

extension PostgresQuery: DatabaseQuery {
    /// The bindings type for Postgres queries.
    ///
    /// This type represents parameter bindings for PostgresNIO.
    public typealias Bindings = PostgresBindings

    /// The bound parameters for the SQL text.
    ///
    /// This exposes the underlying `binds` storage.
    public var bindings: PostgresBindings { binds }
}
