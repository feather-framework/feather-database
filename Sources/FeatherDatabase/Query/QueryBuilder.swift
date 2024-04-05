//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

public protocol QueryBuilder:
    DatabaseTableQuery,
    DatabaseTableQueryAll,
    DatabaseTableQueryCount,
    DatabaseTableQueryDelete,
    DatabaseTableQueryFirst,
    DatabaseTableQueryInsert,
    DatabaseTableQueryList
{

}

public protocol KeyedQueryBuilder:
    QueryBuilder,
    KeyedDatabaseTableQuery,
    KeyedDatabaseTableQueryDelete,
    KeyedDatabaseTableQueryGet,
    KeyedDatabaseTableQueryUpdate
{

}
