import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'libros.dart';

/// Clase DatabaseHelper: se encarga de la conexión y operaciones con SQLite
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  static const String _tableName = 'libros';

  DatabaseHelper._init();

  /// Obtiene la base de datos (y la crea si no existe)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('libros.db');
    return _database!;
  }

  /// Inicializa la base de datos en el path correcto
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Crea la tabla de libros
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL
      )
    ''');
  }

  /// Inserta un libro en la base de datos
  Future<int> insertLibro(Libro libro) async {
    final db = await instance.database;
    return await db.insert(_tableName, libro.toMap());
  }

  /// Obtiene todos los libros
  Future<List<Libro>> getLibros() async {
    final db = await instance.database;
    final result = await db.query(_tableName, orderBy: 'id ASC');
    return result.map((m) => Libro.fromMap(m)).toList();
  }

  /// Actualiza un libro
  Future<int> updateLibro(Libro libro) async {
    final db = await instance.database;
    return await db.update(
      _tableName,
      libro.toMap(),
      where: 'id = ?',
      whereArgs: [libro.id],
    );
  }

  /// Elimina un libro
  Future<int> deleteLibro(int id) async {
    final db = await instance.database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
