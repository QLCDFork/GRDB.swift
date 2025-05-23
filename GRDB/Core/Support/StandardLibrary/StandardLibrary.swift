// Import C SQLite functions
#if SWIFT_PACKAGE
import GRDBSQLite
#elseif GRDBCIPHER
import SQLCipher
#elseif !GRDBCUSTOMSQLITE && !GRDBCIPHER
import SQLite3
#endif

// MARK: - Value Types

/// Bool adopts DatabaseValueConvertible and StatementColumnConvertible.
extension Bool: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    public init(sqliteStatement: SQLiteStatement, index: CInt) {
        self = sqlite3_column_int64(sqliteStatement, index) != 0
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        (self ? 1 : 0).databaseValue
    }
    
    /// Returns a `Bool` from the specified database value.
    ///
    /// If the database value contains an integer or a double, returns whether
    /// this number is zero.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Bool? {
        // IMPLEMENTATION NOTE
        //
        // https://www.sqlite.org/lang_expr.html#booleanexpr
        //
        // > # Boolean Expressions
        // >
        // > The SQL language features several contexts where an expression is
        // > evaluated and the result converted to a boolean (true or false)
        // > value. These contexts are:
        // >
        // > - the WHERE clause of a SELECT, UPDATE or DELETE statement,
        // > - the ON or USING clause of a join in a SELECT statement,
        // > - the HAVING clause of a SELECT statement,
        // > - the WHEN clause of an SQL trigger, and
        // > - the WHEN clause or clauses of some CASE expressions.
        // >
        // > To convert the results of an SQL expression to a boolean value,
        // > SQLite first casts the result to a NUMERIC value in the same way as
        // > a CAST expression. A numeric zero value (integer value 0 or real
        // > value 0.0) is considered to be false. A NULL value is still NULL.
        // > All other values are considered true.
        // >
        // > For example, the values NULL, 0.0, 0, 'english' and '0' are all
        // > considered to be false. Values 1, 1.0, 0.1, -0.1 and '1english' are
        // > considered to be true.
        //
        // OK so we have to support boolean for all storage classes?
        // Actually we won't, because of the SQLite boolean interpretation of
        // strings:
        //
        // The doc says that "english" should be false, and "1english" should
        // be true. I guess "-1english" and "0.1english" should be true also.
        // And... what about "0.0e10english"?
        //
        // Ideally, we'd ask SQLite to perform the conversion itself, and return
        // its own boolean interpretation of the string. Unfortunately, it looks
        // like it is not so easy...
        //
        // So we could take a short route, and assume all strings are false,
        // since most strings are falsey for SQLite.
        //
        // Considering all strings falsey is unfortunately very
        // counter-intuitive. This is not the correct way to tackle the boolean
        // problem.
        //
        // Instead, let's use the fact that the BOOLEAN typename has Numeric
        // affinity (https://www.sqlite.org/datatype3.html), and that the doc
        // says:
        //
        // > SQLite does not have a separate Boolean storage class. Instead,
        // > Boolean values are stored as integers 0 (false) and 1 (true).
        //
        // So we extract bools from Integer and Real only. Integer because it is
        // the natural boolean storage class, and Real because Numeric affinity
        // store big numbers as Real.
        
        switch dbValue.storage {
        case .int64(let int64):
            return (int64 != 0)
        case .double(let double):
            return (double != 0.0)
        default:
            return nil
        }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, self ? 1 : 0)
    }
}

/// Int adopts DatabaseValueConvertible and StatementColumnConvertible.
extension Int: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    @inline(__always)
    @inlinable
    public init?(sqliteStatement: SQLiteStatement, index: CInt) {
        let int64 = sqlite3_column_int64(sqliteStatement, index)
        guard let v = Int(exactly: int64) else { return nil }
        self = v
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        Int64(self).databaseValue
    }
    
    /// Returns a `Int` from the specified database value.
    ///
    /// If the database value contains a integer representable in this type,
    /// returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Int? {
        Int64.fromDatabaseValue(dbValue).flatMap { Int(exactly: $0) }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, Int64(self))
    }
}

