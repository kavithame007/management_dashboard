import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseConnection{

  Future<Database> setDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'db_crud');
    var database = await openDatabase(path,version: 1, onCreate: _createDatabase, onUpgrade: _onUpgrade);
    return database;
  }

  Future<void> _createDatabase(Database database, int version) async {
    String employeeFilterTable = "CREATE TABLE EmployeeProductivityFilter(id INTEGER PRIMARY KEY, UserID TEXT, FilterName TEXT, selectedManagerID TEXT, selectedManagerName TEXT, selectedCustomerID TEXT, selectedCustomerName TEXT, isWeekly INTEGER, isEmployee INTEGER, selectedDate TEXT, selectedYear INTEGER, selectedMonth INTEGER)";
    String projectAllocationFilter = "CREATE TABLE ProjectAllocationFilter(id INTEGER PRIMARY KEY, UserID TEXT, FilterName TEXT, selectedManagerID TEXT, selectedManagerName TEXT, selectedStartYear INTEGER, selectedEndYear INTEGER, selectedStartMonth TEXT, selectedEndMonth TEXT)";
    String timesheetFilterTable = "CREATE TABLE TimeSheetFilter(id INTEGER PRIMARY KEY, UserID TEXT, FilterName TEXT, selectedManagerID TEXT, selectedManagerName TEXT,  selectedWeek TEXT)";

    await database.execute(employeeFilterTable);
    await database.execute(projectAllocationFilter);
    await database.execute(timesheetFilterTable);
  }

  // Future<void> deleteDatabaseFile() async {
  //   try {
  //     var directory = await getApplicationDocumentsDirectory();
  //     var path = join(directory.path, 'db_crud');
  //
  //     // Check if the database file exists before deleting it
  //     bool databaseExists = await databaseFactory.databaseExists(path);
  //
  //     if (databaseExists) {
  //       // Close any open connections to the database
  //       await (await openDatabase(path)).close();
  //
  //       // Delete the database file
  //       await deleteDatabase(path);
  //
  //       print('Database deleted successfully.');
  //     } else {
  //       print('Database does not exist.');
  //     }
  //   } catch (e) {
  //     print('Error deleting database: $e');
  //   }
  // }

  Future<void> _onUpgrade(Database database, int oldVersion, int newVersion) async {

  }
}