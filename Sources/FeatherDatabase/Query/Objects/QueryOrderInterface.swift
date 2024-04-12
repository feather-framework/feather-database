//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol QueryOrderInterface {
    associatedtype Field: DatabaseColumnName

    var field: Field { get }
    var direction: QueryDirection { get }
}

extension SQLSelectBuilder {

    func applyOrders<T: QueryOrderInterface>(
        _ orders: [T]
    ) -> Self {
        var res = self
        for order in orders {
            res = res.orderBy(order.field.sqlValue, order.direction.sqlValue)
        }
        return res
    }

    func applyOrder<T: QueryOrderInterface>(
        _ order: T?
    ) -> Self {
        guard let order else {
            return self
        }
        return orderBy(order.field.sqlValue, order.direction.sqlValue)
    }
}
