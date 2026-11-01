import 'package:flutter/material.dart';

import 'book.dart';
import 'widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final lib = context.lib;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(initial: lib.name),
    );
    if (name != null) lib.setName(name);
  }

  Future<void> _editGoal(BuildContext context) async {
    final lib = context.lib;
    final goal = await showDialog<int>(
      context: context,
      builder: (_) => _GoalDialog(initial: lib.goal),
    );
    if (goal != null) lib.setGoal(goal);
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.lib;
    final c = Theme.of(context).colorScheme;
    final stats = [
      (Icons.collections_bookmark_outlined, 'In library', lib.books.length),
      (Icons.check_circle_outline, 'Completed', lib.readCount),
      (
        Icons.auto_stories_outlined,
        'Reading now',
        lib.withStatus(ReadingStatus.reading).length,
      ),
      (Icons.favorite_border, 'Favorites', lib.favoriteCount),
    ];
    final initial = lib.name.isEmpty
        ? '?'
        : lib.name.characters.first.toUpperCase();

    return Constrained(
      maxWidth: 720,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Sp.page, Sp.md, Sp.page, Sp.xl),
        children: [
          Text('YOUR PROFILE', style: overline(context)),
          const SizedBox(height: Sp.lg),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.primaryContainer,
                  border: Border.all(color: c.secondary, width: 1.5),
                ),
                child: Text(
                  initial,
                  style: serif(context, size: 30, color: c.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: Sp.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lib.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: serif(context, size: 26),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lib.readCount} ${lib.readCount == 1 ? 'book' : 'books'} read',
                      style: muted(context, size: 14),
                    ),
                  ],
                ),
              ),
              IconButton.outlined(
                tooltip: 'Edit name',
                onPressed: () => _editName(context),
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),

          const SectionTitle('Reading stats'),
          LayoutBuilder(
            builder: (context, box) {
              final cols = box.maxWidth > 560 ? 4 : 2;
              const gap = Sp.md - 4;
              final w = (box.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final s in stats)
                    SizedBox(
                      width: w,
                      child: Panel(
                        padding: const EdgeInsets.all(Sp.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(s.$1, size: 20, color: c.secondary),
                            const SizedBox(height: Sp.sm + 2),
                            Text(
                              '${s.$3}',
                              style: serif(context, size: 28, height: 1),
                            ),
                            const SizedBox(height: Sp.xs),
                            Text(s.$2, style: muted(context)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const SectionTitle('Reading goal'),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${lib.readCount}',
                      style: serif(context, size: 34, height: 1),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: Sp.sm, bottom: 3),
                        child: Text(
                          'of ${lib.goal} books',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: muted(context, size: 15),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _editGoal(context),
                      child: const Text('Edit goal'),
                    ),
                  ],
                ),
                const SizedBox(height: Sp.md - 4),
                ProgressBar(lib.goalProgress, height: 8),
              ],
            ),
          ),

          const SectionTitle('Appearance'),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {lib.themeMode},
            onSelectionChanged: (v) => lib.setTheme(v.first),
          ),

          const SectionTitle('About BookNest'),
          Panel(
            padding: const EdgeInsets.all(Sp.lg - 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Logo(),
                const SizedBox(height: Sp.md - 2),
                Text(
                  'A simple book tracker built with Flutter as a college project. '
                  'Book data and covers come from the Open Library API. '
                  'Your library is stored only on this device.',
                  style: muted(context, size: 14).copyWith(height: 1.5),
                ),
                const SizedBox(height: Sp.md - 2),
                Text('VERSION 1.0.0', style: overline(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Display name'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      maxLength: 30,
      textCapitalization: TextCapitalization.words,
      onSubmitted: (v) => Navigator.pop(context, v),
      decoration: const InputDecoration(hintText: 'Your name'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Save'),
      ),
    ],
  );
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({required this.initial});
  final int initial;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late int _goal = widget.initial;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Reading goal'),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: 'Fewer',
          onPressed: _goal > 1 ? () => setState(() => _goal--) : null,
          icon: const Icon(Icons.remove),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sp.lg),
          child: Text('$_goal books', style: serif(context, size: 22)),
        ),
        IconButton.filledTonal(
          tooltip: 'More',
          onPressed: _goal < 365 ? () => setState(() => _goal++) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _goal),
        child: const Text('Save'),
      ),
    ],
  );
}
