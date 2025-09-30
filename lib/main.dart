import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database_helper.dart';
import 'libros.dart';

void main() {
  // Inicialización especial para escritorio (Windows/Linux/Mac)
  if (!Platform.isAndroid && !Platform.isIOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}

/// App principal
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD LIBROS ACTIVIDAD 2 y 3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: LibroPage(),
    );
  }
}

/// Página principal: muestra la lista de libros
class LibroPage extends StatefulWidget {
  @override
  _LibroPageState createState() => _LibroPageState();
}

class _LibroPageState extends State<LibroPage> {
  final dbHelper = DatabaseHelper.instance;
  List<Libro> _libros = [];

  @override
  void initState() {
    super.initState();
    _cargarLibros();
  }

  /// Cargar todos los libros desde la BD
  Future<void> _cargarLibros() async {
    final libros = await dbHelper.getLibros();
    setState(() {
      _libros = libros;
    });
  }

  /// Eliminar un libro
  Future<void> _eliminarLibro(int id) async {
    await dbHelper.deleteLibro(id);
    await _cargarLibros();
  }

  /// Navegar a la pantalla de formulario para agregar libro
  void _abrirFormularioAgregar() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddBookPage()),
    );
    if (resultado == true) {
      _cargarLibros();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD LIBROS ACTIVIDAD 2 y 3")),
      body: _libros.isEmpty
          ? Center(child: Text("No hay libros registrados"))
          : ListView.builder(
              itemCount: _libros.length,
              itemBuilder: (context, index) {
                final libro = _libros[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${libro.id ?? ''}')),
                  title: Text(libro.titulo),
                  subtitle: Text("ID: ${libro.id ?? '-'}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminarLibro(libro.id!),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioAgregar,
        child: Icon(Icons.add),
      ),
    );
  }
}

/// Página con formulario para agregar libros
class AddBookPage extends StatefulWidget {
  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  Future<void> _guardarLibro() async {
    if (_formKey.currentState!.validate()) {
      await dbHelper.insertLibro(Libro(titulo: _controller.text.trim()));
      Navigator.pop(context, true); // Regresa a la lista y recarga
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Agregar Libro")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Ingrese el título del libro",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Por favor ingrese un título";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarLibro,
                child: Text("Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
