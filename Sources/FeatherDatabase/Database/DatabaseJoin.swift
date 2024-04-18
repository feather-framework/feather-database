//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public struct DatabaseJoin<L: DatabaseColumnName, R: DatabaseColumnName> {

    public let column: L
    public let otherColumn: R
    public let method: SQLJoinMethod
    public let op: SQLBinaryOperator
    public let filter: DatabaseFilter<R>?

    public init(
        column: L,
        with otherColumn: R,
        method: SQLJoinMethod = .inner,
        op: SQLBinaryOperator = .equal,
        filter: DatabaseFilter<R>? = nil
    ) {
        self.column = column
        self.otherColumn = otherColumn
        self.method = method
        self.op = op
        self.filter = filter
    }
}
