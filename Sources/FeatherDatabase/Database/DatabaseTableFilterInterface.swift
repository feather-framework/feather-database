//
//  File.swift
//
//
//  Created by Tibor Bodecs on 17/03/2024.
//

public protocol DatabaseTableFilterInterface {

    var relation: DatabaseFilterRelation { get }
    var groups: [any DatabaseGroupFilterInterface] { get }
}
