//
//  DatabaseIndexedQueryBinding.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 02. 07..
//

/// A bound value with a stable index for a query.
public struct DatabaseQueryBindings: Sendable, Equatable, Hashable, Codable {

    /// The zero-based binding index.
    public var index: Int
    /// The bound value.
    public var binding: DatabaseQueryBinding

    /// Create a new indexed binding.
    /// - Parameters:
    ///   - index: The zero-based binding index.
    ///   - binding: The bound value.
    public init(
        index: Int,
        binding: DatabaseQueryBinding
    ) {
        self.index = index
        self.binding = binding
    }
}
