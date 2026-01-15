//
//  MySQLTransactionError.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

/// Transaction error details for MySQL operations.
///
/// Use this to capture errors from transaction phases.
public struct MySQLTransactionError: DatabaseTransactionError {

    /// The source file where the error was created.
    ///
    /// This is captured with `#fileID` by default.
    public let file: String
    /// The source line where the error was created.
    ///
    /// This is captured with `#line` by default.
    public let line: Int

    /// The error thrown while beginning the transaction.
    ///
    /// Set when the `START TRANSACTION` step fails.
    public var beginError: Error?
    /// The error thrown inside the transaction closure.
    ///
    /// Set when the closure fails before commit.
    public var closureError: Error?
    /// The error thrown while committing the transaction.
    ///
    /// Set when the `COMMIT` step fails.
    public var commitError: Error?
    /// The error thrown while rolling back the transaction.
    ///
    /// Set when the `ROLLBACK` step fails.
    public var rollbackError: Error?

    /// Create a MySQL transaction error payload.
    ///
    /// Use this to record the errors that occurred during transaction handling.
    /// - Parameters:
    ///   - file: The source file identifier.
    ///   - line: The source line number.
    ///   - beginError: The error thrown while beginning the transaction.
    ///   - closureError: The error thrown inside the transaction closure.
    ///   - commitError: The error thrown while committing the transaction.
    ///   - rollbackError: The error thrown while rolling back the transaction.
    public init(
        file: String = #fileID,
        line: Int = #line,
        beginError: Error? = nil,
        closureError: Error? = nil,
        commitError: Error? = nil,
        rollbackError: Error? = nil
    ) {
        self.file = file
        self.line = line
        self.beginError = beginError
        self.closureError = closureError
        self.commitError = commitError
        self.rollbackError = rollbackError
    }
}
