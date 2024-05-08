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

extension SQLDeleteBuilder {

    func applyFilter(
        _ filter: (any DatabaseTableFilterInterface)?
    ) -> Self {
        guard let filter else {
            return self
        }
        var res = self
        for group in filter.groups {
            switch filter.relation {
            case .and:
                res = res.where { p in
                    var p = p
                    for filter in group.columns {
                        switch group.relation {
                        case .and:
                            p = p.where(
                                filter.column.sqlValue,
                                filter.operator,
                                filter.value
                            )
                        case .or:
                            p = p.orWhere(
                                filter.column.sqlValue,
                                filter.operator,
                                filter.value
                            )
                        }
                    }
                    return p
                }
            case .or:
                res = res.orWhere { p in
                    var p = p
                    for filter in group.columns {
                        switch group.relation {
                        case .and:
                            p = p.where(
                                filter.column.sqlValue,
                                filter.operator,
                                filter.value
                            )
                        case .or:
                            p = p.orWhere(
                                filter.column.sqlValue,
                                filter.operator,
                                filter.value
                            )
                        }
                    }
                    return p
                }
            }

        }
        return res
    }
}
