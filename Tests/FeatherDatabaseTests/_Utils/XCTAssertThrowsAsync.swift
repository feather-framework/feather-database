//
//  File.swift
//
//
//  Created by Tibor Bodecs on 29/02/2024.
//

import XCTest

func XCTAssertThrowsAsync<E: Error>(
    _ expression: () async throws -> Void,
    _: E.Type,
    _ errorBlock: ((E) async throws -> Void)? = nil,
    _ message: String,
    file: StaticString = #file,
    line: UInt = #line
) async throws {
    do {
        _ = try await expression()
    }
    catch let error as E {
        try await errorBlock?(error)
    }
    catch {
        XCTFail(message, file: file, line: line)
    }
}
