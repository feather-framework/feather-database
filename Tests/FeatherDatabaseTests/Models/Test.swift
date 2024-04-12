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
    struct Model: DatabaseModel {
        static let tableName = "test"

        // TODO: macro
        enum CodingKeys: String, DatabaseColumnName {
            case id
            case title
            case notes
        }
        static let columnNames = CodingKeys.self

        // MARK: - fields
        let id: Key<Self>
        let title: String
        let notes: String?
    }

    struct ModelSecond: DatabaseModel {
        static let tableName = "test_second"

        // TODO: macro
        enum CodingKeys: String, DatabaseColumnName {
            case id
            case secondValue = "second_value"
        }
        static let columnNames = CodingKeys.self

        // MARK: - fields
        let id: Key<Self>
        let secondValue: String
    }

    struct ModelConnector: DatabaseModel {
        static let tableName = "test_connector"

        // TODO: macro
        enum CodingKeys: String, DatabaseColumnName {
            case idModel = "id_model"
            case idModelSecond = "id_model_second"
        }
        static let columnNames = CodingKeys.self

        // MARK: - fields
        let idModel: Key<Model>
        let idModelSecond: Key<ModelSecond>
    }

    // @DatabaseQueryBuilder("test", Model.self)
    struct Query:
        QueryBuilder,
        KeyedQueryBuilder
    {
        typealias Row = Model

        static let primaryKey = Row.CodingKeys.id
    }

    struct QuerySecond:
        QueryBuilder,
        KeyedQueryBuilder,
        DatabaseQueryJointAll
    {
        typealias ReferenceModel = Model
        typealias ConnectorModel = ModelConnector
        typealias Row = ModelSecond

        static let referenceField = ReferenceModel.columnNames.id
        static let connectorField = ConnectorModel.columnNames.idModelSecond
        static let valueField = Row.columnNames.id

        static let primaryKey = Row.CodingKeys.id
    }

    struct QueryConnector:
        QueryBuilder
    {
        typealias Row = ModelConnector
    }

    // MARK: - migration

    struct Table: DatabaseTable {
        static let tableName = Model.tableName
        static let columns: [DatabaseColumn] = [
            KeyColumn(Model.ColumnNames.id),
            StringColumn(Model.ColumnNames.title),
            StringColumn(Model.ColumnNames.notes, isMandatory: false),
        ]
    }

    struct TableConnector: DatabaseTable {
        static let tableName = ModelConnector.tableName
        static let columns: [DatabaseColumn] = [
            StringColumn(ModelConnector.ColumnNames.idModel),
            StringColumn(ModelConnector.ColumnNames.idModelSecond),
        ]
    }

    struct TableSecond: DatabaseTable {
        static let tableName = ModelSecond.tableName
        static let columns: [DatabaseColumn] = [
            KeyColumn(ModelSecond.ColumnNames.id),
            StringColumn(ModelSecond.ColumnNames.secondValue),
        ]
    }

    // Depracated field example:
    //enum DeprecatedColumnNames: String, DatabaseColumnName {
    //  case none
    //}
}
