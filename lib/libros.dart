/// Clase Libro: representa la entidad "Libro" de la base de datos
class Libro {
  int? id;        // ID autoincremental en la BD
  String titulo;  // Título del libro

  Libro({this.id, required this.titulo});

  /// Convierte un objeto Libro a un mapa para guardarlo en SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'titulo': titulo};
    if (id != null) map['id'] = id;
    return map;
  }

  /// Convierte un mapa de SQLite a un objeto Libro
  factory Libro.fromMap(Map<String, dynamic> map) {
    return Libro(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
    );
  }
}
