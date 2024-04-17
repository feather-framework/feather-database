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

        public struct Model: KeyedDatabaseModel {

            public enum CodingKeys: String, DatabaseColumnName {
                case id
                case name
            }
            public static let tableName = "tag"
            public static let columnNames = CodingKeys.self
            public static let key = CodingKeys.id

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

        public enum Query: DatabaseQuery {
            public typealias Row = Model
        }

        // MARK: - table

        public enum Table: DatabaseTable {
            public static let tableName = Model.tableName
            public static let columns: [DatabaseColumnInterface] = [
                StringColumn(Model.ColumnNames.id),
                StringColumn(Model.ColumnNames.name),
            ]

            public static let constraints: [DatabaseConstraintInterface] = [
                PrimaryKeyConstraint(Model.ColumnNames.id)
            ]
        }
    }
}
