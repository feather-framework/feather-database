//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

public protocol DatabaseModel: Codable {
    associatedtype ColumnNames: DatabaseColumnName

    static var tableName: String { get }
    static var columnNames: ColumnNames.Type { get }
}
