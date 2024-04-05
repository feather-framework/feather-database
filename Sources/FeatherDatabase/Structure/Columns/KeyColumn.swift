//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

public struct KeyColumn: ColumnStructure {

    public let type: SQLDataType
    public let name: String
    public let constraints: [SQLColumnConstraintAlgorithm]

    public init(
        name: String = "id"
    ) {
        self.type = .text
        self.name = name
        self.constraints = [.primaryKey(autoIncrement: false), .notNull]
    }
}
