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
            public typealias KeyType = Key<Blog.Tag>

            public enum CodingKeys: String, DatabaseColumnName {
                case id
                case name
                case notes
            }
            public static let tableName = "tag"
            public static let columnNames = CodingKeys.self
            public static let keyName = CodingKeys.id

            // MARK: - fields
            public let id: KeyType
            public let name: String
            public let notes: String?

            public init(
                id: KeyType,
                name: String,
                notes: String? = nil
            ) {
                self.id = id
                self.name = name
                self.notes = notes
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
                StringColumn(Model.ColumnNames.notes, isMandatory: false),
            ]

            public static let constraints: [DatabaseConstraintInterface] = [
                PrimaryKeyConstraint(Model.ColumnNames.id)
            ]
        }
    }
}
