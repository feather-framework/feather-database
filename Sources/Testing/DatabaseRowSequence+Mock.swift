public import FeatherDatabase

public struct MockDatabaseRowSequence: DatabaseRowSequence {
    public typealias Row = MockDatabaseRow
    public typealias Element = Row

    private let rows: [MockDatabaseRow]

    public init(rows: [MockDatabaseRow] = []) {
        self.rows = rows
    }

    public struct Iterator: AsyncIteratorProtocol {
        private let rows: [MockDatabaseRow]
        private var index = 0

        fileprivate init(rows: [MockDatabaseRow]) {
            self.rows = rows
        }

        public mutating func next() async -> MockDatabaseRow? {
            guard index < rows.count else { return nil }
            defer { index += 1 }
            return rows[index]
        }
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(rows: rows)
    }

    public func collect() async throws(DatabaseError) -> [MockDatabaseRow] {
        rows
    }
}
