//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

public protocol DatabaseColumn {
    var name: any DatabaseColumnName { get }
    var type: SQLDataType { get }
    var constraints: [SQLColumnConstraintAlgorithm] { get }
}
