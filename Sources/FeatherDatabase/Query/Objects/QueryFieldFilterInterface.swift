//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol QueryFieldFilterInterface {
    associatedtype Field: QueryFieldKey

    var field: Field { get }
    var `operator`: SQLBinaryOperator { get }
    var value: SQLExpression { get }
}

extension SQLSelectBuilder {

    func applyFilter<T: QueryFieldFilterInterface>(
        _ filter: T?
    ) -> Self {
        guard let filter else {
            return self
        }
        return self.where(
            filter.field.sqlValue,
            filter.operator,
            filter.value
        )
    }
}

extension SQLDeleteBuilder {

    func applyFilter<T: QueryFieldFilterInterface>(
        _ filter: T?
    ) -> Self {
        guard let filter else {
            return self
        }
        return self.where(
            filter.field.sqlValue,
            filter.operator,
            filter.value
        )
    }
}
