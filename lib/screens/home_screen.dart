import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/db_service.dart';
import '../widgets/note_tile.dart';
import 'note_editor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_filterNotes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() async {
    final notes = await DatabaseService.instance.getNotes();
    setState(() {
      _notes = notes;
      _filteredNotes = notes;
    });
  }

  void _filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _deleteNote(int id) async {
    await DatabaseService.instance.deleteNote(id);
    _loadNotes();
  }

  Future<void> _lockNote(Note note) async {
    final pinController = TextEditingController();
    String? newPin;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set PIN to Lock Note'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: const InputDecoration(hintText: 'Enter 4-digit PIN'),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (pinController.text.length == 4 &&
                    pinController.text.isNumericOnly) {
                  newPin = pinController.text;
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a 4-digit PIN')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newPin != null) {
      final updatedNote = Note(
        id: note.id,
        title: note.title,
        content: note.content,
        isLocked: true,
        pin: newPin,
      );
      await DatabaseService.instance.updateNote(updatedNote);
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quick Note',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Notes',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return GestureDetector(
                  onLongPress: () => _lockNote(note),
                  child: NoteTile(
                    note: note,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEditorScreen(note: note),
                        ),
                      ).then((_) => _loadNotes());
                    },
                    onDelete: () => _deleteNote(note.id!),
                    isLocked: note.isLocked,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          ).then((_) => _loadNotes());
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

extension StringExtension on String {
  bool get isNumericOnly => double.tryParse(this) != null;
}
