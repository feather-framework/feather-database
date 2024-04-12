//
//  File.swift
//
//
//  Created by Tibor Bodecs on 17/03/2024.
//

// TODO: create a real predicate builder
public struct DatabaseTableFilter<F: DatabaseColumnName>:
    DatabaseTableFilterInterface
{

    public let relation: DatabaseFilterRelation
    public let groups: [any DatabaseGroupFilterInterface]

    public init(
        relation: DatabaseFilterRelation = .and,
        groups: [DatabaseGroupFilter<F>]
    ) {
        self.relation = relation
        self.groups = groups
    }
}
