//
//  File.swift
//
//
//  Created by Tibor Bodecs on 17/03/2024.
//

public protocol QueryFilterInterface {

    var relation: QueryFilterRelation { get }
    var groups: [any QueryFilterGroupInterface] { get }
}
