public struct SQLiteTransactionError: DatabaseTransactionError {

    public let file: String
    public let line: UInt

    public var beginError: Error?
    public var closureError: Error?
    public var commitError: Error?
    public var rollbackError: Error?

    public init(
        file: String = #fileID,
        line: UInt = #line,
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
