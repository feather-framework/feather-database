//
//  File.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 01. 10..
//

public protocol DatabaseRow: Sendable {

    func decode<T: Decodable>(
        column: String,
        as: T.Type
    ) throws(DecodingError) -> T
}

