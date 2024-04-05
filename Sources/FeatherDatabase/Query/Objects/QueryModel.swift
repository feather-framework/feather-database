//
//  File.swift
//
//
//  Created by Tibor Bodecs on 07/03/2024.
//

public protocol QueryModel: Codable {
    associatedtype FieldKeys: QueryFieldKey

    static var fieldKeys: FieldKeys.Type { get }
}
