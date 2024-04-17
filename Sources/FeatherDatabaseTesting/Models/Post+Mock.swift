//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 17/04/2024.
//

import NanoID

extension Blog.Post.Model {

    static func mock(_ i: Int = 0) -> Blog.Post.Model {
        .init(
            id: NanoID.generateKey(),
            slug: "slug-\(i)",
            title: "title-\(i)"
        )
    }
}
