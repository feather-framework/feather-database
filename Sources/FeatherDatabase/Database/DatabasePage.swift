//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public struct DatabasePage {

    public let limit: DatabaseLimit
    public let offset: DatabaseOffset

    public init(
        size: UInt,
        index: UInt
    ) {
        self.limit = .init(size)
        self.offset = .init(size * index)
    }
}

extension SQLSelectBuilder {

    func applyPage(_ page: DatabasePage? = nil) -> Self {
        guard let page else {
            return self
        }
        return
            self
            .applyLimit(page.limit)
            .applyOffset(page.offset)
    }
}
