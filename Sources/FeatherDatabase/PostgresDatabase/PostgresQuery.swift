import PostgresNIO

extension PostgresQuery: DatabaseQuery {
    public typealias Bindings = PostgresBindings

    public var bindings: PostgresBindings { binds }
}