/// Int8 adopts DatabaseValueConvertible and StatementColumnConvertible.
extension Int8: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    @inline(__always)
    @inlinable
    public init?(sqliteStatement: SQLiteStatement, index: CInt) {
        let int64 = sqlite3_column_int64(sqliteStatement, index)
        guard let v = Int8(exactly: int64) else { return nil }
        self = v
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        Int64(self).databaseValue
    }
    
    /// Returns a `Int8` from the specified database value.
    ///
    /// If the database value contains a integer representable in this type,
    /// returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Int8? {
        Int64.fromDatabaseValue(dbValue).flatMap { Int8(exactly: $0) }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, Int64(self))
    }
}

/// Int16 adopts DatabaseValueConvertible and StatementColumnConvertible.
extension Int16: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    @inline(__always)
    @inlinable
    public init?(sqliteStatement: SQLiteStatement, index: CInt) {
        let int64 = sqlite3_column_int64(sqliteStatement, index)
        guard let v = Int16(exactly: int64) else { return nil }
        self = v
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        Int64(self).databaseValue
    }
    
    /// Returns a `Int16` from the specified database value.
    ///
    /// If the database value contains a integer representable in this type,
    /// returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Int16? {
        Int64.fromDatabaseValue(dbValue).flatMap { Int16(exactly: $0) }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, Int64(self))
    }
}

/// Int32 adopts DatabaseValueConvertible and StatementColumnConvertible.
extension Int32: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    @inline(__always)
    @inlinable
    public init?(sqliteStatement: SQLiteStatement, index: CInt) {
        let int64 = sqlite3_column_int64(sqliteStatement, index)
        guard let v = Int32(exactly: int64) else { return nil }
        self = v
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        Int64(self).databaseValue
    }
    
    /// Returns a `Int32` from the specified database value.
    ///
    /// If the database value contains a integer representable in this type,
    /// returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Int32? {
        Int64.fromDatabaseValue(dbValue).flatMap { Int32(exactly: $0) }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, Int64(self))
    }
}

/// Int64 adopts DatabaseValueConvertible and StatementColumnConvertible.
extension Int64: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    public init(sqliteStatement: SQLiteStatement, index: CInt) {
        self = sqlite3_column_int64(sqliteStatement, index)
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        DatabaseValue(storage: .int64(self))
    }
    
    /// Returns a `Int64` from the specified database value.
    ///
    /// If the database value contains a integer, returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Int64? {
        switch dbValue.storage {
        case .int64(let int64):
            return int64
        case .double(let double):
            guard double >= Double(Int64.min) else { return nil }
            guard double < Double(Int64.max) else { return nil }
            return Int64(double)
        default:
            return nil
        }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, self)
    }
}

/// UInt adopts DatabaseValueConvertible and StatementColumnConvertible.
extension UInt: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    @inline(__always)
    @inlinable
    public init?(sqliteStatement: SQLiteStatement, index: CInt) {
        let int64 = sqlite3_column_int64(sqliteStatement, index)
        guard let v = UInt(exactly: int64) else { return nil }
        self = v
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        Int64(self).databaseValue
    }
    
    /// Returns a `UInt` from the specified database value.
    ///
    /// If the database value contains a integer representable in this type,
    /// returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> UInt? {
        Int64.fromDatabaseValue(dbValue).flatMap { UInt(exactly: $0) }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, Int64(self))
    }
}

/// UInt8 adopts DatabaseValueConvertible and StatementColumnConvertible.
extension UInt8: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    @inline(__always)
    @inlinable
    public init?(sqliteStatement: SQLiteStatement, index: CInt) {
        let int64 = sqlite3_column_int64(sqliteStatement, index)
        guard let v = UInt8(exactly: int64) else { return nil }
        self = v
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        Int64(self).databaseValue
    }
    
    /// Returns a `UInt8` from the specified database value.
    ///
    /// If the database value contains a integer representable in this type,
    /// returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> UInt8? {
        Int64.fromDatabaseValue(dbValue).flatMap { UInt8(exactly: $0) }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, Int64(self))
    }
}

