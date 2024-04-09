import FeatherComponent
import FeatherDatabase
import XCTest

extension Test.Model {

    static func mock(_ i: Int = 1) -> Test.Model {
        Test.Model(
            id: .init(rawValue: "id-\(i)"),
            title: "title-\(i)",
            notes: "notes-\(i)"
        )
    }
}

final class QueryTests: TestCase {

    func testInsert() async throws {
        let test = Test.Model.mock()
        let db = try await components.database().connection()
        
        let testQueryBuilder = Test.QueryBuilder(db: db)

        try await testQueryBuilder.insert(test)
    }

    func testCount() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        let models: [Test.Model] = (1...50)
            .map {
                .mock($0)
            }
        try await testQueryBuilder.insert(models)

        let count1 = try await testQueryBuilder.count()
        XCTAssertEqual(count1, 50)

        let count2 = try await testQueryBuilder.count(
            filter: .init(
                field: .title,
                operator: .like,
                value: ["title-1%"]
            )
        )
        XCTAssertEqual(count2, 11)
    }

    func testGet() async throws {

        let test = Test.Model.mock()
        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)
        try await testQueryBuilder.insert(test)

        let test1 = try await testQueryBuilder.get(
            Key<Test.Model>(rawValue: "id-1")
        )

        XCTAssertEqual(test1?.id.rawValue, "id-1")

    }

    func testFirst() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        let test1 = Test.Model.mock(1)
        try await testQueryBuilder.insert(test1)
        let test2 = Test.Model.mock(2)
        try await testQueryBuilder.insert(test2)

        let res1 = try await testQueryBuilder.first(
            filter: .init(
                field: .id,
                operator: .in,
                value: ["id-1", "id-2"]
            ),
            order: .init(
                field: .title,
                direction: .desc
            )
        )

        XCTAssertEqual(test2.id, res1?.id)

        let res2 = try await testQueryBuilder.first(
            filter: .init(
                field: .id,
                operator: .equal,
                value: ["id-2"]
            )
        )

        XCTAssertEqual(test2.id, res2?.id)
    }

    func testUpdate() async throws {

        let test = Test.Model.mock()
        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)
        try await testQueryBuilder.insert(test)

        try await testQueryBuilder.update(.init(rawValue: "id-1"), .mock(2))

        let test1 = try await testQueryBuilder.get(.init(rawValue: "id-2"))
        XCTAssertEqual(test1?.id.rawValue, "id-2")
        XCTAssertEqual(test1?.title, "title-2")
        XCTAssertEqual(test1?.notes, "notes-2")
    }

    func testDelete() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        let models: [Test.Model] = (1...6)
            .map {
                .mock($0)
            }
        try await testQueryBuilder.insert(models)

        let total = try await testQueryBuilder.count()
        XCTAssertEqual(total, 6)

        print(try await testQueryBuilder.all())

        try await testQueryBuilder.delete(.init(rawValue: "id-1"))

        try await testQueryBuilder.delete(
            filter: .init(
                field: .id,
                operator: .in,
                value: [
                    Key<Test>(rawValue: "id-2"),
                    Key<Test>(rawValue: "id-3"),
                ]
            )
        )

        try await testQueryBuilder.delete(
            filter: .init(
                field: .title,
                operator: .in,
                value: [
                    "title-4",
                    "title-5",
                ]
            )
        )

        let all = try await testQueryBuilder.all()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all[0].id.rawValue, "id-6")
    }

    func testAll() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        let models: [Test.Model] = (1...50)
            .map {
                .mock($0)
            }
        try await testQueryBuilder.insert(models)

        let res1 = try await testQueryBuilder.all()
        XCTAssertEqual(res1.count, 50)

        let res2 = try await testQueryBuilder.all(
            filter: .init(
                field: .title,
                operator: .in,
                value: ["title-1", "title-2"]
            )
        )
        XCTAssertEqual(res2.count, 2)

        let res3 = try await testQueryBuilder.all(
            filter: .init(
                field: .title,
                operator: .equal,
                value: "title-2"
            )
        )
        XCTAssertEqual(res3.count, 1)
    }

    func testAllWithOrder() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        let models: [Test.Model] = (1...50)
            .map {
                .mock($0)
            }
        try await testQueryBuilder.insert(models)

        let res1 = try await testQueryBuilder.all()
        XCTAssertEqual(res1.count, 50)

        let res2 = try await testQueryBuilder.all(
            orders: [
                .init(
                    field: .title,
                    direction: .desc
                )
            ]
        )
        XCTAssertEqual(res2[0].title, "title-9")
    }

    func testListFilterGroupUsingOrRelation() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        let models: [Test.Model] = (1...50)
            .map {
                .mock($0)
            }
        try await testQueryBuilder.insert(models)

        let list1 = try await testQueryBuilder.list(
            .init(
                page: .init(
                    size: 5,
                    index: 0
                ),
                orders: [
                    .init(
                        field: .title,
                        direction: .asc
                    )
                ],
                filter: .init(
                    relation: .and,
                    groups: [
                        .init(
                            relation: .or,
                            fields: [
                                .init(
                                    field: .title,
                                    operator: .in,
                                    value: ["title-1", "title-2"]
                                ),
                                .init(
                                    field: .notes,
                                    operator: .equal,
                                    value: "notes-3"
                                ),
                            ]
                        )
                    ]
                )
            )
        )

        XCTAssertEqual(list1.total, 3)
        XCTAssertEqual(list1.items.count, 3)
        XCTAssertEqual(list1.items[0].title, "title-1")
        XCTAssertEqual(list1.items[1].title, "title-2")
        XCTAssertEqual(list1.items[2].title, "title-3")
    }

    func testListFilterGroupRelation() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        let models: [Test.Model] = (1...50)
            .map {
                .mock($0)
            }
        try await testQueryBuilder.insert(models)

        let list1 = try await testQueryBuilder.list(
            .init(
                page: .init(
                    size: 5,
                    index: 0
                ),
                orders: [
                    .init(
                        field: .title,
                        direction: .asc
                    )
                ],
                filter: .init(
                    relation: .and,
                    groups: [
                        .init(
                            relation: .and,
                            fields: [
                                .init(
                                    field: .title,
                                    operator: .like,
                                    value: "title-1%"
                                )
                            ]
                        ),
                        .init(
                            relation: .or,
                            fields: [
                                .init(
                                    field: .title,
                                    operator: .in,
                                    value: ["title-11", "title-12"]
                                ),
                                .init(
                                    field: .notes,
                                    operator: .equal,
                                    value: "notes-13"
                                ),
                            ]
                        ),
                    ]
                )
            )
        )

        XCTAssertEqual(list1.total, 3)
        XCTAssertEqual(list1.items.count, 3)
        XCTAssertEqual(list1.items[0].title, "title-11")
        XCTAssertEqual(list1.items[1].title, "title-12")
        XCTAssertEqual(list1.items[2].title, "title-13")
    }

    func testListOrder() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        try await testQueryBuilder.insert(
            [
                .init(
                    id: .init(
                        rawValue: "id-1"
                    ),
                    title: "title-1",
                    notes: "notes-1"
                ),
                .init(
                    id: .init(
                        rawValue: "id-2"
                    ),
                    title: "title-1",
                    notes: "notes-2"
                ),
                .init(
                    id: .init(
                        rawValue: "id-3"
                    ),
                    title: "title-2",
                    notes: "notes-1"
                ),
                .init(
                    id: .init(
                        rawValue: "id-4"
                    ),
                    title: "title-2",
                    notes: "notes-2"
                ),
            ]
        )

        let list1 = try await testQueryBuilder.list(
            .init(
                page: .init(
                    size: 5,
                    index: 0
                ),
                orders: [
                    .init(
                        field: .title,
                        direction: .desc
                    ),
                    .init(
                        field: .notes,
                        direction: .asc
                    ),
                ]
            )
        )

        XCTAssertEqual(list1.total, 4)
        XCTAssertEqual(list1.items.count, 4)

        XCTAssertEqual(list1.items[0].title, "title-2")
        XCTAssertEqual(list1.items[0].notes, "notes-1")

        XCTAssertEqual(list1.items[1].title, "title-2")
        XCTAssertEqual(list1.items[1].notes, "notes-2")

        XCTAssertEqual(list1.items[2].title, "title-1")
        XCTAssertEqual(list1.items[2].notes, "notes-1")

        XCTAssertEqual(list1.items[3].title, "title-1")
        XCTAssertEqual(list1.items[3].notes, "notes-2")

    }

    func testList() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        let models: [Test.Model] = (1...50)
            .map {
                .mock($0)
            }
        try await testQueryBuilder.insert(models)

        let list1 = try await testQueryBuilder.list(
            .init(
                page: .init(
                    size: 5,
                    index: 0
                ),
                orders: [
                    .init(
                        field: .title,
                        direction: .desc
                    )
                ],
                filter: .init(
                    relation: .and,
                    groups: [
                        .init(
                            relation: .and,
                            fields: [
                                .init(
                                    field: .title,
                                    operator: .like,
                                    value: "%title-1%"
                                ),
                                .init(
                                    field: .notes,
                                    operator: .like,
                                    value: "%notes-1%"
                                ),
                            ]
                        )
                    ]
                )
            )
        )

        XCTAssertEqual(list1.total, 11)
        XCTAssertEqual(list1.items.count, 5)
        XCTAssertEqual(list1.items[0].title, "title-19")
        XCTAssertEqual(list1.items[1].title, "title-18")
        XCTAssertEqual(list1.items[2].title, "title-17")
        XCTAssertEqual(list1.items[3].title, "title-16")
        XCTAssertEqual(list1.items[4].title, "title-15")

        let list2 = try await testQueryBuilder.list(
            .init(
                page: .init(
                    size: 5,
                    index: 1
                ),
                orders: [
                    .init(
                        field: .title,
                        direction: .desc
                    )
                ],
                filter: .init(
                    relation: .and,
                    groups: [
                        .init(
                            relation: .and,
                            fields: [
                                .init(
                                    field: .title,
                                    operator: .like,
                                    value: "%title-1%"
                                ),
                                .init(
                                    field: .notes,
                                    operator: .like,
                                    value: "%notes-1%"
                                ),
                            ]
                        )
                    ]
                )
            )
        )

        XCTAssertEqual(list2.total, 11)
        XCTAssertEqual(list2.items.count, 5)
        XCTAssertEqual(list2.items[0].title, "title-14")
        XCTAssertEqual(list2.items[1].title, "title-13")
        XCTAssertEqual(list2.items[2].title, "title-12")
        XCTAssertEqual(list2.items[3].title, "title-11")
        XCTAssertEqual(list2.items[4].title, "title-10")

        let list3 = try await testQueryBuilder.list(
            .init(
                page: .init(
                    size: 5,
                    index: 2
                ),
                orders: [
                    .init(
                        field: .title,
                        direction: .desc
                    )
                ],
                filter: .init(
                    relation: .and,
                    groups: [
                        .init(
                            relation: .and,
                            fields: [
                                .init(
                                    field: .title,
                                    operator: .like,
                                    value: "%title-1%"
                                ),
                                .init(
                                    field: .notes,
                                    operator: .like,
                                    value: "%notes-1%"
                                ),
                            ]
                        )
                    ]
                )
            )
        )

        XCTAssertEqual(list3.total, 11)
        XCTAssertEqual(list3.items.count, 1)
        XCTAssertEqual(list3.items[0].title, "title-1")
    }

    func testListWithoutPaging() async throws {

        let db = try await components.database().connection()
        let testQueryBuilder = Test.QueryBuilder(db: db)

        let models: [Test.Model] = (1...50)
            .map {
                .mock($0)
            }
        try await testQueryBuilder.insert(models)

        let list1 = try await testQueryBuilder.list(
            .init(
                orders: [
                    .init(
                        field: .title,
                        direction: .desc
                    )
                ]
            )
        )

        XCTAssertEqual(list1.total, 50)
        XCTAssertEqual(list1.items.count, 50)
    }

}
