//
//  File.swift
//
//
//  Created by Tibor Bodecs on 14/02/2024.
//

public protocol KeyedDatabaseQueryInterface: DatabaseQueryInterface {

    associatedtype P: DatabaseColumnName

    static var primaryKey: P { get }
}