/// UInt16 adopts DatabaseValueConvertible and StatementColumnConvertible.
extension UInt16: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    @inline(__always)
    @inlinable
    public init?(sqliteStatement: SQLiteStatement, index: CInt) {
        let int64 = sqlite3_column_int64(sqliteStatement, index)
        guard let v = UInt16(exactly: int64) else { return nil }
        self = v
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        Int64(self).databaseValue
    }
    
    /// Returns a `UInt16` from the specified database value.
    ///
    /// If the database value contains a integer representable in this type,
    /// returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> UInt16? {
        Int64.fromDatabaseValue(dbValue).flatMap { UInt16(exactly: $0) }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, Int64(self))
    }
}

/// UInt32 adopts DatabaseValueConvertible and StatementColumnConvertible.
extension UInt32: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    @inline(__always)
    @inlinable
    public init?(sqliteStatement: SQLiteStatement, index: CInt) {
        let int64 = sqlite3_column_int64(sqliteStatement, index)
        guard let v = UInt32(exactly: int64) else { return nil }
        self = v
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        Int64(self).databaseValue
    }
    
    /// Returns a `UInt32` from the specified database value.
    ///
    /// If the database value contains a integer representable in this type,
    /// returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> UInt32? {
        Int64.fromDatabaseValue(dbValue).flatMap { UInt32(exactly: $0) }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, Int64(self))
    }
}

/// UInt64 adopts DatabaseValueConvertible and StatementColumnConvertible.
extension UInt64: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    @inline(__always)
    @inlinable
    public init?(sqliteStatement: SQLiteStatement, index: CInt) {
        let int64 = sqlite3_column_int64(sqliteStatement, index)
        guard let v = UInt64(exactly: int64) else { return nil }
        self = v
    }
    
    /// Returns an INTEGER database value.
    public var databaseValue: DatabaseValue {
        Int64(self).databaseValue
    }
    
    /// Returns a `UInt64` from the specified database value.
    ///
    /// If the database value contains a integer representable in this type,
    /// returns this integer.
    ///
    /// If the database value contains a double representable in this type after
    /// rounding toward zero, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> UInt64? {
        Int64.fromDatabaseValue(dbValue).flatMap { UInt64(exactly: $0) }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_int64(sqliteStatement, index, Int64(self))
    }
}

/// Double adopts DatabaseValueConvertible and StatementColumnConvertible.
extension Double: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    public init(sqliteStatement: SQLiteStatement, index: CInt) {
        self = sqlite3_column_double(sqliteStatement, index)
    }
    
    /// Returns a REAL database value.
    public var databaseValue: DatabaseValue {
        DatabaseValue(storage: .double(self))
    }
    
    /// Returns a `Double` from the specified database value.
    ///
    /// If the database value contains a integer, returns the conversion.
    ///
    /// If the database value contains a double, returns this double.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Double? {
        switch dbValue.storage {
        case .int64(let int64):
            return Double(int64)
        case .double(let double):
            return double
        default:
            return nil
        }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_double(sqliteStatement, index, self)
    }
}

/// Float adopts DatabaseValueConvertible and StatementColumnConvertible.
extension Float: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    public init(sqliteStatement: SQLiteStatement, index: CInt) {
        self = Float(sqlite3_column_double(sqliteStatement, index))
    }
    
    /// Returns a REAL database value.
    public var databaseValue: DatabaseValue {
        Double(self).databaseValue
    }
    
    /// Returns a `Float` from the specified database value.
    ///
    /// If the database value contains a integer, returns the conversion.
    ///
    /// If the database value contains a double, returns the conversion.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Float? {
        switch dbValue.storage {
        case .int64(let int64):
            return Float(int64)
        case .double(let double):
            return Float(double)
        default:
            return nil
        }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_double(sqliteStatement, index, Double(self))
    }
}

