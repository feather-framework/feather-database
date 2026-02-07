//
//  DatabaseIndexedQueryBinding.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 02. 07..
//

public struct DatabaseQueryBindings: Sendable, Equatable, Hashable, Codable {
    
    public var index: Int
    public var binding: DatabaseQueryBinding
    
    public init(
        index: Int,
        binding: DatabaseQueryBinding
    ) {
        self.index = index
        self.binding = binding
    }
}
