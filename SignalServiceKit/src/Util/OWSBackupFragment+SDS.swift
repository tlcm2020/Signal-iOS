//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import Foundation
import GRDB
import SignalCoreKit

// NOTE: This file is generated by /Scripts/sds_codegen/sds_generate.py.
// Do not manually edit it, instead run `sds_codegen.sh`.

// MARK: - Record

public struct BackupFragmentRecord: SDSRecord {
    public var tableMetadata: SDSTableMetadata {
        return OWSBackupFragmentSerializer.table
    }

    public static let databaseTableName: String = OWSBackupFragmentSerializer.table.tableName

    public var id: Int64?

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    public let recordType: SDSRecordType
    public let uniqueId: String

    // Base class properties
    public let attachmentId: String?
    public let downloadFilePath: String?
    public let encryptionKey: Data
    public let recordName: String
    public let relativeFilePath: String?
    public let uncompressedDataLength: UInt64?

    public enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case id
        case recordType
        case uniqueId
        case attachmentId
        case downloadFilePath
        case encryptionKey
        case recordName
        case relativeFilePath
        case uncompressedDataLength
    }

    public static func columnName(_ column: BackupFragmentRecord.CodingKeys, fullyQualified: Bool = false) -> String {
        return fullyQualified ? "\(databaseTableName).\(column.rawValue)" : column.rawValue
    }
}

// MARK: - Row Initializer

public extension BackupFragmentRecord {
    static var databaseSelection: [SQLSelectable] {
        return CodingKeys.allCases
    }

    init(row: Row) {
        id = row[0]
        recordType = row[1]
        uniqueId = row[2]
        attachmentId = row[3]
        downloadFilePath = row[4]
        encryptionKey = row[5]
        recordName = row[6]
        relativeFilePath = row[7]
        uncompressedDataLength = row[8]
    }
}

// MARK: - StringInterpolation

public extension String.StringInterpolation {
    mutating func appendInterpolation(backupFragmentColumn column: BackupFragmentRecord.CodingKeys) {
        appendLiteral(BackupFragmentRecord.columnName(column))
    }
    mutating func appendInterpolation(backupFragmentColumnFullyQualified column: BackupFragmentRecord.CodingKeys) {
        appendLiteral(BackupFragmentRecord.columnName(column, fullyQualified: true))
    }
}

// MARK: - Deserialization

// TODO: Rework metadata to not include, for example, columns, column indices.
extension OWSBackupFragment {
    // This method defines how to deserialize a model, given a
    // database row.  The recordType column is used to determine
    // the corresponding model class.
    class func fromRecord(_ record: BackupFragmentRecord) throws -> OWSBackupFragment {

        guard let recordId = record.id else {
            throw SDSError.invalidValue
        }

        switch record.recordType {
        case .backupFragment:

            let uniqueId: String = record.uniqueId
            let attachmentId: String? = record.attachmentId
            let downloadFilePath: String? = record.downloadFilePath
            let encryptionKey: Data = record.encryptionKey
            let recordName: String = record.recordName
            let relativeFilePath: String? = record.relativeFilePath
            let uncompressedDataLength: NSNumber? = SDSDeserialization.optionalNumericAsNSNumber(record.uncompressedDataLength, name: "uncompressedDataLength", conversion: { NSNumber(value: $0) })

            return OWSBackupFragment(uniqueId: uniqueId,
                                     attachmentId: attachmentId,
                                     downloadFilePath: downloadFilePath,
                                     encryptionKey: encryptionKey,
                                     recordName: recordName,
                                     relativeFilePath: relativeFilePath,
                                     uncompressedDataLength: uncompressedDataLength)

        default:
            owsFailDebug("Unexpected record type: \(record.recordType)")
            throw SDSError.invalidValue
        }
    }
}

// MARK: - SDSModel

extension OWSBackupFragment: SDSModel {
    public var serializer: SDSSerializer {
        // Any subclass can be cast to it's superclass,
        // so the order of this switch statement matters.
        // We need to do a "depth first" search by type.
        switch self {
        default:
            return OWSBackupFragmentSerializer(model: self)
        }
    }

    public func asRecord() throws -> SDSRecord {
        return try serializer.asRecord()
    }

    public var sdsTableName: String {
        return BackupFragmentRecord.databaseTableName
    }

    public static var table: SDSTableMetadata {
        return OWSBackupFragmentSerializer.table
    }
}

// MARK: - Table Metadata

extension OWSBackupFragmentSerializer {

