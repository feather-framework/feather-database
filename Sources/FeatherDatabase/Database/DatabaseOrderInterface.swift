//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseOrderInterface {
    associatedtype Column: DatabaseColumnName

    var column: Column { get }
    var direction: DatabaseDirection { get }
}

extension SQLSelectBuilder {

    func applyOrders<T: DatabaseOrderInterface>(
        _ orders: [T]
    ) -> Self {
        var res = self
        for order in orders {
            res = res.orderBy(order.column.sqlValue, order.direction.sqlValue)
        }
        return res
    }

    func applyOrder<T: DatabaseOrderInterface>(
        _ order: T?
    ) -> Self {
        guard let order else {
            return self
        }
        return orderBy(order.column.sqlValue, order.direction.sqlValue)
    }
}
