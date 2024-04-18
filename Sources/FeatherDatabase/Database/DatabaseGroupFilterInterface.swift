//
//  File.swift
//
//
//  Created by Tibor Bodecs on 11/03/2024.
//

import SQLKit

public protocol DatabaseGroupFilterInterface {

    var relation: DatabaseFilterRelation { get }
    var columns: [any DatabaseFilterInterface] { get }
}

//// SELECT * FROM galaxies WHERE name != NULL AND (name == ? OR name == ?)
//_ = try await self.db.select()
//    .column("*")
//    .from("galaxies")
//    .where("name", .notEqual, SQLLiteral.null)
//    .where { $0
//        .orWhere("name", .equal, SQLBind("Milky Way"))
//        .orWhere("name", .equal, SQLBind("Andromeda"))
//    }
//    .all()

extension SQLSelectBuilder {

    func applyGroupFilters<T: DatabaseGroupFilterInterface>(
        _ groupFilters: [T]
    ) -> Self {
        var res = self
        for group in groupFilters {
            res = res.where { p in
                var p = p
                for filter in group.columns {
                    switch group.relation {
                    case .and:
                        p = p.where(
                            filter.column.sqlValue,
                            filter.operator,
                            filter.value
                        )
                    case .or:
                        p = p.orWhere(
                            filter.column.sqlValue,
                            filter.operator,
                            filter.value
                        )
                    }
                }
                return p
            }
        }
        return res
    }
}

extension SQLSelectBuilder {

    func applyFilter(
        _ filter: (any DatabaseTableFilterInterface)?
    ) -> Self {
        guard let filter else {
            return self
        }
        var res = self
        for group in filter.groups {
            switch filter.relation {
            case .and:
                res = res.where { p in
                    var p = p
                    for filter in group.columns {
                        switch group.relation {
                        case .and:
                            p = p.where(
                                filter.column.sqlValue,
                                filter.operator,
                                filter.value
                            )
                        case .or:
                            p = p.orWhere(
                                filter.column.sqlValue,
                                filter.operator,
                                filter.value
                            )
                        }
                    }
                    return p
                }
            case .or:
                res = res.orWhere { p in
                    var p = p
                    for filter in group.columns {
                        switch group.relation {
                        case .and:
                            p = p.where(
                                filter.column.sqlValue,
                                filter.operator,
                                filter.value
                            )
                        case .or:
                            p = p.orWhere(
                                filter.column.sqlValue,
                                filter.operator,
                                filter.value
                            )
                        }
                    }
                    return p
                }
            }

        }
        return res
    }
}
