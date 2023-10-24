import 'package:management_dashboard/Local_DB/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  late DatabaseConnection _databaseConnection;

  Repository() {
    _databaseConnection = DatabaseConnection();
  }

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _databaseConnection.setDatabase();
      return _database;
    }
  }

  //Insert Records
  insertData(table, data) async {
    print('Insert Data $table $data');
    var connection = await database;
    return await connection?.insert(table, data);
  }

  //GetAll Records
  readData(table) async {
    var connection = await database;
    return await connection?.query(table);
  }

  //Find one Record
  readDataByID(table, id) async {
    var connection = await database;
    return await connection?.query(table, where: 'id=?', whereArgs: [id]);
  }

  //Update Record
  updateRecord(table, data) async {
    var connection = await database;
    return await connection
        ?.update(table, data, where: 'id=?', whereArgs: [data['id']]);
  }

  deleteDataByID(table, id) async {
    var connection = await database;
    return await connection?.rawDelete("delete from $table where id=$id");
  }
}
