import 'package:flutter/material.dart';

import 'book.dart';
import 'details.dart';
import 'library.dart';
import 'widgets.dart';

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key, required this.onGoTo});
  final ValueChanged<int> onGoTo;

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  SortOption _sort = SortOption.recent;

  @override
  Widget build(BuildContext context) {
    final lib = context.lib;
    final filters = <(String, ReadingStatus?)>[
      ('All', null),
      ('Want to Read', ReadingStatus.wantToRead),
      ('Reading', ReadingStatus.reading),
      ('Read', ReadingStatus.read),
    ];

    return DefaultTabController(
      length: filters.length,
      child: Constrained(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Sp.page, Sp.md, Sp.sm, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('YOUR LIBRARY', style: overline(context)),
                        const SizedBox(height: Sp.xs),
                        Text('My Books', style: serif(context, size: 28)),
                      ],
                    ),
                  ),
                  PopupMenuButton<SortOption>(
                    tooltip: 'Sort',
                    icon: const Icon(Icons.sort),
                    initialValue: _sort,
                    onSelected: (s) => setState(() => _sort = s),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: SortOption.recent,
                        child: Text('Recently added'),
                      ),
                      PopupMenuItem(
                        value: SortOption.title,
                        child: Text('Title (A–Z)'),
                      ),
                      PopupMenuItem(
                        value: SortOption.rating,
                        child: Text('Highest rated'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Sp.sm),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.symmetric(horizontal: Sp.sm),
              tabs: [
                for (final f in filters)
                  Tab(
                    text:
                        '${f.$1} (${f.$2 == null ? lib.books.length : lib.withStatus(f.$2!).length})',
                  ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [for (final f in filters) _list(context, f.$2)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, ReadingStatus? status) {
    final lib = context.lib;
    final books = lib.sorted(
      status == null ? lib.books : lib.withStatus(status),
      _sort,
    );
    if (books.isEmpty) {
      return EmptyState(
        icon: Icons.collections_bookmark_outlined,
        title: status == null ? 'Your shelf is empty' : 'No books here yet',
        message: status == null
            ? 'Find a book you love and add it to start your collection.'
            : 'Books you mark as "${status.label}" will appear here.',
        actionLabel: 'Discover books',
        onAction: () => widget.onGoTo(1),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Sp.page, Sp.md, Sp.page, Sp.xl),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: Sp.md - 4),
      itemBuilder: (_, i) => _BookCard(books[i]),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard(this.book);
  final Book book;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openDetails(context, book),
        child: Padding(
          padding: const EdgeInsets.all(Sp.md - 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(book, width: 66),
              const SizedBox(width: Sp.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: serif(context, size: 16, height: 1.2),
                          ),
                        ),
                        if (book.favorite)
                          Padding(
                            padding: const EdgeInsets.only(left: Sp.sm, top: 2),
                            child: Icon(
                              Icons.favorite,
                              size: 16,
                              color: c.secondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted(context),
                    ),
                    const SizedBox(height: Sp.sm + 2),
                    Wrap(
                      spacing: Sp.sm,
                      runSpacing: Sp.xs + 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(book.status),
                        if (book.rating > 0) Stars(book.rating),
                        if (book.isSample)
                          Text('Sample', style: muted(context, size: 11.5)),
                      ],
                    ),
                    if (book.status == ReadingStatus.reading) ...[
                      const SizedBox(height: Sp.sm + 2),
                      Row(
                        children: [
                          Expanded(child: ProgressBar(book.progress / 100)),
                          const SizedBox(width: Sp.sm),
                          Text(
                            '${book.progress}%',
                            style: muted(context, size: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Options',
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert, color: c.onSurfaceVariant),
                onSelected: (v) {
                  final lib = context.lib;
                  if (v == 'remove') {
                    confirmRemove(context, book);
                  } else {
                    lib.setStatus(book, ReadingStatus.values.byName(v));
                    toast(
                      context,
                      'Moved to "${ReadingStatus.values.byName(v).label}"',
                    );
                  }
                },
                itemBuilder: (_) => [
                  for (final s in ReadingStatus.values)
                    if (s != book.status)
                      PopupMenuItem(
                        value: s.name,
                        child: Text('Mark as ${s.label}'),
                      ),
                  const PopupMenuItem(value: 'remove', child: Text('Remove')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
