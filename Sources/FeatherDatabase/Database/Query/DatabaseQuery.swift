//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

public protocol DatabaseQuery:
    DatabaseQueryInterface,
    DatabaseQueryCount,
    DatabaseQueryDelete,
    DatabaseQueryGet,
    DatabaseQueryInsert,
    DatabaseQueryList,
    DatabaseQueryListAll,
    DatabaseQueryUpdate,
    DatabaseQueryJoin
{

}
