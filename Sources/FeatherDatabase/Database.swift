//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//
import ServiceLifecycle

/// The Database protocol.
public protocol Database: Sendable, ServiceLifecycle.Service {

    associatedtype Connection: DatabaseConnection

    //    var dialect: String { get }

    @discardableResult
    func connection(
        _:
            nonisolated(nonsending)(Connection) async throws ->
        sending Connection.Result,
    ) async throws -> sending Connection.Result

    @discardableResult
    func transaction(
        _:
            nonisolated(nonsending)(Connection) async throws ->
        sending Connection.Result,
    ) async throws -> sending Connection.Result

    @discardableResult
    func execute(
        query: Connection.Query,
    ) async throws -> Connection.Result

}

extension Database {

    public func run() async throws {

    }

    @discardableResult
    public func execute(
        query: Connection.Query,
    ) async throws -> Connection.Result {
        try await connection { connection in
            try await connection.execute(query: query)
        }
    }
}
