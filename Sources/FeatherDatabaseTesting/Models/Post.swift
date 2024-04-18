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
            public typealias KeyType = Key<Blog.Post>

            public enum CodingKeys: String, DatabaseColumnName {
                case id
                case slug
                case title
                case published
            }
            public static let tableName = "post"
            public static let columnNames = CodingKeys.self
            public static let keyName = CodingKeys.id

            // MARK: - fields
            public let id: KeyType
            public let slug: String
            public let title: String
            public let published: Bool

            public init(
                id: KeyType,
                slug: String,
                title: String,
                published: Bool
            ) {
                self.id = id
                self.slug = slug
                self.title = title
                self.published = published
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
                BoolColumn(Model.ColumnNames.published),
            ]

            public static let constraints: [DatabaseConstraintInterface] = [
                PrimaryKeyConstraint(Model.ColumnNames.id),
                UniqueConstraint(Model.ColumnNames.slug),
            ]
        }
    }
}
