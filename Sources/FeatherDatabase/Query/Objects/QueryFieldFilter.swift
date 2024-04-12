//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public struct QueryFieldFilter<F: DatabaseColumnName>: QueryFieldFilterInterface
{

    public let field: F
    public let `operator`: SQLBinaryOperator
    public var value: SQLExpression

    public init<T: Encodable>(
        field: F,
        operator: SQLBinaryOperator,
        value: [T]
    ) {
        self.field = field
        self.operator = `operator`
        self.value = SQLBind.group(value)
    }

    public init<T: Encodable>(
        field: F,
        operator: SQLBinaryOperator,
        value: T
    ) {
        self.field = field
        self.operator = `operator`
        self.value = SQLBind(value)
    }

}
