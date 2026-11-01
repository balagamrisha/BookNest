import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'book.dart';

enum SortOption { recent, title, rating }

/// The app's single source of truth: library + preferences, saved locally.
class Library extends ChangeNotifier {
  List<Book> books = [];
  String name = 'Reader';
  int goal = 12;
  ThemeMode themeMode = ThemeMode.system;
  bool saveFailed = false;
  bool loaded = false;

  SharedPreferences? _prefs;

  Future<void> load() async {
    try {
      final prefs = _prefs = await SharedPreferences.getInstance();
      name = prefs.getString('name') ?? name;
      goal = prefs.getInt('goal') ?? goal;
      themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == prefs.getString('theme'),
        orElse: () => ThemeMode.system,
      );
      final raw = prefs.getString('books');
      if (raw != null) {
        try {
          for (final item in jsonDecode(raw) as List) {
            final b = Book.fromJson(item);
            if (b != null && !books.any((e) => e.id == b.id)) books.add(b);
          }
        } catch (_) {
          books = []; // corrupt data: start fresh
        }
      }
      // Older versions saved hand-written text as the description of sample
      // books. Descriptions should only come from Open Library, so drop it.
      books = [
        for (final b in books)
          if (b.id.startsWith('sample:') && b.description != null)
            Book.fromJson({...b.toJson(), 'description': null})!
          else
            b,
      ];
      if (!(prefs.getBool('seeded') ?? false)) {
        // First launch only: a few clearly-labelled sample books.
        final now = DateTime.now();
        books = [
          sampleBooks[0].copyWith(
            status: ReadingStatus.reading,
            progress: 40,
            addedAt: now,
            isSample: true,
          ),
          sampleBooks[1].copyWith(
            status: ReadingStatus.wantToRead,
            addedAt: now.subtract(const Duration(minutes: 1)),
            isSample: true,
          ),
          sampleBooks[2].copyWith(
            status: ReadingStatus.read,
            rating: 5,
            progress: 100,
            addedAt: now.subtract(const Duration(minutes: 2)),
            isSample: true,
          ),
        ];
        await prefs.setBool('seeded', true);
        await _save();
      }
    } catch (_) {
      saveFailed = true; // storage unavailable: app still works this session
    }
    loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = _prefs;
    if (prefs == null) return;
    try {
      await prefs.setString(
        'books',
        jsonEncode(books.map((b) => b.toJson()).toList()),
      );
      await prefs.setString('name', name);
      await prefs.setInt('goal', goal);
      await prefs.setString('theme', themeMode.name);
    } catch (_) {
      saveFailed = true;
    }
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  /// The saved copy of [b], matched by id or by title + author.
  Book? find(Book b) {
    for (final s in books) {
      if (s.id == b.id || s.matchKey == b.matchKey) return s;
    }
    return null;
  }

  bool contains(Book b) => find(b) != null;

  /// Adds the book, or updates the existing copy. Never creates duplicates.
  /// Returns true if it was newly added.
  bool save(Book b) {
    final existing = find(b);
    if (existing == null) {
      books = [b.copyWith(addedAt: DateTime.now(), isSample: false), ...books];
    } else {
      books = [
        for (final s in books)
          if (identical(s, existing))
            b.copyWith(addedAt: existing.addedAt, isSample: false)
          else
            s,
      ];
    }
    _changed();
    return existing == null;
  }

  void remove(Book b) {
    final existing = find(b);
    books = books.where((s) => !identical(s, existing)).toList();
    _changed();
  }

  void setStatus(Book b, ReadingStatus status) {
    final s = find(b);
    if (s == null) return;
    save(
      s.copyWith(
        status: status,
        progress: status == ReadingStatus.read
            ? 100
            : (status == ReadingStatus.wantToRead ? 0 : s.progress),
      ),
    );
  }

  void setName(String v) {
    name = v.trim().isEmpty ? 'Reader' : v.trim();
    _changed();
  }

  void setGoal(int v) {
    goal = v.clamp(1, 1000);
    _changed();
  }

  void setTheme(ThemeMode m) {
    themeMode = m;
    _changed();
  }

  // Everything below is calculated from the stored books.
  List<Book> withStatus(ReadingStatus s) =>
      books.where((b) => b.status == s).toList();
  int get readCount => withStatus(ReadingStatus.read).length;
  int get favoriteCount => books.where((b) => b.favorite).length;
  double get goalProgress => (readCount / goal).clamp(0.0, 1.0);

  List<Book> sorted(List<Book> list, SortOption sort) {
    final out = [...list];
    switch (sort) {
      case SortOption.recent:
        out.sort(
          (a, b) =>
              (b.addedAt ?? DateTime(0)).compareTo(a.addedAt ?? DateTime(0)),
        );
      case SortOption.title:
        out.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case SortOption.rating:
        out.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return out;
  }
}
