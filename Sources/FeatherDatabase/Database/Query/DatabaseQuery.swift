//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

public protocol DatabaseQuery:
    DatabaseQueryInterface,
    DatabaseQueryAll,
    DatabaseQueryCount,
    DatabaseQueryDelete,
    DatabaseQueryFirst,
    DatabaseQueryInsert,
    DatabaseQueryList,
    DatabaseQueryUpdate
{

}
