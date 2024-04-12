//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/02/2024.
//

public protocol KeyedDatabaseQuery: DatabaseQuery {

    associatedtype PrimaryField: DatabaseColumnName

    static var primaryKey: PrimaryField { get }
}
