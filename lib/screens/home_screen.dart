import 'package:flutter/material.dart';
import '../model/note.dart';
import '../db/notes_database.dart';
import 'edit_note_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshNotes();
    _searchController.addListener(() {
      filterNotes();
    });
  }

  Future refreshNotes() async {
    final data = await NotesDatabase.instance.readAllNotes();
    setState(() {
      _notes = data;
      _filteredNotes = data;
    });
  }

  void filterNotes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        return note.title.toLowerCase().contains(query) ||
               note.content.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MyNotes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotes.length,
              itemBuilder: (context, index) {
                final note = _filteredNotes[index];
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    '${note.content.split('\n').take(2).join('\n')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '${note.timestamp.toLocal()}'.split('.')[0],
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    await Navigator.push(context,
                      MaterialPageRoute(builder: (_) => EditNoteScreen(note: note))
                    );
                    refreshNotes();
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => EditNoteScreen())
          );
          refreshNotes();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
