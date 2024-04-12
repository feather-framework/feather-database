//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseFilterInterface {
    associatedtype ColumnName: DatabaseColumnName

    var column: ColumnName { get }
    var `operator`: SQLBinaryOperator { get }
    var value: SQLExpression { get }
}

extension SQLSelectBuilder {

    func applyFilter<T: DatabaseFilterInterface>(
        _ filter: T?
    ) -> Self {
        guard let filter else {
            return self
        }
        return self.where(
            filter.column.sqlValue,
            filter.operator,
            filter.value
        )
    }
}

extension SQLDeleteBuilder {

    func applyFilter<T: DatabaseFilterInterface>(
        _ filter: T?
    ) -> Self {
        guard let filter else {
            return self
        }
        return self.where(
            filter.column.sqlValue,
            filter.operator,
            filter.value
        )
    }
}
