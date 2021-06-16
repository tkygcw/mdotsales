import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mdotorder/object/Order.dart';

class DatabaseHelper {
  static final _databaseName = "cartlist.db";
  static final _databaseVersion = 1;

  static final table = 'cartitem';

  static final columnId = 'id';
  static final columnItemcode = 'itemcode';
  static final columnName = 'name';
  static final columnPrice = 'price';
  static final columnQuantity = 'quantity';
  static final columnColor = 'color';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    print('db location : '+path);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
    print('db location : '+path);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnItemcode INTEGER NOT NULL,
            $columnName FLOAT NOT NULL,
            $columnPrice DOUBLE NOT NULL,
            $columnQuantity INTEGER NOT NULL,
            $columnColor STRING NOT NULL
          )
          ''');
  }

  Future<int> insert(Order order) async {
    Database db = await instance.database;
    var res = await db.insert(table, order.toMap());
    return res;
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    var res = await db.query(table, orderBy: "$columnId DESC");
    return res;
  }

  Future<List<Map<String, dynamic>>> query(itemcode) async {
    Database db = await instance.database;
    var res = await db.query(table, where: '$columnItemcode = $itemcode', orderBy: "$columnId DESC");
    return res;
  }

  Future<List<Map<String, dynamic>>> querycolor(itemcode, color) async {
    Database db = await instance.database;
    var res = await db.query(table, where: '$columnItemcode = $itemcode and $columnColor = "$color"', orderBy: "$columnId DESC");
    return res;
  }

  Future<int> update(itemcode, quantity, color) async {
    Database db = await instance.database;

    return await db.update(table,{'quantity': quantity},where: '${DatabaseHelper.columnItemcode} = ? and $columnColor = "$color"',whereArgs: [itemcode]);
  }


  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> clearTable() async {
    Database db = await instance.database;
    return await db.rawQuery("DELETE FROM $table");
  }

}

