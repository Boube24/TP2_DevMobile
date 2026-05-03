import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/note.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  late SharedPreferences _prefs;

  List<Note> get notes => _notes;

  NoteProvider(this._prefs) {
    _loadNotes();
  }

  // Charger les notes depuis SharedPreferences
  void _loadNotes() {
    final String? notesJson = _prefs.getString('notes');
    if (notesJson != null) {
      final List<dynamic> data = jsonDecode(notesJson);
      _notes = data.map((json) => Note.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Sauvegarder les notes dans SharedPreferences
  Future<void> _saveNotes() async {
    final String notesJson = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await _prefs.setString('notes', notesJson);
  }

  // Ajouter une note
  Future<void> addNote(Note note) async {
    _notes.add(note);
    notifyListeners();
    await _saveNotes();
  }

  // Modifier une note
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
      await _saveNotes();
    }
  }

  // Supprimer une note
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    await _saveNotes();
  }
}