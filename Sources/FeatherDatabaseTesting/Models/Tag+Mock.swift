//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 17/04/2024.
//

import NanoID

extension Blog.Tag.Model {

    static func mock(_ i: Int = 0) -> Blog.Tag.Model {
        .init(
            id: NanoID.generateKey(),
            name: "name-\(i)"
        )
    }
}