/// String adopts DatabaseValueConvertible and StatementColumnConvertible.
extension String: DatabaseValueConvertible, StatementColumnConvertible {
    
    /// Returns a value initialized from a raw SQLite statement pointer.
    ///
    /// - parameters:
    ///     - sqliteStatement: A pointer to an SQLite statement.
    ///     - index: The column index.
    public init(sqliteStatement: SQLiteStatement, index: CInt) {
        self = String(cString: sqlite3_column_text(sqliteStatement, index)!)
    }
    
    /// Returns a TEXT database value.
    public var databaseValue: DatabaseValue {
        DatabaseValue(storage: .string(self))
    }
    
    /// Returns a `String` from the specified database value.
    ///
    /// If the database value contains a string, returns it.
    ///
    /// If the database value contains a data blob, parses this data as an
    /// UTF8 string.
    ///
    /// Otherwise, returns nil.
    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> String? {
        switch dbValue.storage {
        case .blob(let data):
            // Implicit conversion from blob to string, just as SQLite does
            // See <https://www.sqlite.org/c3ref/column_blob.html>
            return String(data: data, encoding: .utf8)
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    
    public func bind(to sqliteStatement: SQLiteStatement, at index: CInt) -> CInt {
        sqlite3_bind_text(sqliteStatement, index, self, -1, SQLITE_TRANSIENT)
    }
    
    /// Calls the given closure after binding a statement argument.
    ///
    /// The binding is valid only during the execution of this method.
    ///
    /// - parameter sqliteStatement: An SQLite statement.
    /// - parameter index: 1-based index to statement arguments.
    /// - parameter body: The closure to execute when argument is bound.
    func withBinding<T>(to sqliteStatement: SQLiteStatement, at index: CInt, do body: () throws -> T) throws -> T {
        try withCString {
            let code = sqlite3_bind_text(sqliteStatement, index, $0, -1, nil /* SQLITE_STATIC */)
            try checkBindingSuccess(code: code, sqliteStatement: sqliteStatement)
            return try body()
        }
    }
}


// MARK: - SQL Functions

extension DatabaseFunction {
    /// An SQL function that calls the Foundation
    /// `String.capitalized` property.
    ///
    /// `NULL` is returned for non-strings values.
    ///
    /// This function is automatically added by GRDB to your database
    /// connections. It is the function used by the query interface's
    /// ``SQLSpecificExpressible/capitalized``:
    ///
    /// ```swift
    /// let request = Player.select { $0.name.capitalized }
    /// let names = try String.fetchAll(dbQueue, request) // [String]
    /// ```
    public static let capitalize =
        DatabaseFunction("swiftCapitalizedString", argumentCount: 1, pure: true) { dbValues in
            guard let string = String.fromDatabaseValue(dbValues[0]) else {
                return nil
            }
            return string.capitalized
        }
    
    /// An SQL function that calls the Swift
    /// `String.lowercased()` method.
    ///
    /// `NULL` is returned for non-strings values.
    ///
    /// This function is automatically added by GRDB to your database
    /// connections. It is the function used by the query interface's
    /// ``SQLSpecificExpressible/lowercased``:
    ///
    /// ```swift
    /// let request = Player.select { $0.name.lowercased }
    /// let names = try String.fetchAll(dbQueue, request) // [String]
    /// ```
    public static let lowercase =
        DatabaseFunction("swiftLowercaseString", argumentCount: 1, pure: true) { dbValues in
            guard let string = String.fromDatabaseValue(dbValues[0]) else {
                return nil
            }
            return string.lowercased()
        }
    
    /// An SQL function that calls the Swift
    /// `String.uppercased()` method.
    ///
    /// `NULL` is returned for non-strings values.
    ///
    /// This function is automatically added by GRDB to your database
    /// connections. It is the function used by the query interface's
    /// ``SQLSpecificExpressible/uppercased``:
    ///
    /// ```swift
    /// let request = Player.select { $0.name.uppercased }
    /// let names = try String.fetchAll(dbQueue, request) // [String]
    /// ```
    public static let uppercase =
        DatabaseFunction("swiftUppercaseString", argumentCount: 1, pure: true) { dbValues in
            guard let string = String.fromDatabaseValue(dbValues[0]) else {
                return nil
            }
            return string.uppercased()
        }

    /// An SQL function that calls the Foundation
    /// `String.localizedCapitalized` property.
    ///
    /// `NULL` is returned for non-strings values.
    ///
    /// This function is automatically added by GRDB to your database
    /// connections. It is the function used by the query interface's
    /// ``SQLSpecificExpressible/localizedCapitalized``:
    ///
    /// ```swift
    /// let request = Player.select { $0.name.localizedCapitalized }
    /// let names = try String.fetchAll(dbQueue, request) // [String]
    /// ```
    public static let localizedCapitalize =
        DatabaseFunction("swiftLocalizedCapitalizedString", argumentCount: 1, pure: true) { dbValues in
            guard let string = String.fromDatabaseValue(dbValues[0]) else {
                return nil
            }
            return string.localizedCapitalized
        }
    
    
    /// An SQL function that calls the Foundation
    /// `String.localizedLowercase` property.
    ///
    /// `NULL` is returned for non-strings values.
    ///
    /// This function is automatically added by GRDB to your database
    /// connections. It is the function used by the query interface's
    /// ``SQLSpecificExpressible/localizedLowercased``:
    ///
    /// ```swift
    /// let request = Player.select { $0.name.localizedLowercase }
    /// let names = try String.fetchAll(dbQueue, request) // [String]
    /// ```
    public static let localizedLowercase =
        DatabaseFunction("swiftLocalizedLowercaseString", argumentCount: 1, pure: true) { dbValues in
            guard let string = String.fromDatabaseValue(dbValues[0]) else {
                return nil
            }
            return string.localizedLowercase
        }
    
    /// An SQL function that calls the Foundation
    /// `String.localizedUppercase` property.
    ///
    /// `NULL` is returned for non-strings values.
    ///
    /// This function is automatically added by GRDB to your database
    /// connections. It is the function used by the query interface's
    /// ``SQLSpecificExpressible/localizedUppercased``:
    ///
    /// ```swift
    /// let request = Player.select { $0.name.localizedUppercase }
    /// let names = try String.fetchAll(dbQueue, request) // [String]
    /// ```
    public static let localizedUppercase =
        DatabaseFunction("swiftLocalizedUppercaseString", argumentCount: 1, pure: true) { dbValues in
            guard let string = String.fromDatabaseValue(dbValues[0]) else {
                return nil
            }
            return string.localizedUppercase
        }
}


// MARK: - SQLite Collations

extension DatabaseCollation {
    // Here we define a set of predefined collations.
    //
    // We should avoid renaming those collations, because database created with
    // earlier versions of the library may have used those collations in the
    // definition of tables. A renaming would prevent SQLite to find the
    // collation.
    //
    // Yet we're not absolutely stuck: we could register support for obsolete
    // collation names with sqlite3_collation_needed().
    // See https://www.sqlite.org/capi3ref.html#sqlite3_collation_needed
    
    /// A collation that compares strings according to the built-in `==` and
    /// `<=` operators of the Swift String.
    ///
    /// This collation is automatically added by GRDB to your database
    /// connections.
    ///
    /// You can use the collation when creating database tables:
    ///
    /// ```swift
    /// try db.create(table: "player") { t in
    ///     t.column("name", .text).collate(.unicodeCompare)
    /// }
    /// ```
    ///
    /// Embed the collation name in your raw SQL queries:
    ///
    /// ```swift
    /// let collationName = DatabaseCollation.unicodeCompare.name
    /// dbQueue.execute(sql: """
    ///     CREATE TABLE player (
    ///       name TEXT COLLATE \(collationName)
    ///     )
    ///     """)
    /// ```
    public static let unicodeCompare =
        DatabaseCollation("swiftCompare") { (lhs, rhs) in
            (lhs < rhs) ? .orderedAscending : ((lhs == rhs) ? .orderedSame : .orderedDescending)
        }
    
    /// A collation that compares strings according to the Foundation
    /// `String.caseInsensitiveCompare(_:)` method.
    ///
    /// This collation is automatically added by GRDB to your database
    /// connections.
    ///
    /// You can use the collation when creating database tables:
    ///
    /// ```swift
    /// try db.create(table: "player") { t in
    ///     t.column("name", .text).collate(.caseInsensitiveCompare)
    /// }
    /// ```
    ///
    /// Embed the collation name in your raw SQL queries:
    ///
    /// ```swift
    /// let collationName = DatabaseCollation.caseInsensitiveCompare.name
    /// dbQueue.execute(sql: """
    ///     CREATE TABLE player (
    ///       name TEXT COLLATE \(collationName)
    ///     )
    ///     """)
    /// ```
    public static let caseInsensitiveCompare =
        DatabaseCollation("swiftCaseInsensitiveCompare") { (lhs, rhs) in
            lhs.caseInsensitiveCompare(rhs)
        }
    
    /// A collation that compares strings according to the Foundation
    /// `String.localizedCaseInsensitiveCompare(_:)` method.
    ///
    /// This collation is automatically added by GRDB to your database
    /// connections.
    ///
    /// You can use the collation when creating database tables:
    ///
    /// ```swift
    /// try db.create(table: "player") { t in
    ///     t.column("name", .text).collate(.localizedCaseInsensitiveCompare)
    /// }
    /// ```
    ///
    /// Embed the collation name in your raw SQL queries:
    ///
    /// ```swift
    /// let collationName = DatabaseCollation.localizedCaseInsensitiveCompare.name
    /// dbQueue.execute(sql: """
    ///     CREATE TABLE player (
    ///       name TEXT COLLATE \(collationName)
    ///     )
    ///     """)
    /// ```
    public static let localizedCaseInsensitiveCompare =
        DatabaseCollation("swiftLocalizedCaseInsensitiveCompare") { (lhs, rhs) in
            lhs.localizedCaseInsensitiveCompare(rhs)
        }
    
    /// A collation that compares strings according to the Foundation
    /// `String.localizedCompare(_:)` method.
    ///
    /// This collation is automatically added by GRDB to your database
    /// connections.
    ///
    /// You can use the collation when creating database tables:
    ///
    /// ```swift
    /// try db.create(table: "player") { t in
    ///     t.column("name", .text).collate(.localizedCompare)
    /// }
    /// ```
    ///
    /// Embed the collation name in your raw SQL queries:
    ///
    /// ```swift
    /// let collationName = DatabaseCollation.localizedCompare.name
    /// dbQueue.execute(sql: """
    ///     CREATE TABLE player (
    ///       name TEXT COLLATE \(collationName)
    ///     )
    ///     """)
    /// ```
    public static let localizedCompare =
        DatabaseCollation("swiftLocalizedCompare") { (lhs, rhs) in
            lhs.localizedCompare(rhs)
        }
    
    /// A collation that compares strings according to the Foundation
    /// `String.localizedStandardCompare(_:)` method.
    ///
    /// This collation is automatically added by GRDB to your database
    /// connections.
    ///
    /// You can use the collation when creating database tables:
    ///
    /// ```swift
    /// try db.create(table: "player") { t in
    ///     t.column("name", .text).collate(.localizedStandardCompare)
    /// }
    /// ```
    ///
    /// Embed the collation name in your raw SQL queries:
    ///
    /// ```swift
    /// let collationName = DatabaseCollation.localizedStandardCompare.name
    /// dbQueue.execute(sql: """
    ///     CREATE TABLE player (
    ///       name TEXT COLLATE \(collationName)
    ///     )
    ///     """)
    /// ```
    public static let localizedStandardCompare =
        DatabaseCollation("swiftLocalizedStandardCompare") { (lhs, rhs) in
            lhs.localizedStandardCompare(rhs)
        }
}
