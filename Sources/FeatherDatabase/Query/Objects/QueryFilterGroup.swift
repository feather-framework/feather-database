//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

import SQLKit

public struct QueryFilterGroup<F: DatabaseColumnName>: QueryFilterGroupInterface
{

    public let relation: QueryFilterRelation
    public let fields: [any QueryFieldFilterInterface]

    public init(
        relation: QueryFilterRelation = .and,
        fields: [QueryFieldFilter<F>]
    ) {
        self.relation = relation
        self.fields = fields
    }
}
