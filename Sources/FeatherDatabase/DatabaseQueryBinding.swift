//
//  DatabaseQueryBinding.swift
//  feather-database
//
//  Created by Tibor Bödecs on 2026. 02. 07..
//

public enum DatabaseQueryBinding: Sendable, Equatable, Hashable, Codable {
    case string(String)
    case int(Int)
    case double(Double)
}
