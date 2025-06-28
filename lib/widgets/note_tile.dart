import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isLocked;

  const NoteTile({
    Key? key,
    required this.note,
    required this.onTap,
    required this.onDelete,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color: Colors.grey[700]!,
          width: 1.0,
        ),
      ),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                note.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey : null,
                    ),
              ),
            ),
            if (isLocked)
              const Icon(Icons.lock, size: 18.0, color: Colors.grey),
          ],
        ),
        // Only show content preview if not locked
        subtitle: isLocked
            ? null
            : Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
