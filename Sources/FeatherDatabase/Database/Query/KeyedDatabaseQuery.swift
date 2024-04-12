//
//  File.swift
//
//
//  Created by Tibor Bodecs on 12/04/2024.
//

public protocol KeyedDatabaseQuery:
    DatabaseQuery,
    KeyedDatabaseQueryDelete,
    KeyedDatabaseQueryGet,
    KeyedDatabaseQueryUpdate
{

}
