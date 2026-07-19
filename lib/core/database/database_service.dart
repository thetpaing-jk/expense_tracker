import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/app_const.dart';

class DatabaseService{
    DatabaseService._();
    static final DatabaseService instance = DatabaseService._();

    String dbName = "expense_tracker.db";
    int dbVersion = 1;

    Database? _db;

    Future<Database> get database async{
        if(_db != null && _db!.isOpen)return _db!;
        _db = await _initDb();
        return _db!;
    }
    Future<Database> _initDb() async{
        String dbPath = await getDatabasesPath();
        String path = join(dbPath, dbName);
        return await openDatabase(
            path,
            version: dbVersion,
            onCreate: _dbCreate,
            onUpgrade:_dbUpgrade,
            onOpen: (db) {
              db.execute('PRAGMA Foreign_keys = ON');
            },
        );
    }

    Future<void> close(Database db) async{
        if(_db != null && _db!.isOpen){
            await _db!.close();
            _db = null;
        }
    }

    Future<void> _dbUpgrade(Database db, int oldVersion, int newVersion) async{
        // To migrate the database
    }

    Future<void> _dbCreate(Database db, int version) async{
        await db.transaction((txn) async{
            await txn.execute("""
                Create table ${AppConst.userTable} (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  username STRING NOT NULL,
                  password STRING NOT NULL,
                  email    STRING NOT NULL DEFAULT "",
                  createdAt STRING NOT NULL DEFAULT ""
                )
            """);
            await txn.execute("""
              Create table ${AppConst.expenseTypeTable}(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL DEFAULT "",
                subtitle TEXT NOT NULL DEFAULT "",
                icon INTEGER NOT NULL DEFAULT 0,
                color INTEGER NOT NULL DEFAULT 0
              )
            """);
            await txn.execute("""
              Create table ${AppConst.expenseTable}(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL DEFAULT "",
                amount DOUBLE NOT NULL DEFAULT 0.0,
                type INTEGER NOT NULL DEFAULT 1,
                date TEXT NOT NULL DEFAULT "",
                note TEXT NOT NULL DEFAULT "",
                FOREIGN KEY (type) REFERENCES ${AppConst.expenseTypeTable} (id)
                  ON DELETE CASCADE
                  ON UPDATE CASCADE
              )
            """);
        });
    }
}
