import 'package:flutter/material.dart';

import 'book.dart';
import 'details.dart';
import 'library.dart';
import 'widgets.dart';

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onGoTo});
  final ValueChanged<int> onGoTo;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _quote = 0;

  String _greeting() {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good morning'
        : (h < 18 ? 'Good afternoon' : 'Good evening');
  }

  String _today() {
    final d = DateTime.now();
    return '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.lib;
    final reading = lib.sorted(
      lib.withStatus(ReadingStatus.reading),
      SortOption.recent,
    );
    final recent = lib.sorted(lib.books, SortOption.recent).take(6).toList();
    final picks = sampleBooks.where((b) => !lib.contains(b)).take(8).toList();

    return Constrained(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Sp.page, Sp.md, Sp.page, Sp.xl),
        children: [
          const Logo(),
          const SizedBox(height: Sp.lg),
          Text(_today(), style: overline(context)),
          const SizedBox(height: Sp.xs + 2),
          Text(
            '${_greeting()},\n${lib.name}',
            style: serif(context, size: 30, height: 1.15),
          ),
          const SizedBox(height: Sp.lg),
          _GoalCard(onFind: () => widget.onGoTo(1)),

          SectionTitle(
            'Continue Reading',
            subtitle: reading.isEmpty ? null : '${reading.length} in progress',
          ),
          if (reading.isEmpty)
            Panel(
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: Sp.md),
                  Expanded(
                    child: Text(
                      'Nothing in progress. Mark a book as "Currently Reading" to see it here.',
                      style: muted(context, size: 14).copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            )
          else
            for (final b in reading)
              Padding(
                padding: const EdgeInsets.only(bottom: Sp.md - 4),
                child: _ContinueCard(b),
              ),

          SectionTitle(
            'Pick Up Your Next Read',
            subtitle: 'Sample suggestions',
          ),
          if (picks.isEmpty)
            Text(
              'You have added all of our sample picks. Try Discover for more.',
              style: muted(context, size: 14),
            )
          else
            BookCarousel(books: picks, onOpen: (b) => openDetails(context, b)),

          if (recent.isNotEmpty) ...[
            const SectionTitle('Recently Added'),
            BookCarousel(
              books: recent,
              tileWidth: 104,
              onOpen: (b) => openDetails(context, b),
            ),
          ],

          const SectionTitle('Reading Inspiration'),
          _QuoteCard(
            index: _quote,
            onNext: () =>
                setState(() => _quote = (_quote + 1) % sampleQuotes.length),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.onFind});
  final VoidCallback onFind;

  @override
  Widget build(BuildContext context) {
    final lib = context.lib;
    final c = Theme.of(context).colorScheme;
    final left = lib.goal - lib.readCount;
    return Card(
      color: c.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Sp.md + 2),
        child: Row(
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: lib.goalProgress,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      backgroundColor: c.onPrimaryContainer.withValues(
                        alpha: 0.18,
                      ),
                    ),
                  ),
                  Text(
                    '${(lib.goalProgress * 100).round()}%',
                    style: serif(
                      context,
                      size: 16,
                      color: c.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Sp.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR READING GOAL',
                    style: overline(
                      context,
                      color: c.onPrimaryContainer.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${lib.readCount} of ${lib.goal} books',
                    style: serif(
                      context,
                      size: 21,
                      color: c.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    left <= 0 ? 'Goal reached. Well done!' : '$left more to go',
                    style: TextStyle(
                      fontSize: 13,
                      color: c.onPrimaryContainer.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            IconButton.outlined(
              tooltip: 'Find a book',
              onPressed: onFind,
              style: IconButton.styleFrom(
                foregroundColor: c.onPrimaryContainer,
                side: BorderSide(
                  color: c.onPrimaryContainer.withValues(alpha: 0.4),
                ),
              ),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard(this.book);
  final Book book;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openDetails(context, book),
        child: Padding(
          padding: const EdgeInsets.all(Sp.md - 4),
          child: Row(
            children: [
              BookCover(book, width: 64),
              const SizedBox(width: Sp.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: serif(context, size: 16, height: 1.2),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted(context),
                    ),
                    const SizedBox(height: Sp.md - 2),
                    ProgressBar(book.progress / 100),
                    const SizedBox(height: Sp.sm - 2),
                    Text(
                      '${book.progress}% read',
                      style: muted(context, size: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.index, required this.onNext});
  final int index;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final quote = sampleQuotes[index % sampleQuotes.length];
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Sp.lg, Sp.md, Sp.md, Sp.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '“',
              style: serif(context, size: 56, color: c.secondary, height: 1),
            ),
            Text(
              quote.$1,
              style: serif(
                context,
                size: 21,
                weight: FontWeight.w400,
                height: 1.4,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: Sp.md),
            Row(
              children: [
                Container(width: 24, height: 1.5, color: c.secondary),
                const SizedBox(width: Sp.sm + 2),
                Expanded(
                  child: Text(quote.$2.toUpperCase(), style: overline(context)),
                ),
              ],
            ),
            const SizedBox(height: Sp.sm),
            Row(
              children: [
                Text('Sample quotes', style: muted(context, size: 12)),
                const Spacer(),
                TextButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
