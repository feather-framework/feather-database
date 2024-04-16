//
//  File.swift
//
//
//  Created by Tibor Bodecs on 16/04/2024.
//

import FeatherDatabase

extension Blog {

    public enum Tag {

        // MARK: - model

        public struct Model: DatabaseModel {
            public enum CodingKeys: String, DatabaseColumnName {
                case id
                case name
            }
            public static let tableName = "tag"
            public static let columnNames = CodingKeys.self

            // MARK: - fields
            public let id: Key<Blog.Tag>
            public let name: String

            public init(
                id: Key<Blog.Tag>,
                name: String
            ) {
                self.id = id
                self.name = name
            }
        }

        // MARK: - query

        public enum Query: KeyedDatabaseQuery {
            public typealias Row = Model
            public static let primaryKey = Row.CodingKeys.id
        }

        // MARK: - table

        public enum Table: DatabaseTable {
            public static let tableName = Model.tableName
            public static let columns: [DatabaseColumnInterface] = [
                KeyColumn(Model.ColumnNames.id),
                StringColumn(Model.ColumnNames.name),
            ]
        }
    }
}
