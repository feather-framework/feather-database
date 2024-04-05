//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/03/2024.
//

import FeatherComponent
import FeatherDatabase
import NanoID
import XCTest

final class KeyGenerationTests: TestCase {

    func testKeyGeneration() {
        struct MyModel {}

        let nanoId: Key<MyModel> = NanoID.generateKey()

        XCTAssertEqual(nanoId.rawValue.count, 21)

        let customId: Key<MyModel> = UUID.generateKey()
        let customId2: Key<MyModel> = .init(rawValue: customId.rawValue)

        XCTAssertEqual(customId, customId2)
    }
}
