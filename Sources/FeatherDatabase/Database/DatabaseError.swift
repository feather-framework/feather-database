//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

extension Database {

    public enum Error: Swift.Error {
        case connection(Swift.Error)
        case query(Swift.Error)
    }
}
