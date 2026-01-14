//
//  DatabaseTestSuite.swift
//  feather-database
//
//  Created by Tibor Bodecs on 2023. 01. 16..
//

import Logging
import Testing
import PostgresNIO

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

@testable import FeatherDatabase
@testable import FeatherDatabaseTesting

@Suite
struct PostgresDatabaseTestSuite {

    private func getTestDatabaseClient() async throws -> PostgresDatabaseClient {
        var logger = Logger(label: "test")
        logger.logLevel = .info

        let finalCertPath = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("docker")
            .appendingPathComponent("certificates")
            .appendingPathComponent("ca.pem")
            .path()

        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        let rootCert = try NIOSSLCertificate.fromPEMFile(finalCertPath)
        tlsConfig.trustRoots = .certificates(rootCert)
        tlsConfig.certificateVerification = .fullVerification

        return .init(
            client: .init(
                configuration: .init(
                    host: "127.0.0.1",
                    port: 5432,
                    username: "postgres",
                    password: "postgres",
                    database: "postgres",
                    tls: .require(tlsConfig)
                ),
                backgroundLogger: logger
            ),
            logger: logger
        )
    }
    
    private func runUsingTestDatabaseClient(
        _ closure: ((PostgresDatabaseClient) async throws -> Void)
    ) async throws {
        let database = try await getTestDatabaseClient()
        
        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask {
                try await database.run()
            }
            try await closure(database)
            taskGroup.cancelAll()
        }
    }
    
    // MARK: -
    
    @Test
    func versionCheck() async throws {
        try await runUsingTestDatabaseClient { database in
            let result = try await database.execute(
                query: #"""
                    SELECT 
                        version() AS "version" 
                    WHERE 
                        1=\#(1);
                    """#
            )

            let resultArray = try await result.collect()
            #expect(resultArray.count == 1)

            let item = resultArray[0]
            let version = try item.decode(column: "version", as: String.self)
            #expect(version.contains("PostgreSQL"))
        }
    }
}
