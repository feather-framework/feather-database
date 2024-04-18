//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public struct DatabaseJoin<L: DatabaseColumnName, R: DatabaseColumnName> {

    public let lhs: L
    public let rhs: R
    public let method: SQLJoinMethod
    public let op: SQLBinaryOperator
    public let filter: DatabaseFilter<R>?
    
    public init(
        lhs: L,
        rhs: R,
        method: SQLJoinMethod = .inner,
        op: SQLBinaryOperator = .equal,
        filter: DatabaseFilter<R>? = nil
    )
    {
        self.lhs = lhs
        self.rhs = rhs
        self.method = method
        self.op = op
        self.filter = filter
    }
}
