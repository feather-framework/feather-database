//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

import SQLKit

public struct DatabaseList<F: DatabaseColumnName>: DatabaseListInterface {
    //public let column: QueryColumn<F>
    public let page: DatabasePage?
    public let orders: [DatabaseOrder<F>]
    public let filter: DatabaseTableFilter<F>?

    public init(
        page: DatabasePage? = nil,
        orders: [DatabaseOrder<F>] = [],
        filter: DatabaseTableFilter<F>? = nil
    ) {
        self.page = page
        self.orders = orders
        self.filter = filter
    }

    public struct Result<T: Codable> {
        public let items: [T]
        public let total: UInt

        public init(items: [T], total: UInt) {
            self.items = items
            self.total = total
        }
    }
}
