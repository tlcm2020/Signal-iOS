//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDB
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Record

public struct DeviceRecord: SDSRecord {
    public var tableMetadata: SDSTableMetadata {
        return OWSDeviceSerializer.table
    }

    public static let databaseTableName: String = OWSDeviceSerializer.table.tableName

    public var id: Int64?

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    public let recordType: SDSRecordType
    public let uniqueId: String

    // Base class properties
    public let createdAt: Date
    public let deviceId: Int
    public let lastSeenAt: Date
    public let name: String?

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case createdAt
        case deviceId
        case lastSeenAt
        case name
    }

    public static func columnName(_ column: DeviceRecord.CodingKeys, fullyQualified: Bool = false) -> String {
        return fullyQualified ? "\(databaseTableName).\(column.rawValue)" : column.rawValue
    }
}

// MARK: - Row Initializer

public extension DeviceRecord {
    static var databaseSelection: [SQLSelectable] {
        return CodingKeys.allCases
    }

    init(row: Row) {
        id = row[0]
        recordType = row[1]
        uniqueId = row[2]
        createdAt = row[3]
        deviceId = row[4]
        lastSeenAt = row[5]
        name = row[6]
    }
}

// MARK: - StringInterpolation

public extension String.StringInterpolation {
    mutating func appendInterpolation(deviceColumn column: DeviceRecord.CodingKeys) {
        appendLiteral(DeviceRecord.columnName(column))
    }
    mutating func appendInterpolation(deviceColumnFullyQualified column: DeviceRecord.CodingKeys) {
        appendLiteral(DeviceRecord.columnName(column, fullyQualified: true))
    }
}

// MARK: - Deserialization

// TODO: Rework metadata to not include, for example, columns, column indices.
extension OWSDevice {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func fromRecord(_ record: DeviceRecord) throws -> OWSDevice {

        guard let recordId = record.id else {
            throw SDSError.invalidValue
        }

        switch record.recordType {
        case .device:

            let uniqueId: String = record.uniqueId
            let createdAt: Date = record.createdAt
            let deviceId: Int = record.deviceId
            let lastSeenAt: Date = record.lastSeenAt
            let name: String? = record.name

            return OWSDevice(uniqueId: uniqueId,
                             createdAt: createdAt,
                             deviceId: deviceId,
                             lastSeenAt: lastSeenAt,
                             name: name)

        default:
            owsFailDebug("Unexpected record type: \(record.recordType)")
            throw SDSError.invalidValue
        }
    }
}

// MARK: - SDSModel

extension OWSDevice: SDSModel {
    public var serializer: SDSSerializer {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        default:
            return OWSDeviceSerializer(model: self)
        }
    }

    public func asRecord() throws -> SDSRecord {
        return try serializer.asRecord()
    }

    public var sdsTableName: String {
        return DeviceRecord.databaseTableName
    }

    public static var table: SDSTableMetadata {
        return OWSDeviceSerializer.table
    }
}

// MARK: - Table Metadata

extension OWSDeviceSerializer {

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    static let idColumn = SDSColumnMetadata(columnName: "id", columnType: .primaryKey, columnIndex: 0)
    static let recordTypeColumn = SDSColumnMetadata(columnName: "recordType", columnType: .int64, columnIndex: 1)
    static let uniqueIdColumn = SDSColumnMetadata(columnName: "uniqueId", columnType: .unicodeString, columnIndex: 2)
    // Base class properties
    static let createdAtColumn = SDSColumnMetadata(columnName: "createdAt", columnType: .int64, columnIndex: 3)
    static let deviceIdColumn = SDSColumnMetadata(columnName: "deviceId", columnType: .int64, columnIndex: 4)
    static let lastSeenAtColumn = SDSColumnMetadata(columnName: "lastSeenAt", columnType: .int64, columnIndex: 5)
    static let nameColumn = SDSColumnMetadata(columnName: "name", columnType: .unicodeString, isOptional: true, columnIndex: 6)

    // TODO: We should decide on a naming convention for
    //       tables that store models.
    public static let table = SDSTableMetadata(collection: OWSDevice.collection(),
                                               tableName: "model_OWSDevice",
                                               columns: [
        idColumn,
        recordTypeColumn,
        uniqueIdColumn,
        createdAtColumn,
        deviceIdColumn,
        lastSeenAtColumn,
        nameColumn
        ])
}

