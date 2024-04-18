//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol DatabaseColumnName: CodingKey, RawRepresentable
where RawValue == String {

}

extension DatabaseColumnName {

    var sqlValue: SQLIdentifier {
        SQLIdentifier(rawValue)
    }
}
