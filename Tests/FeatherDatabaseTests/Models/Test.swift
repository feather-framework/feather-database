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
        enum CodingKeys: String, DatabaseColumnName {
            case id
            case title
            case notes
        }
        static let tableName = "test"
        static let columnNames = CodingKeys.self

        // MARK: - fields
        let id: Key<Self>
        let title: String
        let notes: String?
    }

    struct ModelSecond: DatabaseModel {

        enum CodingKeys: String, DatabaseColumnName {
            case id
            case secondValue = "second_value"
        }
        static let tableName = "test_second"
        static let columnNames = CodingKeys.self

        // MARK: - fields
        let id: Key<Self>
        let secondValue: String
    }

    struct ModelConnector: DatabaseModel {

        enum CodingKeys: String, DatabaseColumnName {
            case idModel = "id_model"
            case idModelSecond = "id_model_second"
        }
        static let tableName = "test_connector"
        static let columnNames = CodingKeys.self

        // MARK: - fields
        let idModel: Key<Model>
        let idModelSecond: Key<ModelSecond>
    }

    // @DatabaseQueryBuilder("test", Model.self)
    struct Query: KeyedDatabaseQuery {
        typealias Row = Model

        static let primaryKey = Row.CodingKeys.id
    }

    struct QuerySecond: KeyedDatabaseQuery {
        typealias Row = ModelSecond

        static let primaryKey = Row.CodingKeys.id
    }

    struct QuerySecondJointModel:
        DatabaseQueryJoinAll
    {
        typealias ReferenceModel = Model
        typealias ConnectorModel = ModelConnector
        typealias Row = ModelSecond

        static let referenceField = ReferenceModel.columnNames.id
        static let connectorField = ConnectorModel.columnNames.idModelSecond
        static let valueField = Row.columnNames.id
    }

    struct QueryConnector: DatabaseQuery {
        typealias Row = ModelConnector
    }

    // MARK: - migration

    struct Table: DatabaseTable {
        static let tableName = Model.tableName
        static let columns: [DatabaseColumnInterface] = [
            KeyColumn(Model.ColumnNames.id),
            StringColumn(Model.ColumnNames.title),
            StringColumn(Model.ColumnNames.notes, isMandatory: false),
        ]
    }

    struct TableConnector: DatabaseTable {
        static let tableName = ModelConnector.tableName
        static let columns: [DatabaseColumnInterface] = [
            StringColumn(ModelConnector.ColumnNames.idModel),
            StringColumn(ModelConnector.ColumnNames.idModelSecond),
        ]
    }

    struct TableSecond: DatabaseTable {
        static let tableName = ModelSecond.tableName
        static let columns: [DatabaseColumnInterface] = [
            KeyColumn(ModelSecond.ColumnNames.id),
            StringColumn(ModelSecond.ColumnNames.secondValue),
        ]
    }

    // Depracated field example:
    //enum DeprecatedColumnNames: String, DatabaseColumnName {
    //  case none
    //}
}