// MARK: - Save/Remove/Update

@objc
public extension OWSDevice {
    func anyInsert(transaction: SDSAnyWriteTransaction) {
        sdsSave(saveMode: .insert, transaction: transaction)
    }

    // This method is private; we should never use it directly.
    // Instead, use anyUpdate(transaction:block:), so that we
    // use the "update with" pattern.
    private func anyUpdate(transaction: SDSAnyWriteTransaction) {
        sdsSave(saveMode: .update, transaction: transaction)
    }

    @available(*, deprecated, message: "Use anyInsert() or anyUpdate() instead.")
    func anyUpsert(transaction: SDSAnyWriteTransaction) {
        let isInserting: Bool
        if OWSDevice.anyFetch(uniqueId: uniqueId, transaction: transaction) != nil {
            isInserting = false
        } else {
            isInserting = true
        }
        sdsSave(saveMode: isInserting ? .insert : .update, transaction: transaction)
    }

    // This method is used by "updateWith..." methods.
    //
    // This model may be updated from many threads. We don't want to save
    // our local copy (this instance) since it may be out of date.  We also
    // want to avoid re-saving a model that has been deleted.  Therefore, we
    // use "updateWith..." methods to:
    //
    // a) Update a property of this instance.
    // b) If a copy of this model exists in the database, load an up-to-date copy,
    //    and update and save that copy.
    // b) If a copy of this model _DOES NOT_ exist in the database, do _NOT_ save
    //    this local instance.
    //
    // After "updateWith...":
    //
    // a) Any copy of this model in the database will have been updated.
    // b) The local property on this instance will always have been updated.
    // c) Other properties on this instance may be out of date.
    //
    // All mutable properties of this class have been made read-only to
    // prevent accidentally modifying them directly.
    //
    // This isn't a perfect arrangement, but in practice this will prevent
    // data loss and will resolve all known issues.
    func anyUpdate(transaction: SDSAnyWriteTransaction, block: (OWSDevice) -> Void) {

        block(self)

        guard let dbCopy = type(of: self).anyFetch(uniqueId: uniqueId,
                                                   transaction: transaction) else {
            return
        }

        // Don't apply the block twice to the same instance.
        // It's at least unnecessary and actually wrong for some blocks.
        // e.g. `block: { $0 in $0.someField++ }`
        if dbCopy !== self {
            block(dbCopy)
        }

        dbCopy.anyUpdate(transaction: transaction)
    }

    func anyRemove(transaction: SDSAnyWriteTransaction) {
        sdsRemove(transaction: transaction)
    }

    func anyReload(transaction: SDSAnyReadTransaction) {
        anyReload(transaction: transaction, ignoreMissing: false)
    }

    func anyReload(transaction: SDSAnyReadTransaction, ignoreMissing: Bool) {
        guard let latestVersion = type(of: self).anyFetch(uniqueId: uniqueId, transaction: transaction) else {
            if !ignoreMissing {
                owsFailDebug("`latest` was unexpectedly nil")
            }
            return
        }

        setValuesForKeys(latestVersion.dictionaryValue)
    }
}

// MARK: - OWSDeviceCursor

@objc
public class OWSDeviceCursor: NSObject {
    private let cursor: RecordCursor<DeviceRecord>?

    init(cursor: RecordCursor<DeviceRecord>?) {
        self.cursor = cursor
    }

    public func next() throws -> OWSDevice? {
        guard let cursor = cursor else {
            return nil
        }
        guard let record = try cursor.next() else {
            return nil
        }
        return try OWSDevice.fromRecord(record)
    }

    public func all() throws -> [OWSDevice] {
        var result = [OWSDevice]()
        while true {
            guard let model = try next() else {
                break
            }
            result.append(model)
        }
        return result
    }
}

// MARK: - Obj-C Fetch

// TODO: We may eventually want to define some combination of:
//
// * fetchCursor, fetchOne, fetchAll, etc. (ala GRDB)
// * Optional "where clause" parameters for filtering.
// * Async flavors with completions.
//
// TODO: I've defined flavors that take a read transaction.
//       Or we might take a "connection" if we end up having that class.
@objc
public extension OWSDevice {
    class func grdbFetchCursor(transaction: GRDBReadTransaction) -> OWSDeviceCursor {
        let database = transaction.database
        do {
            let cursor = try DeviceRecord.fetchCursor(database)
            return OWSDeviceCursor(cursor: cursor)
        } catch {
            owsFailDebug("Read failed: \(error)")
            return OWSDeviceCursor(cursor: nil)
        }
    }

