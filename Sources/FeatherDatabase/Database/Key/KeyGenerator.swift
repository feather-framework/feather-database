//
//  File.swift
//
//
//  Created by Tibor Bodecs on 21/03/2024.
//

public protocol KeyGenerator {

    static func generateKey<T>() -> Key<T>
}

//extension Key {
//
//    public static func generate<G: KeyGenerator>(
//        _ generator: G.Type
//    ) -> Self {
//        G.generateKey()
//    }
//}
