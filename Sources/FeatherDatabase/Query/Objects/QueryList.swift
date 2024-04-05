//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

import SQLKit

public struct QueryList<F: QueryFieldKey>: QueryListInterface {
    //public let column: QueryColumn<F>
    public let page: QueryPage?
    public let orders: [QueryOrder<F>]
    public let filter: QueryFilter<F>?

    public init(
        page: QueryPage? = nil,
        orders: [QueryOrder<F>] = [],
        filter: QueryFilter<F>? = nil
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
