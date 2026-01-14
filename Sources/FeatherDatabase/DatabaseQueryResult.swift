//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

public protocol DatabaseQueryResult:
    AsyncSequence,
    Sendable
where
    Element == Row
{
    associatedtype Row: DatabaseRow

    func collect() async throws -> [Element]

    func collectFirst() async throws -> Element?
}

public extension DatabaseQueryResult {

    func collectFirst() async throws -> Element? {
        for try await item in self {
            return item
        }
        return nil
   }
}
