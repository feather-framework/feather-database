//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import FeatherDatabase
import SQLKit

enum Test {

    // @DatabaseQueryModel
    struct Model: QueryModel {

        // TODO: macro
        enum CodingKeys: String, QueryFieldKey {
            case id
            case title
            case notes
        }
        static let fieldKeys = CodingKeys.self

        // MARK: - fields
        let id: Key<Test>
        let title: String
        let notes: String?
    }

    // @DatabaseQueryBuilder("test", Model.self)
    struct QueryBuilder: KeyedQueryBuilder {
        typealias Row = Model

        static let name = "test"
        static let primaryKey = Model.FieldKeys.id

        let db: Database
    }

    // MARK: - migration

    //    struct Migration: DatabaseTableMigration {
    //
    //        public let name: String
    //
    //        public init() {
    //            self.name = "test"
    //        }
    //
    //        public func statements(
    //            _ builder: SQLCreateTableBuilder
    //        ) -> SQLCreateTableBuilder {
    //            builder
    //                .primaryId()
    //                .text("title")
    //                .text("notes", isMandatory: false)
    //        }
    //    }

    //    struct MigrationGroup: MigrationKit.MigrationGroup {
    //
    //        func migrations() -> [MigrationKit.Migration] {
    //            [
    //                Migration()
    //            ]
    //        }
    //    }
}
