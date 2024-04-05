//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

import SQLKit

public protocol Table {
    static var name: String { get }
}

public protocol DatabaseTable: Table {
    static var name: String { get }

    var db: Database { get }
}
