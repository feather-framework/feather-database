//
//  File.swift
//
//
//  Created by Tibor Bodecs on 16/02/2024.
//

import FeatherComponent
import FeatherDatabase
import Logging
import NIO
import SQLKit
import SQLiteNIO
import SQLiteKit

extension ComponentRegistry {

    public func configure(
        _ threadPool: NIOThreadPool,
        _ eventLoopGroup: EventLoopGroup
    ) async throws {
        let connectionSource = SQLiteConnectionSource(
            configuration: .init(
                storage: .memory
            ),
            threadPool: threadPool
        )

        let pool = EventLoopGroupConnectionPool(
            source: connectionSource,
            on: eventLoopGroup
        )

        try await addDatabase(
            SQLiteDatabaseComponentContext(
                pool: pool
            )
        )

    }
}
