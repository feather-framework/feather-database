//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

public protocol DatabaseListInterface {
    associatedtype Column: DatabaseColumnName

    var page: DatabasePage? { get }
    var orders: [DatabaseOrder<Column>] { get }
    var filter: DatabaseTableFilter<Column>? { get }
}
