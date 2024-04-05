//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public struct QueryPage {

    public let limit: QueryLimit
    public let offset: QueryOffset

    public init(
        size: UInt,
        index: UInt
    ) {
        self.limit = .init(size)
        self.offset = .init(size * index)
    }
}

extension SQLSelectBuilder {

    func applyPage(_ page: QueryPage? = nil) -> Self {
        guard let page else {
            return self
        }
        return
            self
            .applyLimit(page.limit)
            .applyOffset(page.offset)
    }
}
