//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

public protocol DatabaseTransactionError: Error, Sendable {
    var file: String { get }
    var line: Int { get }

    var beginError: Error? { get set }
    var closureError: Error? { get set }
    var commitError: Error? { get set }
    var rollbackError: Error? { get set }
}

public enum DatabaseError: Error, Sendable {
    case connection(Error)
    case query(Error)
    case transaction(DatabaseTransactionError)
}
