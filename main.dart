import 'package:flutter/material.dart';
import 'package:lab13/note_database.dart';
import 'package:lab13/note_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NoteDatabase.instance.initDB();
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab13 Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotesPage(title: "Flutter Demo Home Page"),
    );
  }
}

class NotesPage extends StatefulWidget {
  final String title;
  const NotesPage({super.key, required this.title});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    notes = await NoteDatabase.instance.getNotes(); // already DESC = LIFO
    setState(() {});
  }

  Future<void> addNote() async {
    if (!_formKey.currentState!.validate()) return;

    final text = _controller.text.trim();

    final note = Note(
      text: text,
      createdAt: DateTime.now(),
    );

    await NoteDatabase.instance.insertNote(note);
    _controller.clear();
    await loadNotes();
  }

  String formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, "0");
    final m = dt.month.toString().padLeft(2, "0");
    final y = dt.year;

    final hh = dt.hour.toString().padLeft(2, "0");
    final mm = dt.minute.toString().padLeft(2, "0");

    return "$d.$m.$y  $hh:$mm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // INPUT FIELD + BUTTON (exact demo style)
            Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: "Введіть нотатку",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Нотатка не може бути порожньою";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: addNote,
                    child: const Text("Додати"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // NOTES LIST (default Material style)
            Expanded(
              child: notes.isEmpty
                  ? const Center(
                child: Text(
                  "Немає нотаток",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];

                  return Card(
                    child: ListTile(
                      title: Text(note.text),
                      subtitle: Text(formatDate(note.createdAt)),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
