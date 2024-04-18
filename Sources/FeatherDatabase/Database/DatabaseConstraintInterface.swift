//
//  File.swift
//
//
//  Created by Tibor Bodecs on 16/04/2024.
//

import SQLKit

public protocol DatabaseConstraintInterface {

    var sqlConstraint: SQLTableConstraintAlgorithm { get }
}
