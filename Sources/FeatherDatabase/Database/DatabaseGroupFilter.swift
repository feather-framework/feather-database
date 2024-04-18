//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

import SQLKit

public struct DatabaseGroupFilter<F: DatabaseColumnName>:
    DatabaseGroupFilterInterface
{

    public let relation: DatabaseFilterRelation
    public let columns: [any DatabaseFilterInterface]

    public init(
        relation: DatabaseFilterRelation = .and,
        columns: [DatabaseFilter<F>]
    ) {
        self.relation = relation
        self.columns = columns
    }
}