    // Fetches a single model by "unique id".
    class func anyFetch(uniqueId: String,
                        transaction: SDSAnyReadTransaction) -> OWSDevice? {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return OWSDevice.ydb_fetch(uniqueId: uniqueId, transaction: ydbTransaction)
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT * FROM \(DeviceRecord.databaseTableName) WHERE \(deviceColumn: .uniqueId) = ?"
            return grdbFetchOne(sql: sql, arguments: [uniqueId], transaction: grdbTransaction)
        }
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    class func anyEnumerate(transaction: SDSAnyReadTransaction,
                            batched: Bool = false,
                            block: @escaping (OWSDevice, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let batchSize = batched ? Batching.kDefaultBatchSize : 0
        anyEnumerate(transaction: transaction, batchSize: batchSize, block: block)
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    //
    // If batchSize > 0, the enumeration is performed in autoreleased batches.
    class func anyEnumerate(transaction: SDSAnyReadTransaction,
                            batchSize: UInt,
                            block: @escaping (OWSDevice, UnsafeMutablePointer<ObjCBool>) -> Void) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            OWSDevice.ydb_enumerateCollectionObjects(with: ydbTransaction) { (object, stop) in
                guard let value = object as? OWSDevice else {
                    owsFailDebug("unexpected object: \(type(of: object))")
                    return
                }
                block(value, stop)
            }
        case .grdbRead(let grdbTransaction):
            do {
                let cursor = OWSDevice.grdbFetchCursor(transaction: grdbTransaction)
                var stop: ObjCBool = false
                try Batching.loop(batchSize: batchSize,
                                  conditionBlock: {
                                      return !stop.boolValue
                },
                                  loopBlock: {
                                      guard let value = try cursor.next() else {
                                          stop = true
                                          return
                                      }
                                      block(value, &stop)
                })
            } catch let error {
                owsFailDebug("Couldn't fetch models: \(error)")
            }
        }
    }

