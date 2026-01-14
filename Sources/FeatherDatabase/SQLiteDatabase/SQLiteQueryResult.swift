import SQLiteNIO

public struct SQLiteQueryResult: DatabaseQueryResult {
    let elements: [SQLiteRow]

    public struct Iterator: AsyncIteratorProtocol {
        var index = 0
        let elements: [SQLiteRow]

        public mutating func next() async -> SQLiteRow? {
            guard index < elements.count else {
                return nil
            }
            defer { index += 1 }
            return elements[index]
        }
    }

    public func makeAsyncIterator() -> Iterator {
        Iterator(elements: elements)
    }

    public func collect() async throws -> [SQLiteRow] {
        elements
    }
}
