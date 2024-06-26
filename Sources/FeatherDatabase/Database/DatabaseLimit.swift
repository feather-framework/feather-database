//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public struct DatabaseLimit {

    public let value: UInt

    public init(_ value: UInt) {
        self.value = value
    }

    var sqlValue: Int {
        Int(value)
    }
}

extension SQLSelectBuilder {

    func applyLimit(_ limit: DatabaseLimit? = nil) -> Self {
        guard let limit else {
            return self
        }
        return self.limit(limit.sqlValue)
    }
}
