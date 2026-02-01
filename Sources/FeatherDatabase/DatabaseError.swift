//
//  DatabaseError.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 14..
//

/// High-level database errors surfaced by the client API.
///
/// Use these cases to represent connection, query, and transaction failures.
public enum DatabaseError: Error, Sendable {

    /// A connection-level failure.
    ///
    /// The associated error provides the underlying cause.
    case connection(Error)

    /// A transaction failure.
    ///
    /// The associated error includes phase-specific details.
    case transaction(DatabaseTransactionError)

    /// A query execution failure.
    ///
    /// The associated error provides the underlying cause.
    case query(Error)

}
