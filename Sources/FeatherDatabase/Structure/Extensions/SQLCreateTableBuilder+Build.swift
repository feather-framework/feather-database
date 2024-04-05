//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

extension SQLCreateTableBuilder {

    public func build(_ schema: any DatabaseTableStructure) -> Self {
        var otherSelf = self
        for column in schema.columns {
            otherSelf = otherSelf.column(
                column.name,
                type: column.type,
                column.constraints
            )
        }
        return otherSelf
    }
}
