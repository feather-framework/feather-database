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

        public struct Model: KeyedDatabaseModel {
            public typealias KeyType = Key<Blog.Category>

            public enum CodingKeys: String, DatabaseColumnName {
                case id
                case title
            }
            public static let tableName = "category"
            public static let columnNames = CodingKeys.self
            public static let keyName = CodingKeys.id

            // MARK: - fields
            public let id: KeyType
            public let title: String

            public init(
                id: KeyType,
                title: String
            ) {
                self.id = id
                self.title = title
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
                StringColumn(Model.ColumnNames.title),
            ]
            public static let constraints: [DatabaseConstraintInterface] = [
                PrimaryKeyConstraint(Model.ColumnNames.id)
            ]
        }
    }
}
