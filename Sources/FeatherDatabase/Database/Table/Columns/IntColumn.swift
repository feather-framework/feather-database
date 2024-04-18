//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

public struct IntColumn: DatabaseColumnInterface {

    public let type: SQLDataType
    public let name: any DatabaseColumnName
    public let constraints: [SQLColumnConstraintAlgorithm]

    public init(
        _ name: any DatabaseColumnName,
        isMandatory: Bool = true
    ) {
        self.type = .int
        self.name = name
        self.constraints = isMandatory ? [.notNull] : []
    }
}
