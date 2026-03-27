import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'sentinel.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE patients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            phone TEXT,
            pregnancy_stage INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE visits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patient_id INTEGER,
            bp INTEGER,
            heart_rate INTEGER,
            symptoms TEXT,
            risk_level TEXT,
            possible_condition TEXT,
            synced INTEGER
          )
        ''');
      },
    );
  }

  // CRUD for patients
  static Future<int> insertPatient(Map<String, dynamic> patient) async {
    final db = await database;
    return db.insert('patients', patient);
  }

  static Future<List<Map<String, dynamic>>> getPatients() async {
    final db = await database;
    return db.query('patients');
  }

  // CRUD for visits
  static Future<int> insertVisit(Map<String, dynamic> visit) async {
    final db = await database;
    return db.insert('visits', visit);
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedVisits() async {
    final db = await database;
    return db.query('visits', where: 'synced = ?', whereArgs: [0]);
  }

  static Future<void> markVisitSynced(int id) async {
    final db = await database;
    await db.update('visits', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
