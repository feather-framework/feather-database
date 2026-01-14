//
//  DatabaseTestSuite.swift
//  Feather-database
//
//  Created by Tibor Bodecs on 2026. 01. 10..
//

import FeatherDatabase

//
//    public func testInsert(_ db: Database) async throws {
//        let test = Blog.Tag.Model.mock()
//        try await Blog.Tag.Query.insert(test, on: db)
//    }
//
//    public func testCount(_ db: Database) async throws {
//        let count1 = try await Blog.Tag.Query.count(on: db)
//
//        let models: [Blog.Tag.Model] = (1...50)
//            .map {
//                .mock($0)
//            }
//        try await Blog.Tag.Query.insert(models, on: db)
//
//        let count2 = try await Blog.Tag.Query.count(on: db)
//        XCTAssertEqual(count2, count1 + 50)
//
//        let count3 = try await Blog.Tag.Query.count(
//            filter: .init(
//                column: .name,
//                operator: .like,
//                value: ["name-1%"]
//            ),
//            on: db
//        )
//        XCTAssertEqual(count3, 11)
//    }
//
//    public func testCountFilterGroup(_ db: Database) async throws {
//        let models: [Blog.Tag.Model] = (1...50)
//            .map {
//                .mock($0)
//            }
//        try await Blog.Tag.Query.insert(models, on: db)
//
//        let count = try await Blog.Tag.Query.count(
//            filter: .init(groups: [
//                .init(columns: [
//                    .init(column: .name, operator: .like, value: ["name-1%"]),
//                    .init(column: .notes, operator: .like, value: ["notes-1%"]),
//                ])
//            ]),
//            on: db
//        )
//
//        XCTAssertEqual(count, 11)
//    }
//
//    public func testGet(_ db: Database) async throws {
//
//        let test = Blog.Tag.Model(
//            id: NanoID.generateKey(),
//            name: "foo1"
//        )
//        try await Blog.Tag.Query.insert(test, on: db)
//
//        let test1 = try await Blog.Tag.Query.get(test.id, on: db)
//        XCTAssertEqual(test1?.id, test.id)
//    }
//
//    public func testFirst(_ db: Database) async throws {
//
//        let test1 = Blog.Tag.Model(
//            id: NanoID.generateKey(),
//            name: "foo2"
//        )
//        try await Blog.Tag.Query.insert(test1, on: db)
//
//        let test2 = Blog.Tag.Model(
//            id: NanoID.generateKey(),
//            name: "foo3"
//        )
//        try await Blog.Tag.Query.insert(test2, on: db)
//
//        let res1 = try await Blog.Tag.Query.getFirst(
//            filter: .init(
//                column: .name,
//                operator: .in,
//                value: ["foo2", "foo3"]
//            ),
//            order: .init(
//                column: .name,
//                direction: .desc
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(test2.id, res1?.id)
//
//        let res2 = try await Blog.Tag.Query.getFirst(
//            filter: .init(
//                column: .name,
//                operator: .equal,
//                value: ["foo3"]
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(test2.id, res2?.id)
//    }
//
//    public func testUpdateOne(_ db: Database) async throws {
//        let test1 = Blog.Tag.Model(
//            id: NanoID.generateKey(),
//            name: "foo4"
//        )
//
//        let test2 = Blog.Tag.Model(
//            id: test1.id,
//            name: "foo5"
//        )
//
//        try await Blog.Tag.Query.insert(test1, on: db)
//        try await Blog.Tag.Query.update(test1.id, test2, on: db)
//
//        let res1 = try await Blog.Tag.Query.get(test1.id, on: db)
//        XCTAssertEqual(res1?.id, test1.id)
//        XCTAssertEqual(res1?.name, test2.name)
//    }
//
//    public func testDelete(_ db: Database) async throws {
//        let count1 = try await Blog.Tag.Query.count(on: db)
//
//        let models: [Blog.Tag.Model] = (1...6).map { .mock($0) }
//        try await Blog.Tag.Query.insert(models, on: db)
//
//        let count2 = try await Blog.Tag.Query.count(on: db)
//        XCTAssertEqual(count2, count1 + 6)
//
//        try await Blog.Tag.Query.delete(models[0].id, on: db)
//
//        let count3 = try await Blog.Tag.Query.count(on: db)
//        XCTAssertEqual(count3, count2 - 1)
//
//        try await Blog.Tag.Query.delete(
//            filter: .init(
//                column: .id,
//                operator: .in,
//                value: [
//                    models[1].id,
//                    models[2].id,
//                ]
//            ),
//            on: db
//        )
//
//        let count4 = try await Blog.Tag.Query.count(on: db)
//        XCTAssertEqual(count4, count3 - 2)
//
//        try await Blog.Tag.Query.delete(
//            filter: .init(
//                column: .name,
//                operator: .in,
//                value: [
//                    "name-4",
//                    "name-5",
//                ]
//            ),
//            on: db
//        )
//
//        let all = try await Blog.Tag.Query.listAll(on: db)
//        XCTAssertEqual(all.count, Int(count1) + 1)
//        XCTAssertEqual(all[0].id, models[5].id)
//    }
//
//    public func testAll(_ db: Database) async throws {
//        let models: [Blog.Tag.Model] = (1...50).map { .mock($0) }
//        try await Blog.Tag.Query.insert(models, on: db)
//
//        let res1 = try await Blog.Tag.Query.listAll(on: db)
//        XCTAssertEqual(res1.count, 50)
//
//        let res2 = try await Blog.Tag.Query.listAll(
//            filter: .init(
//                column: .name,
//                operator: .in,
//                value: ["name-1", "name-2"]
//            ),
//            on: db
//        )
//        XCTAssertEqual(res2.count, 2)
//
//        let res3 = try await Blog.Tag.Query.listAll(
//            filter: .init(
//                column: .name,
//                operator: .equal,
//                value: "name-2"
//            ),
//            on: db
//        )
//        XCTAssertEqual(res3.count, 1)
//    }
//
//    public func testAllWithOrder(_ db: Database) async throws {
//        let models: [Blog.Tag.Model] = (1...50).map { .mock($0) }
//        try await Blog.Tag.Query.insert(models, on: db)
//
//        let res1 = try await Blog.Tag.Query.listAll(on: db)
//        XCTAssertEqual(res1.count, 50)
//
//        let res2 = try await Blog.Tag.Query.listAll(
//            orders: [
//                .init(
//                    column: .name,
//                    direction: .desc
//                )
//            ],
//            on: db
//        )
//        XCTAssertEqual(res2[0].name, "name-9")
//    }
//
//    public func testListFilterGroupUsingOrRelation(_ db: Database) async throws
//    {
//        let models: [Blog.Tag.Model] = (1...50).map { .mock($0) }
//        try await Blog.Tag.Query.insert(models, on: db)
//
//        let list1 = try await Blog.Tag.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 0
//                ),
//                orders: [
//                    .init(
//                        column: .name,
//                        direction: .asc
//                    )
//                ],
//                filter: .init(
//                    relation: .and,
//                    groups: [
//                        .init(
//                            relation: .or,
//                            columns: [
//                                .init(
//                                    column: .name,
//                                    operator: .in,
//                                    value: ["name-1", "name-2"]
//                                ),
//                                .init(
//                                    column: .notes,
//                                    operator: .equal,
//                                    value: "notes-3"
//                                ),
//                            ]
//                        )
//                    ]
//                )
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(list1.total, 3)
//        XCTAssertEqual(list1.items.count, 3)
//        XCTAssertEqual(list1.items[0].name, "name-1")
//        XCTAssertEqual(list1.items[1].name, "name-2")
//        XCTAssertEqual(list1.items[2].name, "name-3")
//    }
//
//    public func testListFilterGroupRelation(_ db: Database) async throws {
//        let models: [Blog.Tag.Model] = (1...50).map { .mock($0) }
//        try await Blog.Tag.Query.insert(models, on: db)
//
//        let list1 = try await Blog.Tag.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 0
//                ),
//                orders: [
//                    .init(
//                        column: .name,
//                        direction: .asc
//                    )
//                ],
//                filter: .init(
//                    relation: .and,
//                    groups: [
//                        .init(
//                            relation: .and,
//                            columns: [
//                                .init(
//                                    column: .name,
//                                    operator: .like,
//                                    value: "name-1%"
//                                )
//                            ]
//                        ),
//                        .init(
//                            relation: .or,
//                            columns: [
//                                .init(
//                                    column: .name,
//                                    operator: .in,
//                                    value: ["name-11", "name-12"]
//                                ),
//                                .init(
//                                    column: .notes,
//                                    operator: .equal,
//                                    value: "notes-13"
//                                ),
//                            ]
//                        ),
//                    ]
//                )
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(list1.total, 3)
//        XCTAssertEqual(list1.items.count, 3)
//        XCTAssertEqual(list1.items[0].name, "name-11")
//        XCTAssertEqual(list1.items[1].name, "name-12")
//        XCTAssertEqual(list1.items[2].name, "name-13")
//    }
//
//    public func testListOrder(_ db: Database) async throws {
//
//        try await Blog.Tag.Query.insert(
//            [
//                .init(
//                    id: .init(
//                        rawValue: "id-1"
//                    ),
//                    name: "name-1",
//                    notes: "notes-1"
//                ),
//                .init(
//                    id: .init(
//                        rawValue: "id-2"
//                    ),
//                    name: "name-1",
//                    notes: "notes-2"
//                ),
//                .init(
//                    id: .init(
//                        rawValue: "id-3"
//                    ),
//                    name: "name-2",
//                    notes: "notes-1"
//                ),
//                .init(
//                    id: .init(
//                        rawValue: "id-4"
//                    ),
//                    name: "name-2",
//                    notes: "notes-2"
//                ),
//            ],
//            on: db
//        )
//
//        let list1 = try await Blog.Tag.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 0
//                ),
//                orders: [
//                    .init(
//                        column: .name,
//                        direction: .desc
//                    ),
//                    .init(
//                        column: .notes,
//                        direction: .asc
//                    ),
//                ]
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(list1.total, 4)
//        XCTAssertEqual(list1.items.count, 4)
//
//        XCTAssertEqual(list1.items[0].name, "name-2")
//        XCTAssertEqual(list1.items[0].notes, "notes-1")
//
//        XCTAssertEqual(list1.items[1].name, "name-2")
//        XCTAssertEqual(list1.items[1].notes, "notes-2")
//
//        XCTAssertEqual(list1.items[2].name, "name-1")
//        XCTAssertEqual(list1.items[2].notes, "notes-1")
//
//        XCTAssertEqual(list1.items[3].name, "name-1")
//        XCTAssertEqual(list1.items[3].notes, "notes-2")
//
//    }
//
//    public func testList(_ db: Database) async throws {
//
//        let models: [Blog.Tag.Model] = (1...50).map { .mock($0) }
//        try await Blog.Tag.Query.insert(models, on: db)
//
//        let list1 = try await Blog.Tag.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 0
//                ),
//                orders: [
//                    .init(
//                        column: .name,
//                        direction: .desc
//                    )
//                ],
//                filter: .init(
//                    relation: .and,
//                    groups: [
//                        .init(
//                            relation: .and,
//                            columns: [
//                                .init(
//                                    column: .name,
//                                    operator: .like,
//                                    value: "%name-1%"
//                                ),
//                                .init(
//                                    column: .notes,
//                                    operator: .like,
//                                    value: "%notes-1%"
//                                ),
//                            ]
//                        )
//                    ]
//                )
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(list1.total, 11)
//        XCTAssertEqual(list1.items.count, 5)
//        XCTAssertEqual(list1.items[0].name, "name-19")
//        XCTAssertEqual(list1.items[1].name, "name-18")
//        XCTAssertEqual(list1.items[2].name, "name-17")
//        XCTAssertEqual(list1.items[3].name, "name-16")
//        XCTAssertEqual(list1.items[4].name, "name-15")
//
//        let list2 = try await Blog.Tag.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 1
//                ),
//                orders: [
//                    .init(
//                        column: .name,
//                        direction: .desc
//                    )
//                ],
//                filter: .init(
//                    relation: .and,
//                    groups: [
//                        .init(
//                            relation: .and,
//                            columns: [
//                                .init(
//                                    column: .name,
//                                    operator: .like,
//                                    value: "%name-1%"
//                                ),
//                                .init(
//                                    column: .notes,
//                                    operator: .like,
//                                    value: "%notes-1%"
//                                ),
//                            ]
//                        )
//                    ]
//                )
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(list2.total, 11)
//        XCTAssertEqual(list2.items.count, 5)
//        XCTAssertEqual(list2.items[0].name, "name-14")
//        XCTAssertEqual(list2.items[1].name, "name-13")
//        XCTAssertEqual(list2.items[2].name, "name-12")
//        XCTAssertEqual(list2.items[3].name, "name-11")
//        XCTAssertEqual(list2.items[4].name, "name-10")
//
//        let list3 = try await Blog.Tag.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 2
//                ),
//                orders: [
//                    .init(
//                        column: .name,
//                        direction: .desc
//                    )
//                ],
//                filter: .init(
//                    relation: .and,
//                    groups: [
//                        .init(
//                            relation: .and,
//                            columns: [
//                                .init(
//                                    column: .name,
//                                    operator: .like,
//                                    value: "%name-1%"
//                                ),
//                                .init(
//                                    column: .notes,
//                                    operator: .like,
//                                    value: "%notes-1%"
//                                ),
//                            ]
//                        )
//                    ]
//                )
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(list3.total, 11)
//        XCTAssertEqual(list3.items.count, 1)
//        XCTAssertEqual(list3.items[0].name, "name-1")
//    }
//
//    public func testListWithoutPaging(_ db: Database) async throws {
//
//        let models: [Blog.Tag.Model] = (1...50).map { .mock($0) }
//        try await Blog.Tag.Query.insert(models, on: db)
//
//        let list1 = try await Blog.Tag.Query.list(
//            .init(
//                orders: [
//                    .init(
//                        column: .name,
//                        direction: .desc
//                    )
//                ]
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(list1.total, 50)
//        XCTAssertEqual(list1.items.count, 50)
//    }
//
//    public func testJoinTag(_ db: Database) async throws {
//
//        let posts: [Blog.Post.Model] = (0...20).map { .mock($0) }
//        let tags: [Blog.Tag.Model] = (0...20).map { .mock($0) }
//        let postsTags: [Blog.PostTag.Model] = (0...20)
//            .map {
//                .init(postId: posts[$0].id, tagId: tags[$0].id)
//            }
//
//        try await Blog.Post.Query.insert(posts, on: db)
//        try await Blog.Tag.Query.insert(tags, on: db)
//        try await Blog.PostTag.Query.insert(postsTags, on: db)
//
//        for (index, element) in posts.enumerated() {
//            let res = try await Blog.PostTag.Query.join(
//                Blog.Tag.Model.self,
//                join: .init(
//                    column: .id,
//                    with: .tagId,
//                    filter: .init(
//                        column: .postId,
//                        operator: .equal,
//                        value: element.id
//                    )
//                ),
//                orders: [
//                    .init(
//                        column: .name,
//                        direction: .asc
//                    )
//                ],
//                filter: .init(
//                    column: .name,
//                    operator: .equal,
//                    value: "name-\(index)"
//                ),
//                on: db
//            )
//
//            XCTAssertEqual(res.count, 1)
//            XCTAssertEqual(res[0].name, "name-\(index)")
//        }
//    }
//
//    public func testJoinPost(_ db: Database) async throws {
//
//        let posts: [Blog.Post.Model] = (0...20).map { .mock($0) }
//        let tags: [Blog.Tag.Model] = (0...20).map { .mock($0) }
//        let postsTags: [Blog.PostTag.Model] = (0...20)
//            .map {
//                .init(postId: posts[$0].id, tagId: tags[$0].id)
//            }
//
//        try await Blog.Post.Query.insert(posts, on: db)
//        try await Blog.Tag.Query.insert(tags, on: db)
//        try await Blog.PostTag.Query.insert(postsTags, on: db)
//
//        for (index, element) in tags.enumerated() {
//            let res = try await Blog.PostTag.Query.join(
//                Blog.Post.Model.self,
//                join: .init(
//                    column: .id,
//                    with: .postId,
//                    method: .inner,
//                    op: .equal,
//                    filter: .init(
//                        column: .tagId,
//                        operator: .equal,
//                        value: element.id
//                    )
//                ),
//                orders: [
//                    .init(
//                        column: .title,
//                        direction: .asc
//                    )
//                ],
//                filter: .init(
//                    column: .title,
//                    operator: .equal,
//                    value: "title-\(index)"
//                ),
//                on: db
//            )
//
//            XCTAssertEqual(res.count, 1)
//            XCTAssertEqual(res[0].title, "title-\(index)")
//            XCTAssertEqual(res[0].published, index % 2 == 0)
//        }
//    }
