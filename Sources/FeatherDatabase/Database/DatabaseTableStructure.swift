//
//  File.swift
//
//
//  Created by Tibor Bodecs on 05/04/2024.
//

public protocol DatabaseTableStructure: DatabaseTable {

    static var columns: [ColumnStructure] { get }
}
