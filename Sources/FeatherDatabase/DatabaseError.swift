//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

public enum DatabaseError: Error {
    case connection(Error)
    case query(Error)
}
