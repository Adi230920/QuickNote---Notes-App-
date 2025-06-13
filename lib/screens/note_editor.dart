import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/db_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({Key? key, this.note}) : super(key: key);

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late DateTime _creationDate;

  @override
  void initState() {
    super.initState();
    _creationDate = DateTime.now();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      // If editing, we don't update the creation date
      _creationDate = DateTime.now(); // For simplicity, using current time
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content cannot be empty')),
      );
      return;
    }

    final note = Note(
      id: widget.note?.id,
      title: _titleController.text,
      content: _contentController.text,
    );

    final db = DatabaseService.instance;
    if (widget.note == null) {
      await db.insertNote(note);
    } else {
      await db.updateNote(note);
    }

    Navigator.pop(context);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('d MMM h:mm a').format(dateTime);
  }

  int _calculateCharacterCount() {
    return (_titleController.text + _contentController.text).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24), // Larger title font
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none, // Remove underline
              ),
              onChanged: (value) => setState(() {}), // Update character count
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatDateTime(_creationDate)} | ${_calculateCharacterCount()} characters',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
            const Spacer(), // Pushes content to the bottom
            TextField(
              controller: _contentController,
              style: const TextStyle(fontSize: 16), // Smaller content font
              decoration: const InputDecoration(
                hintText: 'Start typing',
                border: InputBorder.none, // Remove underline
              ),
              maxLines: null,
              onChanged: (value) => setState(() {}), // Update character count
            ),
          ],
        ),
      ),
    );
  }
}
