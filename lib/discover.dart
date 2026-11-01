import 'dart:async';

import 'package:flutter/material.dart';

import 'api.dart';
import 'book.dart';
import 'details.dart';
import 'library.dart';
import 'widgets.dart';

const _categories = [
  'Fiction',
  'Fantasy',
  'Mystery',
  'Romance',
  'Science Fiction',
];

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  int _requestId = 0; // lets us ignore out-of-date responses

  String _query = ''; // text actually searched
  String? _category;
  bool _loading = false;
  bool _offline = false;
  List<Book>? _results; // null = nothing searched yet

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    setState(() {}); // refresh the clear button
    if (text.trim().length < 2) {
      if (text.trim().isEmpty) _reset();
      return;
    }
    // Wait until the user pauses typing before calling the API.
    _debounce = Timer(const Duration(milliseconds: 600), () => _search(text));
  }

  void _reset() {
    _requestId++;
    setState(() {
      _query = '';
      _category = null;
      _results = null;
      _loading = false;
      _offline = false;
    });
  }

  Future<void> _search(String text, {String? category}) async {
    final q = text.trim();
    if (q.isEmpty) return;
    _debounce?.cancel();
    final id = ++_requestId;
    setState(() {
      _query = q;
      _category = category;
      _loading = true;
    });
    try {
      final results = await searchBooks(
        category != null ? 'subject:"${category.toLowerCase()}"' : q,
      );
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _offline = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || id != _requestId) return;
      // Network problem: fall back to the built-in sample books.
      final lower = q.toLowerCase();
      setState(() {
        _results = sampleBooks.where((b) {
          if (category != null) {
            return b.genres.contains(category.toLowerCase());
          }
          return b.title.toLowerCase().contains(lower) ||
              b.author.toLowerCase().contains(lower) ||
              b.genres.any((g) => g.contains(lower));
        }).toList();
        _offline = true;
        _loading = false;
      });
    }
  }

  void _pickCategory(String cat) {
    _controller.text = cat;
    _search(cat, category: cat);
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.lib;
    final c = Theme.of(context).colorScheme;
    final results = _results;

    Widget body;
    if (_loading) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: Sp.md),
            Text('Searching the shelves…', style: muted(context, size: 14)),
          ],
        ),
      );
    } else if (results == null) {
      body = _grid(
        sampleBooks,
        lib,
        title: 'Popular picks',
        subtitle: 'Sample books to get you started',
      );
    } else if (results.isEmpty) {
      body = EmptyState(
        icon: Icons.search_off,
        title: 'No books found',
        message: _offline
            ? 'You appear to be offline, and none of our sample books match "$_query".'
            : 'Nothing matched "$_query". Try a different title, author or keyword.',
      );
    } else {
      body = _grid(
        results,
        lib,
        title: _category ?? '“$_query”',
        subtitle: _offline ? null : '${results.length} results',
        offline: _offline,
      );
    }

    return Constrained(
      maxWidth: 1000,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Sp.page, Sp.md, Sp.page, Sp.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DISCOVER', style: overline(context)),
                const SizedBox(height: Sp.xs),
                Text('Find your next book', style: serif(context, size: 28)),
                const SizedBox(height: Sp.md),
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onChanged: _onChanged,
                  onSubmitted: (v) => _search(v),
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search title, author or keyword',
                    contentPadding: const EdgeInsets.symmetric(vertical: 17),
                    prefixIcon: Icon(Icons.search, color: c.secondary),
                    suffixIcon: _controller.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _controller.clear();
                              _reset();
                            },
                          ),
                  ),
                ),
                const SizedBox(height: Sp.md - 4),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: Sp.sm),
                    itemBuilder: (_, i) => ChoiceChip(
                      label: Text(_categories[i]),
                      selected: _category == _categories[i],
                      onSelected: (_) => _pickCategory(_categories[i]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _grid(
    List<Book> books,
    Library lib, {
    required String title,
    String? subtitle,
    bool offline = false,
  }) {
    final c = Theme.of(context).colorScheme;
    const gap = Sp.md;
    return LayoutBuilder(
      builder: (context, box) {
        // Pick a column count, then size rows so every cover keeps its 2:3 shape.
        final avail = box.maxWidth - Sp.page * 2;
        final cols = (avail / 150).floor().clamp(2, 7);
        final tileWidth = (avail - gap * (cols - 1)) / cols;
        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Sp.page, Sp.sm, Sp.page, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (offline)
                      Container(
                        margin: const EdgeInsets.only(bottom: Sp.sm),
                        padding: const EdgeInsets.all(Sp.md - 4),
                        decoration: BoxDecoration(
                          color: c.secondaryContainer,
                          borderRadius: BorderRadius.circular(kRadius),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off,
                              size: 18,
                              color: c.onSecondaryContainer,
                            ),
                            const SizedBox(width: Sp.sm + 2),
                            Expanded(
                              child: Text(
                                "You're offline. Showing matching sample books.",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: c.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SectionTitle(title, subtitle: subtitle),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Sp.page, 0, Sp.page, Sp.xl),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: Sp.lg - 4,
                  mainAxisExtent: tileWidth / kCoverRatio + kTileTextHeight,
                ),
                itemCount: books.length,
                itemBuilder: (_, i) => BookTile(
                  books[i],
                  saved: lib.contains(books[i]),
                  onTap: () => openDetails(context, books[i]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
