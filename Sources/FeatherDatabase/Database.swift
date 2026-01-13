//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//
import ServiceLifecycle

/// The Database protocol.
public protocol Database: Sendable, ServiceLifecycle.Service {

    associatedtype Query: DatabaseQuery
    associatedtype Result: DatabaseResult

    //    var dialect: String { get }

    @discardableResult
    func connection(
        _:
            nonisolated(nonsending)(any DatabaseConnection) async throws ->
            sending Result,
    ) async throws -> sending Result

    @discardableResult
    func transaction(
        _:
            nonisolated(nonsending)(any DatabaseConnection) async throws ->
            sending Result,
    ) async throws -> sending Result

    @discardableResult
    func execute(
        query: Query,
    ) async throws -> Result

}

extension Database {

    public func run() async throws {

    }

    @discardableResult
    public func execute(
        query: Query,
    ) async throws -> Result {
        try await connection { connection in
            try await connection.execute(query: query)
        }
    }
}
