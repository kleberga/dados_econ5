import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Toggle_reg {
  final id;
  final valorToggle;
  final dataCompara;
  const Toggle_reg({required this.id, required this.valorToggle, required this.dataCompara});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valorToggle': valorToggle,
      'dataCompara': dataCompara,
    };
  }
  @override
  String toString() {
    return 'Toggle{id: $id, valorToggle: $valorToggle, dataCompara: $dataCompara}';
  }
}

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbName = "toggles.db";

  static Future<Database> _getDB() async {
    return openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) async => await db.execute(
          "CREATE TABLE toggle(id INTEGER PRIMARY KEY, valorToggle INTEGER NOT NULL, dataCompara TEXT)"),
      version: _version,
    );
  }

  static Future<void> insertToggle(Toggle_reg valorToggle) async {
    final db = await _getDB();
    await db.insert(
      'toggle',
      valorToggle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateToggle(Toggle_reg valorToggle) async {
    final db = await _getDB();
    await db.update(
      'toggle',
      valorToggle.toMap(),
      where: 'id = ?',
      whereArgs: [valorToggle.id],
    );
  }

  static Future<List<Toggle_reg>?> getAllToggle() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query('toggle');
    if(maps.isEmpty){
      return null;
    }
    return List.generate(maps.length, (i) {
      return Toggle_reg(
        id: maps[i]['id'] as int,
        valorToggle: maps[i]['valorToggle'] as int,
        dataCompara: maps[i]['dataCompara'] as String,
      );
    });
  }
}
