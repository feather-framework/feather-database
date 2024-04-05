//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public enum QueryDirection {
    case asc
    case desc
}

extension QueryDirection {

    var sqlValue: SQLDirection {
        switch self {
        case .asc: .ascending
        case .desc: .descending
        }
    }
}
