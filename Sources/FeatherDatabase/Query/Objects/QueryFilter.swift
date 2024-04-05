//
//  File.swift
//
//
//  Created by Tibor Bodecs on 17/03/2024.
//

// TODO: create a real predicate builder
public struct QueryFilter<F: QueryFieldKey>: QueryFilterInterface {

    public let relation: QueryFilterRelation
    public let groups: [any QueryFilterGroupInterface]

    public init(
        relation: QueryFilterRelation = .and,
        groups: [QueryFilterGroup<F>]
    ) {
        self.relation = relation
        self.groups = groups
    }
}
