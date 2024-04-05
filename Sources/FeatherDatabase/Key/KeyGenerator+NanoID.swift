//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/03/2024.
//

import NanoID

extension NanoID: KeyGenerator {

    public static func generateKey<T>() -> Key<T> {
        .init(rawValue: NanoID().rawValue)
    }
}
