//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

public struct QueryOrder<F: QueryFieldKey>: QueryOrderInterface {
    public let field: F
    public let direction: QueryDirection

    public init(field: F, direction: QueryDirection) {
        self.field = field
        self.direction = direction
    }
}
