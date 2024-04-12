//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

public protocol QueryListInterface {
    associatedtype Field: DatabaseColumnName

    var page: QueryPage? { get }
    var orders: [QueryOrder<Field>] { get }
    var filter: QueryFilter<Field>? { get }
}
