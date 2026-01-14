import PostgresNIO

public struct PostgresQueryResult: DatabaseQueryResult {

    var backingSequence: PostgresRowSequence

    public struct AsyncIterator: AsyncIteratorProtocol {
        var backingIterator: PostgresRowSequence.AsyncIterator

        @concurrent
        public mutating func next() async throws -> PostgresRow? {
            guard !Task.isCancelled else {
                return nil
            }
            guard let postgresRow = try await backingIterator.next() else {
                return nil
            }
            return postgresRow
        }
    }

    public func makeAsyncIterator() -> AsyncIterator {
        .init(
            backingIterator: backingSequence.makeAsyncIterator(),
        )
    }

    public func collect() async throws -> [PostgresRow] {
        var items: [PostgresRow] = []
        for try await item in self {
            items.append(item)
        }
        return items
    }
}
