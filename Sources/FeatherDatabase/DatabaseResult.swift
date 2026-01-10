//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

public protocol DatabaseResult: AsyncSequence, Sendable where Element == Row {
    associatedtype Row: DatabaseRow

    func collect() async throws -> [Element]
}
