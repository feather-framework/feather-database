//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

public protocol DatabaseColumnInterface {
    var name: any DatabaseColumnName { get }
    var type: SQLDataType { get }
    var constraints: [SQLColumnConstraintAlgorithm] { get }
}
