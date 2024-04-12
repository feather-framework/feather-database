//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

public struct KeyColumn: DatabaseColumn {

    public let type: SQLDataType
    public let name: any DatabaseColumnName
    public let constraints: [SQLColumnConstraintAlgorithm]

    public init(
        _ name: any DatabaseColumnName
    ) {
        self.type = .text
        self.name = name
        self.constraints = [.primaryKey(autoIncrement: false), .notNull]
    }
}
