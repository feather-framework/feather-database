import FeatherComponent
import FeatherDatabase
import FeatherDatabaseTesting
import NanoID
import XCTest

//final class QueryTests: TestCase {


//
//
//    func testFirst() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        let test1 = Test.Model.mock(1)
//        try await Test.Query.insert(test1, on: db)
//        let test2 = Test.Model.mock(2)
//        try await Test.Query.insert(test2, on: db)
//
//        let res1 = try await Test.Query.first(
//            filter: .init(
//                column: .id,
//                operator: .in,
//                value: ["id-1", "id-2"]
//            ),
//            order: .init(
//                column: .title,
//                direction: .desc
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(test2.id, res1?.id)
//
//        let res2 = try await Test.Query.first(
//            filter: .init(
//                column: .id,
//                operator: .equal,
//                value: ["id-2"]
//            ),
//            on: db
//        )
//
//        XCTAssertEqual(test2.id, res2?.id)
//    }
//
//    func testUpdate() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        let test = Test.Model.mock()
//        try await Test.Query.insert(test, on: db)
//
//        try await Test.Query.update(.init(rawValue: "id-1"), .mock(2), on: db)
//
//        let test1 = try await Test.Query.get(.init(rawValue: "id-2"), on: db)
//        XCTAssertEqual(test1?.id.rawValue, "id-2")
//        XCTAssertEqual(test1?.title, "title-2")
//        XCTAssertEqual(test1?.notes, "notes-2")
//    }
//
//    func testDelete() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        let models: [Test.Model] = (1...6)
//            .map {
//                .mock($0)
//            }
//        try await Test.Query.insert(models, on: db)
//
//        let total = try await Test.Query.count(on: db)
//        XCTAssertEqual(total, 6)
//
//        print(try await Test.Query.all(on: db))
//
//        try await Test.Query.delete(.init(rawValue: "id-1"), on: db)
//
//        try await Test.Query.delete(
//            filter: .init(
//                column: .id,
//                operator: .in,
//                value: [
//                    Key<Test>(rawValue: "id-2"),
//                    Key<Test>(rawValue: "id-3"),
//                ]
//            ),
//            on: db
//        )
//
//        try await Test.Query.delete(
//            filter: .init(
//                column: .title,
//                operator: .in,
//                value: [
//                    "title-4",
//                    "title-5",
//                ]
//            ),
//            on: db
//        )
//
//        let all = try await Test.Query.all(on: db)
//        XCTAssertEqual(all.count, 1)
//        XCTAssertEqual(all[0].id.rawValue, "id-6")
//    }
//
//    func testAll() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        let models: [Test.Model] = (1...50)
//            .map {
//                .mock($0)
//            }
//        try await Test.Query.insert(models, on: db)
//
//        let res1 = try await Test.Query.all(on: db)
//        XCTAssertEqual(res1.count, 50)
//
//        let res2 = try await Test.Query.all(
//            filter: .init(
//                column: .title,
//                operator: .in,
//                value: ["title-1", "title-2"]
//            ),
//            on: db
//        )
//        XCTAssertEqual(res2.count, 2)
//
//        let res3 = try await Test.Query.all(
//            filter: .init(
//                column: .title,
//                operator: .equal,
//                value: "title-2"
//            ),
//            on: db
//        )
//        XCTAssertEqual(res3.count, 1)
//    }
//
//    func testAllWithOrder() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        let models: [Test.Model] = (1...50)
//            .map {
//                .mock($0)
//            }
//        try await Test.Query.insert(models, on: db)
//
//        let res1 = try await Test.Query.all(on: db)
//        XCTAssertEqual(res1.count, 50)
//
//        let res2 = try await Test.Query.all(
//            orders: [
//                .init(
//                    column: .title,
//                    direction: .desc
//                )
//            ],
//            on: db
//        )
//        XCTAssertEqual(res2[0].title, "title-9")
//    }
//
//    func testListFilterGroupUsingOrRelation() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        let models: [Test.Model] = (1...50)
//            .map {
//                .mock($0)
//            }
//        try await Test.Query.insert(models, on: db)
//
//        let list1 = try await Test.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 0
//                ),
//                orders: [
//                    .init(
//                        column: .title,
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
//                                    column: .title,
//                                    operator: .in,
//                                    value: ["title-1", "title-2"]
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
//        XCTAssertEqual(list1.items[0].title, "title-1")
//        XCTAssertEqual(list1.items[1].title, "title-2")
//        XCTAssertEqual(list1.items[2].title, "title-3")
//    }
//
//    func testListFilterGroupRelation() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        let models: [Test.Model] = (1...50)
//            .map {
//                .mock($0)
//            }
//        try await Test.Query.insert(models, on: db)
//
//        let list1 = try await Test.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 0
//                ),
//                orders: [
//                    .init(
//                        column: .title,
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
//                                    column: .title,
//                                    operator: .like,
//                                    value: "title-1%"
//                                )
//                            ]
//                        ),
//                        .init(
//                            relation: .or,
//                            columns: [
//                                .init(
//                                    column: .title,
//                                    operator: .in,
//                                    value: ["title-11", "title-12"]
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
//        XCTAssertEqual(list1.items[0].title, "title-11")
//        XCTAssertEqual(list1.items[1].title, "title-12")
//        XCTAssertEqual(list1.items[2].title, "title-13")
//    }
//
//    func testListOrder() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        try await Test.Query.insert(
//            [
//                .init(
//                    id: .init(
//                        rawValue: "id-1"
//                    ),
//                    title: "title-1",
//                    notes: "notes-1"
//                ),
//                .init(
//                    id: .init(
//                        rawValue: "id-2"
//                    ),
//                    title: "title-1",
//                    notes: "notes-2"
//                ),
//                .init(
//                    id: .init(
//                        rawValue: "id-3"
//                    ),
//                    title: "title-2",
//                    notes: "notes-1"
//                ),
//                .init(
//                    id: .init(
//                        rawValue: "id-4"
//                    ),
//                    title: "title-2",
//                    notes: "notes-2"
//                ),
//            ],
//            on: db
//        )
//
//        let list1 = try await Test.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 0
//                ),
//                orders: [
//                    .init(
//                        column: .title,
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
//        XCTAssertEqual(list1.items[0].title, "title-2")
//        XCTAssertEqual(list1.items[0].notes, "notes-1")
//
//        XCTAssertEqual(list1.items[1].title, "title-2")
//        XCTAssertEqual(list1.items[1].notes, "notes-2")
//
//        XCTAssertEqual(list1.items[2].title, "title-1")
//        XCTAssertEqual(list1.items[2].notes, "notes-1")
//
//        XCTAssertEqual(list1.items[3].title, "title-1")
//        XCTAssertEqual(list1.items[3].notes, "notes-2")
//
//    }
//
//    func testList() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        let models: [Test.Model] = (1...50)
//            .map {
//                .mock($0)
//            }
//        try await Test.Query.insert(models, on: db)
//
//        let list1 = try await Test.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 0
//                ),
//                orders: [
//                    .init(
//                        column: .title,
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
//                                    column: .title,
//                                    operator: .like,
//                                    value: "%title-1%"
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
//        XCTAssertEqual(list1.items[0].title, "title-19")
//        XCTAssertEqual(list1.items[1].title, "title-18")
//        XCTAssertEqual(list1.items[2].title, "title-17")
//        XCTAssertEqual(list1.items[3].title, "title-16")
//        XCTAssertEqual(list1.items[4].title, "title-15")
//
//        let list2 = try await Test.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 1
//                ),
//                orders: [
//                    .init(
//                        column: .title,
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
//                                    column: .title,
//                                    operator: .like,
//                                    value: "%title-1%"
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
//        XCTAssertEqual(list2.items[0].title, "title-14")
//        XCTAssertEqual(list2.items[1].title, "title-13")
//        XCTAssertEqual(list2.items[2].title, "title-12")
//        XCTAssertEqual(list2.items[3].title, "title-11")
//        XCTAssertEqual(list2.items[4].title, "title-10")
//
//        let list3 = try await Test.Query.list(
//            .init(
//                page: .init(
//                    size: 5,
//                    index: 2
//                ),
//                orders: [
//                    .init(
//                        column: .title,
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
//                                    column: .title,
//                                    operator: .like,
//                                    value: "%title-1%"
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
//        XCTAssertEqual(list3.items[0].title, "title-1")
//    }
//
//    func testListWithoutPaging() async throws {
//        let db = try await components.database().connection()
//        try await Test.Table.create(on: db)
//
//        let models: [Test.Model] = (1...50)
//            .map {
//                .mock($0)
//            }
//        try await Test.Query.insert(models, on: db)
//
//        let list1 = try await Test.Query.list(
//            .init(
//                orders: [
//                    .init(
//                        column: .title,
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
//    func testJoin() async throws {
//        let db = try await components.database().connection()
//
//        let posts: [Blog.Post.Model] = (0...20).map { .mock($0) }
//        let tags: [Blog.Tag.Model] = (0...20).map { .mock($0) }
//        let postsTags: [Blog.PostTag.Model] = (0...20)
//            .map {
//                .init(postId: posts[$0].id, tagId: tags[$0].id)
//            }
//
//        try await Blog.Post.Table.create(on: db)
//        try await Blog.Tag.Table.create(on: db)
//        try await Blog.PostTag.Table.create(on: db)
//
//        try await Blog.Post.Query.insert(posts, on: db)
//        try await Blog.Tag.Query.insert(tags, on: db)
//        try await Blog.PostTag.Query.insert(postsTags, on: db)
//
//        for (index, element) in posts.enumerated() {
//            let res = try await Blog.PostTag.Query.join(
//                Blog.Tag.Model.self,
//                join: (
//                    .id,
//                    .tagId
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
//                filterJoin: .init(
//                    column: .postId,
//                    operator: .equal,
//                    value: element.id
//                ),
//                on: db
//            )
//
//            XCTAssertEqual(res.count, 1)
//            XCTAssertEqual(res[0].name, "name-\(index)")
//        }
//    }
//
//}