    // This defines all of the columns used in the table
    // where this model (and any subclasses) are persisted.
    static let idColumn = SDSColumnMetadata(columnName: "id", columnType: .primaryKey, columnIndex: 0)
    static let recordTypeColumn = SDSColumnMetadata(columnName: "recordType", columnType: .int64, columnIndex: 1)
    static let uniqueIdColumn = SDSColumnMetadata(columnName: "uniqueId", columnType: .unicodeString, columnIndex: 2)
    // Base class properties
    static let attachmentIdColumn = SDSColumnMetadata(columnName: "attachmentId", columnType: .unicodeString, isOptional: true, columnIndex: 3)
    static let downloadFilePathColumn = SDSColumnMetadata(columnName: "downloadFilePath", columnType: .unicodeString, isOptional: true, columnIndex: 4)
    static let encryptionKeyColumn = SDSColumnMetadata(columnName: "encryptionKey", columnType: .blob, columnIndex: 5)
    static let recordNameColumn = SDSColumnMetadata(columnName: "recordName", columnType: .unicodeString, columnIndex: 6)
    static let relativeFilePathColumn = SDSColumnMetadata(columnName: "relativeFilePath", columnType: .unicodeString, isOptional: true, columnIndex: 7)
    static let uncompressedDataLengthColumn = SDSColumnMetadata(columnName: "uncompressedDataLength", columnType: .int64, isOptional: true, columnIndex: 8)

    // TODO: We should decide on a naming convention for
    //       tables that store models.
    public static let table = SDSTableMetadata(collection: OWSBackupFragment.collection(),
                                               tableName: "model_OWSBackupFragment",
                                               columns: [
        idColumn,
        recordTypeColumn,
        uniqueIdColumn,
        attachmentIdColumn,
        downloadFilePathColumn,
        encryptionKeyColumn,
        recordNameColumn,
        relativeFilePathColumn,
        uncompressedDataLengthColumn
        ])
}

// MARK: - Save/Remove/Update

