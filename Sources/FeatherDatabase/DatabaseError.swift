//
//  DatabaseError.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 14..
//

/// High-level database errors surfaced by the client API.
///
/// Use these cases to represent connection, query, and transaction failures.
public enum DatabaseError: Error {

    /// A connection-level failure.
    ///
    /// The associated error provides the underlying cause.
    case connection(any Error)

    /// A transaction failure.
    ///
    /// The associated error includes phase-specific details.
    case transaction(any DatabaseTransactionError)

    /// A query execution failure.
    ///
    /// The associated error provides the underlying cause.
    case query(any Error)

}
