import 'package:flutter/material.dart';

import 'api.dart';
import 'book.dart';
import 'widgets.dart';

void openDetails(BuildContext context, Book book) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => DetailsScreen(book: book)));
}

/// Asks before removing. Returns true if the book was removed.
Future<bool> confirmRemove(BuildContext context, Book book) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Remove this book?'),
      content: Text(
        '"${book.title}" will be removed from your library, including your rating and review.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (ok == true && context.mounted) {
    context.lib.remove(book);
    toast(context, 'Removed "${book.title}"');
    return true;
  }
  return false;
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.book});
  final Book book;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  static const _collapsedChars = 320; // longer descriptions get "Read more"

  late Book
  _draft; // edits are applied to the library only when the user taps the button
  late final TextEditingController _review;
  String? _description;
  bool _loadingDescription = false;
  bool _expanded = false;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    _draft = context.lib.find(widget.book) ?? widget.book;
    _review = TextEditingController(text: _draft.review);
    _description = _draft.description;
    if (_description == null || _description!.isEmpty) _loadDescription();
  }

  @override
  void dispose() {
    _review.dispose();
    super.dispose();
  }

  Future<void> _loadDescription() async {
    setState(() => _loadingDescription = true);
    String? text;
    try {
      var key = widget.book.id;
      if (!key.startsWith('/works/')) {
        // Sample books have no Open Library id: look the work up by title and author.
        final matches = await searchBooks(
          '${widget.book.title} ${widget.book.author}',
        );
        key = matches
            .firstWhere(
              (m) => m.matchKey == widget.book.matchKey,
              orElse: () => widget.book,
            )
            .id;
      }
      text = await fetchDescription(key);
    } catch (_) {
      // offline: the understated "unavailable" note is shown instead
    }
    if (!mounted) return;
    setState(() {
      _description = text;
      _loadingDescription = false;
    });
  }

  void _setStatus(ReadingStatus s) {
    setState(() {
      _draft = _draft.copyWith(
        status: s,
        progress: s == ReadingStatus.read
            ? 100
            : (s == ReadingStatus.wantToRead ? 0 : _draft.progress),
      );
    });
  }

  void _commit() {
    final lib = context.lib;
    final wasSaved = lib.contains(widget.book);
    final added = lib.save(
      _draft.copyWith(review: _review.text.trim(), description: _description),
    );
    toast(
      context,
      added
          ? 'Added "${_draft.title}" to My Books'
          : (wasSaved ? 'Book updated' : 'Saved'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final saved = context.lib.contains(widget.book);
    final desc = _description ?? '';
    final long = desc.length > _collapsedChars;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book details'),
        actions: [
          if (saved)
            IconButton(
              tooltip: 'Remove from My Books',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final nav = Navigator.of(context);
                if (await confirmRemove(context, _draft)) nav.pop();
              },
            ),
        ],
      ),
      body: Constrained(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Sp.page, Sp.sm, Sp.page, Sp.xl),
          children: [
            // ----- Header: cover, title, author, facts -----
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(_draft, width: 138, radius: 8),
                const SizedBox(width: Sp.lg - 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_draft.isSample) ...[
                        Text('SAMPLE BOOK', style: overline(context)),
                        const SizedBox(height: Sp.xs + 2),
                      ],
                      Text(
                        _draft.title,
                        style: serif(context, size: 26, height: 1.15),
                      ),
                      const SizedBox(height: Sp.sm),
                      Text(
                        _draft.author,
                        style: TextStyle(
                          fontSize: 16,
                          color: c.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Sp.md),
                      _Fact('First published', _draft.year?.toString()),
                      _Fact('Publisher', _draft.publisher),
                    ],
                  ),
                ),
              ],
            ),

            // ----- Description -----
            const SectionTitle('About this book'),
            if (_loadingDescription)
              const LinearProgressIndicator()
            else if (desc.isEmpty)
              Text(
                'No description is available for this book.',
                style: muted(
                  context,
                  size: 14.5,
                ).copyWith(fontStyle: FontStyle.italic),
              )
            else ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.topCenter,
                child: Text(
                  desc,
                  maxLines: long && !_expanded ? 7 : null,
                  overflow: long && !_expanded
                      ? TextOverflow.fade
                      : TextOverflow.visible,
                  style: const TextStyle(fontSize: 15.5, height: 1.6),
                ),
              ),
              if (long)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                    ),
                    onPressed: () => setState(() => _expanded = !_expanded),
                    child: Text(_expanded ? 'Show less' : 'Read more'),
                  ),
                ),
            ],

            // ----- Personal controls -----
            const SectionTitle('Your reading'),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STATUS', style: overline(context)),
                  const SizedBox(height: Sp.sm + 2),
                  SegmentedButton<ReadingStatus>(
                    showSelectedIcon: false,
                    segments: [
                      for (final s in ReadingStatus.values)
                        ButtonSegment(
                          value: s,
                          label: Text(
                            s.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12.5),
                          ),
                        ),
                    ],
                    selected: {_draft.status},
                    onSelectionChanged: (v) => _setStatus(v.first),
                  ),
                  if (_draft.status == ReadingStatus.reading) ...[
                    const SizedBox(height: Sp.md),
                    Row(
                      children: [
                        Text('PROGRESS', style: overline(context)),
                        const Spacer(),
                        Text(
                          '${_draft.progress}%',
                          style: serif(context, size: 16),
                        ),
                      ],
                    ),
                    Slider(
                      value: _draft.progress.toDouble(),
                      max: 100,
                      divisions: 20,
                      label: '${_draft.progress}%',
                      onChanged: (v) => setState(
                        () => _draft = _draft.copyWith(progress: v.round()),
                      ),
                    ),
                  ],
                  const Divider(height: Sp.lg + 8),
                  Row(
                    children: [
                      Text('YOUR RATING', style: overline(context)),
                      const Spacer(),
                      Stars(
                        _draft.rating,
                        size: 28,
                        onChanged: (r) =>
                            setState(() => _draft = _draft.copyWith(rating: r)),
                      ),
                    ],
                  ),
                  const Divider(height: Sp.lg),
                  Row(
                    children: [
                      Text('FAVORITE', style: overline(context)),
                      const Spacer(),
                      IconButton(
                        tooltip: _draft.favorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: () => setState(
                          () => _draft = _draft.copyWith(
                            favorite: !_draft.favorite,
                          ),
                        ),
                        icon: Icon(
                          _draft.favorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: c.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.md),
            TextField(
              controller: _review,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Review or notes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: Sp.lg),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _commit,
              icon: Icon(saved ? Icons.check : Icons.add),
              label: Text(saved ? 'Update Book' : 'Add to My Books'),
            ),
          ],
        ),
      ),
    );
  }
}

/// One "Label  value" line; shows a quiet fallback when the value is missing.
class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Sp.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: overline(context).copyWith(fontSize: 10.5),
        ),
        const SizedBox(height: 1),
        Text(
          value ?? 'Not available',
          style: value == null
              ? muted(context, size: 14)
              : const TextStyle(fontSize: 14.5),
        ),
      ],
    ),
  );
}
