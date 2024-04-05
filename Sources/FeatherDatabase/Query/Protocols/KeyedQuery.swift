//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/02/2024.
//

public protocol KeyedDatabaseTableQuery: DatabaseTableQuery {

    associatedtype PrimaryField: QueryFieldKey

    static var primaryKey: PrimaryField { get }
}
