//
//  File.swift
//
//
//  Created by Tibor Bodecs on 16/04/2024.
//

import FeatherDatabase

extension Blog {

    public enum Category {

        // MARK: - model

        public struct Model: DatabaseModel {

            public enum CodingKeys: String, DatabaseColumnName {
                case id
                case title
            }
            public static let tableName = "category"
            public static let columnNames = CodingKeys.self

            // MARK: - fields
            public let id: Key<Blog.Category>
            public let title: String

            public init(
                id: Key<Blog.Category>,
                title: String
            ) {
                self.id = id
                self.title = title
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
                StringColumn(Model.ColumnNames.id),
                StringColumn(Model.ColumnNames.title),
            ]
            public static let constraints: [DatabaseConstraintInterface] = [
                PrimaryKeyConstraint(Model.ColumnNames.id)
            ]
        }
    }
}
