//
//  File.swift
//
//
//  Created by Tibor Bodecs on 16/04/2024.
//

import SQLKit

public struct UniqueConstraint: DatabaseConstraintInterface {
    public let sqlConstraint: SQLTableConstraintAlgorithm

    public init(_ columns: any DatabaseColumnName...) {
        self.init(columns)
    }

    public init(_ columns: [any DatabaseColumnName]) {
        self.sqlConstraint = .unique(
            columns: columns.map { SQLIdentifier($0.rawValue) }
        )
    }
}
