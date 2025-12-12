import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'note_model.dart';

class NoteDatabase {
  NoteDatabase._private();
  static final NoteDatabase instance = NoteDatabase._private();

  Database? _database;

  Future<void> initDB() async {
    if (_database != null) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, "notes.db");

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            created_at TEXT NOT NULL
          );
        """);
      },
    );
  }

  Future<int> insertNote(Note note) async {
    return await _database!.insert("notes", note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final List<Map<String, dynamic>> maps =
    await _database!.query("notes", orderBy: "id DESC");

    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }
}
