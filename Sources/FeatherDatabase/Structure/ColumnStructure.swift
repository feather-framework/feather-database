//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

public protocol ColumnStructure {
    var name: String { get }
    var type: SQLDataType { get }
    var constraints: [SQLColumnConstraintAlgorithm] { get }
}
