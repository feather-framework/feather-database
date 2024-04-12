//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public struct DatabaseFilter<F: DatabaseColumnName>: DatabaseFilterInterface {

    public let column: F
    public let `operator`: SQLBinaryOperator
    public var value: SQLExpression

    public init<T: Encodable>(
        column: F,
        operator: SQLBinaryOperator,
        value: [T]
    ) {
        self.column = column
        self.operator = `operator`
        self.value = SQLBind.group(value)
    }

    public init<T: Encodable>(
        column: F,
        operator: SQLBinaryOperator,
        value: T
    ) {
        self.column = column
        self.operator = `operator`
        self.value = SQLBind(value)
    }

}