    // Traverses all records' unique ids.
    // Records are not visited in any particular order.
    class func anyEnumerateUniqueIds(transaction: SDSAnyReadTransaction,
                                     batched: Bool = false,
                                     block: @escaping (String, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let batchSize = batched ? Batching.kDefaultBatchSize : 0
        anyEnumerateUniqueIds(transaction: transaction, batchSize: batchSize, block: block)
    }

    // Traverses all records' unique ids.
    // Records are not visited in any particular order.
    //
    // If batchSize > 0, the enumeration is performed in autoreleased batches.
    class func anyEnumerateUniqueIds(transaction: SDSAnyReadTransaction,
                                     batchSize: UInt,
                                     block: @escaping (String, UnsafeMutablePointer<ObjCBool>) -> Void) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            ydbTransaction.enumerateKeys(inCollection: OWSDevice.collection()) { (uniqueId, stop) in
                block(uniqueId, stop)
            }
        case .grdbRead(let grdbTransaction):
            grdbEnumerateUniqueIds(transaction: grdbTransaction,
                                   sql: """
                    SELECT \(deviceColumn: .uniqueId)
                    FROM \(DeviceRecord.databaseTableName)
                """,
                batchSize: batchSize,
                block: block)
        }
    }

    // Does not order the results.
    class func anyFetchAll(transaction: SDSAnyReadTransaction) -> [OWSDevice] {
        var result = [OWSDevice]()
        anyEnumerate(transaction: transaction) { (model, _) in
            result.append(model)
        }
        return result
    }

    // Does not order the results.
    class func anyAllUniqueIds(transaction: SDSAnyReadTransaction) -> [String] {
        var result = [String]()
        anyEnumerateUniqueIds(transaction: transaction) { (uniqueId, _) in
            result.append(uniqueId)
        }
        return result
    }

    class func anyCount(transaction: SDSAnyReadTransaction) -> UInt {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return ydbTransaction.numberOfKeys(inCollection: OWSDevice.collection())
        case .grdbRead(let grdbTransaction):
            return DeviceRecord.ows_fetchCount(grdbTransaction.database)
        }
    }

    // WARNING: Do not use this method for any models which do cleanup
    //          in their anyWillRemove(), anyDidRemove() methods.
    class func anyRemoveAllWithoutInstantation(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            ydbTransaction.removeAllObjects(inCollection: OWSDevice.collection())
        case .grdbWrite(let grdbTransaction):
            do {
                try DeviceRecord.deleteAll(grdbTransaction.database)
            } catch {
                owsFailDebug("deleteAll() failed: \(error)")
            }
        }

        if shouldBeIndexedForFTS {
            FullTextSearchFinder.allModelsWereRemoved(collection: collection(), transaction: transaction)
        }
    }

    class func anyRemoveAllWithInstantation(transaction: SDSAnyWriteTransaction) {
        // To avoid mutationDuringEnumerationException, we need
        // to remove the instances outside the enumeration.
        let uniqueIds = anyAllUniqueIds(transaction: transaction)

        var index: Int = 0
        do {
            try Batching.loop(batchSize: Batching.kDefaultBatchSize,
                              conditionBlock: {
                                  return index < uniqueIds.count
            },
                              loopBlock: {
                                  let uniqueId = uniqueIds[index]
                                  index = index + 1
                                  guard let instance = anyFetch(uniqueId: uniqueId, transaction: transaction) else {
                                      owsFailDebug("Missing instance.")
                                      return
                                  }
                                  instance.anyRemove(transaction: transaction)
            })
        } catch {
            owsFailDebug("Error: \(error)")
        }

        if shouldBeIndexedForFTS {
            FullTextSearchFinder.allModelsWereRemoved(collection: collection(), transaction: transaction)
        }
    }

    class func anyExists(uniqueId: String,
                        transaction: SDSAnyReadTransaction) -> Bool {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return ydbTransaction.hasObject(forKey: uniqueId, inCollection: OWSDevice.collection())
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT EXISTS ( SELECT 1 FROM \(DeviceRecord.databaseTableName) WHERE \(deviceColumn: .uniqueId) = ? )"
            let arguments: StatementArguments = [uniqueId]
            return try! Bool.fetchOne(grdbTransaction.database, sql: sql, arguments: arguments) ?? false
        }
    }
}

// MARK: - Swift Fetch

public extension OWSDevice {
    class func grdbFetchCursor(sql: String,
                               arguments: StatementArguments = StatementArguments(),
                               transaction: GRDBReadTransaction) -> OWSDeviceCursor {
        do {
            let sqlRequest = SQLRequest<Void>(sql: sql, arguments: arguments, cached: true)
            let cursor = try DeviceRecord.fetchCursor(transaction.database, sqlRequest)
            return OWSDeviceCursor(cursor: cursor)
        } catch {
            Logger.error("sql: \(sql)")
            owsFailDebug("Read failed: \(error)")
            return OWSDeviceCursor(cursor: nil)
        }
    }

    class func grdbFetchOne(sql: String,
                            arguments: StatementArguments = StatementArguments(),
                            transaction: GRDBReadTransaction) -> OWSDevice? {
        assert(sql.count > 0)

        do {
            let sqlRequest = SQLRequest<Void>(sql: sql, arguments: arguments, cached: true)
            guard let record = try DeviceRecord.fetchOne(transaction.database, sqlRequest) else {
                return nil
            }

            return try OWSDevice.fromRecord(record)
        } catch {
            owsFailDebug("error: \(error)")
            return nil
        }
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class OWSDeviceSerializer: SDSSerializer {

    private let model: OWSDevice
    public required init(model: OWSDevice) {
        self.model = model
    }

    // MARK: - Record

    func asRecord() throws -> SDSRecord {
        let id: Int64? = nil

        let recordType: SDSRecordType = .device
        let uniqueId: String = model.uniqueId

        // Base class properties
        let createdAt: Date = model.createdAt
        let deviceId: Int = model.deviceId
        let lastSeenAt: Date = model.lastSeenAt
        let name: String? = model.name

        return DeviceRecord(id: id, recordType: recordType, uniqueId: uniqueId, createdAt: createdAt, deviceId: deviceId, lastSeenAt: lastSeenAt, name: name)
    }
}
