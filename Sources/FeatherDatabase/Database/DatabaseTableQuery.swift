//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

public protocol DatabaseTableQuery: DatabaseTable {
    associatedtype Row: QueryModel
}
