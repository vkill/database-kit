/// Represents an application's configured databases (zero or more).
public struct Databases: ServiceType {
    /// See `ServiceType`.
    public static func makeService(for container: Container) throws -> Databases {
        return try container.make(DatabasesConfig.self).resolve(on: container)
    }

    /// Private storage: `[DatabaseIdentifier: Database]`
    private let storage: [String: Any]

    /// Private storage: `[DatabaseIdentifier: ConnectionConfig]`
    private let connectionConfig: [String: Any]

    /// Private storage: `[DatabaseIdentifier: Int]`
    private let poolSizeConfig: [String: Int]

    /// Private init: creates a new `Databases` struct.
    internal init(storage: [String: Any], connectionConfig: [String: Any], poolSizeConfig: [String: Int]) {
        self.storage = storage
        self.connectionConfig = connectionConfig
        self.poolSizeConfig = poolSizeConfig
    }

    /// Fetches the `Database` for a given `DatabaseIdentifier`.
    ///
    ///     let psql = try databases.requireDatabase(for: .psql)
    ///
    /// - parameters:
    ///     - id: `DatabaseIdentifier` of the `Database` to fetch.
    /// - throws: Throws an error if no `Database` with that id was found.
    /// - returns: `Database` identified by the supplied ID.
    public func requireDatabase<D>(for dbid: DatabaseIdentifier<D>) throws -> ConfiguredDatabase<D> {
        guard let db = database(for: dbid) else {
            throw DatabaseKitError(identifier: "dbRequired", reason: "No database with id '\(dbid.uid)' is configured.")
        }
        return db
    }

    /// Fetches the `Database` for a given `DatabaseIdentifier`.
    ///
    ///     let psql = databases.database(for: .psql)
    ///
    /// - parameters:
    ///     - id: `DatabaseIdentifier` of the `Database` to fetch.
    /// - returns: `Database` identified by the supplied ID, if one could be found.
    public func database<D>(for dbid: DatabaseIdentifier<D>) -> ConfiguredDatabase<D>? {
        guard let db = storage[dbid.uid] as? D else {
            return nil
        }
        let config = connectionConfig[dbid.uid] as? ConnectionConfig<D> ?? .init()
        return ConfiguredDatabase(config: config, base: db)
    }

    /// Fetches the `poolSize` for a given `DatabaseIdentifier`.
    ///
    ///     let poolSize = databases.poolSize(for: .psql)
    ///
    /// - parameters:
    ///     - id: `DatabaseIdentifier` of the `Database` to fetch.
    /// - returns: poolSize by the supplied ID, if one could be found.
    public func poolSize<D>(for dbid: DatabaseIdentifier<D>) -> Int? {
        guard let size = poolSizeConfig[dbid.uid] else {
            return nil
        }
        return size
    }

}
