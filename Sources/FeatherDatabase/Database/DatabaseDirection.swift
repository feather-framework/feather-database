//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public enum DatabaseDirection {
    case asc
    case desc
}

extension DatabaseDirection {

    var sqlValue: SQLDirection {
        switch self {
        case .asc: .ascending
        case .desc: .descending
        }
    }
}
