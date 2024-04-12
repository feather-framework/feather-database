//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public struct DatabaseOffset {

    public let value: UInt

    public init(_ value: UInt) {
        self.value = value
    }

    var sqlValue: Int {
        Int(value)
    }
}

extension SQLSelectBuilder {

    func applyOffset(_ offset: DatabaseOffset? = nil) -> Self {
        guard let offset else {
            return self
        }
        return self.offset(offset.sqlValue)
    }
}
