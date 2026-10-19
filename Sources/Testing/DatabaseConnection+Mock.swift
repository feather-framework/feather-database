public import FeatherDatabase

public struct MockDatabaseConnection<Key: DatabaseQueryKey>: DatabaseConnection
{
    public typealias RowSequence = MockDatabaseRowSequence

    public struct Response: Sendable {
        public let key: Key
        public let rows: [MockDatabaseRow]

        public init(key: Key, rows: [MockDatabaseRow] = []) {
            self.key = key
            self.rows = rows
        }
    }

    private let state: State

    public init(responses: [Response]) {
        self.state = State(responses: responses)
    }

    public func run<T: Sendable>(
        query: DatabaseQuery,
        _ handler: (RowSequence) async throws -> T
    ) async throws(DatabaseError) -> T {
        let rows: [MockDatabaseRow]
        do {
            rows = try await state.recordAndNextResponse(for: query)
        }
        catch {
            throw .query(error)
        }
        do {
            return try await handler(.init(rows: rows))
        }
        catch let error as DatabaseError {
            throw error
        }
        catch {
            throw .query(error)
        }
    }

    public func executedQueries() async -> [Key: [DatabaseQuery]] {
        await state.executedQueries()
    }

    public func assertAllResponsesConsumed() async throws {
        try await state.assertAllResponsesConsumed()
    }

    private actor State {
        private var responses: [Response]
        private var queries: [Key: [DatabaseQuery]] = [:]

        init(responses: [Response]) {
            self.responses = responses
        }

        func recordAndNextResponse(for query: DatabaseQuery) throws
            -> [MockDatabaseRow]
        {
            guard !responses.isEmpty else {
                throw UnexpectedQueryError(
                    message: "Received an unexpected query: \(query.sql)"
                )
            }
            let response = responses.removeFirst()
            queries[response.key, default: []].append(query)
            return response.rows
        }

        func executedQueries() -> [Key: [DatabaseQuery]] { queries }

        func assertAllResponsesConsumed() throws {
            guard !responses.isEmpty else { return }
            let keys = responses.map { String(reflecting: $0.key) }
                .joined(separator: ", ")
            throw UnexpectedQueryError(
                message: "Expected query responses were not consumed: \(keys)"
            )
        }
    }

    private struct UnexpectedQueryError: Error, Sendable,
        CustomStringConvertible
    {
        let message: String
        var description: String { message }
    }
}
