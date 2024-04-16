//
//  File.swift
//
//
//  Created by Tibor Bodecs on 16/04/2024.
//

import FeatherDatabase

extension Blog {

    public enum PostTag {

        // MARK: - model

        public struct Model: DatabaseModel {

            public enum CodingKeys: String, DatabaseColumnName {
                case postId = "post_id"
                case tagId = "tag_id"
            }
            public static let tableName = "post_tag"
            public static let columnNames = CodingKeys.self

            // MARK: - fields
            public let postId: Key<Blog.Post>
            public let tagId: Key<Blog.Tag>

            public init(postId: Key<Blog.Post>, tagId: Key<Blog.Tag>) {
                self.postId = postId
                self.tagId = tagId
            }
        }

        // MARK: - query

        public enum Query: DatabaseQuery, DatabaseQueryJoin {
            public typealias Row = Model
        }

        // MARK: - table

        public enum Table: DatabaseTable {
            public static let tableName = Model.tableName
            public static let columns: [DatabaseColumnInterface] = [
                StringColumn(Model.ColumnNames.postId),
                StringColumn(Model.ColumnNames.tagId),
            ]

            public static let constraints: [DatabaseConstraintInterface] = [
                PrimaryKeyConstraint(
                    [
                        Model.ColumnNames.postId,
                        Model.ColumnNames.tagId,
                    ]
                )
            ]
        }
    }
}
