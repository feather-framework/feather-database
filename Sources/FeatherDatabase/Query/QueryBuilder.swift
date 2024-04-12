//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

public protocol QueryBuilder:
    DatabaseQuery,
    DatabaseQueryAll,
    DatabaseQueryCount,
    DatabaseQueryDelete,
    DatabaseQueryFirst,
    DatabaseQueryInsert,
    DatabaseQueryList
{

}

public protocol KeyedQueryBuilder:
    QueryBuilder,
    KeyedDatabaseQuery,
    KeyedDatabaseQueryDelete,
    KeyedDatabaseQueryGet,
    KeyedDatabaseQueryUpdate
{

}
