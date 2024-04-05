//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

public struct IntColumn: ColumnStructure {

    public let type: SQLDataType
    public let name: String
    public let constraints: [SQLColumnConstraintAlgorithm]

    public init(
        name: String,
        isMandatory: Bool = true
    ) {
        self.type = .int
        self.name = name
        self.constraints = isMandatory ? [.notNull] : []
    }
}
