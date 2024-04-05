//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

import SQLKit

public protocol QueryFieldKey: CodingKey, RawRepresentable
where RawValue == String {

}

extension QueryFieldKey {

    var sqlValue: SQLIdentifier {
        SQLIdentifier(rawValue)
    }
}
