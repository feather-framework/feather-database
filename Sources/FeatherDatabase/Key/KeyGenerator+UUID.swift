//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/03/2024.
//

import Foundation

extension UUID: KeyGenerator {

    public static func generateKey<T>() -> Key<T> {
        .init(rawValue: UUID().uuidString)
    }
}
