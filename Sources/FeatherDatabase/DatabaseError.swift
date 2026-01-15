//
//  DatabaseError.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 14..
//

/// A transaction error that captures failure details.
///
/// Use this protocol to report errors from transaction phases.
public protocol DatabaseTransactionError: Error, Sendable {
    /// The source file where the transaction error was created.
    ///
    /// This is typically populated using `#fileID`.
    var file: String { get }
    /// The source line where the transaction error was created.
    ///
    /// This is typically populated using `#line`.
    var line: Int { get }

    /// The error thrown while beginning the transaction.
    ///
    /// This is set when the begin step fails.
    var beginError: Error? { get set }
    /// The error thrown inside the transaction closure.
    ///
    /// This is set when the closure fails before commit.
    var closureError: Error? { get set }
    /// The error thrown while committing the transaction.
    ///
    /// This is set when the commit step fails.
    var commitError: Error? { get set }
    /// The error thrown while rolling back the transaction.
    ///
    /// This is set when the rollback step fails.
    var rollbackError: Error? { get set }
}

/// High-level database errors surfaced by the client API.
///
/// Use these cases to represent connection, query, and transaction failures.
public enum DatabaseError: Error, Sendable {
    /// A connection-level failure.
    ///
    /// The associated error provides the underlying cause.
    case connection(Error)
    /// A query execution failure.
    ///
    /// The associated error provides the underlying cause.
    case query(Error)
    /// A transaction failure.
    ///
    /// The associated error includes phase-specific details.
    case transaction(DatabaseTransactionError)
}
