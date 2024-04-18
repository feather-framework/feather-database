//
//  File.swift
//
//
//  Created by Tibor Bodecs on 16/04/2024.
//

import SQLKit

public struct PrimaryKeyConstraint: DatabaseConstraintInterface {
    public let sqlConstraint: SQLTableConstraintAlgorithm

    public init(_ column: any DatabaseColumnName) {
        self.init([column])
    }

    public init(_ columns: [any DatabaseColumnName]) {
        self.sqlConstraint = .primaryKey(
            columns: columns.map { SQLIdentifier($0.rawValue) }
        )
    }
}
