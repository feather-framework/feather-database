//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

public protocol DatabaseRow: Sendable {

    func decode<T: Decodable>(column: String, as: T.Type) throws -> T
}

//func transform<T>(
//    _ t: @escaping (PostgresRow) throws -> T
//) -> RowSequence<T> {
//    .init(
//        backingSequence: self,
//        transformer: t
//    )
//}
//
//func transform<T>(
//    _ t: @escaping (PostgresRandomAccessRow) throws -> T
//) async throws -> RowSequence<T> {
//    transform { try t(.init($0)) }
//}
//
//func collectFirst<T: PostgresDecodable>(
//    as _: T.Type
//) async throws -> T? {
//    guard let first = try await collect().first?.decode(T.self) else {
//        return nil
//    }
//    return first
//}

//public struct RowSequence<T>: AsyncSequence {
//    public typealias Element = T
//
//    var backingSequence: PostgresRowSequence
//    var transformer: (PostgresRow) throws -> T
//
//    public struct AsyncIterator: AsyncIteratorProtocol {
//        var backingIterator: PostgresRowSequence.AsyncIterator
//        var transformer: (PostgresRow) throws -> T
//
//        public mutating func next() async throws -> Element? {
//            guard !Task.isCancelled else {
//                return nil
//            }
//            guard let postgresRow = try await backingIterator.next() else {
//                return nil
//            }
//            return try transformer(postgresRow)
//        }
//    }
//
//    public func makeAsyncIterator() -> AsyncIterator {
//        .init(
//            backingIterator: backingSequence.makeAsyncIterator(),
//            transformer: transformer
//        )
//    }
//
//    public func collect() async throws -> [T] {
//        var items: [T] = []
//        for try await item in self {
//            items.append(item)
//        }
//        return items
//    }
//}
