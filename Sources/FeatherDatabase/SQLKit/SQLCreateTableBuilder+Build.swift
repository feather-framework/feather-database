//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

extension SQLCreateTableBuilder {

    public func build(_ columns: [any DatabaseColumnInterface]) -> Self {
        var otherSelf = self
        // TODO: use SQLColumnDefinition
        for column in columns {
            otherSelf = otherSelf.column(
                column.name.rawValue,
                type: column.type,
                column.constraints
            )
        }
        return otherSelf
    }
}
