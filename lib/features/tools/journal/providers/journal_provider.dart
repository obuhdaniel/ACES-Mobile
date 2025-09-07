// journal_provider.dart
import 'package:aces_uniben/features/tools/journal/models/journal_entry_model.dart';
import 'package:aces_uniben/features/tools/journal/services/journal_db_helper.dart';
import 'package:flutter/foundation.dart';

class JournalProvider with ChangeNotifier {
  final JournalDatabaseHelper _dbHelper = JournalDatabaseHelper.instance;
  List<JournalEntry> _journals = [];
  bool _isLoading = false;

  List<JournalEntry> get journals => _journals;
  bool get isLoading => _isLoading;

  JournalProvider() {
    loadJournals();
  }

  Future<void> loadJournals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _journals = await _dbHelper.readAll();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading journals: $e');
      }
      _journals = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<JournalEntry> createJournal(JournalEntry journal) async {
    try {
      final newJournal = await _dbHelper.create(journal);
      _journals.insert(0, newJournal);
      notifyListeners();
      return newJournal;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating journal: $e');
      }
      rethrow;
    }
  }

  Future<JournalEntry> updateJournal(JournalEntry journal) async {
    try {
      await _dbHelper.update(journal);
      final index = _journals.indexWhere((j) => j.id == journal.id);
      if (index != -1) {
        _journals[index] = journal;
        notifyListeners();
      }
      return journal;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating journal: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteJournal(String id) async {
    try {
      await _dbHelper.delete(id);
      _journals.removeWhere((journal) => journal.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting journal: $e');
      }
      rethrow;
    }
  }

  JournalEntry? getJournalById(String id) {
    try {
      return _journals.firstWhere((journal) => journal.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> close() async {
    await _dbHelper.close();
  }
}