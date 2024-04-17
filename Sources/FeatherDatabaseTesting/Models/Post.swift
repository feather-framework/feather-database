//
//  File.swift
//
//
//  Created by Tibor Bodecs on 16/04/2024.
//

import FeatherDatabase

extension Blog {

    public enum Post {

        // MARK: - model

        public struct Model: KeyedDatabaseModel {
            public enum CodingKeys: String, DatabaseColumnName {
                case id
                case slug
                case title
            }
            public static let tableName = "post"
            public static let columnNames = CodingKeys.self
            public static let key = CodingKeys.id

            // MARK: - fields
            public let id: Key<Blog.Post>
            public let slug: String
            public let title: String

            public init(
                id: Key<Blog.Post>,
                slug: String,
                title: String
            ) {
                self.id = id
                self.slug = slug
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
                StringColumn(Model.ColumnNames.slug),
                StringColumn(Model.ColumnNames.title),
            ]

            public static let constraints: [DatabaseConstraintInterface] = [
                PrimaryKeyConstraint(Model.ColumnNames.id),
                UniqueConstraint(Model.ColumnNames.slug),
            ]
        }
    }
}