@objc
public extension OWSBackupFragment {
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
        if OWSBackupFragment.anyFetch(uniqueId: uniqueId, transaction: transaction) != nil {
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
    func anyUpdate(transaction: SDSAnyWriteTransaction, block: (OWSBackupFragment) -> Void) {

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

// MARK: - OWSBackupFragmentCursor

@objc
public class OWSBackupFragmentCursor: NSObject {
    private let cursor: RecordCursor<BackupFragmentRecord>?

    init(cursor: RecordCursor<BackupFragmentRecord>?) {
        self.cursor = cursor
    }

    public func next() throws -> OWSBackupFragment? {
        guard let cursor = cursor else {
            return nil
        }
        guard let record = try cursor.next() else {
            return nil
        }
        return try OWSBackupFragment.fromRecord(record)
    }

    public func all() throws -> [OWSBackupFragment] {
        var result = [OWSBackupFragment]()
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
public extension OWSBackupFragment {
    class func grdbFetchCursor(transaction: GRDBReadTransaction) -> OWSBackupFragmentCursor {
        let database = transaction.database
        do {
            let cursor = try BackupFragmentRecord.fetchCursor(database)
            return OWSBackupFragmentCursor(cursor: cursor)
        } catch {
            owsFailDebug("Read failed: \(error)")
            return OWSBackupFragmentCursor(cursor: nil)
        }
    }

    // Fetches a single model by "unique id".
    class func anyFetch(uniqueId: String,
                        transaction: SDSAnyReadTransaction) -> OWSBackupFragment? {
        assert(uniqueId.count > 0)

        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            return OWSBackupFragment.ydb_fetch(uniqueId: uniqueId, transaction: ydbTransaction)
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT * FROM \(BackupFragmentRecord.databaseTableName) WHERE \(backupFragmentColumn: .uniqueId) = ?"
            return grdbFetchOne(sql: sql, arguments: [uniqueId], transaction: grdbTransaction)
        }
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    class func anyEnumerate(transaction: SDSAnyReadTransaction,
                            batched: Bool = false,
                            block: @escaping (OWSBackupFragment, UnsafeMutablePointer<ObjCBool>) -> Void) {
        let batchSize = batched ? Batching.kDefaultBatchSize : 0
        anyEnumerate(transaction: transaction, batchSize: batchSize, block: block)
    }

    // Traverses all records.
    // Records are not visited in any particular order.
    //
    // If batchSize > 0, the enumeration is performed in autoreleased batches.
    class func anyEnumerate(transaction: SDSAnyReadTransaction,
                            batchSize: UInt,
                            block: @escaping (OWSBackupFragment, UnsafeMutablePointer<ObjCBool>) -> Void) {
        switch transaction.readTransaction {
        case .yapRead(let ydbTransaction):
            OWSBackupFragment.ydb_enumerateCollectionObjects(with: ydbTransaction) { (object, stop) in
                guard let value = object as? OWSBackupFragment else {
                    owsFailDebug("unexpected object: \(type(of: object))")
                    return
                }
                block(value, stop)
            }
        case .grdbRead(let grdbTransaction):
            do {
                let cursor = OWSBackupFragment.grdbFetchCursor(transaction: grdbTransaction)
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
            ydbTransaction.enumerateKeys(inCollection: OWSBackupFragment.collection()) { (uniqueId, stop) in
                block(uniqueId, stop)
            }
        case .grdbRead(let grdbTransaction):
            grdbEnumerateUniqueIds(transaction: grdbTransaction,
                                   sql: """
                    SELECT \(backupFragmentColumn: .uniqueId)
                    FROM \(BackupFragmentRecord.databaseTableName)
                """,
                batchSize: batchSize,
                block: block)
        }
    }

    // Does not order the results.
    class func anyFetchAll(transaction: SDSAnyReadTransaction) -> [OWSBackupFragment] {
        var result = [OWSBackupFragment]()
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
            return ydbTransaction.numberOfKeys(inCollection: OWSBackupFragment.collection())
        case .grdbRead(let grdbTransaction):
            return BackupFragmentRecord.ows_fetchCount(grdbTransaction.database)
        }
    }

    // WARNING: Do not use this method for any models which do cleanup
    //          in their anyWillRemove(), anyDidRemove() methods.
    class func anyRemoveAllWithoutInstantation(transaction: SDSAnyWriteTransaction) {
        switch transaction.writeTransaction {
        case .yapWrite(let ydbTransaction):
            ydbTransaction.removeAllObjects(inCollection: OWSBackupFragment.collection())
        case .grdbWrite(let grdbTransaction):
            do {
                try BackupFragmentRecord.deleteAll(grdbTransaction.database)
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
            return ydbTransaction.hasObject(forKey: uniqueId, inCollection: OWSBackupFragment.collection())
        case .grdbRead(let grdbTransaction):
            let sql = "SELECT EXISTS ( SELECT 1 FROM \(BackupFragmentRecord.databaseTableName) WHERE \(backupFragmentColumn: .uniqueId) = ? )"
            let arguments: StatementArguments = [uniqueId]
            return try! Bool.fetchOne(grdbTransaction.database, sql: sql, arguments: arguments) ?? false
        }
    }
}

// MARK: - Swift Fetch

public extension OWSBackupFragment {
    class func grdbFetchCursor(sql: String,
                               arguments: StatementArguments = StatementArguments(),
                               transaction: GRDBReadTransaction) -> OWSBackupFragmentCursor {
        do {
            let sqlRequest = SQLRequest<Void>(sql: sql, arguments: arguments, cached: true)
            let cursor = try BackupFragmentRecord.fetchCursor(transaction.database, sqlRequest)
            return OWSBackupFragmentCursor(cursor: cursor)
        } catch {
            Logger.error("sql: \(sql)")
            owsFailDebug("Read failed: \(error)")
            return OWSBackupFragmentCursor(cursor: nil)
        }
    }

    class func grdbFetchOne(sql: String,
                            arguments: StatementArguments = StatementArguments(),
                            transaction: GRDBReadTransaction) -> OWSBackupFragment? {
        assert(sql.count > 0)

        do {
            let sqlRequest = SQLRequest<Void>(sql: sql, arguments: arguments, cached: true)
            guard let record = try BackupFragmentRecord.fetchOne(transaction.database, sqlRequest) else {
                return nil
            }

            return try OWSBackupFragment.fromRecord(record)
        } catch {
            owsFailDebug("error: \(error)")
            return nil
        }
    }
}

// MARK: - SDSSerializer

// The SDSSerializer protocol specifies how to insert and update the
// row that corresponds to this model.
class OWSBackupFragmentSerializer: SDSSerializer {

    private let model: OWSBackupFragment
    public required init(model: OWSBackupFragment) {
        self.model = model
    }

    // MARK: - Record

    func asRecord() throws -> SDSRecord {
        let id: Int64? = nil

        let recordType: SDSRecordType = .backupFragment
        let uniqueId: String = model.uniqueId

        // Base class properties
        let attachmentId: String? = model.attachmentId
        let downloadFilePath: String? = model.downloadFilePath
        let encryptionKey: Data = model.encryptionKey
        let recordName: String = model.recordName
        let relativeFilePath: String? = model.relativeFilePath
        let uncompressedDataLength: UInt64? = archiveOptionalNSNumber(model.uncompressedDataLength, conversion: { $0.uint64Value })

        return BackupFragmentRecord(id: id, recordType: recordType, uniqueId: uniqueId, attachmentId: attachmentId, downloadFilePath: downloadFilePath, encryptionKey: encryptionKey, recordName: recordName, relativeFilePath: relativeFilePath, uncompressedDataLength: uncompressedDataLength)
    }
}
