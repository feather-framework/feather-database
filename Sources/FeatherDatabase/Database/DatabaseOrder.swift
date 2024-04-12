//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

public struct DatabaseOrder<C: DatabaseColumnName>: DatabaseOrderInterface {
    public let column: C
    public let direction: DatabaseDirection

    public init(column: C, direction: DatabaseDirection) {
        self.column = column
        self.direction = direction
    }
}
