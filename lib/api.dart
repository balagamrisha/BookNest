import 'dart:convert';

import 'package:http/http.dart' as http;

import 'book.dart';

const _timeout = Duration(seconds: 10);

/// Searches Open Library. Throws if the network or server fails.
Future<List<Book>> searchBooks(String query) async {
  final uri = Uri.https('openlibrary.org', '/search.json', {
    'q': query,
    'limit': '30',
    'fields': 'key,title,author_name,cover_i,first_publish_year,publisher',
  });
  final res = await http.get(uri).timeout(_timeout);
  if (res.statusCode != 200) {
    throw Exception('Server returned ${res.statusCode}');
  }
  final docs = (jsonDecode(res.body) as Map)['docs'];
  if (docs is! List) return [];
  final books = <Book>[];
  for (final d in docs) {
    if (d is! Map || d['key'] is! String || d['title'] is! String) continue;
    final authors = d['author_name'];
    final publishers = d['publisher'];
    books.add(
      Book(
        id: d['key'],
        title: d['title'],
        author: authors is List && authors.isNotEmpty
            ? '${authors.first}'
            : 'Unknown author',
        coverUrl: d['cover_i'] is int
            ? 'https://covers.openlibrary.org/b/id/${d['cover_i']}-M.jpg?default=false'
            : null,
        year: d['first_publish_year'] is int ? d['first_publish_year'] : null,
        publisher: publishers is List && publishers.isNotEmpty
            ? '${publishers.first}'
            : null,
      ),
    );
  }
  return books;
}

/// Fetches a work's description, or null if there isn't one.
Future<String?> fetchDescription(String workKey) async {
  if (!workKey.startsWith('/works/')) return null;
  final res = await http
      .get(Uri.https('openlibrary.org', '$workKey.json'))
      .timeout(_timeout);
  if (res.statusCode != 200) return null;
  final d = (jsonDecode(res.body) as Map)['description'];
  final text = d is String ? d : (d is Map ? d['value'] : null);
  if (text is! String || text.trim().isEmpty) return null;
  return text.split('----').first.trim();
}
