import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
        return openDatabase(
            path,
            version: dbVersion,
            onCreate: _dbCreate,
            onUpgrade:_dbUpgrade,
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
        _db!.transaction((txn) async{
            txn.execute("""
                Create table user 
            """);
        });
    }
}