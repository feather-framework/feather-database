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

    struct Migration: DatabaseTableStructure {
        var db: FeatherDatabase.Database

        static let name: String = "test"
        static let columns: [ColumnStructure] = [
            KeyColumn(),
            StringColumn(name: "title"),
            StringColumn(name: "notes", isMandatory: false),
        ]
    }
}
