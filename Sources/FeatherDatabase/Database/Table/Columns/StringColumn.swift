//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

public struct StringColumn: DatabaseColumnInterface {

    public let type: SQLDataType
    public let name: any DatabaseColumnName
    public let constraints: [SQLColumnConstraintAlgorithm]

    public init(
        _ name: any DatabaseColumnName,
        isMandatory: Bool = true
    ) {
        self.type = .text
        self.name = name
        self.constraints = isMandatory ? [.notNull] : []
    }
}
