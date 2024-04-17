//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 17/04/2024.
//

import NanoID

extension Blog.Category.Model {

    static func mock(_ i: Int = 0) -> Blog.Category.Model {
        .init(
            id: NanoID.generateKey(),
            title: "title-\(i)"
        )
    }
}
